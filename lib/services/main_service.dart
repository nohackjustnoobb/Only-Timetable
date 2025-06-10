import 'package:flutter/material.dart';
import 'package:only_timetable/services/db_service.dart';
import 'package:only_timetable/services/eta_service.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/services/settings_service.dart';
import 'package:only_timetable/services/bookmark_service.dart';

class MainService extends ChangeNotifier {
  final dbService = DbService();
  final pluginService = PluginService();
  final settingsService = SettingsService();
  final etaService = EtaService();
  final bookmarkService = BookmarkService();

  Future<void> init() async {
    await dbService.init();
    await pluginService.init(dbService);
    await bookmarkService.init(dbService);
    settingsService.init(dbService);
  }
}
