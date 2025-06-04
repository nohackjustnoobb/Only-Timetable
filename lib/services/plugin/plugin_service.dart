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

  Future<void> updateAllRoutes() async {
    List<Future<void>> futures = [];

    for (final plugin in plugins) {
      // await updateRoute(plugin.id);
      futures.add(updateRoute(plugin.id));
    }

    await Future.wait(futures);
  }

  Future<void> updateRoute(String pluginId) async {
    if (_routesUpdating.contains(pluginId)) return; // Skip if already updating
    _routesUpdating.add(pluginId);

    final plugin = _plugins[pluginId];

    if (plugin != null) {
      try {
        await plugin.updateRoutes();

        routesUpdateTimestamps[pluginId] = DateTime.now();
        await saveRouteUpdateTimestamp();

        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print("Failed to update routes for plugin $pluginId: $e");
        }

        if (navigatorKey.currentContext != null) {
          showErrorSnackbar(
            navigatorKey.currentContext!.l10n.failedToUpdateRoutes(plugin.name),
          );
        }
      }
    }

    _routesUpdating.remove(pluginId);
  }

  Future<void> saveRouteUpdateTimestamp() async {
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

  Future<void> savePlugins() async {
    for (final pluginHandler in pluginHandlers) {
      await pluginHandler.savePlugin(plugins);
    }
  }

  Future<void> removePlugin(BasePlugin plugin) async {
    _plugins.remove(plugin.id);
    notifyListeners();

    for (final pluginHandler in pluginHandlers) {
      await pluginHandler.deletePlugin(plugin);
    }

    await dbService.deletePluginIsar(plugin.id);
    routesUpdateTimestamps.remove(plugin.id);
    await saveRouteUpdateTimestamp();
  }

  BasePlugin getPluginById(String id) {
    if (!_plugins.containsKey(id)) {
      throw Exception("Plugin with id $id not found");
    }

    return _plugins[id]!;
  }
}
