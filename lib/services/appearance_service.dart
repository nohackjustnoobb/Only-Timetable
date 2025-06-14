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

  /// Sets the application's locale to the specified [locale].
  ///
  /// This method updates the locale used throughout the application.
  /// If [locale] is `null`, the default locale will be used.
  ///
  /// [locale]: The new locale to set, or `null` to reset to the default locale.
  ///
  /// Returns a [Future] that completes when the locale has been set.
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

  /// Sets the primary color for the application.
  ///
  /// This method allows updating the primary color used in the application's
  /// appearance settings. The provided [color] can be null, in which case
  /// the primary color will be reset or left unchanged depending on the implementation.
  ///
  /// [color]: The new primary color to set, or null to reset.
  ///
  /// Returns a [Future] that completes when the operation is finished.
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

  /// Sets the application's theme mode.
  ///
  /// This method allows you to change the theme mode of the application
  /// to the specified [mode]. The [mode] can be one of the following:
  /// - [ThemeMode.system]: Uses the system's theme setting.
  /// - [ThemeMode.light]: Forces the application to use the light theme.
  /// - [ThemeMode.dark]: Forces the application to use the dark theme.
  ///
  /// This operation is asynchronous and may involve saving the theme mode
  /// to persistent storage or applying it to the app's appearance.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    await _isar.writeTxn(() async {
      await _isar.kvPairs.put(KvPair(key: 'themeMode', value: mode.toString()));
    });

    notifyListeners();
  }
}
