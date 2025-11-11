import 'package:drift/drift.dart';

@DataClassName('NotificationEntry')
class NotificationEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get farmUuid => text().nullable()();
  TextColumn get farmName => text().nullable()();
  TextColumn get livestockUuid => text().nullable()();
  TextColumn get livestockName => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get scheduledAt => text()(); // ISO8601
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant<bool>(false))();
  BoolColumn get synced =>
      boolean().withDefault(const Constant<bool>(false))();
  TextColumn get syncAction =>
      text().withDefault(const Constant<String>('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}

