import 'dart:io';

import 'package:isar/isar.dart';
import 'package:only_timetable/models/kv_pair.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/services/plugin/handler.dart';
import 'package:path_provider/path_provider.dart';

class DbService {
  late final Directory _dir;
  Map<String, Isar> pluginIsars = {};
  Map<String, Isar> pluginHandlerIsars = {};
  late Isar appIsar;

  Future<void> init() async {
    _dir = await getApplicationDocumentsDirectory();
    appIsar = await Isar.open([KvPairSchema], directory: _dir.path);
  }

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

  Future<void> deletePluginIsar(String pluginId) async {
    if (pluginIsars.containsKey(pluginId)) {
      await pluginIsars[pluginId]!.close();
      pluginIsars.remove(pluginId);
    }

    // TODO
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
