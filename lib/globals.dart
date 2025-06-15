import 'dart:ui';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void showSnackbar({
  required String message,
  required Color color,
  required IconData icon,
}) {
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
              color: color.withValues(alpha: .75),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              spacing: 10,
              children: [
                Icon(icon, color: context.colorScheme.surface),
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

void showSuccessSnackbar(String message) {
  showSnackbar(
    message: message,
    color: Colors.green,
    icon: LucideIcons.circleCheck,
  );
}

void showErrorSnackbar(String message) {
  if (navigatorKey.currentContext == null) return;

  showSnackbar(
    message: message,
    color: navigatorKey.currentContext!.colorScheme.error,
    icon: LucideIcons.ban,
  );
}
