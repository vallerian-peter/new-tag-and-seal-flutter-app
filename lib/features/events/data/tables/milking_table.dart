import 'package:drift/drift.dart';

@DataClassName('Milking')
class Milkings extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get farmUuid => text().nullable()();
  TextColumn get livestockUuid => text()();
  IntColumn get milkingMethodId => integer().nullable()();
  TextColumn get amount => text()();
  TextColumn get lactometerReading => text()();
  TextColumn get solid => text()();
  TextColumn get solidNonFat => text()();
  TextColumn get protein => text()();
  TextColumn get correctedLactometerReading => text()();
  TextColumn get totalSolids => text()();
  TextColumn get colonyFormingUnits => text()();
  TextColumn get acidity => text().nullable()();
  TextColumn get session => text().withDefault(const Constant('morning'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
