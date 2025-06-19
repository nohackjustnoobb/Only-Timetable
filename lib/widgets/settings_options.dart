import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';

class ToggleOption extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleOption({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: context.textTheme.titleMedium)),
        SizeTransition(
          sizeFactor: const AlwaysStoppedAnimation<double>(0.75),
          child: Transform.scale(
            alignment: Alignment.centerRight,
            scale: .75,
            child: CupertinoSwitch(
              activeTrackColor: context.primaryColor,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class DropdownOption<T> extends StatelessWidget {
  final String title;
  final T? value;
  final Map<T, String> options;
  final Function(T?) onChanged;

  const DropdownOption({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: context.textTheme.titleMedium)),
        DropdownButtonHideUnderline(
          child: DropdownButton2(
            value: value,
            onChanged: onChanged,
            isDense: true,
            alignment: AlignmentDirectional.centerEnd,
            iconStyleData: IconStyleData(
              icon: Icon(LucideIcons.chevronDown200),
              iconEnabledColor: context.primaryColor,
            ),
            dropdownStyleData: DropdownStyleData(
              openInterval: const Interval(.25, .25),
              decoration: context.containerDecoration.copyWith(
                border: Border.all(
                  color: context.colorScheme.inverseSurface.withValues(
                    alpha: .125,
                  ),
                ),
              ),
              elevation: 0,
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 30,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
            items: options.entries
                .map(
                  (entry) => DropdownMenuItem<T>(
                    alignment: AlignmentDirectional.center,
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
