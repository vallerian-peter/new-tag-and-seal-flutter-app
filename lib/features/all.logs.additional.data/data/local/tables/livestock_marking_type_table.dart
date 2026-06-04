import 'package:drift/drift.dart';

class LivestockMarkingTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}
