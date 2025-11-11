import 'dart:developer';

import 'package:drift/drift.dart';

import '../../../../database/app_database.dart';
import '../dao/notification_dao.dart';
import '../../domain/model/notification_model.dart';
import '../../domain/repo/notification_repo.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final AppDatabase _database;

  NotificationRepository(this._database);

  NotificationDao get _dao => _database.notificationDao;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final rows = await _dao.getAll();
    return rows.map(_map).toList();
  }

  @override
  Future<List<NotificationModel>> getPendingNotifications() async {
    final rows = await _dao.getPending();
    return rows.map(_map).toList();
  }

  @override
  Future<List<NotificationModel>> getNotificationsForDate(DateTime date) async {
    final rows = await _dao.getForDate(date);
    return rows.map(_map).toList();
  }

  @override
  Future<NotificationModel> upsertNotification(NotificationModel model) async {
    final nowIso = DateTime.now().toIso8601String();

    try {
      if (model.id != null) {
        final updated = model.copyWith(
          synced: false,
          syncAction: 'update',
          updatedAt: nowIso,
        );
        await _dao.updateNotification(
          _toCompanion(updated, includeId: true),
        );
        final entry = await _dao.getById(updated.id!);
        if (entry == null) {
          throw StateError('Notification ${updated.id} not found after update');
        }
        return _map(entry);
      } else {
        final created = model.copyWith(
          synced: false,
          syncAction: 'create',
          createdAt: nowIso,
          updatedAt: nowIso,
        );
        final insertedId = await _dao.insertNotification(
          _toCompanion(created),
        );
        final entry = await _dao.getById(insertedId);
        if (entry == null) {
          throw StateError('Notification $insertedId not found after insert');
        }
        return _map(entry);
      }
    } catch (e, stackTrace) {
      log('❌ Failed to upsert notification: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> markCompleted(int id) => _dao.markCompleted(id);

  @override
  Future<void> deleteNotification(int id) => _dao.deleteById(id);

  Future<NotificationModel?> findByTitleAndTime(
    String title,
    String scheduledAt,
    {String? farmUuid, String? livestockUuid}
  ) async {
    final entry = await _dao.findByAttributes(
      title: title,
      scheduledAt: scheduledAt,
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return entry != null ? _map(entry) : null;
  }

  NotificationEntriesCompanion _toCompanion(
    NotificationModel model, {
    bool includeId = false,
  }) {
    return NotificationEntriesCompanion(
      id: includeId && model.id != null
          ? Value(model.id!)
          : const Value.absent(),
      farmUuid:
          model.farmUuid != null ? Value(model.farmUuid!) : const Value.absent(),
      farmName:
          model.farmName != null ? Value(model.farmName!) : const Value.absent(),
      livestockUuid: model.livestockUuid != null
          ? Value(model.livestockUuid!)
          : const Value.absent(),
      livestockName: model.livestockName != null
          ? Value(model.livestockName!)
          : const Value.absent(),
      title: Value(model.title),
      description: model.description != null
          ? Value(model.description!)
          : const Value.absent(),
      scheduledAt: Value(model.scheduledAt),
      isCompleted: Value(model.isCompleted),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  NotificationModel _map(NotificationEntry entry) {
    return NotificationModel(
      id: entry.id,
      farmUuid: entry.farmUuid,
      farmName: entry.farmName,
      livestockUuid: entry.livestockUuid,
      livestockName: entry.livestockName,
      title: entry.title,
      description: entry.description,
      scheduledAt: entry.scheduledAt,
      isCompleted: entry.isCompleted,
      synced: entry.synced,
      syncAction: entry.syncAction,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }
}

