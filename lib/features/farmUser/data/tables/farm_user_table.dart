import 'package:drift/drift.dart';

class FarmUsers extends Table {
  IntColumn get id => integer().nullable()();

  TextColumn get uuid => text()();

  TextColumn get farmUuid => text()();

  TextColumn get firstName => text()();

  TextColumn get middleName => text().nullable()();

  TextColumn get lastName => text()();

  TextColumn get phone => text().nullable()();

  TextColumn get email => text()();

  TextColumn get roleTitle => text()();

  TextColumn get gender => text()();

  BoolColumn get synced =>
      boolean().withDefault(const Constant<bool>(true))();

  TextColumn get syncAction =>
      text().withDefault(const Constant<String>('server-create'))();

  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}


