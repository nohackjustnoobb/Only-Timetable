import 'package:isar/isar.dart';
import 'package:only_timetable/models/fast_hash.dart';
import 'package:only_timetable/models/bookmark.dart';

part 'bookmarked.g.dart';

@collection
class Bookmarked {
  Id get isarId => fastHash(routeId + stopId + pluginId);

  String routeId;
  String stopId;
  String pluginId;

  @Backlink(to: 'bookmarkeds')
  final bookmarks = IsarLinks<Bookmark>();

  Bookmarked({
    required this.routeId,
    required this.stopId,
    required this.pluginId,
  });
}
