import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/modals/modal_base.dart';
import 'package:only_timetable/services/appearance_service.dart';

class ColorPickerModal extends StatefulWidget {
  final Color initialColor;
  final Function(Color color) onDone;

  const ColorPickerModal({
    super.key,
    required this.initialColor,
    required this.onDone,
  });

  @override
  State<ColorPickerModal> createState() => _ColorPickerModalState();
}

class _ColorPickerModalState extends State<ColorPickerModal> {
  late Color _pickerColor;

  @override
  void initState() {
    super.initState();

    _pickerColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: context.l10n.colorPicker,
      children: [
        ColorPicker(
          color: _pickerColor,
          onColorChanged: (color) => setState(() => _pickerColor = color),
          pickersEnabled: {
            ColorPickerType.wheel: true,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
          },
          wheelSquarePadding: 10,
          wheelSquareBorderRadius: 10,
          enableShadesSelection: false,
          padding: EdgeInsets.zero,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          decoration: BoxDecoration(
            color: _pickerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '#${_pickerColor.hex}',
            style: TextStyle(color: context.colorScheme.surfaceContainer),
          ),
        ),
        Row(
          spacing: 10,
          children:
              [
                    DEAFULT_PRIMARY_COLOR,
                    const Color.fromARGB(255, 150, 110, 223),
                    const Color.fromARGB(255, 53, 199, 158),
                    const Color.fromARGB(255, 223, 110, 110),
                    const Color.fromARGB(255, 255, 170, 170),
                    const Color.fromARGB(255, 223, 110, 174),
                  ]
                  .map(
                    (color) => Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: () => setState(() => _pickerColor = color),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        CupertinoButton.filled(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          minimumSize: const Size(double.infinity, 0),
          onPressed: () {
            context.pop();
            widget.onDone(_pickerColor);
          },
          child: Text(context.l10n.done),
        ),
      ],
    );
  }
}
