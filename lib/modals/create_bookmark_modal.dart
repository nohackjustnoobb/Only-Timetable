import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/globals.dart';
import 'package:only_timetable/models/bookmark.dart';
import 'package:only_timetable/services/bookmark_service.dart';
import 'package:only_timetable/modals/modal_base.dart';
import 'package:provider/provider.dart';

class CreateBookmarkModal extends StatefulWidget {
  const CreateBookmarkModal({super.key});

  @override
  State<CreateBookmarkModal> createState() => _CreateBookmarkModalState();
}

class _CreateBookmarkModalState extends State<CreateBookmarkModal> {
  final TextEditingController _textController = TextEditingController();

  submit() async {
    if (!mounted) return;

    final String text = _textController.text.trim();
    if (text.isEmpty) {
      showErrorSnackbar(context.l10n.bookmarkNameRequired);
      return;
    }

    final bookmarkService = Provider.of<BookmarkService>(
      context,
      listen: false,
    );

    try {
      await bookmarkService.createBookmark(Bookmark(name: text));

      // ignore: use_build_context_synchronously
      context.pop();
    } catch (_) {
      // ignore: use_build_context_synchronously
      showErrorSnackbar(context.l10n.bookmarkAlreadyExists);
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
      title: context.l10n.createBookmark,
      children: [
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
              hintText: context.l10n.bookmarkName,
              hintStyle: context.textTheme.titleMedium?.copyWith(
                color: context.subTextColor,
              ),
            ),
          ),
        ),
        CupertinoButton.filled(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          minimumSize: const Size(double.infinity, 0),
          onPressed: submit,
          child: Text(context.l10n.create),
        ),
      ],
    );
  }
}
