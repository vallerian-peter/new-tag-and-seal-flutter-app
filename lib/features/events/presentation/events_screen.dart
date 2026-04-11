import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/sync.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/view_events.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  SyncUnsyncedSummary _unsyncedSummary = const SyncUnsyncedSummary.empty();
  bool _isUnsyncedLoading = false;
  String? _unsyncedError;
  Map<String, int> _todayActivitiesByAnimalGroup = const {};
  bool _isTodayActivityLoading = false;
  _ActivityRange _selectedActivityRange = _ActivityRange.today;
  int _selectedRangeEventsCount = 0;
  Set<String> _selectedRangeAttributableLogKeys = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final provider = context.read<EventsProvider>();
    await provider.loadAllEvents();
    await _loadTodayActivitiesByAnimalGroup(provider);
    await _loadUnsyncedSummary();
  }

  Future<void> _loadTodayActivitiesByAnimalGroup(EventsProvider provider) async {
    setState(() => _isTodayActivityLoading = true);
    try {
      final db = context.read<AppDatabase>();
      final livestockTypes = await db.livestockTypeDao.getAllLivestockTypes();
      final livestockTypeMap = <int, String>{
        for (final item in livestockTypes) item.id: item.name,
      };

      final activityCounts = <String, int>{};
      int matchedEvents = 0;
      final attributableLogKeys = <String>{};
      final allLogs = _allEventLogs(provider);
      for (final log in allLogs) {
        final effectiveDate = _extractEffectiveDate(log);
        if (effectiveDate == null || !_matchesSelectedRange(effectiveDate)) {
          continue;
        }
        matchedEvents++;
        final livestockUuid = _extractLivestockUuid(log);
        if (livestockUuid == null || livestockUuid.isEmpty) continue;
        final livestock = await db.livestockDao.getLivestockByUuid(livestockUuid);
        if (livestock == null) continue;
        final groupName = livestockTypeMap[livestock.livestockTypeId];
        if (groupName == null || groupName.trim().isEmpty) {
          continue;
        }
        activityCounts[groupName] = (activityCounts[groupName] ?? 0) + 1;
        final key = _eventLogKey(log);
        if (key != null) {
          attributableLogKeys.add(key);
        }
      }

      if (!mounted) return;
      setState(() {
        _todayActivitiesByAnimalGroup = Map<String, int>.fromEntries(
          activityCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)),
        );
        _selectedRangeEventsCount = matchedEvents;
        _selectedRangeAttributableLogKeys = attributableLogKeys;
        _isTodayActivityLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _todayActivitiesByAnimalGroup = const {};
        _selectedRangeEventsCount = 0;
        _selectedRangeAttributableLogKeys = const {};
        _isTodayActivityLoading = false;
      });
    }
  }

  Future<void> _loadUnsyncedSummary() async {
    setState(() {
      _isUnsyncedLoading = true;
      _unsyncedError = null;
    });

    try {
      final database = context.read<AppDatabase>();
      final summary = await Sync.getUnsyncedSummary(database);
      if (!mounted) return;
      setState(() {
        _unsyncedSummary = summary;
        _isUnsyncedLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUnsyncedLoading = false;
        _unsyncedError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final eventsProvider = context.watch<EventsProvider>();

    final eventTypes = _eventTypesConfig(l10n);
    // If current user is an extension officer, filter to technical event types only
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final filteredEventTypes = authProvider.isExtensionOfficer
        ? eventTypes
              .where((cfg) => authProvider.hasAccessToLogType(cfg.logType))
              .toList()
        : eventTypes;
    final totalLogs = filteredEventTypes.fold<int>(
      0,
      (acc, config) =>
          acc + _logsForType(eventsProvider, config.logType).length,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.allEvents,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l10n.eventsScreenSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _refreshData,
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

            _buildTodayActivitiesByGroupCard(context, eventsProvider),
            const SizedBox(height: 12),
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
            ...filteredEventTypes.map((config) {
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
                        initialLogs: logs,
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

  Widget _buildSummaryRow(BuildContext context, int totalLogs, int typeCount) {
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
            icon: Icons.sync_problem_outlined,
            color: Colors.indigo,
            title: l10n.unsyncedData,
            value: _isUnsyncedLoading
                ? '...'
                : _unsyncedError != null
                ? '--'
                : _unsyncedSummary.totalPending.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayActivitiesByGroupCard(
    BuildContext context,
    EventsProvider eventsProvider,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final surface = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
    final borderColor = theme.colorScheme.outline.withOpacity(0.15);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.livestockType} · ${_activityRangeLabel(l10n, _selectedActivityRange)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PopupMenuButton<_ActivityRange>(
                tooltip: l10n.recordsText,
                icon: const Icon(Icons.filter_alt_outlined),
                color: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                onSelected: (value) async {
                  setState(() => _selectedActivityRange = value);
                  await _loadTodayActivitiesByAnimalGroup(eventsProvider);
                },
                itemBuilder: (ctx) => _ActivityRange.values
                    .map(
                      (range) => PopupMenuItem<_ActivityRange>(
                        value: range,
                        child: Text(_activityRangeLabel(l10n, range)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isTodayActivityLoading)
            const LinearProgressIndicator()
          else if (_todayActivitiesByAnimalGroup.isEmpty &&
              _selectedRangeEventsCount <= 0)
            Text(
              l10n.noData,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
              ),
            )
          else if (_todayActivitiesByAnimalGroup.isEmpty)
            Text(
              '${l10n.recordsText}: $_selectedRangeEventsCount',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
                fontWeight: FontWeight.w600,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.recordsText}: $_selectedRangeEventsCount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${_todayActivitiesByAnimalGroup.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ..._todayActivitiesByAnimalGroup.entries.take(2).map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _showFilteredEventsSheet(context, eventsProvider),
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.viewEvents),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _allEventLogs(EventsProvider provider) {
    return [
      ...provider.allFeedings,
      ...provider.allInseminations,
      ...provider.allPregnancies,
      ...provider.allDewormings,
      ...provider.allTreatments,
      ...provider.allVaccinations,
      ...provider.allDisposals,
      ...provider.allWeightChanges,
      ...provider.allMilkings,
      ...provider.allBirthEvents,
      ...provider.allAbortedPregnancies,
      ...provider.allDryoffs,
      ...provider.allTeethClippings,
      ...provider.allTailDockings,
      ...provider.allIronInjections,
      ...provider.allLivestockMarkings,
      ...provider.allStageChanges,
      ...provider.allPrepuceConditions,
    ];
  }

  DateTime? _extractEffectiveDate(dynamic log) {
    final dynamic eventDateRaw = log.eventDate;
    if (eventDateRaw is String && eventDateRaw.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(eventDateRaw);
      if (parsed != null) return parsed;
    }
    final dynamic createdAtRaw = log.createdAt;
    if (createdAtRaw is String && createdAtRaw.trim().isNotEmpty) {
      return DateTime.tryParse(createdAtRaw);
    }
    return null;
  }

  String? _extractLivestockUuid(dynamic log) {
    final dynamic uuid = log.livestockUuid;
    if (uuid is String && uuid.trim().isNotEmpty) return uuid;
    return null;
  }

  String? _eventLogKey(dynamic log) {
    final dynamic uuid = log.uuid;
    if (uuid is String && uuid.trim().isNotEmpty) {
      return '${log.runtimeType}::${uuid.trim()}';
    }
    final livestockUuid = _extractLivestockUuid(log) ?? '';
    final createdAt = (log.createdAt is String) ? (log.createdAt as String) : '';
    if (livestockUuid.isEmpty && createdAt.isEmpty) return null;
    return '${log.runtimeType}::$livestockUuid::$createdAt';
  }

  /// First day of the month that is [monthsBeforeCurrent] months before [now]'s month.
  /// Example: April 2026 with monthsBeforeCurrent 11 → May 1, 2025 (12 months incl. current).
  DateTime _firstDayOfMonthBefore(DateTime now, int monthsBeforeCurrent) {
    var y = now.year;
    var m = now.month - monthsBeforeCurrent;
    while (m < 1) {
      m += 12;
      y -= 1;
    }
    return DateTime(y, m, 1);
  }

  bool _matchesSelectedRange(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    switch (_selectedActivityRange) {
      case _ActivityRange.today:
        return !local.isBefore(todayStart) && local.isBefore(tomorrowStart);
      case _ActivityRange.yesterday:
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));
        return !local.isBefore(yesterdayStart) && local.isBefore(todayStart);
      case _ActivityRange.thisWeek:
        final sevenDaysBack = todayStart.subtract(const Duration(days: 6));
        return !local.isBefore(sevenDaysBack) && local.isBefore(tomorrowStart);
      case _ActivityRange.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return !local.isBefore(monthStart) && local.isBefore(tomorrowStart);
      case _ActivityRange.last6Months:
        // Six calendar months including current month: from 1st of (current − 5) through end of today.
        final sixMonthWindowStart = _firstDayOfMonthBefore(now, 5);
        return !local.isBefore(sixMonthWindowStart) && local.isBefore(tomorrowStart);
      case _ActivityRange.thisYear:
        // Twelve calendar months including current: 11 months back + current month (rolling year).
        final twelveMonthWindowStart = _firstDayOfMonthBefore(now, 11);
        return !local.isBefore(twelveMonthWindowStart) && local.isBefore(tomorrowStart);
      case _ActivityRange.last6Years:
        final sixYearsBack = DateTime(now.year - 6, now.month, now.day);
        return !local.isBefore(sixYearsBack) && local.isBefore(tomorrowStart);
    }
  }

  String _activityRangeLabel(AppLocalizations l10n, _ActivityRange range) {
    switch (range) {
      case _ActivityRange.today:
        return l10n.upcomingToday;
      case _ActivityRange.yesterday:
        return l10n.yesterday;
      case _ActivityRange.thisWeek:
        return l10n.thisWeek;
      case _ActivityRange.thisMonth:
        return l10n.thisMonth;
      case _ActivityRange.last6Months:
        return l10n.last6Months;
      case _ActivityRange.thisYear:
        return l10n.lastYear;
      case _ActivityRange.last6Years:
        return l10n.last6Years;
    }
  }

  List<dynamic> _filterLogsForSelectedRange(List<dynamic> logs) {
    return logs.where((log) {
      final effectiveDate = _extractEffectiveDate(log);
      return effectiveDate != null && _matchesSelectedRange(effectiveDate);
    }).toList();
  }

  Future<void> _showFilteredEventsSheet(
    BuildContext context,
    EventsProvider eventsProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventTypes = _eventTypesConfig(l10n);
    final filteredEventTypes = authProvider.isExtensionOfficer
        ? eventTypes
              .where((cfg) => authProvider.hasAccessToLogType(cfg.logType))
              .toList()
        : eventTypes;

    final entries = filteredEventTypes
        .map((config) {
          final logs = _filterLogsForSelectedRange(
            _logsForType(eventsProvider, config.logType),
          ).where((log) {
            final key = _eventLogKey(log);
            return key != null && _selectedRangeAttributableLogKeys.contains(key);
          }).toList();
          return (config: config, logs: logs);
        })
        .where((entry) => entry.logs.isNotEmpty)
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_activityRangeLabel(l10n, _selectedActivityRange)} ${l10n.recordsText}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: entries.isEmpty
                      ? Center(child: Text(l10n.noData))
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final item = entries[index];
                            return _EventTypeCard(
                              config: item.config,
                              count: item.logs.length,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ViewEventsScreen(
                                      title: item.config.title,
                                      logType: item.config.logType,
                                      eventsProvider: eventsProvider,
                                      initialLogs: item.logs,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
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
        logType: EventLogTypes.insemination,
        title: l10n.insemination,
        color: Colors.pinkAccent,
        icon: Icons.favorite_outline,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.pregnancy,
        title: l10n.pregnancy,
        color: Colors.deepPurple,
        icon: Icons.pregnant_woman,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.deworming,
        title: l10n.deworming,
        color: Colors.orange,
        icon: Icons.bug_report_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.treatment,
        title: l10n.treatment,
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
        logType: EventLogTypes.milking,
        title: l10n.milking,
        color: Colors.lightBlueAccent,
        icon: Icons.water_drop_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.calving,
        // Generic title for both calving and farrowing
        title: l10n.birthEvent,
        color: Colors.brown,
        icon: Icons.child_friendly,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.abortedPregnancy,
        title: l10n.abortedPregnancy,
        color: Colors.red,
        icon: Icons.warning_amber_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.dryoff,
        title: l10n.dryoff,
        color: Colors.blueGrey,
        icon: Icons.opacity_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.teethClipping,
        title: l10n.teethClipping,
        color: Colors.blue,
        icon: Icons.content_cut_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.tailDocking,
        title: l10n.tailDocking,
        color: Colors.deepOrange,
        icon: Icons.cut_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.ironInjection,
        title: l10n.ironInjection,
        color: Colors.redAccent,
        icon: Icons.vaccines_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.livestockMarking,
        title: l10n.livestockMarking,
        color: Colors.indigo,
        icon: Icons.brush_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.stageChange,
        title: l10n.stageChange,
        color: Colors.teal,
        icon: Icons.trending_up_outlined,
      ),
      _EventTypeConfig(
        logType: EventLogTypes.prepuceCondition,
        title: l10n.prepuceConditionTitle,
        color: Colors.deepPurple,
        icon: Icons.medical_information_outlined,
      ),
    ];
  }

  static List<dynamic> _logsForType(EventsProvider provider, String logType) {
    switch (logType) {
      case EventLogTypes.feeding:
        return provider.allFeedings;
      case EventLogTypes.deworming:
        return provider.allDewormings;
      case EventLogTypes.treatment:
        return provider.allTreatments;
      case EventLogTypes.vaccination:
        return provider.allVaccinations;
      case EventLogTypes.disposal:
        return provider.allDisposals;
      case EventLogTypes.insemination:
        return provider.allInseminations;
      case EventLogTypes.pregnancy:
        return provider.allPregnancies;
      case EventLogTypes.milking:
        return provider.allMilkings;
      case EventLogTypes.dryoff:
        return provider.allDryoffs;
      case EventLogTypes.calving:
      case EventLogTypes.farrowing:
        // Both calving and farrowing are stored as birth events
        return provider.allBirthEvents;
      case EventLogTypes.abortedPregnancy:
        return provider.allAbortedPregnancies;
      case EventLogTypes.weightChange:
        return provider.allWeightChanges;
      case EventLogTypes.teethClipping:
        return provider.allTeethClippings;
      case EventLogTypes.tailDocking:
        return provider.allTailDockings;
      case EventLogTypes.ironInjection:
        return provider.allIronInjections;
      case EventLogTypes.livestockMarking:
        return provider.allLivestockMarkings;
      case EventLogTypes.stageChange:
        return provider.allStageChanges;
      case EventLogTypes.prepuceCondition:
        return provider.allPrepuceConditions;
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
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
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

enum _ActivityRange {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  last6Months,
  thisYear,
  last6Years,
}
