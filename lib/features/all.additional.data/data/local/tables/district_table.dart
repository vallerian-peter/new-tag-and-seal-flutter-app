import 'package:drift/drift.dart';
import 'region_table.dart';

@DataClassName('District')
class Districts extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get regionId => integer().references(Regions, #id)();

  @override
  Set<Column> get primaryKey => {id};
}