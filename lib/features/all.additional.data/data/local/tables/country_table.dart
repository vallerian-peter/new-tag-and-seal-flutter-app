import 'package:drift/drift.dart';

@DataClassName('Country')
class Countries extends Table {
  IntColumn get id => integer()();

  // Basic identity
  TextColumn get name => text()();
  TextColumn get shortName => text()();

  @override
  Set<Column> get primaryKey => {id};
}