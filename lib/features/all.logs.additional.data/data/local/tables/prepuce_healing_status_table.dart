import 'package:drift/drift.dart';

@DataClassName('PrepuceHealingStatus')
class PrepuceHealingStatuses extends Table {
  @override
  String get tableName => 'prepuce_healing_statuses';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameSw => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
