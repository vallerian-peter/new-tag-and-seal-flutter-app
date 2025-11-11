import 'package:drift/drift.dart';

class Breeds extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get group => text()();
  IntColumn get livestockTypeId => integer()();

  @override
  Set<Column> get primaryKey => {id};
}






