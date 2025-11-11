import 'package:drift/drift.dart';

@DataClassName('Pregnancy')
class Pregnancies extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get farmUuid => text()();
  TextColumn get livestockUuid => text()();
  IntColumn get testResultId => integer()();
  TextColumn get noOfMonths => text().nullable()();
  TextColumn get testDate => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get remarks => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
