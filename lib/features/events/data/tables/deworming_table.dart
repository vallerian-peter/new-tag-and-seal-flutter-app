import 'package:drift/drift.dart';

@DataClassName('Deworming')
class Dewormings extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get farmUuid => text()();
  TextColumn get livestockUuid => text()();
  IntColumn get administrationRouteId => integer().nullable()();
  IntColumn get medicineId => integer().nullable()();
  TextColumn get vetId => text().nullable()();
  TextColumn get extensionOfficerId => text().nullable()();
  TextColumn get quantity => text().nullable()();
  TextColumn get dose => text().nullable()();
  TextColumn get nextAdministrationDate => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
