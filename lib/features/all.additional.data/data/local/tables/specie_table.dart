import 'package:drift/drift.dart';

@DataClassName('Specie')
class Species extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  // Optional link to livestock type (e.g. Cattle, Swine, Goat)
  IntColumn get livestockTypeId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}






