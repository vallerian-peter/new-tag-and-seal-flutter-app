import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class ViewEventsScreen extends StatelessWidget {
  final String title;
  final String logType;
  final String? farmUuid;
  final String? livestockUuid;
  final EventsProvider eventsProvider;
  final String? farmName;
  final String? livestockName;
  final List<dynamic>? initialLogs;

  const ViewEventsScreen({
    super.key,
    required this.title,
    required this.logType,
    this.farmUuid,
    this.livestockUuid,
    required this.eventsProvider,
    this.farmName,
    this.livestockName,
    this.initialLogs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final chips = <Widget>[];
    if (farmName != null && farmName!.trim().isNotEmpty) {
      chips.add(
        _ContextChip(
          icon: Icons.agriculture,
          label: '${l10n.farm}: ${farmName!.trim()}',
        ),
      );
    }
    if (livestockName != null && livestockName!.trim().isNotEmpty) {
      chips.add(
        _ContextChip(
          icon: Icons.pets_rounded,
          label: '${l10n.livestock}: ${livestockName!.trim()}',
        ),
      );
    }

    final displayTitle =
        '${title.trim().isNotEmpty ? title.trim() : l10n.recordsText} ${l10n.recordsText}';

    return FutureBuilder<List<dynamic>>(
      future: _loadLogsWithReferences(context),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        final totalLogs =
            snapshot.connectionState == ConnectionState.waiting ? null : logs.length;

        PreferredSizeWidget buildAppBar(int? total) {
          return AppBar(
            title: Text(displayTitle),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '(${total ?? '--'})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            bottom: chips.isEmpty
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: chips,
                        ),
                      ),
                    ),
                  ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: buildAppBar(null),
            body: const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: buildAppBar(null),
            body: Center(
              child: Text(
                l10n.eventsLoadFailed,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        if (logs.isEmpty) {
          return Scaffold(
            appBar: buildAppBar(0),
            body: Center(
              child: Text(
                l10n.noData,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        final logReferences = Provider.of<LogAdditionalDataProvider>(
          context,
          listen: false,
        );

        return Scaffold(
          appBar: buildAppBar(totalLogs),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EventLogCard(
                  logType: logType,
                  log: log,
                  references: logReferences,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<List<dynamic>> _loadLogsWithReferences(BuildContext context) async {
    final logReferences =
        Provider.of<LogAdditionalDataProvider>(context, listen: false);
    await logReferences.ensureLoaded();

    if (initialLogs != null) {
      return initialLogs!;
    }

    if (livestockUuid == null || livestockUuid!.isEmpty) {
      return const [];
    }

    return eventsProvider.loadLogsForType(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid!,
      logType: logType,
    );
  }

}


class _EventLogCard extends StatelessWidget {
  final String logType;
  final dynamic log;
  final LogAdditionalDataProvider? references;

  const _EventLogCard({
    required this.logType,
    required this.log,
    this.references,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd().add_jm();

    IconData icon = Icons.info_outline;
    String title = l10n.comingSoon;
    final rows = <_LogRow>[];
    DateTime? createdDate;

    void addRow(String label, String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      rows.add(_LogRow(label: label, value: trimmed));
    }

    switch (logType) {
      case EventLogTypes.feeding:
        final feeding = log as FeedingModel;
        icon = Icons.restaurant;
        title = l10n.feeding;
        final nextTime = DateTime.tryParse(feeding.nextFeedingTime);
        addRow(
          l10n.nextFeedingTime,
          nextTime != null
              ? dateFormat.format(nextTime.toLocal())
              : feeding.nextFeedingTime,
        );
        addRow(l10n.amount, feeding.amount);
        addRow(l10n.remarks, feeding.remarks);
        createdDate = DateTime.tryParse(feeding.createdAt);
        break;
      case EventLogTypes.weightChange:
        final change = log as WeightChangeModel;
        icon = Icons.monitor_weight;
        title = l10n.weightChange;
        addRow(l10n.previousWeight, change.oldWeight);
        addRow(l10n.currentWeight, change.newWeight);
        final updatedAt = DateTime.tryParse(change.updatedAt);
        addRow(
          l10n.updatedAt,
          updatedAt != null
              ? dateFormat.format(updatedAt.toLocal())
              : change.updatedAt,
        );
        addRow(l10n.remarks, change.remarks);
        createdDate = DateTime.tryParse(change.createdAt);
        break;
      case EventLogTypes.deworming:
        final deworming = log as DewormingModel;
        icon = Icons.bug_report;
        title = l10n.deworming;
        final medicineName = _resolveMedicineName(deworming.medicineId);
        final routeName =
            _resolveAdministrationRouteName(deworming.administrationRouteId);

        addRow(l10n.medicine, medicineName);
        addRow(
          l10n.administrationRoute,
          routeName,
        );
        addRow(l10n.quantity, deworming.quantity);
        addRow(l10n.dose, deworming.dose);
        if (deworming.vetId != null && deworming.vetId!.trim().isNotEmpty) {
          addRow(l10n.vetLicense, deworming.vetId);
        }
        if (deworming.extensionOfficerId != null &&
            deworming.extensionOfficerId!.trim().isNotEmpty) {
          addRow(
            l10n.extensionOfficerLicense,
            deworming.extensionOfficerId,
          );
        }
        if (deworming.nextAdministrationDate != null) {
          final nextDate = DateTime.tryParse(deworming.nextAdministrationDate!);
          addRow(
            l10n.nextAdministrationDate,
            nextDate != null
                ? dateFormat.format(nextDate.toLocal())
                : deworming.nextAdministrationDate!,
          );
        }
        createdDate = DateTime.tryParse(deworming.createdAt);
        break;
    }

    return _EventLogCardContainer(
      icon: icon,
      title: title,
      rows: rows,
      createdDate: createdDate,
    );
  }
}

extension _DewormingLookup on _EventLogCard {
  String _resolveMedicineName(int? medicineId) {
    if (medicineId == null) return '--';
    if (references == null) return medicineId.toString();

    for (final medicine in references!.medicines) {
      if (medicine.id == medicineId) {
        return medicine.name;
      }
    }

    return medicineId.toString();
  }

  String _resolveAdministrationRouteName(int? routeId) {
    if (routeId == null) return '--';
    if (references == null) return routeId.toString();

    for (final route in references!.administrationRoutes) {
      if (route.id == routeId) {
        return route.name;
      }
    }

    return routeId.toString();
  }
}

class _EventLogCardContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_LogRow> rows;
  final DateTime? createdDate;

  const _EventLogCardContainer({
    required this.icon,
    required this.title,
    required this.rows,
    this.createdDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.colorScheme.surfaceVariant.withOpacity(0.35)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row.value,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (createdDate != null) ...[
            const SizedBox(height: 12),
            _LogFooter(
              title: AppLocalizations.of(context)!.createdAt,
              date: createdDate!,
            ),
          ],
        ],
      ),
    );
  }
}

class _LogRow {
  final String label;
  final String value;

  const _LogRow({required this.label, required this.value});
}

class _LogFooter extends StatelessWidget {
  final String title;
  final DateTime date;

  const _LogFooter({
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat.yMMMd().add_jm().format(date.toLocal());

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            formattedDate,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContextChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContextChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white.withOpacity(0.85) : primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white.withOpacity(0.85) : primary,
            ),
          ),
        ],
      ),
    );
  }
}

