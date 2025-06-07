import 'package:flutter/cupertino.dart';
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
              activeTrackColor: context.colorScheme.primary,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
