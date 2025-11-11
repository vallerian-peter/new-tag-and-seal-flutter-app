import 'package:drift/drift.dart';

@DataClassName('MedicineTypeData')
class MedicineTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
