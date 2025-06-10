import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/globals.dart';
import 'package:only_timetable/models/kv_pair.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/services/db_service.dart';
import 'package:only_timetable/services/plugin/handler.dart';
import 'package:only_timetable/services/plugin/js_plugin/js_plugin_handler.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';

/// A service class responsible for managing plugins within the application.
class PluginService extends ChangeNotifier {
  static List<Handler> pluginHandlers = [JsPluginHandler()];
  late final DbService dbService;

  final Map<String, BasePlugin> _plugins = {};
  List<BasePlugin> get plugins => _plugins.values.toList();
  final Set<String> _routesUpdating = {};
  Map<String, DateTime> routesUpdateTimestamps = {};

  /// Searches for routes based on the provided criteria.
  ///
  /// Returns a [Future] that completes with a [Map] where the keys are [String]
  /// plugin's id and the values are lists of [Route] objects matching the search.
  ///
  /// Throws an exception if the search fails.
  Future<Map<String, List<Route>>> searchRoute(
    String query, {
    String? pluginId,
    int limit = 50,
    int offset = 0,
  }) async {
    final Map<String, List<Route>> results = {};

    for (final entry
        in (pluginId == null
            ? dbService.pluginIsars.entries
            : dbService.pluginIsars.entries.where((e) => e.key == pluginId))) {
      final pluginId = entry.key;
      final isar = entry.value;

      results[pluginId] = await isar.routes
          .filter()
          .nameContains(query, caseSensitive: false)
          .or()
          .idContains(query, caseSensitive: false)
          .or()
          .displayIdContains(query, caseSensitive: false)
          .offset(offset)
          .limit(limit)
          .findAll();
    }

    return results;
  }

  Future<void> init(DbService dbService) async {
    this.dbService = dbService;

    for (final pluginHandler in pluginHandlers) {
      pluginHandler.isar = await dbService.getPluginHandlerIsar(pluginHandler);
      final loadedPlugins = await pluginHandler.loadPlugins();

      for (final plugin in loadedPlugins) {
        plugin.isar = await dbService.getPluginIsar(plugin.id);
        await pluginHandler.initPlugin(plugin);
      }

      _plugins.addEntries(
        loadedPlugins.map((plugin) => MapEntry(plugin.id, plugin)),
      );
    }

    final rawRoutesUpdateTimestamps = await dbService.appIsar.kvPairs.getByKey(
      "routesUpdateTimestamps",
    );
    if (rawRoutesUpdateTimestamps != null) {
      routesUpdateTimestamps =
          (jsonDecode(rawRoutesUpdateTimestamps.value) as Map<String, dynamic>)
              .map(
                (String id, dynamic timestamps) => MapEntry(
                  id,
                  DateTime.fromMillisecondsSinceEpoch(timestamps, isUtc: true),
                ),
              );
    }

    updateAllRoutes();
  }

  /// Updates all routes by fetching the latest data and applying necessary changes.
  ///
  /// This method performs asynchronous operations to ensure that all routes
  /// are up-to-date. It may involve network requests, database updates, or
  /// other side effects required to synchronize route information.
  ///
  /// Throws an exception if the update process fails.
  Future<void> updateAllRoutes() async {
    List<Future<void>> futures = [];

    for (final plugin in plugins) {
      futures.add(updateRoute(plugin.id));
    }

    await Future.wait(futures);
  }

  /// Updates the route for the specified plugin.
  ///
  /// Takes a [pluginId] as a parameter, which identifies the plugin whose route needs to be updated.
  ///
  /// This method performs the update asynchronously.
  ///
  /// Throws an exception if the update fails.
  Future<void> updateRoute(String pluginId) async {
    if (_routesUpdating.contains(pluginId)) return; // Skip if already updating
    _routesUpdating.add(pluginId);

    final plugin = _plugins[pluginId];

    if (plugin != null) {
      try {
        await plugin.updateRoutes();

        routesUpdateTimestamps[pluginId] = DateTime.now();
        await _saveRouteUpdateTimestamp();

        notifyListeners();
      } catch (e) {
        if (navigatorKey.currentContext != null) {
          showErrorSnackbar(
            navigatorKey.currentContext!.l10n.failedToUpdateRoutes(plugin.name),
          );
        }
      }
    }

    _routesUpdating.remove(pluginId);
  }

  Future<void> _saveRouteUpdateTimestamp() async {
    await dbService.appIsar.writeTxn(() async {
      await dbService.appIsar.kvPairs.put(
        KvPair(
          key: "routesUpdateTimestamps",
          value: jsonEncode(
            routesUpdateTimestamps.map(
              (key, value) => MapEntry(key, value.millisecondsSinceEpoch),
            ),
          ),
        ),
      );
    });
  }

  /// Adds a [plugin] to the service.
  ///
  /// This method asynchronously registers the provided [BasePlugin] instance,
  /// allowing it to be managed and utilized by the service.
  ///
  /// Throws an [Exception] if the plugin cannot be added.
  ///
  /// [plugin]: The plugin instance to add.
  Future<void> addPlugin(BasePlugin plugin) async {
    _plugins[plugin.id] = plugin;
    plugin.isar = await dbService.getPluginIsar(plugin.id);
    for (final pluginHandler in pluginHandlers) {
      await pluginHandler.initPlugin(plugin);
    }

    notifyListeners();
    await savePlugins();

    updateRoute(plugin.id);
  }

  /// Saves the current state of plugins to persistent storage.
  ///
  /// This method performs any necessary serialization and writes the plugin data
  /// to a storage medium (such as local files or a database). It is asynchronous
  /// and should be awaited to ensure that the save operation completes before
  /// proceeding.
  ///
  /// Throws an exception if the save operation fails.
  Future<void> savePlugins() async {
    for (final pluginHandler in pluginHandlers) {
      await pluginHandler.savePlugin(plugins);
    }
  }

  /// Removes the specified [plugin] from the system.
  ///
  /// This method performs any necessary cleanup and ensures that the plugin
  /// is properly unregistered or deleted. The operation is asynchronous and
  /// completes when the removal process is finished.
  ///
  /// Throws an exception if the removal fails.
  Future<void> removePlugin(BasePlugin plugin) async {
    _plugins.remove(plugin.id);
    notifyListeners();

    for (final pluginHandler in pluginHandlers) {
      await pluginHandler.deletePlugin(plugin);
    }

    await dbService.deletePluginIsar(plugin.id);
    routesUpdateTimestamps.remove(plugin.id);
    await _saveRouteUpdateTimestamp();
  }

  /// Returns the [BasePlugin] instance that matches the given [id].
  ///
  /// Throws an exception if no plugin with the specified [id] is found.
  BasePlugin? getPluginById(String id) {
    return _plugins[id];
  }
}
