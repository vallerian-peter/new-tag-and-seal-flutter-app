import 'package:drift/drift.dart';

@DataClassName('Dryoff')
class Dryoffs extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get farmUuid => text()();
  TextColumn get livestockUuid => text()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get remarks => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
