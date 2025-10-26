import 'package:drift/drift.dart';
import '../../../livestock_types/data/tables/livestock_type_table.dart';

@DataClassName('Breed')
class Breeds extends Table {
  IntColumn get id => integer()();  // Server-provided ID (no autoIncrement)
  TextColumn get name => text()();
  TextColumn get group => text()();
  IntColumn get livestockTypeId => integer().references(LivestockTypes, #id)();
  
  @override
  Set<Column> get primaryKey => {id};
}
