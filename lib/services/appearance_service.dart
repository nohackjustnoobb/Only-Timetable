import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:only_timetable/models/kv_pair.dart';
import 'package:only_timetable/services/db_service.dart';

// ignore: constant_identifier_names
const DEAFULT_PRIMARY_COLOR = Color(0xFF6E7FDF);

class AppearanceService extends ChangeNotifier {
  late final Isar _isar;

  Locale? _locale;
  Locale? get locale => _locale;

  Color _primaryColor = DEAFULT_PRIMARY_COLOR;
  Color get primaryColor => _primaryColor;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> init(DbService dbservice) async {
    _isar = dbservice.appIsar;

    final localeCode = await _isar.kvPairs.getByKey('locale');
    if (localeCode != null) {
      final localeParts = localeCode.value.split('_');
      final languageCode = localeParts.first;
      final countryCode = localeParts.length > 1 ? localeParts.last : null;

      _locale = Locale(languageCode, countryCode);
    }

    final primaryColorCode = await _isar.kvPairs.getByKey('primaryColor');
    if (primaryColorCode != null) {
      _primaryColor = Color(int.parse(primaryColorCode.value));
    }

    final themeModeCode = await _isar.kvPairs.getByKey('themeMode');
    if (themeModeCode != null) {
      switch (themeModeCode.value) {
        case 'ThemeMode.light':
          _themeMode = ThemeMode.light;
          break;
        case 'ThemeMode.dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'ThemeMode.system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      _locale = null;

      await _isar.writeTxn(() async {
        await _isar.kvPairs.deleteByKey('locale');
      });

      notifyListeners();
      return;
    }

    _locale = locale;
    final localeCode =
        '${locale.languageCode}${locale.countryCode != null ? '_${locale.countryCode}' : ''}';

    await _isar.writeTxn(() async {
      await _isar.kvPairs.put(KvPair(key: 'locale', value: localeCode));
    });

    notifyListeners();
  }

  Future<void> setPrimaryColor(Color? color) async {
    if (color == null) {
      _primaryColor = DEAFULT_PRIMARY_COLOR;

      await _isar.writeTxn(() async {
        await _isar.kvPairs.deleteByKey('primaryColor');
      });

      notifyListeners();
      return;
    }

    _primaryColor = color;

    await _isar.writeTxn(() async {
      await _isar.kvPairs.put(
        KvPair(key: 'primaryColor', value: color.toARGB32().toString()),
      );
    });

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    await _isar.writeTxn(() async {
      await _isar.kvPairs.put(KvPair(key: 'themeMode', value: mode.toString()));
    });

    notifyListeners();
  }
}
