import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/model/notification_model.dart';
import 'provider/notification_provider.dart';

class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({
    super.key,
    required this.alarmId,
    required this.alarmSettings,
    required this.soundAbsolutePath,
    this.notification,
    this.onScreenClosed,
  });

  final int alarmId;
  final AlarmSettings alarmSettings;
  final String soundAbsolutePath;
  final NotificationModel? notification;
  final VoidCallback? onScreenClosed;

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  late final AudioPlayer _player;
  bool _stopping = false;
  bool _nativeAlarmStopped = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPlayback());
  }

  @override
  void dispose() {
    _player.dispose();
    widget.onScreenClosed?.call();
    super.dispose();
  }

  Future<void> _startPlayback() async {
    try {
      await _player.setFilePath(widget.soundAbsolutePath);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
      if (!_nativeAlarmStopped) {
        await Alarm.stop(widget.alarmId);
        _nativeAlarmStopped = true;
      }
    } catch (_) {
      // Ignore playback errors and rely on native alarm audio.
    }
  }

  Future<void> _stopAlarm() async {
    if (_stopping) return;
    setState(() => _stopping = true);

    try {
      await _player.stop();
    } catch (_) {}

    try {
      final provider = context.read<NotificationProvider>();
      final notification = widget.notification ??
          provider.getNotificationById(widget.alarmId);
      if (notification?.repeatDaily == true) {
        await provider.rescheduleRecurring(notification!);
      } else {
        await provider.markCompleted(widget.alarmId);
      }
      if (!_nativeAlarmStopped) {
        await Alarm.stop(widget.alarmId);
        _nativeAlarmStopped = true;
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notification = widget.notification;
    final scheduled =
        DateTime.tryParse(notification?.scheduledAt ?? '')?.toLocal();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.notifications,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Colors.redAccent.shade200,
                        Colors.deepOrange.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification?.title ??
                            widget.alarmSettings.notificationSettings.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (notification?.description != null)
                        Text(
                          notification!.description!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      if (scheduled != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          '${scheduled.hour.toString().padLeft(2, '0')}:${scheduled.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${scheduled.day}/${scheduled.month}/${scheduled.year}',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _stopping ? null : _stopAlarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _stopping ? l10n.loading : l10n.stopAlarm,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

