import 'package:drift/drift.dart';

@DataClassName('Specie')
class Species extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}






