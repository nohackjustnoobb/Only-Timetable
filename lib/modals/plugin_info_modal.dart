import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/globals.dart';
import 'package:only_timetable/modals/modal_base.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/services/plugin/js_plugin/js_plugin.dart';
import 'package:only_timetable/services/plugin/plugin_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PluginInfoModal extends StatefulWidget {
  final BasePlugin plugin;

  const PluginInfoModal({super.key, required this.plugin});

  @override
  State<PluginInfoModal> createState() => _PluginInfoModalState();
}

class _PluginInfoModalState extends State<PluginInfoModal> {
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
                      [context.l10n.id, widget.plugin.id],
                      [context.l10n.name, widget.plugin.name],
                      [context.l10n.version, widget.plugin.version],
                      [context.l10n.author, widget.plugin.author],
                      [context.l10n.repository, widget.plugin.repositoryUrl],
                      [context.l10n.description, widget.plugin.description],
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
                            if (info[0] == context.l10n.repository)
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                onPressed: () => launchUrl(
                                  Uri.parse(info[1]!),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: Text(
                                  info[1]!,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(color: context.subTextColor),
                                ),
                              )
                            else
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
        Column(
          spacing: 10,
          children: [
            if (widget.plugin is JsPlugin &&
                (widget.plugin as JsPlugin).updatesUrl != null)
              CupertinoButton.filled(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                minimumSize: const Size(double.infinity, 0),
                onPressed: () async {
                  if (!context.mounted) return;
                  final jsPlugin = widget.plugin as JsPlugin;

                  try {
                    final result = await jsPlugin.updatePlugin();

                    if (result) setState(() {});

                    showSuccessSnackbar(
                      result
                          // ignore: use_build_context_synchronously
                          ? context.l10n.pluginUpdated(
                              jsPlugin.name,
                              jsPlugin.version,
                            )
                          // ignore: use_build_context_synchronously
                          : context.l10n.pluginUpToDate(jsPlugin.name),
                    );
                  } catch (e) {
                    if (kDebugMode) print(e);

                    // ignore: use_build_context_synchronously
                    showErrorSnackbar(context.l10n.failedToCheckForUpdates);
                  }
                },
                child: Text(context.l10n.checkForUpdates),
              ),
            CupertinoButton(
              minimumSize: const Size(double.infinity, 0),
              padding: EdgeInsets.zero,
              onPressed: () => context.showConfirm(
                context.l10n.removePluginConfirm,
                () async {
                  if (!context.mounted) return;

                  final pluginService = Provider.of<PluginService>(
                    context,
                    listen: false,
                  );
                  await pluginService.removePlugin(widget.plugin);

                  // ignore: use_build_context_synchronously
                  context.pop();
                },
              ),
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
        ),
      ],
    );
  }
}
