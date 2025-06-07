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
const ETA_CHECK_INTERVAL = Duration(seconds: 5);
// ignore: constant_identifier_names
const MAX_CACHED_ETA = 100;

class _EtaSubscription {
  // This class is used to store the parameters of an ETA subscription.
  final BasePlugin plugin;
  final Route route;
  final Stop stop;

  // The ETA data for this subscription.
  List<Eta> etas = [];

  // To count the number of active subscriptions for this ETA.
  final Mutex _counterLock = Mutex();
  int counter = 0;

  DateTime? lastUpdate;

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
    try {
      etas = await plugin.getEta(route, stop);
      lastUpdate = DateTime.now();

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

    while (_etaSubscription.isNotEmpty) {
      final now = DateTime.now();

      // Remove subscriptions that have no active counters
      if (_etaSubscription.length > MAX_CACHED_ETA) {
        _etaSubscription.removeWhere(
          (_, subscription) => subscription.counter == 0,
        );
      }

      for (final subscription in _etaSubscription.values) {
        // Skip subscriptions that have no active counters
        if (subscription.counter == 0) continue;

        // Check if the ETA data needs to be updated
        if (subscription.lastUpdate == null ||
            // If the last update was more than ETA_UPDATE_INTERVAL ago
            now.difference(subscription.lastUpdate!) > ETA_UPDATE_INTERVAL ||
            // If the latest ETA is older than the current time
            (subscription.etas.isNotEmpty &&
                subscription.etas.first.arrivalTime >
                    now.millisecondsSinceEpoch)) {
          subscription.update().then((updated) {
            if (updated) notifyListeners();
          });
        }
      }

      await Future.delayed(ETA_CHECK_INTERVAL);
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

  /// Retrieves a list of estimated arrival times ([Eta]) for a given [plugin], [route], and [stop].
  ///
  /// Requires calling [subscribe] before using this method.
  ///
  /// Returns a list of [Eta] objects representing the estimated arrival times.
  List<Eta> getEta(BasePlugin plugin, Route route, Stop stop) {
    final id = _EtaSubscription.getId(plugin, route, stop);

    if (!_etaSubscription.containsKey(id)) {
      throw Exception("Please subscribe to the ETA first.");
    }

    return _etaSubscription[id]!.etas;
  }
}
