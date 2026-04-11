import 'package:drift/drift.dart';

@DataClassName('PrepuceCauseRisk')
class PrepuceCauseRisks extends Table {
  @override
  String get tableName => 'prepuce_cause_risks';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameSw => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
