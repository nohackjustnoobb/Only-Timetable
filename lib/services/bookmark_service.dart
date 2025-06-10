import 'package:flutter/material.dart' hide Route;
import 'package:isar/isar.dart';
import 'package:only_timetable/models/route.dart';
import 'package:only_timetable/models/stop.dart';
import 'package:only_timetable/models/bookmark.dart';
import 'package:only_timetable/models/bookmarked.dart';
import 'package:only_timetable/services/db_service.dart';

import 'plugin/base_plugin.dart';

class BookmarkService extends ChangeNotifier {
  // --------- Isar Instance ---------
  late Isar _isar;

  // --------- Services ---------

  Future<void> init(DbService dbService) async {
    _isar = dbService.appIsar;

    _bookmarks = Map.fromEntries(
      (await _isar.bookmarks.where().findAll()).map(
        (bookmark) => MapEntry(bookmark.name, bookmark),
      ),
    );

    // Ensure at least one default bookmark exists
    if (_bookmarks.isEmpty) {
      final bookmark = Bookmark(name: 'default');

      _bookmarks["default"] = bookmark;
      await _isar.writeTxn(() => _isar.bookmarks.put(bookmark));
    }
  }

  // --------- Bookmarks Management ---------
  Map<String, Bookmark> _bookmarks = {};
  List<Bookmark> get bookmarks => [
    _bookmarks["default"]!,
    ..._bookmarks.values.where((bookmark) => bookmark.name != "default"),
  ];

  Bookmark? getBookmark(String name) => _bookmarks[name];

  Future<void> createBookmark(Bookmark bookmark) async {
    if (_bookmarks[bookmark.name] != null) {
      throw Exception("bookmark ${bookmark.name} already exists");
    }

    await _isar.writeTxn(() => _isar.bookmarks.put(bookmark));

    _bookmarks[bookmark.name] = bookmark;

    notifyListeners();
  }

  Future<void> deleteBookmark(Bookmark bookmark) async {
    if (_bookmarks[bookmark.name] == null) {
      throw Exception("bookmark ${bookmark.name} does not exist");
    }

    await _isar.writeTxn(() async {
      await _isar.bookmarks.delete(_bookmarks[bookmark.name]!.isarId);
      await _isar.bookmarkeds.filter().bookmarksIsEmpty().deleteAll();
    });

    _bookmarks.remove(bookmark.name);

    notifyListeners();
  }

  Future<void> renameBookmark({
    required String oldName,
    required String newName,
  }) async {
    if (_bookmarks[oldName] == null) {
      throw Exception("bookmark $oldName does not exist");
    }

    final bookmark = _bookmarks[oldName]!;
    bookmark.name = newName;

    await _isar.writeTxn(() => _isar.bookmarks.put(bookmark));

    _bookmarks.remove(oldName);
    _bookmarks[newName] = bookmark;

    notifyListeners();
  }

  // --------- Bookmarkeds Management ---------
  Future<void> addBookmark({
    required BasePlugin plugin,
    required Route route,
    required Stop stop,
    required Bookmark bookmark,
  }) async {
    if (_bookmarks[bookmark.name] == null) {
      throw Exception("bookmark ${bookmark.name} does not exist");
    }

    final bookmarked = Bookmarked(
      routeId: route.id,
      stopId: stop.id,
      pluginId: plugin.id,
    );
    _bookmarks[bookmark.name]!.bookmarkeds.add(bookmarked);

    await _isar.writeTxn(() async {
      await _isar.bookmarkeds.put(bookmarked);
      await _bookmarks[bookmark.name]!.bookmarkeds.save();
    });

    notifyListeners();
  }

  Future<void> removeBookmark({
    required BasePlugin plugin,
    required Route route,
    required Stop stop,
    required Bookmark bookmark,
  }) async {
    if (_bookmarks[bookmark.name] == null) {
      throw Exception("bookmark ${bookmark.name} does not exist");
    }

    final bookmarked = await _bookmarks[bookmark.name]!.bookmarkeds
        .filter()
        .routeIdEqualTo(route.id)
        .stopIdEqualTo(stop.id)
        .pluginIdEqualTo(plugin.id)
        .findFirst();

    if (bookmarked == null) {
      throw Exception(
        "bookmarked item not found for the given route, stop, and plugin",
      );
    }

    _bookmarks[bookmark.name]!.bookmarkeds.remove(bookmarked);

    await _isar.writeTxn(() async {
      await _bookmarks[bookmark.name]!.bookmarkeds.save();
      await _isar.bookmarkeds.filter().bookmarksIsEmpty().deleteAll();
    });

    notifyListeners();
  }

  bool isBookmarked({
    required BasePlugin plugin,
    required Route route,
    required Stop stop,
  }) {
    final bookmarks = _isar.bookmarks
        .filter()
        .bookmarkeds(
          (q) => q
              .routeIdEqualTo(route.id)
              .stopIdEqualTo(stop.id)
              .pluginIdEqualTo(plugin.id),
        )
        .findFirstSync();

    return bookmarks != null;
  }

  List<Bookmark> getBookmarks({
    required BasePlugin plugin,
    required Route route,
    required Stop stop,
  }) {
    final bookmarks = _isar.bookmarks
        .filter()
        .bookmarkeds(
          (q) => q
              .routeIdEqualTo(route.id)
              .stopIdEqualTo(stop.id)
              .pluginIdEqualTo(plugin.id),
        )
        .findAllSync();

    return bookmarks.toList();
  }
}
