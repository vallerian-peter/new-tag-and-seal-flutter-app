import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'package:new_tag_and_seal_flutter_app/core/alarm/alarm_audio_utils.dart';
import 'package:new_tag_and_seal_flutter_app/core/alarm/app_alarm_manager.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_date_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

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
  State<_NotificationScreenBody> createState() =>
      _NotificationScreenBodyState();
}

class _NotificationScreenBodyState extends State<_NotificationScreenBody> {
  List<Farm> _farms = const [];
  List<Livestock> _livestock = const [];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _notificationKey(NotificationModel notification) {
    if (NotificationModel.isPrepuceFollowUpTitle(notification.title)) {
      return notification.title;
    }
    return '${notification.id ?? notification.title}-${notification.scheduledAt}-${notification.farmUuid}-${notification.livestockUuid}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationProvider>().loadNotifications();
      _loadNotificationContextData();
    });
  }

  Future<void> _loadNotificationContextData() async {
    try {
      final database = context.read<AppDatabase>();
      final farms = await database.farmDao.getAllActiveFarms();
      final livestock = await database.livestockDao.getAllActiveLivestock();
      if (!mounted) return;
      setState(() {
        _farms = farms;
        _livestock = livestock;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _farms = const [];
        _livestock = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final notifications = [...provider.notifications]
      ..sort(
        (a, b) =>
            _parseDate(a.scheduledAt).compareTo(_parseDate(b.scheduledAt)),
      );
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
    final remainingNotifications = notifications
        .where(
          (notification) =>
              !displayedKeys.contains(_notificationKey(notification)),
        )
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Bootstrap.chevron_left, size: 19),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
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
                      onDelete: () =>
                          provider.deleteNotification(notification.id!),
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
                      onDelete: () =>
                          provider.deleteNotification(notification.id!),
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
                      onDelete: () =>
                          provider.deleteNotification(notification.id!),
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
    String? selectedFarmUuid;
    String? selectedLivestockUuid;
    DateTime? scheduledAt;
    bool repeatDaily = false;
    TimeOfDay? dailyTime;
    String selectedSoundPath = alarmManager.defaultRelativeSoundPath;
    String selectedSoundName = NotificationModel.defaultSoundName;
    bool loopAudio = true;
    bool vibrate = true;
    double volume = 1.0;
    bool previewing = false;
    bool _isPickingFile = false; // Guard against concurrent FilePicker requests
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
            // Guard: block concurrent requests — update state so button disables in UI
            if (_isPickingFile) return;
            setModalState(() => _isPickingFile = true);
            try {
              // Clear stale temp files from previous picks (prevents iOS multiple_request)
              await FilePicker.platform.clearTemporaryFiles();
              final result = await FilePicker.platform.pickFiles(
                type: FileType.audio,
              );
              if (result == null || result.files.isEmpty) return;
              final picked = result.files.single;
              final path = picked.path;
              if (path == null) return;
              final relative = await AlarmAudioUtils.copySoundToAppDirectory(
                path,
              );
              setModalState(() {
                selectedSoundPath = relative;
                selectedSoundName = picked.name;
              });
            } on PlatformException catch (e) {
              // Swallow iOS multiple_request / cancellation exceptions silently
              debugPrint(
                '[FilePicker] PlatformException suppressed: ${e.code} — ${e.message}',
              );
            } on Exception catch (e) {
              debugPrint('[FilePicker] Ignored error: $e');
            } finally {
              // Always re-enable the button via setModalState
              if (mounted) setModalState(() => _isPickingFile = false);
            }
          }

          Future<void> previewSound(StateSetter setModalState) async {
            if (previewing) {
              await previewPlayer.stop();
              setModalState(() => previewing = false);
              return;
            }
            final absolute = await AlarmAudioUtils.resolveAbsolutePath(
              selectedSoundPath,
            );
            try {
              await previewPlayer.setFilePath(absolute);
              setModalState(() => previewing = true);
              await previewPlayer.play();
            } catch (_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.previewSoundFailed)));
            } finally {
              if (previewing) {
                setModalState(() => previewing = false);
              }
            }
          }

          Future<void> pickFarmFromSheet() async {
            await showModalBottomSheet<void>(
              context: context,
              backgroundColor: theme.scaffoldBackgroundColor,
              showDragHandle: true,
              builder: (ctx) {
                if (_farms.isEmpty) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.noData),
                    ),
                  );
                }
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          l10n.selectFarm,
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text('${l10n.recordsText}: ${_farms.length}'),
                      ),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _farms.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: theme.colorScheme.tertiary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final farm = _farms[index];
                            final isSelected = selectedFarmUuid == farm.uuid;

                            return ListTile(
                              leading: Text(
                                '${index + 1}.',
                                style: Theme.of(ctx).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              title: Text(farm.name),
                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (_) {
                                  setState(() {
                                    selectedFarmUuid = farm.uuid;
                                    farmNameController.text = farm.name;
                                    selectedLivestockUuid = null;
                                    livestockNameController.clear();
                                  });
                                  Navigator.of(ctx).pop();
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  selectedFarmUuid = farm.uuid;
                                  farmNameController.text = farm.name;
                                  selectedLivestockUuid = null;
                                  livestockNameController.clear();
                                });
                                Navigator.of(ctx).pop();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          Future<void> pickLivestockFromSheet() async {
            final available = selectedFarmUuid == null
                ? _livestock
                : _livestock
                      .where((l) => l.farmUuid == selectedFarmUuid)
                      .toList();
            await showModalBottomSheet<void>(
              context: context,
              backgroundColor: theme.scaffoldBackgroundColor,
              showDragHandle: true,
              builder: (ctx) {
                if (available.isEmpty) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.noData),
                    ),
                  );
                }
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          l10n.selectLivestock,
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${l10n.recordsText}: ${available.length}',
                        ),
                      ),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: available.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: theme.colorScheme.tertiary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final animal = available[index];
                            final trimmedName = animal.name.trim();
                            final animalNameForTile = trimmedName.isEmpty
                                ? '${l10n.livestock} #${animal.id}'
                                : trimmedName;
                            final isSelected =
                                selectedLivestockUuid == animal.uuid;
                            return ListTile(
                              leading: Text(
                                '${index + 1}.',
                                style: Theme.of(ctx).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              title: Text(animalNameForTile),
                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (_) {
                                  setState(() {
                                    selectedLivestockUuid = animal.uuid;
                                    livestockNameController.text = trimmedName;
                                    if (selectedFarmUuid == null) {
                                      selectedFarmUuid = animal.farmUuid;
                                      String farmName = '';
                                      for (final farm in _farms) {
                                        if (farm.uuid == animal.farmUuid) {
                                          farmName = farm.name;
                                          break;
                                        }
                                      }
                                      farmNameController.text = farmName;
                                    }
                                  });
                                  Navigator.of(ctx).pop();
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  selectedLivestockUuid = animal.uuid;
                                  livestockNameController.text = trimmedName;
                                  if (selectedFarmUuid == null) {
                                    selectedFarmUuid = animal.farmUuid;
                                    String farmName = '';
                                    for (final farm in _farms) {
                                      if (farm.uuid == animal.farmUuid) {
                                        farmName = farm.name;
                                        break;
                                      }
                                    }
                                    farmNameController.text = farmName;
                                  }
                                });
                                Navigator.of(ctx).pop();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.addNotification,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.cancel_outlined),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.cardColor.withValues(
                                  alpha: 0.4,
                                ),
                                shape: const CircleBorder(),
                              ),
                              tooltip: l10n.cancel,
                            ),
                          ],
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
                          onChanged: (value) {
                            final text = value.trim();
                            if (text.isEmpty) {
                              setModalState(() {
                                selectedFarmUuid = null;
                                if (livestockNameController.text
                                    .trim()
                                    .isEmpty) {
                                  selectedLivestockUuid = null;
                                }
                              });
                              return;
                            }
                            // Manual text input should detach from previously selected UUID.
                            final selectedFarmName = _farms
                                .where((f) => f.uuid == selectedFarmUuid)
                                .map((f) => f.name.trim())
                                .firstWhere(
                                  (name) => name.isNotEmpty,
                                  orElse: () => '',
                                );
                            if (selectedFarmName.toLowerCase() !=
                                text.toLowerCase()) {
                              setModalState(() {
                                selectedFarmUuid = null;
                                // Farm context changed manually; reset livestock linkage too.
                                selectedLivestockUuid = null;
                              });
                            }
                          },
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.expand_more),
                            onPressed: pickFarmFromSheet,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: livestockNameController,
                          label: l10n.livestock,
                          hintText: l10n.optionalFieldHint,
                          onChanged: (value) {
                            final text = value.trim();
                            if (text.isEmpty) {
                              setModalState(() => selectedLivestockUuid = null);
                              return;
                            }
                            final selectedLivestockName = _livestock
                                .where((l) => l.uuid == selectedLivestockUuid)
                                .map((l) => l.name.trim())
                                .firstWhere(
                                  (name) => name.isNotEmpty,
                                  orElse: () => '',
                                );
                            if (selectedLivestockName.toLowerCase() !=
                                text.toLowerCase()) {
                              setModalState(() => selectedLivestockUuid = null);
                            }
                          },
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.expand_more),
                            onPressed: pickLivestockFromSheet,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!repeatDaily)
                          CustomDatePicker(
                            controller: scheduleController,
                            label:
                                '${l10n.scheduleDate} • ${l10n.scheduleTime}',
                            hint: '${l10n.scheduleDate} • ${l10n.scheduleTime}',
                            initialDate: scheduledAt ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 5),
                            ),
                            autoFillValue: false,
                            onDateSelected: (date) async {
                              final initialTime = TimeOfDay.fromDateTime(
                                scheduledAt ?? DateTime.now(),
                              );
                              final theme = Theme.of(context);
                              final isDark =
                                  theme.brightness == Brightness.dark;
                              final backgroundColor = isDark
                                  ? theme.scaffoldBackgroundColor
                                  : whiteColor;
                              final time = await showTimePicker(
                                context: context,
                                builder: (context, child) {
                                  return Theme(
                                    data: theme.copyWith(
                                      colorScheme: theme.colorScheme.copyWith(
                                        primary: Constants.primaryColor,
                                        onPrimary: theme.colorScheme.onPrimary,
                                        onSurface: theme.colorScheme.onSurface,
                                        surface: backgroundColor,
                                        surfaceContainerHighest:
                                            backgroundColor,
                                      ),
                                      dialogBackgroundColor: backgroundColor,
                                      canvasColor: backgroundColor,
                                      cardColor: backgroundColor,
                                      scaffoldBackgroundColor: backgroundColor,
                                      timePickerTheme: TimePickerThemeData(
                                        backgroundColor: backgroundColor,
                                        dialBackgroundColor: backgroundColor,
                                        hourMinuteColor: backgroundColor,
                                        hourMinuteTextColor:
                                            theme.colorScheme.onSurface,
                                        dialHandColor: Constants.primaryColor,
                                        dialTextColor:
                                            theme.colorScheme.onSurface,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              Constants.primaryColor,
                                        ),
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
                              final theme = Theme.of(context);
                              final isDark =
                                  theme.brightness == Brightness.dark;
                              final backgroundColor = isDark
                                  ? theme.scaffoldBackgroundColor
                                  : whiteColor;
                              final time = await showTimePicker(
                                context: context,
                                initialTime: initial,
                                builder: (context, child) {
                                  return Theme(
                                    data: theme.copyWith(
                                      colorScheme: theme.colorScheme.copyWith(
                                        primary: Constants.primaryColor,
                                        onPrimary: theme.colorScheme.onPrimary,
                                        onSurface: theme.colorScheme.onSurface,
                                        surface: backgroundColor,
                                        surfaceContainerHighest:
                                            backgroundColor,
                                      ),
                                      dialogBackgroundColor: backgroundColor,
                                      canvasColor: backgroundColor,
                                      cardColor: backgroundColor,
                                      scaffoldBackgroundColor: backgroundColor,
                                      timePickerTheme: TimePickerThemeData(
                                        backgroundColor: backgroundColor,
                                        dialBackgroundColor: backgroundColor,
                                        hourMinuteColor: backgroundColor,
                                        hourMinuteTextColor:
                                            theme.colorScheme.onSurface,
                                        dialHandColor: Constants.primaryColor,
                                        dialTextColor:
                                            theme.colorScheme.onSurface,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              Constants.primaryColor,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
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
                                      // Disabled while a pick is in progress — prevents double-invoke
                                      onPressed: _isPickingFile
                                          ? null
                                          : () => pickSound(setModalState),
                                      child: _isPickingFile
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(l10n.chooseSound),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          previewSound(setModalState),
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
                          onChanged: (value) =>
                              setModalState(() => loopAudio = value),
                          title: Text(l10n.loopSound),
                        ),
                        SwitchListTile.adaptive(
                          value: vibrate,
                          onChanged: (value) =>
                              setModalState(() => vibrate = value),
                          title: Text(l10n.vibrateDevice),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.alarmVolume,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Slider(
                          value: volume,
                          onChanged: (value) =>
                              setModalState(() => volume = value),
                          min: 0.2,
                          max: 1.0,
                          divisions: 4,
                          label: (volume * 100).round().toString(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomOutlinedButton(
                                text: l10n.cancel,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: l10n.saveNotification,
                                onPressed: () async {
                                  if (titleController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.enterNotificationTitle,
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  DateTime? computedDateTime;
                                  if (repeatDaily) {
                                    if (dailyTime == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.selectTimeRequired,
                                          ),
                                        ),
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
                                      candidate = candidate.add(
                                        const Duration(days: 1),
                                      );
                                    }
                                    computedDateTime = candidate;
                                  } else {
                                    if (scheduledAt == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.scheduleDate),
                                        ),
                                      );
                                      return;
                                    }
                                    computedDateTime = scheduledAt;
                                  }

                                  final nowIso = DateTime.now()
                                      .toIso8601String();

                                  await provider.saveNotification(
                                    NotificationModel(
                                      id: null,
                                      farmUuid: selectedFarmUuid,
                                      farmName:
                                          farmNameController.text.trim().isEmpty
                                          ? null
                                          : farmNameController.text.trim(),
                                      livestockUuid: selectedLivestockUuid,
                                      livestockName:
                                          livestockNameController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : livestockNameController.text.trim(),
                                      title: titleController.text.trim(),
                                      description:
                                          descriptionController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : descriptionController.text.trim(),
                                      scheduledAt: computedDateTime!
                                          .toIso8601String(),
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
                            ),
                          ],
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
