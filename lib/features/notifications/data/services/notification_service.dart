import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/model/notification_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _timezoneInitialized = false;
  bool _channelInitialized = false;

  NotificationService();

  Future<void> initialize() async {
    if (_initialized) return;
    await _initializeTimezone();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notificationsPlugin.initialize(initializationSettings);
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await _ensureAndroidPermissions();
    await _ensureNotificationChannel();
    _initialized = true;
  }

  Future<void> scheduleNotification(NotificationModel model) async {
    if (model.id == null) return;
    final scheduledAt = DateTime.tryParse(model.scheduledAt);
    if (scheduledAt == null || scheduledAt.isBefore(DateTime.now())) return;

    await initialize();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'ndoto_reminders_channel',
        'Reminders',
        channelDescription: 'Reminders for upcoming farm and livestock events',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      ),
    );

    final tzScheduled =
        tz.TZDateTime.from(scheduledAt, tz.local);

    await _notificationsPlugin.zonedSchedule(
      model.id!,
      model.title,
      model.description,
      tzScheduled,
      details,
      androidAllowWhileIdle: true,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await initialize();
    await _notificationsPlugin.cancel(id);
  }

  Future<void> syncScheduledNotifications(
    List<NotificationModel> notifications,
  ) async {
    await initialize();
    await _notificationsPlugin.cancelAll();
    for (final notification in notifications) {
      if (notification.isCompleted) continue;
      await scheduleNotification(notification);
    }
  }

  Future<void> _initializeTimezone() async {
    if (_timezoneInitialized) return;
    tz.initializeTimeZones();
    try {
      final name = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _timezoneInitialized = true;
  }

  Future<void> _ensureAndroidPermissions() async {
    if (!Platform.isAndroid) return;
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;
    final granted = await androidImpl.areNotificationsEnabled();
    if (granted ?? true) return;
    try {
      await (androidImpl as dynamic).requestPermission();
    } catch (_) {
      // If the current Android API level or plugin version doesn't support
      // programmatic permission requests, the user will need to enable
      // notifications manually in system settings.
    }
  }

  Future<void> _ensureNotificationChannel() async {
    if (_channelInitialized) return;
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      const channel = AndroidNotificationChannel(
        'ndoto_reminders_channel',
        'Reminders',
        description: 'Reminders for upcoming farm and livestock events',
        importance: Importance.high,
        playSound: true,
        enableLights: true,
        enableVibration: true,
      );
      await androidImpl.createNotificationChannel(channel);
    }
    _channelInitialized = true;
  }
}

