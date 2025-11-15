import 'dart:async';
import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/alarm/alarm_audio_utils.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/domain/model/notification_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/domain/repo/notification_repo.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/presentation/alarm_ringing_screen.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class AppAlarmManager {
  AppAlarmManager({
    required this.navigatorKey,
    required NotificationRepositoryInterface repository,
  }) : _repository = repository;

  final GlobalKey<NavigatorState> navigatorKey;
  final NotificationRepositoryInterface _repository;

  final Set<int> _activeScreens = <int>{};
  StreamSubscription<AlarmSet>? _ringSubscription;
  bool _initialized = false;
  String? _defaultRelativePath;

  String get defaultRelativeSoundPath =>
      _defaultRelativePath ?? NotificationModel.defaultSoundPath;

  Future<void> initialize() async {
    if (_initialized) return;
    await Alarm.init();
    _defaultRelativePath =
        await AlarmAudioUtils.ensureDefaultAlarmSound();
    _ringSubscription = Alarm.ringing.listen(_handleRinging);
    _initialized = true;
  }

  Future<void> dispose() async {
    await _ringSubscription?.cancel();
  }

  Future<void> syncAlarms(List<NotificationModel> notifications) async {
    if (!_initialized) await initialize();
    final active = await Alarm.getAlarms();
    final activeIds = active.map((a) => a.id).toSet();
    final desired = notifications
        .where((n) => !n.isCompleted)
        .map((n) => n.id)
        .whereType<int>()
        .toSet();

    for (final id in activeIds.difference(desired)) {
      await Alarm.stop(id);
    }

    for (final notification in notifications) {
      if (notification.id == null || notification.isCompleted) continue;
      await _scheduleAlarm(notification);
    }
  }

  Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
  }

  Future<void> _scheduleAlarm(NotificationModel notification) async {
    final id = notification.id;
    if (id == null) return;

    final scheduledAt = DateTime.tryParse(notification.scheduledAt);
    if (scheduledAt == null || scheduledAt.isBefore(DateTime.now())) {
      return;
    }

    final relativePath = notification.soundPath.isNotEmpty
        ? notification.soundPath
        : defaultRelativeSoundPath;

    final context = navigatorKey.currentContext;
    final l10n = context != null ? AppLocalizations.of(context) : null;
    final formattedDate =
        DateFormat.yMMMd().add_jm().format(scheduledAt.toLocal());
    final defaultBody =
        l10n?.notificationScheduledOn(formattedDate) ?? 'Scheduled on $formattedDate';
    final body = notification.description ?? defaultBody;
    final stopLabel = l10n?.stopAlarm ?? 'Stop alarm';

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduledAt,
      assetAudioPath: relativePath,
      loopAudio: notification.loopAudio,
      vibrate: notification.vibrate,
      androidFullScreenIntent: true,
      warningNotificationOnKill: true,
      volumeSettings: VolumeSettings.fixed(
        volume: notification.volume,
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: notification.title,
        body: body,
        stopButton: stopLabel,
      ),
      payload: jsonEncode({'notificationId': id}),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> _handleRinging(AlarmSet set) async {
    if (set.alarms.isEmpty) return;

    for (final alarm in set.alarms) {
      if (_activeScreens.contains(alarm.id)) continue;
      _activeScreens.add(alarm.id);

      NotificationModel? notification;
      if (alarm.payload != null) {
        try {
          final payload = jsonDecode(alarm.payload!);
          final notificationId = payload['notificationId'] as int?;
          if (notificationId != null) {
            notification = await _repository.getNotificationById(notificationId);
          }
        } catch (_) {
          // ignore malformed payload
        }
      } else {
        notification = await _repository.getNotificationById(alarm.id);
      }

      final soundPath = notification?.soundPath ?? alarm.assetAudioPath;
      final absolutePath =
          await AlarmAudioUtils.resolveAbsolutePath(soundPath);

      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        _activeScreens.remove(alarm.id);
        continue;
      }

      // ignore: unawaited_futures
      navigator.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AlarmRingingScreen(
            alarmId: alarm.id,
            notification: notification,
            alarmSettings: alarm,
            soundAbsolutePath: absolutePath,
            onScreenClosed: () => _activeScreens.remove(alarm.id),
          ),
        ),
      );
    }
  }
}

