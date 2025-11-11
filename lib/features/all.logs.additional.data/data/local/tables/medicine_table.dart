import 'package:drift/drift.dart';

@DataClassName('MedicineData')
class Medicines extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get medicineTypeId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
