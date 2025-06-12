import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;

import '../l10n/app_localizations.g.dart';

extension Shortcut on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  BoxDecoration get containerDecoration => BoxDecoration(
    border: BoxBorder.all(
      color: isDarkMode
          ? Colors.transparent
          : colorScheme.inverseSurface.withValues(alpha: .125),
    ),
    borderRadius: BorderRadius.circular(10),
    color: colorScheme.surfaceContainer,
  );

  Color get textColor => Theme.of(this).colorScheme.inverseSurface;
  Color get subTextColor =>
      Theme.of(this).colorScheme.inverseSurface.withValues(alpha: .5);
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Future<T?> push<T extends Object?>(Route<T> route) =>
      Navigator.of(this).push(route);

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  void showDialog(String content, {String? title, List<Widget>? actions}) {
    material.showDialog(
      context: this,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(title ?? context.l10n.failed),
        titleTextStyle: context.textTheme.titleLarge,
        content: Text(content),
        titlePadding: const EdgeInsets.only(top: 20, left: 20, bottom: 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.only(top: 10, right: 20, bottom: 20),
        actions:
            actions ??
            [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                child: Text(context.l10n.close),
                onPressed: () => context.pop(),
              ),
            ],
      ),
    );
  }

  void showConfirm(String mesg, Function action) => showDialog(
    mesg,
    title: l10n.confirmation,
    actions: [
      CupertinoButton(
        padding: const EdgeInsets.only(right: 10),
        minimumSize: Size.zero,
        child: Text(l10n.cancel),
        onPressed: () => pop(),
      ),
      CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: Text(l10n.confirm, style: TextStyle(color: colorScheme.error)),
        onPressed: () {
          action();
          pop();
        },
      ),
    ],
  );

  String getLocalizedString(String source) {
    final parsed = jsonDecode(source) as Map<String, dynamic>;

    if (parsed.containsKey(l10n.localeName)) {
      return parsed[l10n.localeName]!;
    }

    // Fallback to English if the current locale is not available
    if (parsed.containsKey('en')) {
      return parsed['en']!;
    }

    throw Exception(
      'No localized string found for locale ${l10n.localeName} in $source',
    );
  }
}
