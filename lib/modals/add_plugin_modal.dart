import 'dart:convert';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/modals/modal_base.dart';
import 'package:only_timetable/modals/plugin_info_modal.dart';
import 'package:only_timetable/services/main_service.dart';
import 'package:only_timetable/services/plugin/js_plugin/js_plugin.dart';
import 'package:only_timetable/widgets/simple_search_bar.dart';
import 'package:provider/provider.dart';

import '../services/plugin/plugin_service.dart';

class _DirectInput extends StatefulWidget {
  final Function(String text, bool isRawJson) submit;

  const _DirectInput({required this.submit});

  @override
  State<_DirectInput> createState() => _DirectInputState();
}

class _DirectInputState extends State<_DirectInput> {
  bool isRawJson = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            20 +
            context.mediaQuery.padding.bottom +
            context.mediaQuery.viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<bool>(
              children: {
                true: Text(context.l10n.json),
                false: Text(context.l10n.url),
              },
              backgroundColor: context.colorScheme.surface,
              thumbColor: context.colorScheme.surfaceContainer,
              groupValue: isRawJson,
              onValueChanged: (value) => setState(() {
                if (value != null) isRawJson = value;
              }),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: isRawJson ? context.l10n.json : context.l10n.url,
                hintStyle: context.textTheme.titleMedium?.copyWith(
                  color: context.subTextColor,
                ),
              ),
              minLines: isRawJson ? 5 : 1,
              maxLines: isRawJson ? 10 : 1,
            ),
          ),
          CupertinoButton.filled(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: const Size(double.infinity, 0),
            onPressed: () => widget.submit(_textController.text, isRawJson),
            child: Text(context.l10n.add),
          ),
        ],
      ),
    );
  }
}

class _Marketplace extends StatefulWidget {
  final Function(String text, bool isRawJson) submit;

  const _Marketplace({required this.submit});

  @override
  State<_Marketplace> createState() => _MarketplaceState();
}

class _MarketplaceState extends State<_Marketplace> {
  Map<String, PluginItem>? _origPlugins;
  Map<String, PluginItem>? _plugins;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    final mainService = Provider.of<MainService>(context, listen: false);
    mainService.getMarketplacePlugins().then((plugins) {
      if (!mounted) return;

      setState(() {
        _plugins = plugins;
        _origPlugins = Map.from(plugins);
      });
    });

    _controller.addListener(() {
      if (_origPlugins == null) return;

      final query = _controller.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          _plugins = Map.from(_origPlugins!);
        } else {
          _plugins = _origPlugins!.values
              .where(
                (plugin) =>
                    plugin.meta.name.toLowerCase().contains(query) ||
                    (plugin.meta.description?.toLowerCase().contains(query) ??
                        false),
              )
              .fold<Map<String, PluginItem>>({}, (map, plugin) {
                map[plugin.link] = plugin;
                return map;
              });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _plugins == null
        ? Padding(
            padding: EdgeInsets.only(
              bottom: 20 + context.mediaQuery.padding.bottom,
            ),
            child: Center(child: CupertinoActivityIndicator()),
          )
        : Column(
            spacing: 20,
            children: [
              SimpleSearchBar(
                autoFocus: false,
                controller: _controller,
                backgroundColor: context.colorScheme.surface,
                alwaysHideBorder: true,
              ),
              if (_plugins!.isEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 20 + context.mediaQuery.padding.bottom,
                  ),
                  child: Text(
                    context.l10n.noPluginAvailable,
                    style: context.textTheme.titleMedium,
                  ),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: 20 + context.mediaQuery.padding.bottom,
                    ),
                    // TODO add lazy loading
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _plugins!.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(
                          color: context.textColor.withValues(alpha: .1),
                          height: 1,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final plugin = _plugins!.values.elementAt(index);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                Text(
                                  plugin.meta.name,
                                  style: context.textTheme.titleMedium,
                                ),
                                Text(
                                  'v${plugin.meta.version}',
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(color: context.subTextColor),
                                ),
                              ],
                            ),
                            if (plugin.meta.description != null)
                              Text(
                                plugin.meta.description!,
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: context.subTextColor,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                spacing: 20,
                                children: [
                                  CupertinoButton.filled(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 25,
                                      vertical: 5,
                                    ),
                                    child: Text(context.l10n.add),
                                    onPressed: () =>
                                        widget.submit(plugin.link, false),
                                  ),
                                  CupertinoButton(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    child: Text(context.l10n.details),
                                    onPressed: () => showModalBottomSheet(
                                      context: context,
                                      builder: (context) => PluginInfoModal(
                                        plugin: plugin.meta,
                                        previewOnly: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
  }
}

class AddPluginModal extends StatefulWidget {
  const AddPluginModal({super.key});

  @override
  State<AddPluginModal> createState() => _AddPluginModalState();
}

class _AddPluginModalState extends State<AddPluginModal> {
  bool _isMarketplace = true;

  submit(String text, bool isRawJson) async {
    if (!mounted) return;

    try {
      // TODO currently only supports JsPlugin
      final plugin = isRawJson
          ? JsPlugin.fromJson(jsonDecode(text))
          : await JsPlugin.fromUri(Uri.parse(text));

      // ignore: use_build_context_synchronously
      final pluginService = Provider.of<PluginService>(context, listen: false);

      await pluginService.addPlugin(plugin);

      // ignore: use_build_context_synchronously
      context.pop();
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: _isMarketplace ? context.l10n.marketplace : context.l10n.addPlugin,
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: Icon(
          _isMarketplace ? LucideIcons.pen200 : LucideIcons.store200,
          size: 25,
          color: context.textColor,
        ),
        onPressed: () => setState(() => _isMarketplace = !_isMarketplace),
      ),
      children: [
        Flexible(
          child: AnimatedSizeAndFade(
            fadeDuration: const Duration(milliseconds: 200),
            sizeDuration: const Duration(milliseconds: 200),
            child: _isMarketplace
                ? _Marketplace(submit: submit)
                : _DirectInput(submit: submit),
          ),
        ),
      ],
    );
  }
}
