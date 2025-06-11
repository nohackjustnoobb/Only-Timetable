import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart';

import '../../../models/eta.dart';
import '../../../models/route.dart';
import '../../../models/stop.dart';
import '../base_plugin.dart';

class JsPlugin extends BasePlugin {
  // --------- Metadata ---------
  final String _id;
  final String _name;
  final String _version;

  final String? _description;
  final String? _author;
  final String? _repositoryUrl;
  final String? updatesUrl;

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
  late final String _updateRoutesScripOrigin;
  late final String _updateRoutesScript;
  late final String _updateRoutesFunctionName;

  late final String _getEtaScriptRawOrigin;
  late final String _getEtaScript;
  late final String _getEtaFunctionName;

  late final String _injectHandler;

  // --------- JavaScript Runtime ---------
  InAppWebViewController? controller;

  // --------- Constructor ---------
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
       _repositoryUrl = repositoryUrl {
    // Extract the function name and set the script
    final regex = RegExp(r'export{(.*) as default};');
    RegExpMatch? match = regex.firstMatch(updateRoutesScript);
    if (match != null && match.groupCount > 0) {
      _updateRoutesScripOrigin = updateRoutesScript;
      _updateRoutesFunctionName = match.group(1)!.trim();
      _updateRoutesScript = updateRoutesScript.replaceFirst(regex, '');
    } else {
      throw Exception('Invalid updateRoutesScript: $updateRoutesScript');
    }

    match = regex.firstMatch(getEtaScript);
    if (match != null && match.groupCount > 0) {
      _getEtaScriptRawOrigin = getEtaScript;
      _getEtaFunctionName = match.group(1)!.trim();
      _getEtaScript = getEtaScript.replaceFirst(regex, '');
    } else {
      throw Exception('Invalid getEtaScript: $getEtaScript');
    }

    // Inject the handlers
    _injectHandler =
        '''
          const sendMessage = (name, ...data) => 
            window.flutter_inappwebview.callHandler(name, "$id", ...data);
        ''';
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
    if (controller == null) {
      throw Exception('Controller is not initialized');
    }

    final result = await controller!.callAsyncJavaScript(
      functionBody:
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
    if (controller == null) {
      throw Exception('Controller is not initialized');
    }

    final encodedRoute = jsonEncode(route.toJson());
    final encodedStop = jsonEncode(stop.toJson());
    final body =
        "$_injectHandler $_getEtaScript return await $_getEtaFunctionName($encodedRoute,$encodedStop);";
    final result = await controller!.callAsyncJavaScript(functionBody: body);

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

  Map<String, dynamic> toJson() => {
    'id': _id,
    'name': _name,
    'version': _version,
    'updateRoutesScript': _updateRoutesScripOrigin,
    'getEtaScript': _getEtaScriptRawOrigin,
    'description': _description,
    'author': _author,
    'repositoryUrl': _repositoryUrl,
    'updatesUrl': updatesUrl,
  };
}
