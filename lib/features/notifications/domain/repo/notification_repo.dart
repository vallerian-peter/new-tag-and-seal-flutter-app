import '../model/notification_model.dart';

abstract class NotificationRepositoryInterface {
  Future<List<NotificationModel>> getNotifications();
  Future<List<NotificationModel>> getPendingNotifications();
  Future<List<NotificationModel>> getNotificationsForDate(DateTime date);
  Future<NotificationModel> upsertNotification(NotificationModel model);
  Future<void> markCompleted(int id);
  Future<void> deleteNotification(int id);
}

