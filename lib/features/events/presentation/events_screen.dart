import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/view_events.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EventsProvider>().loadAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final eventsProvider = context.watch<EventsProvider>();

    final eventTypes = _eventTypesConfig(l10n);
    final totalLogs = eventTypes.fold<int>(
      0,
      (acc, config) => acc + _logsForType(eventsProvider, config.logType).length,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.allEvents,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                )),
            Text(
              l10n.eventsScreenSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
            ),
          ],
        ),
        backgroundColor:  theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: () => eventsProvider.loadAllEvents(),
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            const SizedBox(height: 16),

            _buildSummaryRow(context, totalLogs, eventTypes.length),
            if (eventsProvider.isLoading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                ),
              ],
            const SizedBox(height: 24),
            Text(
              l10n.recordsText,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...eventTypes.map((config) {
              final logs = _logsForType(eventsProvider, config.logType);
              return _EventTypeCard(
                config: config,
                count: logs.length,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViewEventsScreen(
                        title: config.title,
                        logType: config.logType,
                        eventsProvider: eventsProvider,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    int totalLogs,
    int typeCount,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.event_note_outlined,
            color: theme.colorScheme.primary,
            title: l10n.totalLogs,
            value: totalLogs.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.category_outlined,
            color: Colors.teal,
            title: l10n.eventTypes,
            value: typeCount.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.sync_outlined,
            color: Colors.indigo,
            title: l10n.readyOffline,
            value: l10n.yes,
          ),
        ),
      ],
    );
  }

  static List<_EventTypeConfig> _eventTypesConfig(AppLocalizations l10n) {
    return [
      _EventTypeConfig(
        logType: EventLogTypes.feeding,
        title: l10n.feeding,
        color: Colors.green,
        icon: Icons.restaurant_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.milking,
        title: l10n.milking,
        color: Colors.blueAccent,
        icon: Icons.water_drop_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.deworming,
        title: l10n.deworming,
        color: Colors.orange,
        icon: Icons.bug_report_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.medication,
        title: l10n.medication,
        color: Colors.purple,
        icon: Icons.medical_services_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.vaccination,
        title: l10n.vaccination,
        color: Colors.lightBlue,
        icon: Icons.vaccines_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.disposal,
        title: l10n.disposal,
        color: Colors.brown,
        icon: Icons.delete_sweep_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.weightChange,
        title: l10n.weightChange,
        color: Colors.amber,
        icon: Icons.monitor_weight_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.pregnancy,
        title: l10n.pregnancy,
        color: Colors.pinkAccent,
        icon: Icons.pregnant_woman,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.calving,
        title: l10n.calving,
        color: Colors.redAccent,
        icon: Icons.child_friendly_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.dryoff,
        title: l10n.dryoff,
        color: Colors.deepPurple,
        icon: Icons.hourglass_bottom,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.insemination,
        title: l10n.insemination,
        color: Colors.teal,
        icon: Icons.favorite_outline,
      ),
    ];
  }

  static List<dynamic> _logsForType(EventsProvider provider, String logType) {
    switch (logType) {
      case EventLogTypes.feeding:
        return provider.allFeedings;
      case EventLogTypes.milking:
        return provider.allMilkings;
      case EventLogTypes.deworming:
        return provider.allDewormings;
      case EventLogTypes.medication:
        return provider.allMedications;
      case EventLogTypes.vaccination:
        return provider.allVaccinations;
      case EventLogTypes.disposal:
        return provider.allDisposals;
      case EventLogTypes.weightChange:
        return provider.allWeightChanges;
      case EventLogTypes.pregnancy:
        return provider.allPregnancies;
      case EventLogTypes.calving:
        return provider.allCalvings;
      case EventLogTypes.dryoff:
        return provider.allDryoffs;
      case EventLogTypes.insemination:
        return provider.allInseminations;
      default:
        return const [];
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
    final borderColor = theme.colorScheme.outline.withOpacity(0.15);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTypeCard extends StatelessWidget {
  final _EventTypeConfig config;
  final int count;
  final VoidCallback onTap;

  const _EventTypeCard({
    required this.config,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
    final border = theme.colorScheme.outline.withOpacity(0.15);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                  color: config.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
                child: Icon(config.icon, color: config.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      config.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context)!.recordsText}: $count',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ],
            ),
          ),
      ),
    );
  }
}

class _EventTypeConfig {
  final String logType;
  final String title;
  final Color color;
  final IconData icon;

  const _EventTypeConfig({
    required this.logType,
    required this.title,
    required this.color,
    required this.icon,
  });
}
