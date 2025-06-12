import 'package:flutter/material.dart';
import 'package:only_timetable/extensions/shortcut.dart';

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
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
        ),
        Container(
          decoration: context.containerDecoration,
          padding: EdgeInsets.all(20),
          child: child,
        ),
      ],
    );
  }
}
