import 'package:flutter/material.dart';
import 'package:only_timetable/services/db_service.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/services/settings_service.dart';

class MainService extends ChangeNotifier {
  final dbService = DbService();
  final pluginService = PluginService();
  final settingsService = SettingsService();

  Future<void> init() async {
    await dbService.init();
    await settingsService.init(dbService);

    // Initialize plugin service in the background
    // It is not necessary to await this
    pluginService.init(dbService);
  }
}
