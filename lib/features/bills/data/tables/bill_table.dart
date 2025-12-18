import 'package:drift/drift.dart';

class Bills extends Table {
  IntColumn get id => integer().nullable()();

  TextColumn get uuid => text()();

  TextColumn get billNo => text().nullable()();

  TextColumn get farmUuid => text().nullable()();

  IntColumn get extensionOfficerId => integer().nullable()();

  IntColumn get farmerId => integer().nullable()();

  TextColumn get subjectType => text().nullable()();

  TextColumn get subjectUuid => text().nullable()();

  IntColumn get quantity => integer().withDefault(const Constant<int>(1))();

  TextColumn get amount => text()();

  TextColumn get status => text().withDefault(const Constant<String>('pending'))();

  TextColumn get notes => text().nullable()();

  BoolColumn get synced => boolean().withDefault(const Constant<bool>(true))();

  TextColumn get syncAction => text().withDefault(const Constant<String>('server-create'))();

  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
