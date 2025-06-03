import 'package:isar/isar.dart';
import 'package:only_timetable/services/plugin/base_plugin.dart';

abstract class Handler<T1 extends BasePlugin> {
  String get id;
  List<CollectionSchema> get schemas;

  Future<List<T1>> loadPlugins();
  Future<void> initPlugin<T2 extends BasePlugin>(T2 plugin) async {}
  Future<void> savePlugin<T2 extends BasePlugin>(List<T2> plugins);
  Future<void> deletePlugin<T2 extends BasePlugin>(T2 plugin);

  // --------- Isar Instance ---------
  Isar? _isar;
  set isar(Isar isar) => _isar = isar;

  Isar get isar {
    if (_isar == null) throw Exception("Isar instance not set");
    return _isar!;
  }
}
