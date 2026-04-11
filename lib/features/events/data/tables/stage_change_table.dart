import 'package:drift/drift.dart';

@DataClassName('StageChange')
class StageChanges extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get eventDate => text().nullable()();
  TextColumn get farmUuid => text()();
  TextColumn get livestockUuid => text()();
  IntColumn get fromStageId => integer().nullable()();
  IntColumn get toStageId => integer().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
