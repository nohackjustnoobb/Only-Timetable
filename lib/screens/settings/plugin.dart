import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/plugin/js_plugin/js_plugin.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/widgets/modal_base.dart';
import 'package:only_timetable/widgets/settings_group.dart';
import 'package:provider/provider.dart';

class AddPluginModal extends StatefulWidget {
  const AddPluginModal({super.key});

  @override
  State<AddPluginModal> createState() => _AddPluginModalState();
}

// TODO currently only supports JsPlugin
class _AddPluginModalState extends State<AddPluginModal> {
  bool isRawJson = false;
  final TextEditingController _textController = TextEditingController();

  submit() async {
    if (!mounted) return;
    final String text = _textController.text.trim();

    try {
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
      title: context.l10n.addPlugin,
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
                color: context.textColor?.withValues(alpha: .5),
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
          onPressed: submit,
          child: Text(context.l10n.add),
        ),
      ],
    );
  }
}

class PluginInfoModal extends StatelessWidget {
  final BasePlugin plugin;

  const PluginInfoModal({super.key, required this.plugin});

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: context.l10n.pluginInfo,
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children:
                [
                      [context.l10n.id, plugin.id],
                      [context.l10n.name, plugin.name],
                      [context.l10n.version, plugin.version],
                      [context.l10n.author, plugin.author],
                      [context.l10n.repositoryUrl, plugin.repositoryUrl],
                      [context.l10n.description, plugin.description],
                    ]
                    .where((info) => info[1] != null)
                    .map<Widget>(
                      (List<String?> info) => SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Text(
                              info[0]!,
                              style: context.textTheme.titleMedium,
                            ),
                            Text(
                              info[1]!,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.textColor?.withValues(alpha: .5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        CupertinoButton(
          minimumSize: const Size(double.infinity, 0),
          padding: EdgeInsets.zero,
          onPressed: () =>
              context.showConfirm(context.l10n.removePluginConfirm, () async {
                if (!context.mounted) return;

                final pluginService = Provider.of<PluginService>(
                  context,
                  listen: false,
                );
                await pluginService.removePlugin(plugin);

                // ignore: use_build_context_synchronously
                context.pop();
              }),
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: context.colorScheme.error),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                context.l10n.removePlugin,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colorScheme.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PluginGroup extends StatelessWidget {
  const PluginGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: context.l10n.plugin,
      action: Expanded(
        child: CupertinoButton(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          alignment: Alignment.bottomRight,
          child: Icon(LucideIcons.plus200, size: 25),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) => AddPluginModal(),
          ),
        ),
      ),
      child: Consumer<PluginService>(
        builder: (BuildContext context, PluginService pluginService, _) =>
            pluginService.plugins.isEmpty
            ? SizedBox(
                width: double.infinity,
                child: Text(
                  context.l10n.noPluginAvailable,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.textColor?.withValues(alpha: .5),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: pluginService.plugins.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    color: context.textColor?.withValues(alpha: .1),
                    height: 1,
                  ),
                ),
                itemBuilder: (context, index) {
                  final plugin = pluginService.plugins[index];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 20,
                    children: [
                      Flexible(
                        child: CupertinoButton(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          onPressed: () => showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) =>
                                PluginInfoModal(plugin: plugin),
                          ),
                          child: Row(
                            spacing: 5,
                            children: [
                              Flexible(
                                child: Text(
                                  plugin.name,
                                  style: context.textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'v${plugin.version}',
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.textColor?.withValues(
                                    alpha: .5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Text(
                            pluginService.routesUpdateTimestamps[plugin.id] !=
                                    null
                                ? context.l10n.updatedOn(
                                    pluginService.routesUpdateTimestamps[plugin
                                        .id]!,
                                  )
                                : context.l10n.neverUpdated,
                          ),
                          CupertinoButton(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            child: Icon(
                              LucideIcons.refreshCcw200,
                              color: context.textColor,
                            ),
                            onPressed: () =>
                                pluginService.updateRoute(plugin.id),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
