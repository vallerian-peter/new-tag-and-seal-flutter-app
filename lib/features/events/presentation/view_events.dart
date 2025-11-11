import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/medication_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/vaccination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/milking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/calving_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/dryoff_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/insemination_model.dart';
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
  final bool showHeaderContextBadges;
  final bool showCardContextRows;

  const ViewEventsScreen({
    super.key,
    required this.title,
    required this.logType,
    this.farmUuid,
    this.livestockUuid,
    required this.eventsProvider,
    this.farmName,
    this.livestockName,
    this.showHeaderContextBadges = false,
    this.showCardContextRows = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final chips = <Widget>[];
    if (showHeaderContextBadges &&
        farmName != null &&
        farmName!.trim().isNotEmpty) {
      chips.add(
        _ContextChip(
          icon: Icons.agriculture,
          label: '${l10n.farm}: ${farmName!.trim()}',
        ),
      );
    }
    if (showHeaderContextBadges &&
        livestockName != null &&
        livestockName!.trim().isNotEmpty) {
      chips.add(
        _ContextChip(
          icon: Icons.pets_rounded,
          label: '${l10n.livestock}: ${livestockName!.trim()}',
        ),
      );
    }

    final displayTitle =
        title.trim().isNotEmpty ? title.trim() : l10n.recordsText;

    return FutureBuilder<List<_LogWithContext>>(
      future: _loadLogsWithReferences(context),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        final totalLogs = snapshot.connectionState == ConnectionState.waiting
            ? null
            : logs.length;

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
                        child: Wrap(spacing: 8, runSpacing: 4, children: chips),
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
              child: Text(l10n.noData, style: theme.textTheme.bodyMedium),
            ),
          );
        }

        final logReferences = Provider.of<LogAdditionalDataProvider>(
          context,
          listen: false,
        );

        final contextInfo = showHeaderContextBadges
            ? const <String>[]
            : <String>[
                if (farmName != null && farmName!.trim().isNotEmpty)
                  '${l10n.farm}: ${farmName!.trim()}',
                if (livestockName != null && livestockName!.trim().isNotEmpty)
                  '${l10n.livestock}: ${livestockName!.trim()}',
              ];

        return Scaffold(
          appBar: buildAppBar(totalLogs),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contextInfo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    contextInfo.join(' • '),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
                    final entry = logs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EventLogCard(
                  logType: logType,
                        log: entry.log,
                  references: logReferences,
                        farmName: entry.farmName,
                        livestockName: entry.livestockName,
                        includeContextRows: showCardContextRows &&
                            (entry.farmName != null || entry.livestockName != null),
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

  Future<List<_LogWithContext>> _loadLogsWithReferences(
    BuildContext context,
  ) async {
    final logReferences = Provider.of<LogAdditionalDataProvider>(
      context,
      listen: false,
    );
    await logReferences.ensureLoaded();

    final List<dynamic> rawLogs;
    if (livestockUuid == null || livestockUuid!.isEmpty) {
      rawLogs = _logsForTypeFromProvider();
    } else {
      rawLogs = await eventsProvider.loadLogsForType(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
      logType: logType,
    );
  }

    final farmUuids = <String>{};
    final livestockUuids = <String>{};

    for (final log in rawLogs) {
      final farmUuid = _extractFarmUuid(log);
      if (farmUuid != null) {
        farmUuids.add(farmUuid);
      }
      final animalUuid = _extractLivestockUuid(log);
      if (animalUuid != null) {
        livestockUuids.add(animalUuid);
      }
    }

    final resolveContext = showCardContextRows;
    final farmNames = resolveContext
        ? await eventsProvider.resolveFarmNames(farmUuids)
        : const <String, String>{};
    final livestockNames = resolveContext
        ? await eventsProvider.resolveLivestockNames(livestockUuids)
        : const <String, String>{};

    return rawLogs
        .map((log) {
          final farmUuid = _extractFarmUuid(log);
          final animalUuid = _extractLivestockUuid(log);
          return _LogWithContext(
            log: log,
            farmUuid: farmUuid,
            livestockUuid: animalUuid,
            farmName: resolveContext && farmUuid != null
                ? farmNames[farmUuid]
                : null,
            livestockName: resolveContext && animalUuid != null
                ? livestockNames[animalUuid]
                : null,
          );
        })
        .toList();
  }

  List<dynamic> _logsForTypeFromProvider() {
    switch (logType) {
      case EventLogTypes.feeding:
        return eventsProvider.allFeedings;
      case EventLogTypes.weightChange:
        return eventsProvider.allWeightChanges;
      case EventLogTypes.deworming:
        return eventsProvider.allDewormings;
      case EventLogTypes.medication:
        return eventsProvider.allMedications;
      case EventLogTypes.vaccination:
        return eventsProvider.allVaccinations;
      case EventLogTypes.disposal:
        return eventsProvider.allDisposals;
      case EventLogTypes.milking:
        return eventsProvider.allMilkings;
      case EventLogTypes.pregnancy:
        return eventsProvider.allPregnancies;
      case EventLogTypes.calving:
        return eventsProvider.allCalvings;
      case EventLogTypes.dryoff:
        return eventsProvider.allDryoffs;
      case EventLogTypes.insemination:
        return eventsProvider.allInseminations;
      default:
        return const [];
    }
  }

  String? _extractFarmUuid(dynamic log) {
    try {
      final value = (log as dynamic).farmUuid as String?;
      if (value == null) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    } catch (_) {
      return null;
    }
  }

  String? _extractLivestockUuid(dynamic log) {
    try {
      final value = (log as dynamic).livestockUuid as String?;
      if (value == null) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    } catch (_) {
      return null;
    }
  }

}

class _EventLogCard extends StatelessWidget {
  final String logType;
  final dynamic log;
  final LogAdditionalDataProvider? references;
  final String? farmName;
  final String? livestockName;
  final bool includeContextRows;

  const _EventLogCard({
    required this.logType,
    required this.log,
    this.references,
    this.farmName,
    this.livestockName,
    required this.includeContextRows,
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

    if (includeContextRows) {
      addRow(l10n.farm, farmName);
      addRow(l10n.livestock, livestockName);
    }

    switch (logType) {
      case EventLogTypes.feeding:
        final feeding = log as FeedingModel;
        icon = Icons.restaurant;
        title = l10n.feeding;
        addRow(l10n.feedingType, _resolveFeedingTypeName(feeding.feedingTypeId));
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
        createdDate = DateTime.tryParse(deworming.createdAt);
        break;
      case EventLogTypes.medication:
        final medication = log as MedicationModel;
        icon = Icons.medical_services;
        title = l10n.medication;
        addRow(l10n.medicine, _resolveMedicineName(medication.medicineId));
        if (medication.diseaseId != null) {
          addRow(l10n.diseaseId, _resolveDiseaseName(medication.diseaseId));
        }
        addRow(l10n.quantity, medication.quantity);
        if (medication.withdrawalPeriod != null &&
            medication.withdrawalPeriod!.trim().isNotEmpty) {
          addRow(l10n.withdrawalPeriod, medication.withdrawalPeriod);
        }
        if (medication.medicationDate != null &&
            medication.medicationDate!.trim().isNotEmpty) {
          final medDate = DateTime.tryParse(medication.medicationDate!);
          addRow(
            l10n.medicationDate,
            medDate != null
                ? dateFormat.format(medDate.toLocal())
                : medication.medicationDate!,
          );
        }
        addRow(l10n.remarks, medication.remarks);
        createdDate = DateTime.tryParse(medication.createdAt);
        break;
      case EventLogTypes.vaccination:
        final vaccination = log as VaccinationModel;
        icon = Icons.vaccines;
        title = l10n.vaccination;
        addRow(l10n.vaccinationNumber, vaccination.vaccinationNo);
        if (vaccination.vaccineId != null) {
          addRow(l10n.vaccine, vaccination.vaccineId.toString());
        }
        if (vaccination.diseaseId != null) {
          addRow(l10n.diseaseId, _resolveDiseaseName(vaccination.diseaseId));
        }
        addRow(l10n.vaccinationStatus, vaccination.status);
        addRow(l10n.vetLicense, vaccination.vetId);
        addRow(l10n.extensionOfficerLicense, vaccination.extensionOfficerId);
        createdDate = DateTime.tryParse(vaccination.createdAt);
        break;
      case EventLogTypes.disposal:
        final disposal = log as DisposalModel;
        icon = Icons.delete_sweep_outlined;
        title = l10n.disposal;
        addRow(l10n.disposalReasons, disposal.reasons);
        if (disposal.disposalTypeId != null) {
          addRow(
            l10n.disposalTypeId,
            _resolveDisposalTypeName(disposal.disposalTypeId),
          );
        }
        addRow(l10n.status, disposal.status);
        addRow(l10n.remarks, disposal.remarks);
        createdDate = DateTime.tryParse(disposal.createdAt);
        break;
      case EventLogTypes.milking:
        final milking = log as MilkingModel;
        icon = Icons.local_drink;
        title = l10n.milking;
        addRow(
          l10n.milkingMethod,
          _resolveMilkingMethodName(milking.milkingMethodId),
        );
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
        addRow(l10n.acidity, milking.acidity);
        addRow(l10n.session, milking.session);
        addRow(l10n.status, milking.status);
        createdDate = DateTime.tryParse(milking.createdAt);
        break;
      case EventLogTypes.pregnancy:
        final pregnancy = log as PregnancyModel;
        icon = Icons.pregnant_woman;
        title = l10n.pregnancy;
        addRow(l10n.testResult, _resolveTestResultName(pregnancy.testResultId));
        addRow(l10n.numberOfMonths, pregnancy.noOfMonths);
        final testDate = pregnancy.testDate != null
            ? DateTime.tryParse(pregnancy.testDate!)
            : null;
        addRow(
          l10n.testDate,
          testDate != null
              ? dateFormat.format(testDate.toLocal())
              : pregnancy.testDate,
        );
        addRow(l10n.status, pregnancy.status);
        addRow(l10n.remarks, pregnancy.remarks);
        createdDate = DateTime.tryParse(pregnancy.createdAt);
        break;
      case EventLogTypes.calving:
        final calving = log as CalvingModel;
        icon = Icons.child_friendly;
        title = l10n.calving;
        final start = DateTime.tryParse(calving.startDate);
        final end = calving.endDate != null
            ? DateTime.tryParse(calving.endDate!)
            : null;
        addRow(
          l10n.startDate,
          start != null
              ? dateFormat.format(start.toLocal())
              : calving.startDate,
        );
        addRow(
          l10n.endDate,
          end != null ? dateFormat.format(end.toLocal()) : calving.endDate,
        );
        addRow(
          l10n.calvingType,
          _resolveCalvingTypeName(calving.calvingTypeId),
        );
        addRow(
          l10n.calvingProblem,
          _resolveCalvingProblemName(calving.calvingProblemsId),
        );
        addRow(
          l10n.reproductiveProblem,
          _resolveReproductiveProblemName(calving.reproductiveProblemId),
        );
        addRow(l10n.remarks, calving.remarks);
        addRow(l10n.status, calving.status);
        createdDate = DateTime.tryParse(calving.createdAt);
        break;
      case EventLogTypes.dryoff:
        final dryoff = log as DryoffModel;
        icon = Icons.hourglass_bottom;
        title = l10n.dryoff;
        final startDry = DateTime.tryParse(dryoff.startDate);
        final endDry = dryoff.endDate != null
            ? DateTime.tryParse(dryoff.endDate!)
            : null;
        addRow(
          l10n.startDate,
          startDry != null
              ? dateFormat.format(startDry.toLocal())
              : dryoff.startDate,
        );
        addRow(
          l10n.endDate,
          endDry != null ? dateFormat.format(endDry.toLocal()) : dryoff.endDate,
        );
        addRow(l10n.reason, dryoff.reason);
        addRow(l10n.remarks, dryoff.remarks);
        createdDate = DateTime.tryParse(dryoff.createdAt);
        break;
      case EventLogTypes.insemination:
        final insemination = log as InseminationModel;
        icon = Icons.biotech;
        title = l10n.insemination;
        addRow(
          l10n.heatType,
          _resolveHeatTypeName(insemination.currentHeatTypeId),
        );
        addRow(
          l10n.inseminationService,
          _resolveInseminationServiceName(insemination.inseminationServiceId),
        );
        addRow(
          l10n.semenStrawType,
          _resolveSemenStrawTypeName(insemination.semenStrawTypeId),
        );
        final date = insemination.inseminationDate != null
            ? DateTime.tryParse(insemination.inseminationDate!)
            : null;
        addRow(
          l10n.inseminationDate,
          date != null
              ? dateFormat.format(date.toLocal())
              : insemination.inseminationDate,
        );
        addRow(l10n.bullCode, insemination.bullCode);
        addRow(l10n.bullBreed, insemination.bullBreed);
        addRow(l10n.semenProductionDate, insemination.semenProductionDate);
        addRow(l10n.productionCountry, insemination.productionCountry);
        addRow(l10n.semenBatchNumber, insemination.semenBatchNumber);
        addRow(l10n.internationalId, insemination.internationalId);
        addRow(l10n.aiCode, insemination.aiCode);
        addRow(l10n.manufacturerName, insemination.manufacturerName);
        addRow(l10n.semenSupplier, insemination.semenSupplier);
        createdDate = DateTime.tryParse(insemination.createdAt);
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

  String _resolveFeedingTypeName(int feedingTypeId) {
    if (references == null) return feedingTypeId.toString();

    for (final type in references!.feedingTypes) {
      if (type.id == feedingTypeId) {
        return type.name;
      }
    }

    return feedingTypeId.toString();
  }

  String _resolveDiseaseName(int? diseaseId) {
    if (diseaseId == null) return '--';
    if (references == null) return diseaseId.toString();

    for (final disease in references!.diseases) {
      if (disease.id == diseaseId) {
        return disease.name;
      }
    }

    return diseaseId.toString();
  }

  String _resolveDisposalTypeName(int? disposalTypeId) {
    if (disposalTypeId == null) return '--';
    if (references == null) return disposalTypeId.toString();

    for (final type in references!.disposalTypes) {
      if (type.id == disposalTypeId) {
        return type.name;
      }
    }

    return disposalTypeId.toString();
  }

  String _resolveMilkingMethodName(int? milkingMethodId) {
    if (milkingMethodId == null) return '--';
    if (references == null) return milkingMethodId.toString();

    for (final method in references!.milkingMethods) {
      if (method.id == milkingMethodId) {
        return method.name;
      }
    }

    return milkingMethodId.toString();
  }

  String _resolveHeatTypeName(int? heatTypeId) {
    if (heatTypeId == null) return '--';
    if (references == null) return heatTypeId.toString();

    for (final heatType in references!.heatTypes) {
      if (heatType.id == heatTypeId) {
        return heatType.name;
      }
    }

    return heatTypeId.toString();
  }

  String _resolveSemenStrawTypeName(int? strawTypeId) {
    if (strawTypeId == null) return '--';
    if (references == null) return strawTypeId.toString();

    for (final straw in references!.semenStrawTypes) {
      if (straw.id == strawTypeId) {
        return straw.name;
      }
    }

    return strawTypeId.toString();
  }

  String _resolveInseminationServiceName(int? serviceId) {
    if (serviceId == null) return '--';
    if (references == null) return serviceId.toString();

    for (final service in references!.inseminationServices) {
      if (service.id == serviceId) {
        return service.name;
      }
    }

    return serviceId.toString();
  }

  String _resolveCalvingTypeName(int? calvingTypeId) {
    if (calvingTypeId == null) return '--';
    if (references == null) return calvingTypeId.toString();

    for (final type in references!.calvingTypes) {
      if (type.id == calvingTypeId) {
        return type.name;
      }
    }

    return calvingTypeId.toString();
  }

  String _resolveCalvingProblemName(int? calvingProblemId) {
    if (calvingProblemId == null) return '--';
    if (references == null) return calvingProblemId.toString();

    for (final problem in references!.calvingProblems) {
      if (problem.id == calvingProblemId) {
        return problem.name;
      }
    }

    return calvingProblemId.toString();
  }

  String _resolveReproductiveProblemName(int? reproductiveProblemId) {
    if (reproductiveProblemId == null) return '--';
    if (references == null) return reproductiveProblemId.toString();

    for (final problem in references!.reproductiveProblems) {
      if (problem.id == reproductiveProblemId) {
        return problem.name;
      }
    }

    return reproductiveProblemId.toString();
  }

  String _resolveTestResultName(int? testResultId) {
    if (testResultId == null) return '--';
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
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            formattedDate,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
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
            ? Colors.white.withValues(alpha: 0.08)
            : primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white.withValues(alpha: 0.85) : primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white.withValues(alpha: 0.85) : primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogWithContext {
  final dynamic log;
  final String? farmUuid;
  final String? livestockUuid;
  final String? farmName;
  final String? livestockName;

  const _LogWithContext({
    required this.log,
    this.farmUuid,
    this.livestockUuid,
    this.farmName,
    this.livestockName,
  });
}
