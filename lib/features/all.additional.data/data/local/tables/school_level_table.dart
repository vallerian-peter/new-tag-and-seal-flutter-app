import 'package:drift/drift.dart';

@DataClassName('SchoolLevel')
class SchoolLevels extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}