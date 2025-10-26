import 'package:drift/drift.dart';
import 'country_table.dart';

@DataClassName('Region')
class Regions extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()(); 
  IntColumn get countryId => integer().references(Countries, #id)();
  
  @override
  Set<Column> get primaryKey => {id};
} 