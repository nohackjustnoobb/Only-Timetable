import 'package:flutter/material.dart';
import 'package:only_timetable/services/appearance_service.dart';
import 'package:only_timetable/services/db_service.dart';
import 'package:only_timetable/services/eta_service.dart';
import 'package:only_timetable/services/nearby_service.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/services/settings_service.dart';
import 'package:only_timetable/services/bookmark_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

class MainService extends ChangeNotifier {
  final dbService = DbService();
  final pluginService = PluginService();
  final settingsService = SettingsService();
  final etaService = EtaService();
  final bookmarkService = BookmarkService();
  final appearanceService = AppearanceService();
  final nearbyService = NearbyService();

  Future<void> init() async {
    await dbService.init();
    await pluginService.init(dbService);
    await bookmarkService.init(dbService);
    await appearanceService.init(dbService);
    settingsService.init(dbService);
    nearbyService.init(pluginService);
    etaService.init();

    await _loadPubspecInfo();
  }

  String? version;
  String? repository;
  String? license;

  Future<void> _loadPubspecInfo() async {
    try {
      final pubspecString = await rootBundle.loadString('pubspec.yaml');
      final pubspec = loadYaml(pubspecString);
      version = pubspec['version']?.toString();
      repository = pubspec['repository']?.toString();
      license = pubspec['license']?.toString();
    } catch (e) {
      version = null;
      repository = null;
      license = null;
    }
  }
}
