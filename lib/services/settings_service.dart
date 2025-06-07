import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:only_timetable/models/kv_pair.dart';
import 'package:only_timetable/services/db_service.dart';

enum SettingsKey { alwaysUseOSM }

const Map<SettingsKey, dynamic> defaultValue = {
  SettingsKey.alwaysUseOSM: false,
};

class SettingsService extends ChangeNotifier {
  // --------- Isar Instance ---------
  Isar? _isar;
  set isar(Isar isar) => _isar = isar;

  Isar get isar {
    if (_isar == null) throw Exception("Isar instance not set");
    return _isar!;
  }

  // --------- Methods ---------
  Future<void> init(DbService dbService) async {
    isar = dbService.appIsar;
  }

  T _parseValue<T>(String value) {
    if (T == String) return value as T;

    if (T == int) return int.parse(value) as T;

    if (T == double) return double.parse(value) as T;

    if (T == bool) return bool.parse(value) as T;

    throw ArgumentError(
      'Unsupported type: ${value.runtimeType}. Only String, int, double, and bool are allowed.',
    );
  }

  /// Retrieves a value of type [T] associated with the given [key] synchronously.
  ///
  /// Returns the value if it exists, or `null` if the key is not found or the value cannot be cast to type [T].
  ///
  /// [key]: The key for which to retrieve the value.
  ///
  /// Returns: The value of type [T], or `null` if not found or type mismatch.
  T getSync<T>(SettingsKey key) {
    final value =
        isar.kvPairs.getByKeySync(key.name)?.value ??
        defaultValue[key].toString();

    return _parseValue<T>(value);
  }

  /// Retrieves a value of type [T] associated with the given [key] from the settings storage.
  ///
  /// Returns a [Future] that completes with the value if it exists, or `null` if the key is not found.
  ///
  /// [T] is the expected type of the value to be returned.
  ///
  /// Example:
  /// ```dart
  /// final username = await settingsService.get<String>('username');
  /// ```
  Future<T> get<T>(SettingsKey key) async {
    final value =
        (await isar.kvPairs.getByKey(key.name))?.value ??
        defaultValue[key].toString();

    return _parseValue<T>(value);
  }

  /// Asynchronously sets a value of type [T] for the given [key] in the settings storage.
  ///
  /// The [key] parameter specifies the identifier for the setting.
  /// The [value] parameter is the value to be stored, which can be of any type [T].
  ///
  /// Throws an exception if the operation fails.
  Future<void> set<T>(SettingsKey key, T value) async {
    if (value is! String &&
        value is! int &&
        value is! double &&
        value is! bool) {
      throw ArgumentError(
        'Unsupported type: ${value.runtimeType}. Only String, int, double, and bool are allowed.',
      );
    }

    final stringifiedValue = value.toString();

    await isar.writeTxn(() async {
      await isar.kvPairs.put(KvPair(key: key.name, value: stringifiedValue));
    });

    notifyListeners();
  }
}
