import 'package:isar/isar.dart';

import '../../models/eta.dart';
import '../../models/route.dart';
import '../../models/stop.dart';

abstract class BasePlugin {
  // -------- Plugin Handler Metadata ---------
  static const String pluginType = "BasePlugin";

  // --------- Metadata ---------
  String get id;
  String get name;
  String get version;
  String? get description => null;
  String? get author => null;
  String? get repositoryUrl => null;

  // --------- Isar Instance ---------
  Isar? _isar;
  set isar(Isar isar) => _isar = isar;

  /// The Isar instance returned by this getter is not a complete Isar instance.
  ///
  /// All the properties except `routes`, `stops`, and `kvPairs` are not available.
  Isar get isar {
    if (_isar == null) throw Exception("Isar instance not set");
    return _isar!;
  }

  // --------- Language Settings ---------
  String? _lang;
  set lang(String? lang) => _lang = lang;
  String? get lang {
    if (_lang == null) throw Exception("Language not set");
    return _lang;
  }

  // --------- Methods required to be overridden ---------

  /// _This method must be implemented by subclasses._
  ///
  /// Method to update the routes and stops in the Isar instance.
  ///
  /// Boolean return value indicates success or failure.
  ///
  /// Check the `kv_pair.dart`, `route.dart`, and `stop.dart` files for the structure of the data to be updated.
  ///
  /// Note: The `KvPair` is used to store the plugin's data, for example, the last update time, hashes, etc.
  Future<void> updateRoutes();

  /// _This method must be implemented by subclasses._
  /// Method to get the ETA (Estimated Time of Arrival) for a given route and stop.
  ///
  /// The input will be a `Route` object and a `Stop` object.
  ///
  /// The return value should be a list of `Eta` objects, which contain information about the estimated arrival times.
  ///
  /// The number of returned `Eta` objects can vary based on the plugin's implementation, but it should generally return the next `3` estimated arrivals.
  Future<List<Eta>> getEta(Route route, Stop stop);
}
