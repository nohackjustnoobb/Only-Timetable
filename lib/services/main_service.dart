import 'dart:convert';

import 'package:flutter/material.dart' hide Route;
import 'package:http/http.dart';
import 'package:only_timetable/models/eta.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/services/appearance_service.dart';
import 'package:only_timetable/services/db_service.dart';
import 'package:only_timetable/services/eta_service.dart';
import 'package:only_timetable/services/nearby_service.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/services/settings_service.dart';
import 'package:only_timetable/services/bookmark_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

class PluginMeta extends BasePlugin {
  final String _id;
  final String _name;
  final String? _description;
  final String? _author;
  final String _version;
  final String? _repositoryUrl;

  @override
  String get id => _id;
  @override
  String get name => _name;
  @override
  String get version => _version;
  @override
  String? get description => _description;
  @override
  String? get author => _author;
  @override
  String? get repositoryUrl => _repositoryUrl;

  PluginMeta({
    required String id,
    required String name,
    required String version,
    String? description,
    String? author,
    String? repositoryUrl,
  }) : _id = id,
       _name = name,
       _description = description,
       _author = author,
       _version = version,
       _repositoryUrl = repositoryUrl;

  PluginMeta.fromJson(Map<String, dynamic> json)
    : _id = json['id'] as String,
      _name = json['name'] as String,
      _version = json['version'] as String,
      _description = json['description'] as String?,
      _author = json['author'] as String?,
      _repositoryUrl = json['repositoryUrl'] as String?;

  @override
  Future<List<Eta>> getEta(Route route, Stop stop) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateRoutes() {
    throw UnimplementedError();
  }
}

class PluginItem {
  final String link;
  final PluginMeta meta;

  PluginItem({required this.link, required this.meta});

  PluginItem.fromJson(Map<String, dynamic> json)
    : link = json['link'] as String,
      meta = PluginMeta.fromJson(json['meta'] as Map<String, dynamic>);
}

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
  String? marketplaceUrl;

  Future<void> _loadPubspecInfo() async {
    try {
      final pubspecString = await rootBundle.loadString('pubspec.yaml');
      final pubspec = loadYaml(pubspecString);
      version = pubspec['version']?.toString();
      repository = pubspec['repository']?.toString();
      license = pubspec['license']?.toString();
      marketplaceUrl = pubspec['plugin_marketplace']?.toString();
    } catch (e) {
      version = null;
      repository = null;
      license = null;
    }
  }

  Map<String, PluginItem>? _marketplacePlugins;

  /// Fetches the marketplace plugins.
  ///
  /// This method retrieves a map of marketplace plugins, where the keys are
  /// plugin identifiers (as `String`) and the values are `PluginItem` objects
  /// representing the details of each plugin.
  ///
  /// Returns:
  ///   A `Future` that resolves to a `Map<String, PluginItem>` containing the
  ///   marketplace plugins.
  Future<Map<String, PluginItem>> getMarketplacePlugins() async {
    if (marketplaceUrl == null) {
      throw Exception('Marketplace URL is not defined in pubspec.yaml');
    }

    if (_marketplacePlugins != null) {
      return _marketplacePlugins!;
    }

    final resp = await get(Uri.parse(marketplaceUrl!));
    final Map<String, PluginItem> plugins =
        (jsonDecode(resp.body) as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(key, PluginItem.fromJson(value as Map<String, dynamic>)),
        );
    _marketplacePlugins = plugins;

    return plugins;
  }
}
