import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:isar/isar.dart';
import 'package:mutex/mutex.dart';
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

  final Map<String, Isar> _pluginsIsar = {};
  final lock = Mutex();

  Future<CallAsyncJavaScriptResult?> _callAsyncJavaScript(
    String functionBody,
  ) async {
    if (controller == null) {
      await disposeWebView();
      await initWebView();
    }

    CallAsyncJavaScriptResult? result = await controller!.callAsyncJavaScript(
      functionBody: functionBody,
    );

    // If the result is null or has an error, try reinitialize the webview
    if (result == null || result.error != null) {
      await disposeWebView();
      await initWebView();

      result = await controller!.callAsyncJavaScript(
        functionBody: functionBody,
      );
    }

    return result;
  }

  Future<void> initWebView() async {
    await lock.acquire();
    if (headlessWebView != null) {
      lock.release();
      return;
    }

    final completer = Completer<InAppWebViewController>();

    headlessWebView = HeadlessInAppWebView(
      initialSettings: InAppWebViewSettings(isInspectable: kDebugMode),
      initialData: InAppWebViewInitialData(data: ""),
      onWebViewCreated: (controller) {
        // TODO override fetch to bypass cors
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

              // Fetch stops for each route
              for (final route in routes) {
                await route.fetchStops(isar);
                await route.stops.save();
              }
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
    lock.release();
  }

  Future<void> disposeWebView() async {
    if (headlessWebView != null) {
      await headlessWebView!.dispose();
      headlessWebView = null;
      controller = null;
    }
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

    await initWebView();
    plugin.callAsyncJavaScript = _callAsyncJavaScript;
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

    if (_pluginsIsar.isEmpty) await disposeWebView();
  }
}
