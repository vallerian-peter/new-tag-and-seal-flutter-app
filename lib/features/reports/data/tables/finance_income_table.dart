import 'package:drift/drift.dart';

class FinanceIncomes extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get sourceType => text().nullable()();
  TextColumn get sourceUuid => text().nullable()();
  TextColumn get farmUuid => text().nullable()();
  IntColumn get farmerId => integer().nullable()();
  TextColumn get referenceNo => text().nullable()();
  TextColumn get subjectType => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant<int>(1))();
  TextColumn get unitAmount =>
      text().withDefault(const Constant<String>('0'))();
  TextColumn get totalAmount =>
      text().withDefault(const Constant<String>('0'))();
  TextColumn get status =>
      text().withDefault(const Constant<String>('pending'))();
  TextColumn get notes => text().nullable()();
  TextColumn get incomeDate => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(true))();
  TextColumn get syncAction =>
      text().withDefault(const Constant<String>('server-create'))();

  @override
  Set<Column> get primaryKey => {uuid};
}
