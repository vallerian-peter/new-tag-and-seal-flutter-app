import 'package:drift/drift.dart';

@DataClassName('Insemination')
class Inseminations extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get farmUuid => text().nullable()();
  TextColumn get livestockUuid => text()();
  TextColumn get lastHeatDate => text().nullable()();
  IntColumn get currentHeatTypeId => integer()();
  IntColumn get inseminationServiceId => integer()();
  IntColumn get semenStrawTypeId => integer()();
  TextColumn get inseminationDate => text().nullable()();
  TextColumn get bullCode => text().nullable()();
  TextColumn get bullBreed => text().nullable()();
  TextColumn get semenProductionDate => text().nullable()();
  TextColumn get productionCountry => text().nullable()();
  TextColumn get semenBatchNumber => text().nullable()();
  TextColumn get internationalId => text().nullable()();
  TextColumn get aiCode => text().nullable()();
  TextColumn get manufacturerName => text().nullable()();
  TextColumn get semenSupplier => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
