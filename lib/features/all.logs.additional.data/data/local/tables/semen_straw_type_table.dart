import 'package:drift/drift.dart';

class SemenStrawTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
