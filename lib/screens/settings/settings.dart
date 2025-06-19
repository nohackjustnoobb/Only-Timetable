import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/l10n/locale_names.dart';
import 'package:only_timetable/modals/color_picker_modal.dart';
import 'package:only_timetable/services/appearance_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/screens/settings/plugin.dart';
import 'package:only_timetable/services/bookmark_service.dart';
import 'package:only_timetable/services/main_service.dart';
import 'package:only_timetable/services/settings_service.dart';
import 'package:only_timetable/widgets/settings_group.dart';
import 'package:only_timetable/widgets/settings_options.dart';
import 'package:only_timetable/modals/create_bookmark_modal.dart';
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
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom + 20,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            spacing: 20,
            children: [
              SettingsGroup(
                title: context.l10n.general,
                child: Consumer<AppearanceService>(
                  builder: (context, appearanceService, _) =>
                      Consumer<SettingsService>(
                        builder: (context, settingsService, _) => Column(
                          spacing: 10,
                          children: [
                            DropdownOption<dynamic>(
                              title: context.l10n.language,
                              value: appearanceService.locale,
                              options: Map.fromEntries([
                                MapEntry(null, context.l10n.auto),
                                ...context
                                    .findAncestorWidgetOfExactType<
                                      MaterialApp
                                    >()!
                                    .supportedLocales
                                    .map(
                                      (locale) => MapEntry(
                                        locale,
                                        localeNames[locale.toLanguageTag()] ??
                                            locale.toLanguageTag(),
                                      ),
                                    ),
                              ]),
                              onChanged: (dynamic value) =>
                                  appearanceService.setLocale(value as Locale?),
                            ),
                            DropdownOption(
                              title: context.l10n.themeMode,
                              value: appearanceService.themeMode,
                              options: {
                                ThemeMode.system: context.l10n.auto,
                                ThemeMode.light: context.l10n.light,
                                ThemeMode.dark: context.l10n.dark,
                              },
                              onChanged: (ThemeMode? value) => appearanceService
                                  .setThemeMode(value ?? ThemeMode.system),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.primaryColor,
                                  style: context.textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  onPressed: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) =>
                                        ColorPickerModal(
                                          initialColor:
                                              appearanceService.primaryColor,
                                          onDone: (color) => appearanceService
                                              .setPrimaryColor(color),
                                        ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: appearanceService.primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: context.textColor.withValues(
                                          alpha: .125,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      LucideIcons.pipette300,
                                      color:
                                          context.colorScheme.surfaceContainer,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (Platform.isIOS)
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
                        ),
                      ),
                ),
              ),
              PluginGroup(),
              SettingsGroup(
                title: context.l10n.bookmark,
                action: Expanded(
                  child: CupertinoButton(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.bottomRight,
                    child: Icon(LucideIcons.plus200, size: 25),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) => CreateBookmarkModal(),
                    ),
                  ),
                ),
                child: Consumer<BookmarkService>(
                  builder: (context, bookmarkService, child) =>
                      ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: bookmarkService.bookmarks.length,
                        separatorBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            color: context.textColor.withValues(alpha: .1),
                            height: 1,
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final bookmark = bookmarkService.bookmarks[index];
                          final isDefault = bookmark.name == "default";

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 20,
                            children: [
                              Expanded(
                                child: Text(
                                  isDefault
                                      ? context.l10n.defaultBookmark
                                      : bookmark.name,
                                  style: context.textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                onPressed: isDefault
                                    ? null
                                    : () => context.showConfirm(
                                        context.l10n.deleteBookmarkConfirm,
                                        () => bookmarkService.deleteBookmark(
                                          bookmark,
                                        ),
                                      ),
                                child: Icon(
                                  LucideIcons.trash200,
                                  color: isDefault
                                      ? context.subTextColor
                                      : Colors.red,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                ),
              ),
              SettingsGroup(
                title: context.l10n.about,
                child: Consumer<MainService>(
                  builder: (context, mainService, _) {
                    return Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mainService.version != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.version,
                                style: context.textTheme.titleMedium,
                              ),
                              Text(
                                'v${mainService.version!}',
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        if (mainService.repository != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.repository,
                                style: context.textTheme.titleMedium,
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                child: Row(
                                  spacing: 5,
                                  children: [
                                    Icon(LucideIcons.github200),
                                    Icon(LucideIcons.externalLink200),
                                  ],
                                ),
                                onPressed: () async {
                                  final url = Uri.parse(
                                    mainService.repository!,
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        if (mainService.license != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.license,
                                style: context.textTheme.titleMedium,
                              ),
                              Text(
                                mainService.license!,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.primaryColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
