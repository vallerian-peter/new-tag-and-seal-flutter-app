import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../domain/model/notification_model.dart';
import '../../domain/repo/notification_repo.dart';
import '../../data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepositoryInterface _repository;
  final NotificationService _notificationService;

  NotificationProvider({
    required NotificationRepositoryInterface repository,
    required NotificationService notificationService,
  })  : _repository = repository,
        _notificationService = notificationService;

  List<NotificationModel> _notifications = const [];
  bool _loading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadNotifications() async {
    _loading = true;
    notifyListeners();

    try {
      await _notificationService.initialize();
      _notifications = await _repository.getNotifications();
      await _notificationService.syncScheduledNotifications(_notifications);
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
      await _notificationService.cancelNotification(id);
      await loadNotifications();
    } catch (e, stackTrace) {
      log('❌ Failed to mark notification complete: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _repository.deleteNotification(id);
      await _notificationService.cancelNotification(id);
      await loadNotifications();
    } catch (e, stackTrace) {
      log('❌ Failed to delete notification: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}

