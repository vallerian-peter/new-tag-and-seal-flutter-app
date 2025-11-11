import 'package:drift/drift.dart';

class InseminationServices extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}
