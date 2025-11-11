import 'package:drift/drift.dart';

@DataClassName('Feeding')
class Feedings extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  IntColumn get feedingTypeId => integer()();
  TextColumn get farmUuid => text()();
  TextColumn get livestockUuid => text()();
  TextColumn get nextFeedingTime => text()();
  TextColumn get amount => text()();
  TextColumn get remarks => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
