import 'package:drift/drift.dart';
import 'ward_table.dart';

@DataClassName('Village')
class Villages extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get wardId => integer().references(Wards, #id)();
 
  @override
  Set<Column> get primaryKey => {id};
}

