import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:only_timetable/extensions/shortcut.dart';

class SimpleSearchBar extends StatelessWidget {
  final bool appearanceOnly;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final Color? backgroundColor;
  final bool autoFocus;
  final bool alwaysHideBorder;
  final bool enableHero;
  final bool showCloseButton;

  const SimpleSearchBar({
    super.key,
    this.appearanceOnly = false,
    this.onSubmitted,
    this.onChanged,
    this.controller,
    this.backgroundColor,
    this.autoFocus = true,
    this.alwaysHideBorder = false,
    this.enableHero = false,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: Hero(
            createRectTween: (begin, end) => RectTween(begin: begin, end: end),
            tag: enableHero ? "searchbar" : context.hashCode,
            child: Container(
              decoration: context.containerDecoration.copyWith(
                border: BoxBorder.all(
                  color: context.isDarkMode || alwaysHideBorder
                      ? Colors.transparent
                      : context.colorScheme.inverseSurface.withValues(
                          alpha: .25,
                        ),
                ),
                color: backgroundColor,
              ),
              padding: EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(LucideIcons.search200, size: 20),
                    if (appearanceOnly)
                      SizedBox(height: 32)
                    else
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            onSubmitted: onSubmitted,
                            onChanged: onChanged,
                            controller: controller,
                            autofocus: autoFocus,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showCloseButton)
          CupertinoButton(
            key: ValueKey('closeButton'),
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            child: Text(context.l10n.close),
            onPressed: () => context.pop(),
          ),
      ],
    );
  }
}
