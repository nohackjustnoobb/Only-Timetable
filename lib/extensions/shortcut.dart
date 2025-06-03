import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;

import '../l10n/app_localizations.g.dart';

extension Shortcut on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Color? get textColor => Theme.of(this).colorScheme.inverseSurface;

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
                padding: const EdgeInsets.all(0),
                minimumSize: const Size(0, 0),
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
        minimumSize: const Size(0, 0),
        child: Text(l10n.cancel),
        onPressed: () => pop(),
      ),
      CupertinoButton(
        padding: const EdgeInsets.all(0),
        minimumSize: const Size(0, 0),
        child: Text(l10n.confirm, style: TextStyle(color: colorScheme.error)),
        onPressed: () {
          action();
          pop();
        },
      ),
    ],
  );
}
