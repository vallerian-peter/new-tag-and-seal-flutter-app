import 'package:drift/drift.dart';

class BirthTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get livestockTypeId => integer().nullable()(); // NEW: nullable for generic types

  @override
  Set<Column> get primaryKey => {id};
}

