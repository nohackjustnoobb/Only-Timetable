import 'dart:io';

import 'package:isar/isar.dart';
import 'package:only_timetable/models/kv_pair.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/services/plugin/handler.dart';
import 'package:path_provider/path_provider.dart';

/// A service class responsible for managing the Isar instances used by the application.
class DbService {
  late final Directory _dir;
  Map<String, Isar> pluginIsars = {};
  Map<String, Isar> pluginHandlerIsars = {};
  late Isar appIsar;

  Future<void> init() async {
    _dir = await getApplicationDocumentsDirectory();
    appIsar = await Isar.open([KvPairSchema], directory: _dir.path);
  }

  /// Asynchronously retrieves an [Isar] database instance associated with the given [pluginHandler].
  ///
  /// The [pluginHandler] parameter specifies the handler for which the Isar instance is required.
  /// Returns a [Future] that completes with the corresponding [Isar] instance.
  ///
  /// Throws an exception if the database cannot be retrieved or initialized.
  Future<Isar> getPluginHandlerIsar(Handler pluginHandler) async {
    if (pluginHandlerIsars.containsKey(pluginHandler.id)) {
      return pluginHandlerIsars[pluginHandler.id]!;
    }

    final isar = await Isar.open(
      pluginHandler.schemas,
      name: pluginHandler.id,
      directory: _dir.path,
    );

    pluginHandlerIsars[pluginHandler.id] = isar;

    return isar;
  }

  /// Retrieves an instance of [Isar] database associated with the specified [pluginId].
  ///
  /// This method asynchronously returns the [Isar] instance that corresponds to the given
  /// plugin identifier. It can be used to access or manipulate data specific to a plugin.
  ///
  /// Throws an exception if the database instance cannot be retrieved.
  ///
  /// [pluginId] - The unique identifier for the plugin whose database instance is required.
  ///
  /// Returns a [Future] that completes with the [Isar] instance.
  Future<Isar> getPluginIsar(String pluginId) async {
    if (pluginIsars.containsKey(pluginId)) {
      return pluginIsars[pluginId]!;
    }

    final isar = await Isar.open(
      [KvPairSchema, RouteSchema, StopSchema],
      name: pluginId,
      directory: _dir.path,
    );

    pluginIsars[pluginId] = isar;

    return isar;
  }

  /// Deletes a plugin from the Isar database using the provided [pluginId].
  ///
  /// This method performs an asynchronous operation to remove the plugin
  /// identified by [pluginId] from the Isar database.
  ///
  /// Throws an exception if the deletion fails.
  Future<void> deletePluginIsar(String pluginId) async {
    if (pluginIsars.containsKey(pluginId)) {
      await pluginIsars[pluginId]!.close();
      pluginIsars.remove(pluginId);
    }

    final isarFile = File('${_dir.path}/$pluginId.isar');
    if (await isarFile.exists()) {
      await isarFile.delete();
    }

    final isarLockFile = File('${_dir.path}/$pluginId.isar.lock');
    if (await isarLockFile.exists()) {
      await isarLockFile.delete();
    }
  }
}
