import 'package:drift/drift.dart';

class FinanceExpenses extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get sourceType =>
      text().withDefault(const Constant<String>('bill'))();
  TextColumn get sourceUuid => text()();
  TextColumn get farmUuid => text().nullable()();
  IntColumn get farmerId => integer().nullable()();
  TextColumn get billNo => text().nullable()();
  TextColumn get subjectType => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant<int>(1))();
  TextColumn get unitCost => text().withDefault(const Constant<String>('0'))();
  TextColumn get totalCost => text().withDefault(const Constant<String>('0'))();
  TextColumn get status =>
      text().withDefault(const Constant<String>('pending'))();
  TextColumn get notes => text().nullable()();
  TextColumn get expenseDate => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(true))();
  /// Outgoing (unsynced): [create], [update], [deleted]. Server / derived rows: [server-create], [server-update].
  TextColumn get syncAction =>
      text().withDefault(const Constant<String>('server-create'))();

  @override
  Set<Column> get primaryKey => {uuid};
}
