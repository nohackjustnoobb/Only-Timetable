import 'package:isar/isar.dart';

import 'fast_hash.dart';

part 'kv_pair.g.dart';

@collection
class KvPair {
  KvPair({required this.key, required this.value});

  Id get isarId => fastHash(key);

  /// Unique key for the key-value pair.
  @Index(unique: true)
  final String key;

  /// Value associated with the key.
  final String value;
}
