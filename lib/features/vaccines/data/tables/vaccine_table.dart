import 'package:drift/drift.dart';

class Vaccines extends Table {
  IntColumn get id => integer().nullable()();

  TextColumn get uuid => text().unique()();

  TextColumn get farmUuid => text().nullable()();

  TextColumn get name => text()();

  TextColumn get lot => text().nullable()();

  TextColumn get formulationType => text().nullable()();

  TextColumn get dose => text().nullable()();

  TextColumn get status => text().nullable()();

  IntColumn get vaccineTypeId => integer().nullable()();

  TextColumn get vaccineSchedule => text().nullable()();

  BoolColumn get synced =>
      boolean().withDefault(const Constant<bool>(true))();

  TextColumn get syncAction =>
      text().withDefault(const Constant<String>('server-create'))();

  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}

