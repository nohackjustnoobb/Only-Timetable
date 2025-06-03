import 'package:isar/isar.dart';

import 'fast_hash.dart';
import 'route.dart';

part 'stop.g.dart';

@collection
class Stop {
  // --------- Fields ---------

  Id get isarId => fastHash(id);

  /// Unique identifier for the stop.
  @Index(unique: true)
  final String id;

  /// Should be a json-encoded Object which keys are the language codes and values are the names in that language.
  ///
  /// For example: {"en": "Main Street", "fr": "Rue Principale"}
  ///
  /// Fallback to the "en" key if no other language is available.
  final String? name;

  /// Latitude of the stop.
  final double? lat;

  /// Longitude of the stop.
  final double? long;

  /// Additional metadata for the stop, such as description or other information.
  final String? meta;

  /// Links to the routes associated with this stop.
  @Backlink(to: 'stops')
  final routes = IsarLinks<Route>();

  // --------- Constructor ---------

  Stop({required this.id, this.name, this.lat, this.long, this.meta});

  Stop.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String?,
      lat = (json['lat'] as num?)?.toDouble(),
      long = (json['long'] as num?)?.toDouble(),
      meta = json['meta'] as String?;

  // --------- Helper Methods ---------
  Future<dynamic> toJson() async {
    return {'id': id, 'name': name, 'lat': lat, 'long': long, 'meta': meta};
  }
}
