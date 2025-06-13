import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/modals/add_plugin_modal.dart';
import 'package:only_timetable/modals/plugin_info_modal.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:only_timetable/widgets/settings_group.dart';
import 'package:provider/provider.dart';

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
                    color: context.subTextColor,
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
                    color: context.textColor.withValues(alpha: .1),
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
                                  color: context.subTextColor,
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
