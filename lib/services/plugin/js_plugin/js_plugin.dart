import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart';

import '../../../models/eta.dart';
import '../../../models/route.dart';
import '../../../models/stop.dart';
import '../base_plugin.dart';

class JsPlugin extends BasePlugin {
  // --------- Metadata ---------
  String _id;
  String _name;
  String _version;

  String? _description;
  String? _author;
  String? _repositoryUrl;
  String? updatesUrl;

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

  // --------- JavaScript Scripts ---------
  late String _updateRoutesScriptOrigin;
  late String _updateRoutesScript;
  late String _updateRoutesFunctionName;

  late String _getEtaScriptOrigin;
  late String _getEtaScript;
  late String _getEtaFunctionName;

  late String _injectHandler;

  // --------- JavaScript Runtime ---------
  Future<CallAsyncJavaScriptResult?> Function(String functionBody)?
  callAsyncJavaScript;

  // --------- Constructor ---------
  void _init() {
    // Extract the function name and set the script
    final regex = RegExp(r'export{(.*) as default};');
    RegExpMatch? match = regex.firstMatch(_updateRoutesScriptOrigin);
    if (match != null && match.groupCount > 0) {
      _updateRoutesFunctionName = match.group(1)!.trim();
      _updateRoutesScript = _updateRoutesScriptOrigin.replaceFirst(regex, '');
    } else {
      throw Exception('Invalid updateRoutesScript: $_updateRoutesScriptOrigin');
    }

    match = regex.firstMatch(_getEtaScriptOrigin);
    if (match != null && match.groupCount > 0) {
      _getEtaFunctionName = match.group(1)!.trim();
      _getEtaScript = _getEtaScriptOrigin.replaceFirst(regex, '');
    } else {
      throw Exception('Invalid getEtaScript: $_getEtaScriptOrigin');
    }

    // Inject the handlers
    _injectHandler =
        '''
          const sendMessage = (name, ...data) => 
            window.flutter_inappwebview.callHandler(name, "$id", ...data);
        ''';
  }

  JsPlugin({
    required String id,
    required String name,
    required String version,
    required String updateRoutesScript,
    required String getEtaScript,
    String? description,
    String? author,
    String? repositoryUrl,
    this.updatesUrl,
  }) : _id = id,
       _name = name,
       _version = version,
       _description = description,
       _author = author,
       _repositoryUrl = repositoryUrl,
       _updateRoutesScriptOrigin = updateRoutesScript,
       _getEtaScriptOrigin = getEtaScript {
    _init();
  }

  JsPlugin.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'] as String,
        name: json['name'] as String,
        version: json['version'] as String,
        updateRoutesScript: json['updateRoutesScript'] as String,
        getEtaScript: json['getEtaScript'] as String,
        description: json['description'] as String?,
        author: json['author'] as String?,
        repositoryUrl: json['repositoryUrl'] as String?,
        updatesUrl: json['updatesUrl'] as String?,
      );

  static Future<JsPlugin> fromUri(Uri uri) async {
    final resp = await get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load plugin from $uri');
    }

    final json = jsonDecode(resp.body);
    return JsPlugin.fromJson(json as Map<String, dynamic>);
  }

  // --------- Methods ---------
  @override
  Future<void> updateRoutes() async {
    if (callAsyncJavaScript == null) {
      throw Exception('Javascript Runtime is not initialized');
    }

    final result = await callAsyncJavaScript!(
      "$_injectHandler $_updateRoutesScript return await $_updateRoutesFunctionName();",
    );

    if (result == null) {
      throw Exception('Failed to update routes: result is null');
    }

    if (result.error != null) {
      throw Exception('Error updating routes: ${result.error}');
    }
  }

  @override
  Future<List<Eta>> getEta(Route route, Stop stop) async {
    if (callAsyncJavaScript == null) {
      throw Exception('Javascript Runtime is not initialized');
    }

    final encodedRoute = jsonEncode(route.toJson());
    final encodedStop = jsonEncode(stop.toJson());
    final body =
        "$_injectHandler $_getEtaScript return await $_getEtaFunctionName($encodedRoute,$encodedStop);";
    final result = await callAsyncJavaScript!(body);

    if (result == null) {
      throw Exception('Failed to get ETA: result is null');
    }

    if (result.error != null) {
      throw Exception('Error getting ETA: ${result.error}');
    }

    return (result.value as List<dynamic>)
        .map((e) => Eta.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<bool> updatePlugin() async {
    if (updatesUrl == null) {
      throw Exception('No updates URL provided for the plugin');
    }

    final uri = Uri.parse(updatesUrl!);
    final resp = await get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load plugin update from $uri');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (json['version'] == version) {
      return false; // No update available
    }

    final updatedPlugin = JsPlugin.fromJson(json);

    // Update the current plugin instance with the new data
    _id = updatedPlugin._id;
    _name = updatedPlugin._name;
    _version = updatedPlugin._version;
    _description = updatedPlugin._description;
    _author = updatedPlugin._author;
    _repositoryUrl = updatedPlugin._repositoryUrl;
    updatesUrl = updatedPlugin.updatesUrl;
    _getEtaScriptOrigin = updatedPlugin._getEtaScriptOrigin;
    _getEtaScriptOrigin = updatedPlugin._getEtaScriptOrigin;

    _init();

    if (updatedCallback != null) updatedCallback!();

    return true; // Update successful
  }

  Map<String, dynamic> toJson() => {
    'id': _id,
    'name': _name,
    'version': _version,
    'updateRoutesScript': _updateRoutesScriptOrigin,
    'getEtaScript': _getEtaScriptOrigin,
    'description': _description,
    'author': _author,
    'repositoryUrl': _repositoryUrl,
    'updatesUrl': updatesUrl,
  };
}
