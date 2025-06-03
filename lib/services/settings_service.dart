import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:only_timetable/services/db_service.dart';

class SettingsService extends ChangeNotifier {
  Future<void> init(DbService dbService) async {
    isar = dbService.appIsar;
  }

  // --------- Isar Instance ---------
  Isar? _isar;
  set isar(Isar isar) => _isar = isar;

  Isar get isar {
    if (_isar == null) throw Exception("Isar instance not set");
    return _isar!;
  }
}
