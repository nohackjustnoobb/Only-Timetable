import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/extensions/theme.dart';
import 'package:only_timetable/screens/settings/plugin.dart';

class SettingsGroup extends StatelessWidget {
  final String title;
  final Widget? child;
  final Widget? action;

  const SettingsGroup({
    super.key,
    required this.title,
    this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: context.textTheme.titleSmall),
              if (action != null) action!,
            ],
          ),
        ),
        Container(
          decoration: context.theme.boxDecoration,
          padding: EdgeInsets.all(20),
          child: child,
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            PluginGroup(),
            SettingsGroup(title: context.l10n.about),
          ],
        ),
      ),
    );
  }
}
