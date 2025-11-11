import 'package:drift/drift.dart';

import '../../../../database/app_database.dart';
import '../tables/notification_table.dart';

part 'notification_dao.g.dart';

@DriftAccessor(tables: [NotificationEntries])
class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(AppDatabase db) : super(db);

  Future<List<NotificationEntry>> getAll() => select(notificationEntries).get();

  Future<List<NotificationEntry>> getPending() => (select(notificationEntries)
        ..where(
          (tbl) =>
              tbl.isCompleted.equals(false) &
              tbl.syncAction.isNotIn(['deleted']),
        ))
      .get();

  Future<List<NotificationEntry>> getForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(notificationEntries)
          ..where(
            (tbl) => tbl.scheduledAt.isBetweenValues(
              start.toIso8601String(),
              end.toIso8601String(),
            ),
          ))
        .get();
  }

  Future<int> insertNotification(NotificationEntriesCompanion entry) =>
      into(notificationEntries).insert(entry);

  Future<int> updateNotification(NotificationEntriesCompanion entry) {
    assert(entry.id.present, 'Update requires an id');
    return (update(notificationEntries)
          ..where((tbl) => tbl.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<NotificationEntry?> getById(int id) {
    return (select(notificationEntries)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> markCompleted(int id) async {
    await (update(notificationEntries)..where((tbl) => tbl.id.equals(id))).write(
      NotificationEntriesCompanion(
        isCompleted: const Value(true),
        syncAction: const Value('update'),
        synced: const Value(false),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> deleteById(int id) async {
    await (delete(notificationEntries)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<NotificationEntry?> findByAttributes({
    required String title,
    required String scheduledAt,
    String? farmUuid,
    String? livestockUuid,
  }) {
    final query = select(notificationEntries)
      ..where((tbl) => tbl.title.equals(title))
      ..where((tbl) => tbl.scheduledAt.equals(scheduledAt));

    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    } else {
      query.where((tbl) => tbl.farmUuid.isNull());
    }

    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    } else {
      query.where((tbl) => tbl.livestockUuid.isNull());
    }

    return query.getSingleOrNull();
  }
}

