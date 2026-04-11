import 'package:drift/drift.dart';

/// Production stages per livestock type (e.g. piglet / weaner / grower / finisher).
@DataClassName('Stage')
class Stages extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get livestockTypeId => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
