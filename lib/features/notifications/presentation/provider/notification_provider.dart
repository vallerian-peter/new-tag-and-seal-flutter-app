import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'package:new_tag_and_seal_flutter_app/core/alarm/app_alarm_manager.dart';

import '../../domain/model/notification_model.dart';
import '../../domain/repo/notification_repo.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepositoryInterface _repository;
  final AppAlarmManager _alarmManager;

  NotificationProvider({
    required NotificationRepositoryInterface repository,
    required AppAlarmManager alarmManager,
  })  : _repository = repository,
        _alarmManager = alarmManager;

  List<NotificationModel> _notifications = const [];
  bool _loading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _loading;
  String? get error => _error;

  NotificationModel? getNotificationById(int id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadNotifications() async {
    _loading = true;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
      await _alarmManager.initialize();
      await _alarmManager.syncAlarms(_notifications);
      _error = null;
    } catch (e, stackTrace) {
      log('❌ Failed to load notifications: $e', stackTrace: stackTrace);
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<NotificationModel> saveNotification(NotificationModel model) async {
    try {
      final saved = await _repository.upsertNotification(model);
      await loadNotifications();
      return saved;
    } catch (e, stackTrace) {
      log('❌ Failed to save notification: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> markCompleted(int id) async {
    try {
      await _repository.markCompleted(id);
      await _alarmManager.cancelAlarm(id);
      await loadNotifications();
    } catch (e, stackTrace) {
      log('❌ Failed to mark notification complete: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _repository.deleteNotification(id);
      await _alarmManager.cancelAlarm(id);
      await loadNotifications();
    } catch (e, stackTrace) {
      log('❌ Failed to delete notification: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> rescheduleRecurring(NotificationModel model) async {
    try {
      final next = _nextDailyOccurrence(model);
      final updated = model.copyWith(
        scheduledAt: next.toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        synced: false,
        syncAction: 'update',
        isCompleted: false,
      );
      await _repository.upsertNotification(updated);
      await loadNotifications();
    } catch (e, stackTrace) {
      log('❌ Failed to reschedule recurring notification: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  DateTime _nextDailyOccurrence(NotificationModel model) {
    DateTime next = DateTime.parse(model.scheduledAt).toLocal();
    final now = DateTime.now();
    while (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }
}

