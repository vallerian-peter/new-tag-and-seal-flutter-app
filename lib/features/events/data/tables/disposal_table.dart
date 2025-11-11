import 'package:drift/drift.dart';

class Disposals extends Table {
  IntColumn get id => integer().nullable()();

  TextColumn get uuid => text()();

  TextColumn get farmUuid => text()();

  TextColumn get livestockUuid => text()();

  IntColumn get disposalTypeId => integer().nullable()();

  TextColumn get reasons => text()();

  TextColumn get remarks => text().nullable()();

  TextColumn get status =>
      text().withDefault(const Constant<String>('completed'))();

  BoolColumn get synced => boolean().withDefault(const Constant<bool>(true))();

  TextColumn get syncAction =>
      text().withDefault(const Constant<String>('server-create'))();

  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
