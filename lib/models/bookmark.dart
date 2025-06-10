import 'package:isar/isar.dart';
import 'package:only_timetable/models/fast_hash.dart';
import 'package:only_timetable/models/bookmarked.dart';

part 'bookmark.g.dart';

@collection
class Bookmark {
  Id get isarId => fastHash(name);

  String name;

  final bookmarkeds = IsarLinks<Bookmarked>();

  Bookmark({required this.name});
}
