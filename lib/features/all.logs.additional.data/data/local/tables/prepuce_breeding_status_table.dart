import 'package:drift/drift.dart';

@DataClassName('PrepuceBreedingStatus')
class PrepuceBreedingStatuses extends Table {
  @override
  String get tableName => 'prepuce_breeding_statuses';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameSw => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
