import 'package:drift/drift.dart';

class BirthProblems extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get livestockTypeId => integer().nullable()(); // NEW: nullable for generic problems

  @override
  Set<Column> get primaryKey => {id};
}

