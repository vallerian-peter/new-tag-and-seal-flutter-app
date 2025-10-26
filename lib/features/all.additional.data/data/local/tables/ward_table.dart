import 'package:drift/drift.dart';
import 'district_table.dart';

@DataClassName('Ward')
class Wards extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get districtId => integer().references(Districts, #id)();  
 
  @override
  Set<Column> get primaryKey => {id};
}