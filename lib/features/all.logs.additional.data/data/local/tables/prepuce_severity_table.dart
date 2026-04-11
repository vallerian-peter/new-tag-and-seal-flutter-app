import 'package:drift/drift.dart';

@DataClassName('PrepuceSeverity')
class PrepuceSeverities extends Table {
  @override
  String get tableName => 'prepuce_severities';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameSw => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
