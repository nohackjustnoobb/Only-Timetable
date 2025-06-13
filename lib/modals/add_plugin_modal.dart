import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/modals/modal_base.dart';
import 'package:only_timetable/services/plugin/js_plugin/js_plugin.dart';
import 'package:provider/provider.dart';

import '../services/plugin/plugin_service.dart';

class AddPluginModal extends StatefulWidget {
  const AddPluginModal({super.key});

  @override
  State<AddPluginModal> createState() => _AddPluginModalState();
}

// TODO currently only supports JsPlugin
class _AddPluginModalState extends State<AddPluginModal> {
  bool isRawJson = false;
  final TextEditingController _textController = TextEditingController();

  submit() async {
    if (!mounted) return;
    final String text = _textController.text.trim();

    try {
      final plugin = isRawJson
          ? JsPlugin.fromJson(jsonDecode(text))
          : await JsPlugin.fromUri(Uri.parse(text));

      // ignore: use_build_context_synchronously
      final pluginService = Provider.of<PluginService>(context, listen: false);

      await pluginService.addPlugin(plugin);

      // ignore: use_build_context_synchronously
      context.pop();
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.showDialog(e.toString());
    }
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: context.l10n.addPlugin,
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<bool>(
            children: {
              true: Text(context.l10n.json),
              false: Text(context.l10n.url),
            },
            backgroundColor: context.colorScheme.surface,
            thumbColor: context.colorScheme.surfaceContainer,
            groupValue: isRawJson,
            onValueChanged: (value) => setState(() {
              if (value != null) isRawJson = value;
            }),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: isRawJson ? context.l10n.json : context.l10n.url,
              hintStyle: context.textTheme.titleMedium?.copyWith(
                color: context.subTextColor,
              ),
            ),
            minLines: isRawJson ? 5 : 1,
            maxLines: isRawJson ? 10 : 1,
          ),
        ),
        CupertinoButton.filled(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          minimumSize: const Size(double.infinity, 0),
          onPressed: submit,
          child: Text(context.l10n.add),
        ),
      ],
    );
  }
}
