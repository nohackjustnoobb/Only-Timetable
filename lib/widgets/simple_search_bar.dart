import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:only_timetable/extensions/shortcut.dart';

class SimpleSearchBar extends StatelessWidget {
  final bool appearanceOnly;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  const SimpleSearchBar({
    super.key,
    this.appearanceOnly = false,
    this.onSubmitted,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: context.containerDecoration.copyWith(
        border: BoxBorder.all(
          color: context.theme.brightness == Brightness.dark
              ? Colors.transparent
              : context.colorScheme.inverseSurface.withValues(alpha: .25),
        ),
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
                    autofocus: true,
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
    );
  }
}
