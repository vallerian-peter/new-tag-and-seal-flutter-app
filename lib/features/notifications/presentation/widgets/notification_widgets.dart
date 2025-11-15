import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/model/notification_model.dart';

class NotificationSectionHeader extends StatelessWidget {
  const NotificationSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

enum NotificationTileAction { complete, delete }

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.scheduled,
    required this.onDelete,
    this.onMarkCompleted,
    this.isToday = false,
    this.isUpcoming = false,
  });

  final NotificationModel notification;
  final DateTime scheduled;
  final VoidCallback? onMarkCompleted;
  final VoidCallback onDelete;
  final bool isToday;
  final bool isUpcoming;

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
                      PopupMenuButton<NotificationTileAction>(
                        color: theme.scaffoldBackgroundColor,
                        onSelected: (action) {
                          switch (action) {
                            case NotificationTileAction.complete:
                              onMarkCompleted?.call();
                              break;
                            case NotificationTileAction.delete:
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: NotificationTileAction.complete,
                            enabled: onMarkCompleted != null,
                            child: Text(l10n.markCompleted),
                          ),
                          PopupMenuItem(
                            value: NotificationTileAction.delete,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.dark,
  });

  final String label;
  final Color color;
  final bool dark;

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

