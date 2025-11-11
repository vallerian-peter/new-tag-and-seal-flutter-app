import 'package:drift/drift.dart';

class Vaccinations extends Table {
  IntColumn get id => integer().nullable()();

  TextColumn get uuid => text()();

  TextColumn get vaccinationNo => text().nullable()();

  TextColumn get farmUuid => text()();

  TextColumn get livestockUuid => text()();

  IntColumn get vaccineId => integer().nullable()();

  IntColumn get diseaseId => integer().nullable()();

  TextColumn get vetId => text().nullable()();

  TextColumn get extensionOfficerId => text().nullable()();

  TextColumn get status =>
      text().withDefault(const Constant<String>('completed'))();

  BoolColumn get synced => boolean().withDefault(const Constant<bool>(true))();

  TextColumn get syncAction =>
      text().withDefault(const Constant<String>('server-create'))();

  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
