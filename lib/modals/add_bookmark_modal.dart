import 'package:flutter/cupertino.dart' hide Route;
import 'package:flutter/material.dart' hide Route;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:only_timetable/extensions/shortcut.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/services/bookmark_service.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';
import 'package:only_timetable/modals/create_bookmark_modal.dart';
import 'package:only_timetable/modals/modal_base.dart';
import 'package:provider/provider.dart';

class AddBookmarkModal extends StatelessWidget {
  final BasePlugin plugin;
  final Route route;
  final Stop stop;

  const AddBookmarkModal({
    super.key,
    required this.plugin,
    required this.route,
    required this.stop,
  });

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: context.l10n.bookmark,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Consumer<BookmarkService>(
                  builder: (context, bookmarkService, child) {
                    final bookmarks = bookmarkService
                        .getBookmarks(plugin: plugin, route: route, stop: stop)
                        .map((e) => e.name)
                        .toList();

                    final allBookmarks = bookmarkService.bookmarks;

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allBookmarks.length,
                      itemBuilder: (context, index) {
                        final isBookmarked = bookmarks.contains(
                          allBookmarks[index].name,
                        );

                        return CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: Size.zero,
                          onPressed: () async {
                            if (isBookmarked) {
                              await bookmarkService.removeBookmark(
                                plugin: plugin,
                                route: route,
                                stop: stop,
                                bookmark: allBookmarks[index],
                              );
                            } else {
                              await bookmarkService.addBookmark(
                                plugin: plugin,
                                route: route,
                                stop: stop,
                                bookmark: allBookmarks[index],
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  allBookmarks[index].name == "default"
                                      ? context.l10n.defaultBookmark
                                      : allBookmarks[index].name,
                                  style: context.textTheme.titleMedium,
                                ),
                              ),
                              Icon(
                                isBookmarked
                                    ? LucideIcons.circleCheckBig200
                                    : LucideIcons.circle200,
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Divider(
                          color: context.textColor.withValues(alpha: .1),
                          height: 1,
                        ),
                      ),
                    );
                  },
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) => CreateBookmarkModal(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Icon(LucideIcons.plus200, color: context.subTextColor),
                      Text(
                        context.l10n.createBookmark,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        CupertinoButton.filled(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          minimumSize: const Size(double.infinity, 0),
          onPressed: () => context.pop(),
          child: Text(context.l10n.done),
        ),
      ],
    );
  }
}
