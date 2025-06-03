import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:isar/isar.dart';
import 'package:only_timetable/models/kv_pair.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/services/plugin/handler.dart';
import 'package:only_timetable/services/plugin/js_plugin/js_plugin.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';

class JsPluginHandler extends Handler<JsPlugin> {
  @override
  String get id => 'JsPlugin';

  @override
  List<CollectionSchema> get schemas => [KvPairSchema];

  HeadlessInAppWebView? headlessWebView;
  InAppWebViewController? controller;

  int _pluginCount = 0;
  final Map<String, Isar> _pluginsIsar = {};

  Future<void> initWebView() async {
    if (headlessWebView != null) return;

    final completer = Completer<InAppWebViewController>();

    headlessWebView = HeadlessInAppWebView(
      initialSettings: InAppWebViewSettings(isInspectable: kDebugMode),
      initialData: InAppWebViewInitialData(data: ""),
      onWebViewCreated: (controller) {
        // TODO The type of data is changed to JavaScriptHandlerFunctionData after 6.2.0
        controller.addJavaScriptHandler(
          handlerName: "saveStops",
          callback: (data) async {
            final dbId = data[0] as String;
            final stops = (data[1] as List)
                .map((e) => Stop.fromJson(e as Map<String, dynamic>))
                .toList();

            final isar = _pluginsIsar[dbId];
            if (isar == null) throw Exception("Isar not found for dbId: $dbId");

            await isar.writeTxn(() async {
              await isar.stops.clear();
              await isar.stops.putAll(stops);
            });
          },
        );

        controller.addJavaScriptHandler(
          handlerName: "saveRoutes",
          callback: (data) async {
            final dbId = data[0] as String;
            final routes = (data[1] as List)
                .map((e) => Route.fromJson(e as Map<String, dynamic>))
                .toList();

            final isar = _pluginsIsar[dbId];
            if (isar == null) throw Exception("Isar not found for dbId: $dbId");

            await isar.writeTxn(() async {
              await isar.routes.clear();
              await isar.routes.putAll(routes);
            });
          },
        );

        controller.addJavaScriptHandler(
          handlerName: "getValue",
          callback: (data) async {
            final dbId = data[0] as String;
            final key = (data[1] as String);

            final isar = _pluginsIsar[dbId];
            if (isar == null) throw Exception("Isar not found for dbId: $dbId");

            return (await isar.kvPairs.getByKey(key))?.value;
          },
        );

        controller.addJavaScriptHandler(
          handlerName: "setValue",
          callback: (data) async {
            final dbId = data[0] as String;
            final key = (data[1] as String);
            final value = (data[2] as String);

            final isar = _pluginsIsar[dbId];
            if (isar == null) throw Exception("Isar not found for dbId: $dbId");

            await isar.writeTxn(() async {
              await isar.kvPairs.put(KvPair(key: key, value: value));
            });
          },
        );
      },
      onLoadStart: (controller, _) => completer.complete(controller),
    );
    await headlessWebView!.run();

    controller = await completer.future;
  }

  Future<void> disposeWebView() async {
    if (headlessWebView == null) return;

    await headlessWebView!.dispose();
    headlessWebView = null;
    controller = null;
  }

  @override
  Future<List<JsPlugin>> loadPlugins() async {
    List<JsPlugin> plugins = [];

    for (final kvPair
        in await isar.kvPairs.filter().keyIsNotEmpty().findAll()) {
      plugins.add(
        JsPlugin.fromJson(jsonDecode(kvPair.value) as Map<String, dynamic>),
      );
    }

    return plugins;
  }

  @override
  Future<void> initPlugin<T2 extends BasePlugin>(T2 plugin) async {
    if (plugin is! JsPlugin) return;
    _pluginCount++;

    await initWebView();
    plugin.controller = controller;
    _pluginsIsar[plugin.id] = plugin.isar;
  }

  @override
  Future<void> savePlugin<T extends BasePlugin>(List<T> plugins) async {
    List<KvPair> kvPairs = [];

    for (final plugin in plugins) {
      if (plugin is! JsPlugin) continue;

      final encoded = jsonEncode(plugin.toJson());

      kvPairs.add(KvPair(key: plugin.id, value: encoded));
    }

    await isar.writeTxn(() => isar.kvPairs.putAll(kvPairs));
  }

  @override
  Future<void> deletePlugin<T extends BasePlugin>(T plugin) async {
    if (plugin is! JsPlugin) return;

    _pluginsIsar.remove(plugin.id);

    await isar.writeTxn(() => isar.kvPairs.deleteByKey(plugin.id));

    _pluginCount--;
    if (_pluginCount <= 0) await disposeWebView();
  }
}
