import 'package:drift/drift.dart';

@DataClassName('Calving')
class Calvings extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get farmUuid => text()();
  TextColumn get livestockUuid => text()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  IntColumn get calvingTypeId => integer()();
  IntColumn get calvingProblemsId => integer().nullable()();
  IntColumn get reproductiveProblemId => integer().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
