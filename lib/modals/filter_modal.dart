import 'package:flutter/cupertino.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/modals/modal_base.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';

class FilterModal extends StatefulWidget {
  final List<BasePlugin> options;
  final List<String> selectedOptions;
  final Function(List<String>) onFilterChanged;

  const FilterModal({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onFilterChanged,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: context.l10n.filter,
      children: [
        Column(
          spacing: 10,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                context.l10n.showRoutesFrom,
                textAlign: TextAlign.start,
                style: context.textTheme.titleSmall,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 15,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                children: widget.options.map((plugin) {
                  final isSelected = widget.selectedOptions.contains(plugin.id);

                  return CupertinoButton.filled(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    minimumSize: Size.zero,
                    color: isSelected
                        ? context.primaryColor
                        : context.colorScheme.shadow,
                    onPressed: () {
                      if (isSelected) {
                        widget.selectedOptions.remove(plugin.id);
                      } else {
                        widget.selectedOptions.add(plugin.id);
                      }

                      widget.onFilterChanged(widget.selectedOptions);
                      setState(() {});
                    },
                    child: Text(
                      plugin.name,
                      style: TextStyle(
                        color: isSelected
                            ? context.colorScheme.inversePrimary
                            : context.textColor.withValues(alpha: .3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        CupertinoButton(
          minimumSize: const Size(double.infinity, 0),
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: context.primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(context.l10n.done, textAlign: TextAlign.center),
            ),
          ),
        ),
      ],
    );
  }
}
