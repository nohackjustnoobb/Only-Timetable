import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/screens/settings/plugin.dart';
import 'package:only_timetable/services/settings_service.dart';
import 'package:only_timetable/widgets/settings_group.dart';
import 'package:only_timetable/widgets/settings_options.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: context.colorScheme.surface,
        title: Text(context.l10n.settings),
        leading: CupertinoButton(
          child: Icon(
            LucideIcons.chevronLeft200,
            color: context.textColor,
            size: 25,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          spacing: 20,
          children: [
            SettingsGroup(
              title: context.l10n.general,
              child: Consumer<SettingsService>(
                builder: (context, settingsService, _) {
                  return Column(
                    children: [
                      ToggleOption(
                        title: context.l10n.alwaysUseOSM,
                        value: settingsService.getSync<bool>(
                          SettingsKey.alwaysUseOSM,
                        ),
                        onChanged: (value) async {
                          await settingsService.set<bool>(
                            SettingsKey.alwaysUseOSM,
                            value,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            PluginGroup(),
            SettingsGroup(title: context.l10n.about),
          ],
        ),
      ),
    );
  }
}
