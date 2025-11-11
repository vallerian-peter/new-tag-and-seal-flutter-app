import 'package:drift/drift.dart';

class Diseases extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get status => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
