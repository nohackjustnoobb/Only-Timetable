import 'package:isar/isar.dart';

import 'fast_hash.dart';
import 'stop.dart';

part 'route.g.dart';

@collection
class Route {
  // --------- Fields ---------

  Id get isarId => fastHash(id);

  /// Unique identifier for the route.
  @Index(unique: true)
  final String id;

  /// Optional display identifier for the route, which can be used for user-friendly display.
  final String? displayId;

  /// Should be a json-encoded Object which keys are the language codes and values are the sources in that language.
  ///
  /// For example: {"en": "Main Street", "fr": "Rue Principale"}
  ///
  /// Fallback to the "en" key if no other language is available.
  final String? source;

  /// The searchable name associated with this route.
  ///
  /// This is used only for searching and will not be displayed.
  /// Usually, it will be the name of the origin plus the name of the destination.
  final String? name;

  /// Additional metadata for the route, such as description or other information.
  final String? meta;

  /// Id of the destination stop
  final String? dest;

  /// Id of the origin stop
  final String? orig;

  /// Links to the stops associated with this route.
  final stops = IsarLinks<Stop>();

  // --------- Constructor ---------

  Route({
    required this.id,
    this.displayId,
    this.source,
    this.name,
    this.dest,
    this.orig,
    this.meta,
  }) : _stopsId = [];

  late final List<String> _stopsId;
  Route.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      displayId = json['displayId'] as String?,
      source = json['source'] as String?,
      name = json['name'] as String?,
      dest = json['dest'] as String?,
      orig = json['orig'] as String?,
      meta = json['meta'] as String?,
      _stopsId =
          (json['stops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

  // --------- Helper Methods ---------
  Future<void> fetchStops(Isar isar) async {
    if (_stopsId.isEmpty) return;

    final stopsLinks = await isar.stops.getAll(
      _stopsId.map((e) => fastHash(e)).toList(),
    );

    stops.addAll(stopsLinks.whereType<Stop>().toList());
  }

  Future<dynamic> toJson() async {
    return {
      'id': id,
      'displayId': displayId,
      'source': source,
      'name': name,
      'dest': dest,
      'orig': orig,
      'meta': meta,
      'stops': stops.map((stop) => stop.id).toList(),
    };
  }
}
