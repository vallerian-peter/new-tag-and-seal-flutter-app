import 'package:drift/drift.dart';

class Transfers extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get farmUuid => text()();
  TextColumn get livestockUuid => text()();
  TextColumn get toFarmUuid => text().nullable()();
  IntColumn get transporterId => integer().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get price => text().nullable()();
  TextColumn get transferDate => text()();
  TextColumn get remarks => text().nullable()();
  TextColumn get status => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant<bool>(true))();
  TextColumn get syncAction =>
      text().withDefault(const Constant<String>('server-create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}

