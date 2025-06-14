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

  /// Retrieves a bookmark by its name.
  ///
  /// This method looks up a bookmark in the internal collection using the
  /// provided name as the key. If a bookmark with the specified name exists,
  /// it is returned; otherwise, `null` is returned.
  ///
  /// - Parameter name: The name of the bookmark to retrieve.
  /// - Returns: The `Bookmark` object associated with the given name, or `null`
  ///   if no bookmark with that name exists.
  Bookmark? getBookmark(String name) => _bookmarks[name];

  /// Creates a new bookmark.
  ///
  /// This method takes a [Bookmark] object and saves it asynchronously.
  /// It does not return any value upon completion.
  ///
  /// Throws:
  /// - [Exception] if the bookmark creation fails.
  ///
  /// Parameters:
  /// - [bookmark]: The bookmark object to be created.
  Future<void> createBookmark(Bookmark bookmark) async {
    if (_bookmarks[bookmark.name] != null) {
      throw Exception("bookmark ${bookmark.name} already exists");
    }

    await _isar.writeTxn(() => _isar.bookmarks.put(bookmark));

    _bookmarks[bookmark.name] = bookmark;

    notifyListeners();
  }

  /// Deletes the specified bookmark from the storage.
  ///
  /// This method removes the given [bookmark] from the list of saved bookmarks.
  /// It performs the operation asynchronously and does not return any value.
  ///
  /// - Parameter [bookmark]: The bookmark object to be deleted.
  ///
  /// Throws:
  /// - An exception if the deletion process encounters an error.
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

  /// Renames an existing bookmark.
  ///
  /// This method allows you to update the name of a bookmark.
  ///
  /// Parameters:
  /// - `bookmarkId`: The unique identifier of the bookmark to be renamed.
  /// - `newName`: The new name to assign to the bookmark.
  ///
  /// Returns:
  /// A `Future<void>` indicating the completion of the operation.
  ///
  /// Throws:
  /// - `BookmarkNotFoundException` if the bookmark with the given ID does not exist.
  /// - `InvalidNameException` if the new name is invalid or empty.
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
  /// Adds an item to a bookmark.
  ///
  /// This method allows you to associate a route, stop, and plugin with a specific bookmark.
  ///
  /// Parameters:
  /// - `plugin`: The plugin associated with the bookmarked item.
  /// - `route`: The route to be bookmarked.
  /// - `stop`: The stop to be bookmarked.
  /// - `bookmark`: The bookmark to which the item will be added.
  ///
  /// Throws:
  /// - `Exception` if the specified bookmark does not exist.
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

  /// Removes a bookmarked item from a specific bookmark.
  ///
  /// This method removes the association of a route, stop, and plugin from the specified bookmark.
  ///
  /// Parameters:
  /// - `plugin`: The plugin associated with the bookmarked item.
  /// - `route`: The route to be removed from the bookmark.
  /// - `stop`: The stop to be removed from the bookmark.
  /// - `bookmark`: The bookmark from which the item will be removed.
  ///
  /// Throws:
  /// - `Exception` if the specified bookmark does not exist or the item is not found.
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

  /// Checks if a specific item is bookmarked.
  ///
  /// This method determines whether the given item is marked as a bookmark.
  ///
  /// Returns `true` if the item is bookmarked, otherwise `false`.
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

  /// Retrieves a list of bookmarks that a specific item belongs to.
  ///
  /// This method returns a list of `Bookmark` objects associated with the given
  /// route, stop, and plugin. It helps identify which bookmarks contain the specified item.
  ///
  /// Parameters:
  /// - `plugin`: The plugin associated with the item.
  /// - `route`: The route of the item.
  /// - `stop`: The stop of the item.
  ///
  /// Returns:
  ///   A list of `Bookmark` objects containing the specified item.
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
