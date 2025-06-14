import 'package:flutter/material.dart' hide Route;
import 'package:mutex/mutex.dart';
import 'package:only_timetable/models/eta.dart';
import 'package:only_timetable/models/fast_hash.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';

// ignore: constant_identifier_names
const ETA_UPDATE_INTERVAL = Duration(seconds: 30);
// ignore: constant_identifier_names
const ETA_MINIMUM_UPDATE_INTERVAL = Duration(seconds: 5);
// ignore: constant_identifier_names
const MAX_CACHED_ETA = 100;

class _EtaSubscription {
  // This class is used to store the parameters of an ETA subscription.
  BasePlugin plugin;
  Route route;
  Stop stop;

  // The ETA data for this subscription.
  List<Eta> etas = [];

  // To count the number of active subscriptions for this ETA.
  final Mutex _counterLock = Mutex();
  int counter = 1;

  DateTime? lastUpdate;
  DateTime? lastTryUpdate;

  Future<void> incrementCounter() async {
    await _counterLock.acquire();
    counter++;
    _counterLock.release();
  }

  Future<void> decrementCounter() async {
    await _counterLock.acquire();
    counter--;
    if (counter < 0) counter = 0;
    _counterLock.release();
  }

  Future<bool> update() async {
    lastTryUpdate = DateTime.now();

    try {
      etas = await plugin.getEta(route, stop);
      lastUpdate = lastTryUpdate;

      return true;
    } catch (e) {
      return false;
    }
  }

  _EtaSubscription({
    required this.plugin,
    required this.route,
    required this.stop,
  });

  static int getId(BasePlugin plugin, Route route, Stop stop) {
    return fastHash(plugin.id + route.id + stop.id);
  }

  int get id => getId(plugin, route, stop);
}

class EtaService extends ChangeNotifier {
  final Map<int, _EtaSubscription> _etaSubscription = {};
  final Mutex _etaLock = Mutex();

  void _updateEta() async {
    if (_etaLock.isLocked) return;
    await _etaLock.acquire();

    while (_etaSubscription.values
        .where((sub) => sub.counter != 0)
        .isNotEmpty) {
      final now = DateTime.now();

      // Remove subscriptions that have no active counters
      if (_etaSubscription.length > MAX_CACHED_ETA) {
        _etaSubscription.removeWhere(
          (_, subscription) => subscription.counter == 0,
        );
      }

      for (final sub in _etaSubscription.values) {
        // Skip subscriptions that have no active counters
        if (sub.counter == 0) continue;

        // Check if the ETA data needs to be updated
        final shouldUpdate =
            // Never updated before
            sub.lastTryUpdate == null ||
            // Never successfully updated, and last try was a while ago
            (sub.lastUpdate == null &&
                now.difference(sub.lastTryUpdate!) >
                    ETA_MINIMUM_UPDATE_INTERVAL) ||
            // Last successful update was a while ago
            (sub.lastUpdate != null &&
                now.difference(sub.lastUpdate!) > ETA_UPDATE_INTERVAL) ||
            // The latest ETA is already in the past and the last try was a while ago
            (sub.etas.isNotEmpty &&
                now.millisecondsSinceEpoch > sub.etas.first.arrivalTime &&
                now.difference(sub.lastTryUpdate!) >
                    ETA_MINIMUM_UPDATE_INTERVAL);

        if (shouldUpdate) {
          sub.update().then((updated) {
            if (updated) notifyListeners();
          });
        }
      }

      await Future.delayed(Duration(seconds: 1));
    }

    _etaLock.release();
  }

  /// Subscribes to a eta and returns a function that can be used to unsubscribe.
  Future<Future<void> Function()> subscribe(
    BasePlugin plugin,
    Route route,
    Stop stop,
  ) async {
    final id = _EtaSubscription.getId(plugin, route, stop);

    Future<void> unsubcribe() async {
      await _etaSubscription[id]?.decrementCounter();
    }

    if (_etaSubscription.containsKey(id)) {
      await _etaSubscription[id]!.incrementCounter();
      // Update the reference to the plugin, route, and stop
      // As the plugin, route, and stop might have changed
      _etaSubscription[id]!.plugin = plugin;
      _etaSubscription[id]!.route = route;
      _etaSubscription[id]!.stop = stop;
    } else {
      _etaSubscription[id] = _EtaSubscription(
        plugin: plugin,
        route: route,
        stop: stop,
      );
    }

    _updateEta();

    return unsubcribe;
  }

  /// Retrieves a list of estimated time of arrivals (ETA).
  ///
  /// This method returns a list of [Eta] objects, which represent the
  /// estimated times of arrival for a specific service or location.
  ///
  /// Subscribe to the ETA service using [subscribe] before calling this method.
  List<Eta>? getEta(BasePlugin plugin, Route route, Stop stop) {
    final id = _EtaSubscription.getId(plugin, route, stop);

    if (!_etaSubscription.containsKey(id) ||
        _etaSubscription[id]!.lastUpdate == null) {
      return null;
    }

    return _etaSubscription[id]!.etas;
  }
}
