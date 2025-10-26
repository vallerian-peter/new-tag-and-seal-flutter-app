import 'package:drift/drift.dart';
import 'ward_table.dart';

@DataClassName('Street')
class Streets extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get wardId => integer().references(Wards, #id)();
 
  @override
  Set<Column> get primaryKey => {id};
}