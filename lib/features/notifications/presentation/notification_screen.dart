import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'package:new_tag_and_seal_flutter_app/core/alarm/alarm_audio_utils.dart';
import 'package:new_tag_and_seal_flutter_app/core/alarm/app_alarm_manager.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_date_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/model/notification_model.dart';
import 'provider/notification_provider.dart';
import 'widgets/notification_widgets.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotificationScreenBody();
  }
}

class _NotificationScreenBody extends StatefulWidget {
  const _NotificationScreenBody();

  @override
  State<_NotificationScreenBody> createState() => _NotificationScreenBodyState();
}

class _NotificationScreenBodyState extends State<_NotificationScreenBody> {
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _notificationKey(NotificationModel notification) =>
      '${notification.id ?? notification.title}-${notification.scheduledAt}-${notification.farmUuid}-${notification.livestockUuid}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final notifications = [...provider.notifications]
      ..sort((a, b) => _parseDate(a.scheduledAt).compareTo(_parseDate(b.scheduledAt)));
    final now = DateTime.now();
    final todayNotifications = notifications.where((notification) {
      if (notification.isCompleted) return false;
      final scheduled = _parseDate(notification.scheduledAt);
      return scheduled.isAfter(now) && _isSameDay(scheduled, now);
    }).toList();
    final upcoming = notifications.where((notification) {
      if (notification.isCompleted) return false;
      final scheduled = _parseDate(notification.scheduledAt);
      return scheduled.isAfter(now) && !_isSameDay(scheduled, now);
    }).toList();
    final displayedKeys = <String>{
      ...todayNotifications.map(_notificationKey),
      ...upcoming.map(_notificationKey),
    };
    final remainingNotifications = notifications.where(
      (notification) => !displayedKeys.contains(_notificationKey(notification)),
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addNotification,
            onPressed: () => _showAddNotificationSheet(context),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Text(
                    l10n.noNotifications,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (todayNotifications.isNotEmpty) ...[
                      NotificationSectionHeader(title: l10n.upcomingToday),
                      const SizedBox(height: 8),
                      ...todayNotifications.map((notification) {
                        final scheduled = _parseDate(notification.scheduledAt);
                        return NotificationTile(
                          notification: notification,
                          scheduled: scheduled,
                          isToday: true,
                          isUpcoming: true,
                          onMarkCompleted: notification.isCompleted
                              ? null
                              : () => provider.markCompleted(notification.id!),
                          onDelete: () => provider.deleteNotification(notification.id!),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                    if (upcoming.isNotEmpty) ...[
                      NotificationSectionHeader(title: l10n.upcomingNotifications),
                      const SizedBox(height: 8),
                      ...upcoming.map((notification) {
                        final scheduled = _parseDate(notification.scheduledAt);
                        return NotificationTile(
                          notification: notification,
                          scheduled: scheduled,
                          isToday: false,
                          isUpcoming: true,
                          onMarkCompleted: notification.isCompleted
                              ? null
                              : () => provider.markCompleted(notification.id!),
                          onDelete: () => provider.deleteNotification(notification.id!),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                    if (remainingNotifications.isNotEmpty ||
                        (todayNotifications.isEmpty && upcoming.isEmpty)) ...[
                      NotificationSectionHeader(title: l10n.allNotifications),
                      const SizedBox(height: 8),
                      ...remainingNotifications.map((notification) {
                        final scheduled = _parseDate(notification.scheduledAt);
                        final isToday = _isSameDay(scheduled, now);
                        final isUpcoming =
                            !notification.isCompleted && scheduled.isAfter(now);
                        return NotificationTile(
                          notification: notification,
                          scheduled: scheduled,
                          isToday: isToday,
                          isUpcoming: isUpcoming,
                          onMarkCompleted: notification.isCompleted
                              ? null
                              : () => provider.markCompleted(notification.id!),
                          onDelete: () => provider.deleteNotification(notification.id!),
                        );
                      }),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
    );
  }

  Future<void> _showAddNotificationSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<NotificationProvider>();
    final alarmManager = context.read<AppAlarmManager>();

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final farmNameController = TextEditingController();
    final livestockNameController = TextEditingController();
    final scheduleController = TextEditingController();
    DateTime? scheduledAt;
    bool repeatDaily = false;
    TimeOfDay? dailyTime;
    String selectedSoundPath = alarmManager.defaultRelativeSoundPath;
    String selectedSoundName = NotificationModel.defaultSoundName;
    bool loopAudio = true;
    bool vibrate = true;
    double volume = 1.0;
    bool previewing = false;
    final previewPlayer = AudioPlayer();

    final theme = Theme.of(context);

    try {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: theme.scaffoldBackgroundColor,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) {
          final theme = Theme.of(context);

          Future<void> pickSound(StateSetter setModalState) async {
            final result = await FilePicker.platform.pickFiles(type: FileType.audio);
            if (result == null || result.files.isEmpty) return;
            final picked = result.files.single;
            final path = picked.path;
            if (path == null) return;
            final relative = await AlarmAudioUtils.copySoundToAppDirectory(path);
            setModalState(() {
              selectedSoundPath = relative;
              selectedSoundName = picked.name;
            });
          }

          Future<void> previewSound(StateSetter setModalState) async {
            if (previewing) {
              await previewPlayer.stop();
              setModalState(() => previewing = false);
              return;
            }
            final absolute = await AlarmAudioUtils.resolveAbsolutePath(selectedSoundPath);
            try {
              await previewPlayer.setFilePath(absolute);
              setModalState(() => previewing = true);
              await previewPlayer.play();
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.previewSoundFailed)),
              );
            } finally {
              if (previewing) {
                setModalState(() => previewing = false);
              }
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.addNotification,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: titleController,
                          label: l10n.notificationTitle,
                          hintText: l10n.enterNotificationTitle,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: descriptionController,
                          label: l10n.notificationDescription,
                          hintText: l10n.enterNotificationDescription,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: farmNameController,
                          label: l10n.farmName,
                          hintText: l10n.optionalFieldHint,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: livestockNameController,
                          label: l10n.livestock,
                          hintText: l10n.optionalFieldHint,
                        ),
                        const SizedBox(height: 12),
                        if (!repeatDaily)
                          CustomDatePicker(
                            controller: scheduleController,
                            label: '${l10n.scheduleDate} • ${l10n.scheduleTime}',
                            hint: '${l10n.scheduleDate} • ${l10n.scheduleTime}',
                            initialDate: scheduledAt ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            autoFillValue: false,
                            onDateSelected: (date) async {
                              final initialTime = TimeOfDay.fromDateTime(
                                scheduledAt ?? DateTime.now(),
                              );
                              final time = await showTimePicker(
                                context: context,
                                builder: (context, child) {
                                  final theme = Theme.of(context);
                                  final scaffoldColor = theme.scaffoldBackgroundColor;
                                  return Theme(
                                    data: theme.copyWith(
                                      cardColor: scaffoldColor,
                                      dialogBackgroundColor: scaffoldColor,
                                      timePickerTheme: theme.timePickerTheme.copyWith(
                                        backgroundColor: scaffoldColor,
                                        dialBackgroundColor: scaffoldColor.withOpacity(
                                            theme.brightness == Brightness.dark ? 0.6 : 1),
                                        hourMinuteColor: scaffoldColor,
                                        hourMinuteTextColor: theme.colorScheme.onSurface,
                                        dialHandColor: theme.colorScheme.primary,
                                        dialTextColor: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                                initialTime: initialTime,
                              );
                              if (time == null) return;
                              final combined = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              setModalState(() {
                                scheduledAt = combined;
                                scheduleController.text = DateFormat.yMMMd()
                                    .add_jm()
                                    .format(combined.toLocal());
                              });
                            },
                          )
                        else
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.selectTimeLabel),
                            subtitle: Text(
                              dailyTime == null
                                  ? l10n.selectTimeHint
                                  : dailyTime!.format(context),
                            ),
                            trailing: const Icon(Icons.access_time),
                            onTap: () async {
                              final initial = dailyTime ?? TimeOfDay.now();
                              final time = await showTimePicker(
                                context: context,
                                initialTime: initial,
                              );
                              if (time == null) return;
                              setModalState(() {
                                dailyTime = time;
                              });
                            },
                          ),
                        SwitchListTile.adaptive(
                          value: repeatDaily,
                          onChanged: (value) {
                            setModalState(() {
                              repeatDaily = value;
                              if (value) {
                                dailyTime ??= TimeOfDay.now();
                              }
                            });
                          },
                          title: Text(l10n.repeatDailyLabel),
                          subtitle: Text(l10n.repeatDailyHint),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.selectAlarmSound,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.alarmSoundSelected(selectedSoundName),
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => pickSound(setModalState),
                                      child: Text(l10n.chooseSound),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => previewSound(setModalState),
                                      child: Text(
                                        previewing
                                            ? l10n.stopPreview
                                            : l10n.previewSound,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile.adaptive(
                          value: loopAudio,
                          onChanged: (value) => setModalState(() => loopAudio = value),
                          title: Text(l10n.loopSound),
                        ),
                        SwitchListTile.adaptive(
                          value: vibrate,
                          onChanged: (value) => setModalState(() => vibrate = value),
                          title: Text(l10n.vibrateDevice),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.alarmVolume,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Slider(
                          value: volume,
                          onChanged: (value) => setModalState(() => volume = value),
                          min: 0.2,
                          max: 1.0,
                          divisions: 4,
                          label: (volume * 100).round().toString(),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: l10n.saveNotification,
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.enterNotificationTitle)),
                              );
                              return;
                            }
                            DateTime? computedDateTime;
                            if (repeatDaily) {
                              if (dailyTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.selectTimeRequired)),
                                );
                                return;
                              }
                              final now = DateTime.now();
                              var candidate = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                dailyTime!.hour,
                                dailyTime!.minute,
                              );
                              if (!candidate.isAfter(now)) {
                                candidate = candidate.add(const Duration(days: 1));
                              }
                              computedDateTime = candidate;
                            } else {
                              if (scheduledAt == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.scheduleDate)),
                                );
                                return;
                              }
                              computedDateTime = scheduledAt;
                            }

                            final nowIso = DateTime.now().toIso8601String();

                            await provider.saveNotification(
                              NotificationModel(
                                id: null,
                                farmUuid: null,
                                farmName: farmNameController.text.trim().isEmpty
                                    ? null
                                    : farmNameController.text.trim(),
                                livestockUuid: null,
                                livestockName: livestockNameController.text
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : livestockNameController.text.trim(),
                                title: titleController.text.trim(),
                                description: descriptionController.text
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : descriptionController.text.trim(),
                                scheduledAt: computedDateTime!.toIso8601String(),
                                createdAt: nowIso,
                                updatedAt: nowIso,
                                soundPath: selectedSoundPath,
                                soundName: selectedSoundName,
                                loopAudio: loopAudio,
                                vibrate: vibrate,
                                volume: volume,
                                repeatDaily: repeatDaily,
                              ),
                            );
                            if (mounted) Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    } finally {
      await previewPlayer.dispose();
    }
  }

  DateTime _parseDate(String value) {
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}

