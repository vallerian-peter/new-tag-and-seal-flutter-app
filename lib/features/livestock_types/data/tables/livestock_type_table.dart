import 'package:drift/drift.dart';

@DataClassName('LivestockType')
class LivestockTypes extends Table {
  IntColumn get id => integer()();  // Server-provided ID (no autoIncrement)
  TextColumn get name => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}
