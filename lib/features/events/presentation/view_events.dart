import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/birth_event_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/aborted_pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/treatment_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/vaccination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/milking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/dryoff_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/insemination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/transfer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/provider/events_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/data/repository/vaccines_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/milking_trend_graph.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/presentation/widgets/multi_farm_milking_trend_graph.dart';

class ViewEventsScreen extends StatefulWidget {
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
  State<ViewEventsScreen> createState() => _ViewEventsScreenState();
}

class _ViewEventsScreenState extends State<ViewEventsScreen> {
  String _selectedFilter = 'all'; // 'all', 'today', or 'thisWeek'

  bool get _isContextSpecific =>
      widget.livestockUuid != null && widget.livestockUuid!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final chips = <Widget>[];
    if (widget.farmName != null && widget.farmName!.trim().isNotEmpty) {
      chips.add(
        _ContextChip(
          icon: Icons.agriculture,
          label: '${l10n.farm}: ${widget.farmName!.trim()}',
        ),
      );
    }
    if (widget.livestockName != null && widget.livestockName!.trim().isNotEmpty) {
      chips.add(
        _ContextChip(
          icon: Icons.pets_rounded,
          label: '${l10n.livestock}: ${widget.livestockName!.trim()}',
        ),
      );
    }

    // Use the title directly (already includes "Calving" or "Farrowing" from livestock details modal)
    // Add "Records" only if title is empty
    final displayTitle = widget.title.trim().isNotEmpty
        ? widget.title.trim()
        : l10n.recordsText;

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadLogsWithReferences(context),
      builder: (context, snapshot) {
        PreferredSizeWidget buildAppBar(
          int? total, 
          List<dynamic>? logs,
          Map<String, String>? farmNamesMap,
        ) {
          final isMilking = widget.logType == EventLogTypes.milking;
          final showSingleLivestockGraph = isMilking && 
              widget.livestockUuid != null && 
              widget.livestockUuid!.isNotEmpty &&
              logs != null;
          final showMultiFarmGraph = isMilking && 
              (widget.livestockUuid == null || widget.livestockUuid!.isEmpty) &&
              logs != null &&
              logs.isNotEmpty &&
              farmNamesMap != null;
          
          // Create a non-nullable reference for use in callbacks
          final nonNullFarmNamesMap = farmNamesMap;
          
          return AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Text(displayTitle),
            actions: [
              // Graph button for single livestock milking view
              if (showSingleLivestockGraph)
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  tooltip: l10n.milkingTrend,
                  onPressed: () {
                    // logs is guaranteed to be non-null when showSingleLivestockGraph is true
                    final milkingLogs = logs
                        .where((log) {
                          if (log is! MilkingModel) return false;
                          return log.livestockUuid == widget.livestockUuid;
                        })
                        .cast<MilkingModel>()
                        .toList();
                    
                    if (milkingLogs.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.noData)),
                      );
                      return;
                    }
                    
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        builder: (context, scrollController) => MilkingTrendGraph(
                          milkingLogs: milkingLogs,
                          livestockName: widget.livestockName ?? l10n.livestock,
                        ),
                      ),
                    );
                  },
                ),
              // Graph button for multi-farm milking view (all livestock)
              if (showMultiFarmGraph)
                IconButton(
                  icon: const Icon(Icons.show_chart),
                  tooltip: l10n.milkingTrendByFarm,
                  onPressed: () {
                    // logs and farmNamesMap are guaranteed to be non-null when showMultiFarmGraph is true
                    final milkingLogs = logs
                        .where((log) => log is MilkingModel)
                        .cast<MilkingModel>()
                        .toList();
                    
                    if (milkingLogs.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.noData)),
                      );
                      return;
                    }
                    
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        builder: (context, scrollController) => MultiFarmMilkingTrendGraph(
                          milkingLogs: milkingLogs,
                          farmNamesMap: nonNullFarmNamesMap ?? const {},
                        ),
                      ),
                    );
                  },
                ),
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
                        child: Wrap(spacing: 8, runSpacing: 4, children: chips),
                      ),
                    ),
                  ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: buildAppBar(null, null, null),
            body: const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: buildAppBar(null, null, null),
            body: Center(
              child: Text(
                l10n.eventsLoadFailed,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final allLogs = data['logs'] as List<dynamic>;
        final vaccineNamesMap = data['vaccineNames'] as Map<String, String>;
        final farmNamesMap = data['farmNames'] as Map<String, String>;
        final livestockNamesMap = data['livestockNames'] as Map<String, String>;
        
        // Filter logs based on selected filter
        final filteredLogs = _filterLogs(allLogs);
        final totalLogs = filteredLogs.length;

        if (allLogs.isEmpty) {
          return Scaffold(
            appBar: buildAppBar(0, allLogs, farmNamesMap),
            body: Center(
              child: Text(l10n.noData, style: theme.textTheme.bodyMedium),
            ),
          );
        }

        final logReferences = Provider.of<LogAdditionalDataProvider>(
          context,
          listen: false,
        );

        // Check if this is milking events to show summary
        final isMilking = widget.logType == EventLogTypes.milking;
        final milkingLogs = isMilking
            ? allLogs
                .where((log) {
                  if (log is! MilkingModel) return false;
                  // If viewing a specific livestock, restrict summary to that livestock
                  if (widget.livestockUuid == null ||
                      widget.livestockUuid!.isEmpty) {
                    return true;
                  }
                  return log.livestockUuid == widget.livestockUuid;
                })
                .cast<MilkingModel>()
                .toList()
            : <MilkingModel>[];

        return Scaffold(
          appBar: buildAppBar(totalLogs, allLogs, farmNamesMap),
          body: Column(
            children: [
              if (isMilking && milkingLogs.isNotEmpty) ...[
                _buildMilkingSummary(context, milkingLogs),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: filteredLogs.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noData,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EventLogCard(
                              logType: widget.logType,
                              log: log,
                              references: logReferences,
                              vaccineNames: vaccineNamesMap,
                              farmName: farmNamesMap[log.farmUuid],
                              livestockName: livestockNamesMap[log.livestockUuid],
                              showContextRows: !_isContextSpecific,
                            ),
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

  /// Parse a milking amount string into litres.
  ///
  /// Supports values like:
  /// - "2.5"   -> 2.5 L
  /// - "2.5l"  / "2.5 L" / "2.5L" -> 2.5 L
  /// - "250ml" / "250 ml"        -> 0.25 L
  /// Falls back to 0 on invalid input.
  double _parseAmountToLitres(String rawAmount) {
    if (rawAmount.trim().isEmpty) return 0;

    final normalized = rawAmount.trim().toLowerCase();

    // Extract numeric value and optional unit (letters)
    final match =
        RegExp(r'^([0-9]*\.?[0-9]+)\s*([a-zA-Z]*)').firstMatch(normalized);
    if (match == null) {
      return double.tryParse(normalized) ?? 0;
    }

    final numericPart = double.tryParse(match.group(1) ?? '') ?? 0;
    final unit = (match.group(2) ?? '').trim();

    if (unit == 'ml') {
      // Convert millilitres to litres
      return numericPart / 1000.0;
    }

    // Default and for 'l' / 'lt' / unknown units – treat as litres
    return numericPart;
  }

  /// Gets the effective date for a log (eventDate ?? createdAt)
  DateTime? _getEffectiveDate(dynamic log) {
    final eventDateStr = log.eventDate;
    final createdAtStr = log.createdAt;
    
    if (eventDateStr != null && eventDateStr.trim().isNotEmpty) {
      return DateTime.tryParse(eventDateStr);
    }
    if (createdAtStr != null && createdAtStr.trim().isNotEmpty) {
      return DateTime.tryParse(createdAtStr);
    }
    return null;
  }

  List<dynamic> _filterLogs(List<dynamic> logs) {
    if (_selectedFilter == 'all') return logs;
    
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    
    return logs.where((log) {
      // Use eventDate ?? createdAt for all log types
      final effectiveDate = _getEffectiveDate(log);
      if (effectiveDate == null) return false;
      final logDate = DateTime(effectiveDate.year, effectiveDate.month, effectiveDate.day);
      
      if (_selectedFilter == 'today') {
        return logDate.isAtSameMomentAs(todayStart) || 
               (logDate.isAfter(todayStart.subtract(const Duration(milliseconds: 1))) &&
                logDate.isBefore(todayEnd));
      } else if (_selectedFilter == 'thisWeek') {
        return logDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               logDate.isBefore(now.add(const Duration(days: 1)));
      }
      return true;
    }).toList();
  }

  Widget _buildMilkingSummary(BuildContext context, List<MilkingModel> milkingLogs) {
    final l10n = AppLocalizations.of(context)!;
    
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    
    double totalLitres = 0;
    double todayLitres = 0;
    double thisWeekLitres = 0;
    
    for (final milking in milkingLogs) {
      // Use eventDate ?? createdAt
      final effectiveDate = milking.eventDate != null && milking.eventDate!.trim().isNotEmpty
          ? DateTime.tryParse(milking.eventDate!)
          : DateTime.tryParse(milking.createdAt);
      if (effectiveDate == null) continue;
      
      final logDate = DateTime(effectiveDate.year, effectiveDate.month, effectiveDate.day);
      final amount = _parseAmountToLitres(milking.amount);
      
      totalLitres += amount;
      
      if (logDate.year == todayStart.year &&
          logDate.month == todayStart.month &&
          logDate.day == todayStart.day) {
        todayLitres += amount;
      }
      
      if (logDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          logDate.isBefore(now.add(const Duration(days: 1)))) {
        thisWeekLitres += amount;
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   l10n.milkingSummary,
          //   style: theme.textTheme.titleLarge?.copyWith(
          //     fontWeight: FontWeight.w700,
          //   ),
          // ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MilkingSummaryCard(
                  title: l10n.allText,
                  value: totalLitres.toStringAsFixed(1),
                  unit: 'L',
                  isSelected: _selectedFilter == 'all',
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'all';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MilkingSummaryCard(
                  title: l10n.upcomingToday,
                  value: todayLitres.toStringAsFixed(1),
                  unit: 'L',
                  isSelected: _selectedFilter == 'today',
                  onTap: () {
                    setState(() {
                      _selectedFilter = _selectedFilter == 'today' ? 'all' : 'today';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MilkingSummaryCard(
                  title: l10n.thisWeek,
                  value: thisWeekLitres.toStringAsFixed(1),
                  unit: 'L',
                  isSelected: _selectedFilter == 'thisWeek',
                  onTap: () {
                    setState(() {
                      _selectedFilter = _selectedFilter == 'thisWeek' ? 'all' : 'thisWeek';
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _loadLogsWithReferences(
    BuildContext context,
  ) async {
    final logReferences = Provider.of<LogAdditionalDataProvider>(
      context,
      listen: false,
    );
    await logReferences.ensureLoaded();

    // Load vaccines for name resolution
    if (!mounted) return {'logs': <dynamic>[], 'vaccineNames': <String, String>{}, 'farmNames': <String, String>{}, 'livestockNames': <String, String>{}};
    final database = Provider.of<AppDatabase>(context, listen: false);
    final vaccinesRepo = VaccinesRepository(database);
    final vaccines = await vaccinesRepo.getVaccines();
    final vaccineNamesMap = <String, String>{};
    for (final vaccine in vaccines) {
      if (vaccine.uuid.isNotEmpty) {
        vaccineNamesMap[vaccine.uuid] = vaccine.name;
      }
    }

    List<dynamic> logs;
    if (widget.initialLogs != null) {
      logs = widget.initialLogs!;
    } else if (widget.livestockUuid == null || widget.livestockUuid!.isEmpty) {
      logs = const [];
    } else {
      logs = await widget.eventsProvider.loadLogsForType(
        farmUuid: widget.farmUuid,
        livestockUuid: widget.livestockUuid!,
        logType: widget.logType,
      );
    }

    // Resolve Farm and Livestock names for each log
    final farmNamesMap = <String, String>{};
    final livestockNamesMap = <String, String>{};

    for (var log in logs) {
      // Check for farmUuid
      if (log.farmUuid != null &&
          log.farmUuid!.isNotEmpty &&
          !farmNamesMap.containsKey(log.farmUuid)) {
        final farm = await database.farmDao.getFarmByUuid(log.farmUuid!);
        if (farm != null) {
          farmNamesMap[log.farmUuid!] = farm.name;
        }
      }

      // Check for livestockUuid
      if (log.livestockUuid != null &&
          log.livestockUuid.isNotEmpty &&
          !livestockNamesMap.containsKey(log.livestockUuid)) {
        final livestock = await database.livestockDao.getLivestockByUuid(
          log.livestockUuid,
        );
        if (livestock != null) {
          // Use LivestockHelper if imported, otherwise just name.
          // Since we can't easily import LivestockHelper here due to context,
          // we'll format it manually or rely on a simple string.
          // Better: Import LivestockHelper at top if possible.
          // Assuming LivestockHelper is available or we duplicate logic for now.
          // Since I can't see the imports, I will assume basic name for now,
          // OR I can try to import LivestockHelper in the next step if missing.
          // Note: The user requested "name-<...ids??>", so I should try to mimic that.

          String displayName = livestock.name;
          String? id = livestock.dummyTagId;
          if (id == null ||
              id.trim().isEmpty ||
              id.trim().toLowerCase() == 'null') {
            id = livestock.rfidTagId;
          }
          if (id == null ||
              id.trim().isEmpty ||
              id.trim().toLowerCase() == 'null') {
            id = livestock.barcodeTagId;
          }
          if (id == null ||
              id.trim().isEmpty ||
              id.trim().toLowerCase() == 'null') {
            id = livestock.identificationNumber;
          }
          if (id.trim().isNotEmpty &&
              id.trim().toLowerCase() != 'null') {
            displayName = '${livestock.name}-${id.trim()}';
          }
          livestockNamesMap[log.livestockUuid] = displayName;
        }
      }
    }

    return {
      'logs': logs,
      'vaccineNames': vaccineNamesMap,
      'farmNames': farmNamesMap,
      'livestockNames': livestockNamesMap,
    };
  }
}

class _EventLogCard extends StatelessWidget {
  final String logType;
  final dynamic log;
  final LogAdditionalDataProvider? references;
  final Map<String, String>? vaccineNames; // Cache of vaccine UUID -> name
  final String? farmName;
  final String? livestockName;
  final bool showContextRows; // Controls whether to show Farm/Livestock rows

  const _EventLogCard({
    required this.logType,
    required this.log,
    this.references,
    this.vaccineNames,
    this.farmName,
    this.livestockName,
    this.showContextRows = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd().add_jm();

    IconData icon = Icons.info_outline;
    String title = l10n.comingSoon;
    final rows = <_LogRow>[];
    DateTime? createdDate;

    // Add Farm and Livestock rows if available AND showContextRows is true
    // This is true when viewing "All Events" and false when viewing events for a specific livestock
    if (showContextRows) {
      if (farmName != null && farmName!.isNotEmpty) {
        rows.add(_LogRow(label: l10n.farm, value: farmName!));
      }
      if (livestockName != null && livestockName!.isNotEmpty) {
        rows.add(_LogRow(label: l10n.livestock, value: livestockName!));
      }
    }

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
        createdDate = feeding.eventDate != null && feeding.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(feeding.eventDate!)
            : DateTime.tryParse(feeding.createdAt);
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
        createdDate = change.eventDate != null && change.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(change.eventDate!)
            : DateTime.tryParse(change.createdAt);
        break;
      case EventLogTypes.deworming:
        final deworming = log as DewormingModel;
        icon = Icons.bug_report;
        title = l10n.deworming;
        final medicineName = _resolveMedicineName(deworming.medicineId);
        final routeName = _resolveAdministrationRouteName(
          deworming.administrationRouteId,
        );

        addRow(l10n.medicine, medicineName);
        addRow(l10n.administrationRoute, routeName);
        addRow(l10n.quantity, deworming.quantity);
        addRow(l10n.dose, deworming.dose);
        if (deworming.vetId != null && deworming.vetId!.trim().isNotEmpty) {
          addRow(l10n.vetLicense, deworming.vetId);
        }
        if (deworming.extensionOfficerId != null &&
            deworming.extensionOfficerId!.trim().isNotEmpty) {
          addRow(l10n.extensionOfficerLicense, deworming.extensionOfficerId);
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
        createdDate = deworming.eventDate != null && deworming.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(deworming.eventDate!)
            : DateTime.tryParse(deworming.createdAt);
        break;
      case EventLogTypes.calving:
      case EventLogTypes.farrowing:
        final birthEvent = log as BirthEventModel;
        icon = Icons.child_friendly;
        // "Calving" or "Farrowing" depending on eventType/species
        title = birthEvent.getEventName();
        final startDate = DateTime.tryParse(birthEvent.startDate);
        if (startDate != null) {
          addRow(l10n.startDate, dateFormat.format(startDate.toLocal()));
        }
        final endDate = birthEvent.endDate != null
            ? DateTime.tryParse(birthEvent.endDate!)
            : null;
        if (endDate != null) {
          addRow(l10n.endDate, dateFormat.format(endDate.toLocal()));
        }
        final birthTypeName = _resolveBirthTypeName(birthEvent.birthTypeId);
        if (birthTypeName != null) {
          addRow(l10n.birthType, birthTypeName);
        }
        final birthProblemName = birthEvent.birthProblemsId != null
            ? _resolveBirthProblemName(birthEvent.birthProblemsId!)
            : null;
        if (birthProblemName != null) {
          addRow(l10n.birthProblem, birthProblemName);
        }
        // Always show reproductive problem if ID exists (even if lookup fails, show ID)
        if (birthEvent.reproductiveProblemId != null) {
          final reproductiveProblemName = _resolveReproductiveProblemName(
            birthEvent.reproductiveProblemId!,
          );
          // Show the name if found, otherwise show the ID as fallback
          final displayValue =
              reproductiveProblemName ??
              'ID: ${birthEvent.reproductiveProblemId}';
          // Always add the row if ID exists (displayValue will never be empty)
          addRow(l10n.reproductiveProblem, displayValue);
        }
        addRow(l10n.remarks, birthEvent.remarks);
        addRow(l10n.status, birthEvent.status);
        createdDate = birthEvent.eventDate != null && birthEvent.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(birthEvent.eventDate!)
            : DateTime.tryParse(birthEvent.createdAt);
        break;
      case EventLogTypes.abortedPregnancy:
        final abortedPregnancy = log as AbortedPregnancyModel;
        icon = Icons.warning_amber;
        title = l10n.abortedPregnancy;
        final abortionDate = DateTime.tryParse(abortedPregnancy.abortionDate);
        if (abortionDate != null) {
          addRow(l10n.abortionDate, dateFormat.format(abortionDate.toLocal()));
        }
        final reproductiveProblemName =
            abortedPregnancy.reproductiveProblemId != null
            ? _resolveReproductiveProblemName(
                abortedPregnancy.reproductiveProblemId!,
              )
            : null;
        if (reproductiveProblemName != null) {
          addRow(l10n.reproductiveProblem, reproductiveProblemName);
        }
        addRow(l10n.remarks, abortedPregnancy.remarks);
        addRow(l10n.status, abortedPregnancy.status);
        createdDate = abortedPregnancy.eventDate != null && abortedPregnancy.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(abortedPregnancy.eventDate!)
            : DateTime.tryParse(abortedPregnancy.createdAt);
        break;
      case EventLogTypes.treatment:
        final treatment = log as TreatmentModel;
        icon = Icons.medical_services_outlined;
        title = l10n.treatment;
        final medicineName = _resolveMedicineName(treatment.medicineId);
        final diseaseName = _resolveDiseaseName(treatment.diseaseId);
        addRow(l10n.medicine, medicineName);
        if (diseaseName != null) {
          addRow(l10n.diseaseId, diseaseName);
        }
        addRow(l10n.quantity, treatment.quantity);
        addRow(l10n.withdrawalPeriod, treatment.withdrawalPeriod);
        final medicationDate = DateTime.tryParse(
          treatment.medicationDate ?? '',
        );
        if (medicationDate != null) {
          addRow(
            l10n.medicationDate,
            dateFormat.format(medicationDate.toLocal()),
          );
        }
        final nextMedicationDate = DateTime.tryParse(
          treatment.nextMedicationDate ?? '',
        );
        if (nextMedicationDate != null) {
          addRow(
            l10n.nextMedicationDate,
            dateFormat.format(nextMedicationDate.toLocal()),
          );
        }
        addRow(l10n.remarks, treatment.remarks);
        createdDate = treatment.eventDate != null && treatment.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(treatment.eventDate!)
            : DateTime.tryParse(treatment.createdAt);
        break;
      case EventLogTypes.vaccination:
        final vaccination = log as VaccinationModel;
        icon = Icons.vaccines_outlined;
        title = l10n.vaccination;
        if (vaccination.vaccinationNo != null &&
            vaccination.vaccinationNo!.trim().isNotEmpty) {
          addRow(l10n.vaccinationNumber, vaccination.vaccinationNo);
        }
        final vaccineName = _resolveVaccineName(vaccination.vaccineUuid);
        final diseaseName = _resolveDiseaseName(vaccination.diseaseId);
        if (vaccineName != null) {
          addRow(l10n.vaccinesText, vaccineName);
        }
        if (diseaseName != null) {
          addRow(l10n.diseaseId, diseaseName);
        }
        if (vaccination.vetId != null && vaccination.vetId!.trim().isNotEmpty) {
          addRow(l10n.vetLicense, vaccination.vetId);
        }
        if (vaccination.extensionOfficerId != null &&
            vaccination.extensionOfficerId!.trim().isNotEmpty) {
          addRow(l10n.extensionOfficerLicense, vaccination.extensionOfficerId);
        }
        addRow(l10n.status, vaccination.status);
        createdDate = vaccination.eventDate != null && vaccination.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(vaccination.eventDate!)
            : DateTime.tryParse(vaccination.createdAt);
        break;
      case EventLogTypes.disposal:
        final disposal = log as DisposalModel;
        icon = Icons.delete_sweep_outlined;
        title = l10n.disposal;
        final disposalTypeName = _resolveDisposalTypeName(
          disposal.disposalTypeId,
        );
        if (disposalTypeName != null) {
          addRow(l10n.disposalTypeId, disposalTypeName);
        }
        addRow(l10n.disposalReasons, disposal.reasons);
        addRow(l10n.remarks, disposal.remarks);
        addRow(l10n.status, disposal.status);
        createdDate = disposal.eventDate != null && disposal.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(disposal.eventDate!)
            : DateTime.tryParse(disposal.createdAt);
        break;
      case EventLogTypes.milking:
        final milking = log as MilkingModel;
        icon = Icons.water_drop;
        title = l10n.milking;
        final milkingMethodName = _resolveMilkingMethodName(
          milking.milkingMethodId,
        );
        if (milkingMethodName != null) {
          addRow(l10n.milkingMethod, milkingMethodName);
        }
        addRow(l10n.amount, milking.amount);
        addRow(l10n.lactometerReading, milking.lactometerReading);
        addRow(l10n.solids, milking.solid);
        addRow(l10n.solidNonFat, milking.solidNonFat);
        addRow(l10n.protein, milking.protein);
        addRow(
          l10n.correctedLactometerReading,
          milking.correctedLactometerReading,
        );
        addRow(l10n.totalSolids, milking.totalSolids);
        addRow(l10n.colonyFormingUnits, milking.colonyFormingUnits);
        if (milking.acidity != null && milking.acidity!.trim().isNotEmpty) {
          addRow(l10n.acidity, milking.acidity);
        }
        addRow(l10n.session, milking.session);
        addRow(l10n.status, milking.status);
        createdDate = milking.eventDate != null && milking.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(milking.eventDate!)
            : DateTime.tryParse(milking.createdAt);
        break;
      case EventLogTypes.dryoff:
        final dryoff = log as DryoffModel;
        icon = Icons.opacity_outlined;
        title = l10n.dryoff;
        final startDate = DateTime.tryParse(dryoff.startDate);
        if (startDate != null) {
          addRow(l10n.startDate, dateFormat.format(startDate.toLocal()));
        }
        final endDate = dryoff.endDate != null
            ? DateTime.tryParse(dryoff.endDate!)
            : null;
        if (endDate != null) {
          addRow(l10n.endDate, dateFormat.format(endDate.toLocal()));
        }
        addRow(l10n.reason, dryoff.reason);
        addRow(l10n.remarks, dryoff.remarks);
        createdDate = dryoff.eventDate != null && dryoff.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(dryoff.eventDate!)
            : DateTime.tryParse(dryoff.createdAt);
        break;
      case EventLogTypes.insemination:
        final insemination = log as InseminationModel;
        icon = Icons.favorite;
        title = l10n.insemination;
        final lastHeatDate = insemination.lastHeatDate != null
            ? DateTime.tryParse(insemination.lastHeatDate!)
            : null;
        if (lastHeatDate != null) {
          addRow(l10n.lastHeatDate, dateFormat.format(lastHeatDate.toLocal()));
        }
        final heatTypeName = _resolveHeatTypeName(
          insemination.currentHeatTypeId,
        );
        if (heatTypeName != null) {
          addRow(l10n.heatType, heatTypeName);
        }
        final inseminationServiceName = _resolveInseminationServiceName(
          insemination.inseminationServiceId,
        );
        if (inseminationServiceName != null) {
          addRow(l10n.inseminationService, inseminationServiceName);
        }
        final semenStrawTypeName = _resolveSemenStrawTypeName(
          insemination.semenStrawTypeId,
        );
        if (semenStrawTypeName != null) {
          addRow(l10n.semenStrawType, semenStrawTypeName);
        }
        final inseminationDate = insemination.inseminationDate != null
            ? DateTime.tryParse(insemination.inseminationDate!)
            : null;
        if (inseminationDate != null) {
          addRow(
            l10n.inseminationDate,
            dateFormat.format(inseminationDate.toLocal()),
          );
        }
        addRow(l10n.bullCode, insemination.bullCode);
        addRow(l10n.bullBreed, insemination.bullBreed);
        final semenProductionDate = insemination.semenProductionDate != null
            ? DateTime.tryParse(insemination.semenProductionDate!)
            : null;
        if (semenProductionDate != null) {
          addRow(
            l10n.semenProductionDate,
            dateFormat.format(semenProductionDate.toLocal()),
          );
        }
        addRow(l10n.productionCountry, insemination.productionCountry);
        addRow(l10n.semenBatchNumber, insemination.semenBatchNumber);
        addRow(l10n.internationalId, insemination.internationalId);
        addRow(l10n.aiCode, insemination.aiCode);
        addRow(l10n.manufacturerName, insemination.manufacturerName);
        addRow(l10n.semenSupplier, insemination.semenSupplier);
        createdDate = insemination.eventDate != null && insemination.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(insemination.eventDate!)
            : DateTime.tryParse(insemination.createdAt);
        break;
      case EventLogTypes.pregnancy:
        final pregnancy = log as PregnancyModel;
        icon = Icons.pregnant_woman;
        title = l10n.pregnancy;
        final testResultName = _resolveTestResultName(pregnancy.testResultId);
        if (testResultName != null) {
          addRow(l10n.testResult, testResultName);
        }
        if (pregnancy.noOfMonths != null &&
            pregnancy.noOfMonths!.trim().isNotEmpty) {
          addRow(l10n.numberOfMonths, pregnancy.noOfMonths);
        }
        final testDate = pregnancy.testDate != null
            ? DateTime.tryParse(pregnancy.testDate!)
            : null;
        if (testDate != null) {
          addRow(l10n.testDate, dateFormat.format(testDate.toLocal()));
        }
        addRow(l10n.status, pregnancy.status);
        addRow(l10n.remarks, pregnancy.remarks);
        createdDate = pregnancy.eventDate != null && pregnancy.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(pregnancy.eventDate!)
            : DateTime.tryParse(pregnancy.createdAt);
        break;
      case EventLogTypes.transfer:
        final transfer = log as TransferModel;
        icon = Icons.swap_horiz;
        title = l10n.transfer;
        if (transfer.farmName != null && transfer.farmName!.trim().isNotEmpty) {
          addRow(l10n.fromFarmLabel, transfer.farmName);
        }
        if (transfer.toFarmName != null &&
            transfer.toFarmName!.trim().isNotEmpty) {
          addRow(l10n.toFarmLabel, transfer.toFarmName);
        }
        final transferDate = DateTime.tryParse(transfer.transferDate);
        if (transferDate != null) {
          addRow(
            l10n.transferDateLabel,
            dateFormat.format(transferDate.toLocal()),
          );
        }
        addRow(l10n.reason, transfer.reason);
        if (transfer.price != null && transfer.price!.trim().isNotEmpty) {
          addRow(l10n.transferPriceLabel, transfer.price);
        }
        if (transfer.transporterId != null) {
          addRow(l10n.transporterIdLabel, transfer.transporterId.toString());
        }
        addRow(l10n.remarks, transfer.remarks);
        if (transfer.status != null && transfer.status!.trim().isNotEmpty) {
          addRow(l10n.status, transfer.status);
        }
        createdDate = transfer.eventDate != null && transfer.eventDate!.trim().isNotEmpty
            ? DateTime.tryParse(transfer.eventDate!)
            : DateTime.tryParse(transfer.createdAt);
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

  String? _resolveBirthTypeName(int? birthTypeId) {
    if (birthTypeId == null) return null;
    if (references == null) return birthTypeId.toString();

    // Try birth types first
    for (final type in references!.birthTypes) {
      if (type.id == birthTypeId) {
        return type.name;
      }
    }

    // Fallback to calving types for backward compatibility
    for (final type in references!.calvingTypes) {
      if (type.id == birthTypeId) {
        return type.name;
      }
    }

    return birthTypeId.toString();
  }

  String? _resolveBirthProblemName(int birthProblemId) {
    if (references == null) return birthProblemId.toString();

    // Try birth problems first
    for (final problem in references!.birthProblems) {
      if (problem.id == birthProblemId) {
        return problem.name;
      }
    }

    // Fallback to calving problems for backward compatibility
    for (final problem in references!.calvingProblems) {
      if (problem.id == birthProblemId) {
        return problem.name;
      }
    }

    return birthProblemId.toString();
  }

  String? _resolveReproductiveProblemName(int reproductiveProblemId) {
    if (references == null) {
      // References not loaded, return null so caller can show ID
      return null;
    }

    // Check if reproductive problems list is loaded
    final problems = references!.reproductiveProblems;
    if (problems.isEmpty) {
      // List is empty, return null so caller can show ID
      return null;
    }

    // Search for the problem by ID
    for (final problem in problems) {
      if (problem.id == reproductiveProblemId) {
        return problem.name;
      }
    }

    // Problem not found in list, return null so caller can show ID
    return null;
  }

  String? _resolveDiseaseName(int? diseaseId) {
    if (diseaseId == null) return null;
    if (references == null) return diseaseId.toString();

    for (final disease in references!.diseases) {
      if (disease.id == diseaseId) {
        return disease.name;
      }
    }

    return diseaseId.toString();
  }

  String? _resolveVaccineName(String? vaccineUuid) {
    if (vaccineUuid == null || vaccineUuid.isEmpty) return null;
    // Look up vaccine name from cache if available
    if (vaccineNames != null && vaccineNames!.containsKey(vaccineUuid)) {
      return vaccineNames![vaccineUuid];
    }
    // Fallback: return null (will be hidden in UI)
    return null;
  }

  String? _resolveDisposalTypeName(int? disposalTypeId) {
    if (disposalTypeId == null) return null;
    if (references == null) return disposalTypeId.toString();

    for (final type in references!.disposalTypes) {
      if (type.id == disposalTypeId) {
        return type.name;
      }
    }

    return disposalTypeId.toString();
  }

  String? _resolveMilkingMethodName(int? milkingMethodId) {
    if (milkingMethodId == null) return null;
    if (references == null) return milkingMethodId.toString();

    for (final method in references!.milkingMethods) {
      if (method.id == milkingMethodId) {
        return method.name;
      }
    }

    return milkingMethodId.toString();
  }

  String? _resolveHeatTypeName(int? heatTypeId) {
    if (heatTypeId == null) return null;
    if (references == null) return heatTypeId.toString();

    for (final type in references!.heatTypes) {
      if (type.id == heatTypeId) {
        return type.name;
      }
    }

    return heatTypeId.toString();
  }

  String? _resolveInseminationServiceName(int? serviceId) {
    if (serviceId == null) return null;
    if (references == null) return serviceId.toString();

    for (final service in references!.inseminationServices) {
      if (service.id == serviceId) {
        return service.name;
      }
    }

    return serviceId.toString();
  }

  String? _resolveSemenStrawTypeName(int? strawTypeId) {
    if (strawTypeId == null) return null;
    if (references == null) return strawTypeId.toString();

    for (final type in references!.semenStrawTypes) {
      if (type.id == strawTypeId) {
        return type.name;
      }
    }

    return strawTypeId.toString();
  }

  String? _resolveTestResultName(int? testResultId) {
    if (testResultId == null) return null;
    if (references == null) return testResultId.toString();

    for (final result in references!.testResults) {
      if (result.id == testResultId) {
        return result.name;
      }
    }

    return testResultId.toString();
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
              title: AppLocalizations.of(context)!.eventDate,
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

  const _LogFooter({required this.title, required this.date});

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

class _MilkingSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final bool isSelected;
  final VoidCallback onTap;

  const _MilkingSummaryCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withOpacity(0.15);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Responsive value + unit row to avoid overflow with large numbers
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContextChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.15)
              : primary.withOpacity(0.2),
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
