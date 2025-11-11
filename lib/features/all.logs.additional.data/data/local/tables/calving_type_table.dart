import 'package:drift/drift.dart';

class CalvingTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}
