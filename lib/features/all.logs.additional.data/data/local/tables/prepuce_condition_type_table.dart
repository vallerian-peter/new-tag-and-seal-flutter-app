import 'package:drift/drift.dart';

@DataClassName('PrepuceConditionType')
class PrepuceConditionTypes extends Table {
  @override
  String get tableName => 'prepuce_condition_types';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameSw => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
