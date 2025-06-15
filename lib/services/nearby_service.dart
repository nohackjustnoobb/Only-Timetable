import 'dart:math';

import 'package:flutter/material.dart' hide Route;
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:latlong2/latlong.dart';
import 'package:only_timetable/models/fast_hash.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';

// ignore: constant_identifier_names
const NEARBY_RADIUS_DEFAULT = 1.0;

class NearbyRoute {
  BasePlugin plugin;
  Route route;
  Stop stop;

  NearbyRoute({required this.plugin, required this.route, required this.stop});

  int get id => fastHash(plugin.id + route.id + stop.id);
}

class NearbyService extends ChangeNotifier {
  late final PluginService _pluginService;

  void init(PluginService pluginService) {
    _pluginService = pluginService;
  }

  /// Retrieves the current geographical position of the device.
  ///
  /// This method uses location services to fetch the device's position.
  /// It returns a [Future] that resolves to a [Position] object containing
  /// latitude, longitude, and other location details, or `null` if the position
  /// cannot be determined.
  ///
  /// Returns:
  /// - A [Future<Position?>] representing the device's current position.
  /// - `null` if the position is unavailable.
  static Future<Position?> getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  Future<List<NearbyRoute>> getNearbyRoute({int maxResult = 10}) async {
    Position? position = await getPosition();
    if (position == null) return [];

    final latDeg = NEARBY_RADIUS_DEFAULT / 111.0;
    final longDeg =
        NEARBY_RADIUS_DEFAULT /
        (111.0 * pi * cos(degToRadian(position.latitude)));

    final Map<String, NearbyRoute> nearbyRoutes = {};
    for (final plugin in _pluginService.plugins) {
      final stops = await plugin.isar.stops
          .filter()
          .latBetween(position.latitude - latDeg, position.latitude + latDeg)
          .longBetween(
            position.longitude - longDeg,
            position.longitude + longDeg,
          )
          .findAll();

      stops.sort(
        (a, b) => Geolocator.distanceBetween(
          a.lat!,
          a.long!,
          position.latitude,
          position.longitude,
        ).toInt(),
      );

      for (final stop in stops) {
        for (final route
            in await stop.routes
                .filter()
                .not()
                .destEqualTo(stop.id)
                .findAll()) {
          if (nearbyRoutes.containsKey('${plugin.id}_${route.id}')) {
            continue;
          }

          nearbyRoutes['${plugin.id}_${route.id}'] = NearbyRoute(
            plugin: plugin,
            route: route,
            stop: stop,
          );
        }
      }
    }

    return nearbyRoutes.values.toList().take(maxResult).toList();
  }
}
