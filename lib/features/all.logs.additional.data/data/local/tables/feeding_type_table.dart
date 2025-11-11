import 'package:drift/drift.dart';

@DataClassName('FeedingType')
class FeedingTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}
