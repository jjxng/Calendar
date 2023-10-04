import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'schedule.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [ Schedules ]
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(): super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Schedule>> monthSelectSchedules(String fromDate, String toDate) =>
    (select(schedules)
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(fromDate))
      ..where((tbl) => tbl.date.isSmallerOrEqualValue(toDate))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]))
      .get();

  Future<List<Schedule>> watchSchedules(String date) =>
    (select(schedules)
      ..where((tbl) => tbl.date.equals(date))
      ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
      .get();

  Future<int> createSchedule(SchedulesCompanion data) =>
    into(schedules).insert(data);

  Future<int> updateSchedule(Schedule data) {
    return (update(schedules)
      ..where((tbl) => tbl.id.equals(data.id)))
      .write(data);
  }

  Future<int> removeSchedule(int id) =>
    (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'schedule.sqlite'));
    return NativeDatabase(file);
  });

}