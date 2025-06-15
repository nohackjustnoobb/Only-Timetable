import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/modals/add_plugin_modal.dart';
import 'package:only_timetable/modals/modal_base.dart';

class NoPluginsModal extends StatelessWidget {
  const NoPluginsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: context.l10n.noPluginAvailable,
      children: [
        Text(context.l10n.noPluginAvailableDescription),
        Column(
          spacing: 15,
          children: [
            CupertinoButton.filled(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              minimumSize: const Size(double.infinity, 0),
              onPressed: () {
                context.pop();
                showModalBottomSheet(
                  context: context,
                  builder: (context) => AddPluginModal(),
                );
              },
              child: Text(context.l10n.addPlugin),
            ),
            CupertinoButton(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              onPressed: () => context.pop(),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: context.primaryColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(context.l10n.addLater)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
