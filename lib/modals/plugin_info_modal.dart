import 'package:flutter/cupertino.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/modals/modal_base.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:provider/provider.dart';

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
                      [context.l10n.repository, plugin.repositoryUrl],
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
                                color: context.subTextColor,
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
