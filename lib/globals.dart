import 'dart:ui';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void showErrorSnackbar(String message) {
  if (navigatorKey.currentContext == null) return;

  AnimatedSnackBar(
    mobileSnackBarPosition: MobileSnackBarPosition.bottom,
    desktopSnackBarPosition: DesktopSnackBarPosition.bottomCenter,
    builder: ((context) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: context.colorScheme.error.withValues(alpha: .75),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              spacing: 10,
              children: [
                Icon(LucideIcons.ban, color: context.colorScheme.surface),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: context.colorScheme.surface),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }),
  ).show(navigatorKey.currentContext!);
}
