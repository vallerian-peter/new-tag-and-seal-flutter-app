import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:new_tag_and_seal_flutter_app/core/components/custom_button.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_date_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';

import '../../../database/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../data/repository/notification_repository.dart';
import '../data/services/notification_service.dart';
import '../domain/model/notification_model.dart';
import 'provider/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotificationProvider>(
      create: (context) {
        final db = context.read<AppDatabase>();
        final repository = NotificationRepository(db);
        final service = NotificationService();
        final provider = NotificationProvider(
          repository: repository,
          notificationService: service,
        );
        provider.loadNotifications();
        return provider;
      },
      child: const _NotificationScreenBody(),
    );
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
                      _SectionHeader(title: l10n.upcomingToday),
                      const SizedBox(height: 8),
                      ...todayNotifications.map((notification) {
                        final scheduled = _parseDate(notification.scheduledAt);
                        return _NotificationTile(
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
                      _SectionHeader(title: l10n.upcomingNotifications),
                      const SizedBox(height: 8),
                      ...upcoming.map((notification) {
                        final scheduled = _parseDate(notification.scheduledAt);
                        return _NotificationTile(
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
                      _SectionHeader(title: l10n.allNotifications),
                      const SizedBox(height: 8),
                      ...remainingNotifications.map((notification) {
                        final scheduled = _parseDate(notification.scheduledAt);
                        final isToday = _isSameDay(scheduled, now);
                        final isUpcoming =
                            !notification.isCompleted && scheduled.isAfter(now);
                        return _NotificationTile(
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

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final farmNameController = TextEditingController();
    final livestockNameController = TextEditingController();
    final scheduleController = TextEditingController();
    DateTime? scheduledAt;

    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {

        final theme = Theme.of(context);
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      l10n.addNotification,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, 
                        fontSize: 24),
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
                                  dialBackgroundColor:
                                      scaffoldColor.withOpacity(theme.brightness == Brightness.dark ? 0.6 : 1),
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
                          scheduleController.text =
                              DateFormat.yMMMd().add_jm().format(combined.toLocal());
                        });
                      },
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
                        if (scheduledAt == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.scheduleDate)),
                          );
                          return;
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
                            livestockName:
                                livestockNameController.text.trim().isEmpty
                                    ? null
                                    : livestockNameController.text.trim(),
                            title: titleController.text.trim(),
                            description:
                                descriptionController.text.trim().isEmpty
                                    ? null
                                    : descriptionController.text.trim(),
                            scheduledAt: scheduledAt!.toIso8601String(),
                            isCompleted: false,
                            synced: false,
                            syncAction: 'create',
                            createdAt: nowIso,
                            updatedAt: nowIso,
                          ),
                        );
                        if (mounted) Navigator.of(context).pop();
                      },
                    ),
                  
                    const SizedBox(height: 26),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  DateTime _parseDate(String value) {
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final DateTime scheduled;
  final VoidCallback? onMarkCompleted;
  final VoidCallback onDelete;
  final bool isToday;
  final bool isUpcoming;

  const _NotificationTile({
    required this.notification,
    required this.scheduled,
    required this.onMarkCompleted,
    required this.onDelete,
    this.isToday = false,
    this.isUpcoming = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheduledLabel = DateFormat.yMMMd().add_jm().format(scheduled.toLocal());
    final baseColor = _notificationColor(notification.title, theme);
    final dark = theme.brightness == Brightness.dark;
    final gradient = LinearGradient(
      colors: dark
          ? [baseColor.withOpacity(0.4), baseColor.withOpacity(0.15)]
          : [baseColor.withOpacity(0.35), baseColor.withOpacity(0.08)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final icon = _notificationIcon(notification.title);

    final chips = <Widget>[];
    if (isToday) {
      chips.add(_StatusChip(
        label: l10n.notificationChipToday,
        color: baseColor,
        dark: dark,
      ));
    } else if (isUpcoming) {
      chips.add(_StatusChip(
        label: l10n.notificationChipUpcoming,
        color: baseColor,
        dark: dark,
      ));
    }
    if (notification.isCompleted) {
      chips.add(_StatusChip(
        label: l10n.markCompleted,
        color: theme.colorScheme.tertiary,
        dark: dark,
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withOpacity(dark ? 0.5 : 0.25)),
        boxShadow: dark
            ? []
            : [
                BoxShadow(
                  color: baseColor.withOpacity(0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: baseColor.withOpacity(dark ? 0.85 : 0.9),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: notification.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      PopupMenuButton<_NotificationAction>(
                        color: theme.scaffoldBackgroundColor,
                        onSelected: (action) {
                          switch (action) {
                            case _NotificationAction.complete:
                              onMarkCompleted?.call();
                              break;
                            case _NotificationAction.delete:
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: _NotificationAction.complete,
                            enabled: onMarkCompleted != null,
                            child: Text(l10n.markCompleted),
                          ),
                          PopupMenuItem(
                            value: _NotificationAction.delete,
                            child: Text(l10n.deleteNotification),
                          ),
                        ],
                        icon: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    l10n.notificationScheduledOn(scheduledLabel),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                    ),
                  ),
                  if (notification.description != null &&
                      notification.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                  if (notification.farmName != null ||
                      notification.livestockName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (notification.farmName != null) notification.farmName!,
                        if (notification.livestockName != null)
                          notification.livestockName!,
                      ].join(' • '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: chips,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _notificationColor(String title, ThemeData theme) {
    final lower = title.toLowerCase();
    if (lower.contains('feed')) {
      return Colors.orangeAccent;
    } else if (lower.contains('deworm')) {
      return Colors.teal;
    } else if (lower.contains('medicat')) {
      return Colors.indigoAccent;
    } else if (lower.contains('vaccin')) {
      return Colors.green;
    }
    return theme.colorScheme.primary;
  }

  static IconData _notificationIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('feed')) {
      return Icons.restaurant;
    } else if (lower.contains('deworm')) {
      return Icons.medication_outlined;
    } else if (lower.contains('medicat')) {
      return Icons.local_hospital_outlined;
    } else if (lower.contains('vaccin')) {
      return Icons.vaccines_outlined;
    }
    return Icons.notifications_active_outlined;
  }
}

enum _NotificationAction { complete, delete }

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool dark;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final background = dark ? color.withOpacity(0.4) : color.withOpacity(0.2);
    final foreground = dark ? Colors.white : color.darken();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
      ),
    );
  }
}

extension on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
