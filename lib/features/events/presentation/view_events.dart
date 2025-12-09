import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/birth_event_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/aborted_pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/medication_model.dart';
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

    // Use the title directly (already includes "Calving" or "Farrowing" from livestock details modal)
    // Add "Records" only if title is empty
    final displayTitle = title.trim().isNotEmpty 
        ? title.trim() 
        : l10n.recordsText;

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadLogsWithReferences(context),
      builder: (context, snapshot) {
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

        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
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

        final data = snapshot.data!;
        final logs = data['logs'] as List<dynamic>;
        final vaccineNamesMap = data['vaccineNames'] as Map<String, String>;
        final totalLogs = logs.length;

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
                  vaccineNames: vaccineNamesMap,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadLogsWithReferences(BuildContext context) async {
    final logReferences =
        Provider.of<LogAdditionalDataProvider>(context, listen: false);
    await logReferences.ensureLoaded();

    // Load vaccines for name resolution
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
    if (initialLogs != null) {
      logs = initialLogs!;
    } else if (livestockUuid == null || livestockUuid!.isEmpty) {
      logs = const [];
    } else {
      logs = await eventsProvider.loadLogsForType(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid!,
        logType: logType,
      );
    }

    return {
      'logs': logs,
      'vaccineNames': vaccineNamesMap,
    };
  }

}


class _EventLogCard extends StatelessWidget {
  final String logType;
  final dynamic log;
  final LogAdditionalDataProvider? references;
  final Map<String, String>? vaccineNames; // Cache of vaccine UUID -> name

  const _EventLogCard({
    required this.logType,
    required this.log,
    this.references,
    this.vaccineNames,
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
          final reproductiveProblemName = _resolveReproductiveProblemName(birthEvent.reproductiveProblemId!);
          // Show the name if found, otherwise show the ID as fallback
          final displayValue = reproductiveProblemName ?? 'ID: ${birthEvent.reproductiveProblemId}';
          // Always add the row if ID exists (displayValue will never be empty)
          addRow(l10n.reproductiveProblem, displayValue);
        }
        addRow(l10n.remarks, birthEvent.remarks);
        addRow(l10n.status, birthEvent.status);
        createdDate = DateTime.tryParse(birthEvent.createdAt);
        break;
      case EventLogTypes.abortedPregnancy:
        final abortedPregnancy = log as AbortedPregnancyModel;
        icon = Icons.warning_amber;
        title = l10n.abortedPregnancy;
        final abortionDate = DateTime.tryParse(abortedPregnancy.abortionDate);
        if (abortionDate != null) {
          addRow(l10n.abortionDate, dateFormat.format(abortionDate.toLocal()));
        }
        final reproductiveProblemName = abortedPregnancy.reproductiveProblemId != null
            ? _resolveReproductiveProblemName(abortedPregnancy.reproductiveProblemId!)
            : null;
        if (reproductiveProblemName != null) {
          addRow(l10n.reproductiveProblem, reproductiveProblemName);
        }
        addRow(l10n.remarks, abortedPregnancy.remarks);
        addRow(l10n.status, abortedPregnancy.status);
        createdDate = DateTime.tryParse(abortedPregnancy.createdAt);
        break;
      case EventLogTypes.medication:
        final medication = log as MedicationModel;
        icon = Icons.medical_services_outlined;
        title = l10n.medication;
        final medicineName = _resolveMedicineName(medication.medicineId);
        final diseaseName = _resolveDiseaseName(medication.diseaseId);
        addRow(l10n.medicine, medicineName);
        if (diseaseName != null) {
          addRow(l10n.diseaseId, diseaseName);
        }
        addRow(l10n.quantity, medication.quantity);
        addRow(l10n.withdrawalPeriod, medication.withdrawalPeriod);
        final medicationDate = DateTime.tryParse(medication.medicationDate ?? '');
        if (medicationDate != null) {
          addRow(l10n.medicationDate, dateFormat.format(medicationDate.toLocal()));
        }
        addRow(l10n.remarks, medication.remarks);
        createdDate = DateTime.tryParse(medication.createdAt);
        break;
      case EventLogTypes.vaccination:
        final vaccination = log as VaccinationModel;
        icon = Icons.vaccines_outlined;
        title = l10n.vaccination;
        if (vaccination.vaccinationNo != null && vaccination.vaccinationNo!.trim().isNotEmpty) {
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
        if (vaccination.extensionOfficerId != null && vaccination.extensionOfficerId!.trim().isNotEmpty) {
          addRow(l10n.extensionOfficerLicense, vaccination.extensionOfficerId);
        }
        addRow(l10n.status, vaccination.status);
        createdDate = DateTime.tryParse(vaccination.createdAt);
        break;
      case EventLogTypes.disposal:
        final disposal = log as DisposalModel;
        icon = Icons.delete_sweep_outlined;
        title = l10n.disposal;
        final disposalTypeName = _resolveDisposalTypeName(disposal.disposalTypeId);
        if (disposalTypeName != null) {
          addRow(l10n.disposalTypeId, disposalTypeName);
        }
        addRow(l10n.disposalReasons, disposal.reasons);
        addRow(l10n.remarks, disposal.remarks);
        addRow(l10n.status, disposal.status);
        createdDate = DateTime.tryParse(disposal.createdAt);
        break;
      case EventLogTypes.milking:
        final milking = log as MilkingModel;
        icon = Icons.water_drop;
        title = l10n.milking;
        final milkingMethodName = _resolveMilkingMethodName(milking.milkingMethodId);
        if (milkingMethodName != null) {
          addRow(l10n.milkingMethod, milkingMethodName);
        }
        addRow(l10n.amount, milking.amount);
        addRow(l10n.lactometerReading, milking.lactometerReading);
        addRow(l10n.solids, milking.solid);
        addRow(l10n.solidNonFat, milking.solidNonFat);
        addRow(l10n.protein, milking.protein);
        addRow(l10n.correctedLactometerReading, milking.correctedLactometerReading);
        addRow(l10n.totalSolids, milking.totalSolids);
        addRow(l10n.colonyFormingUnits, milking.colonyFormingUnits);
        if (milking.acidity != null && milking.acidity!.trim().isNotEmpty) {
          addRow(l10n.acidity, milking.acidity);
        }
        addRow(l10n.session, milking.session);
        addRow(l10n.status, milking.status);
        createdDate = DateTime.tryParse(milking.createdAt);
        break;
      case EventLogTypes.dryoff:
        final dryoff = log as DryoffModel;
        icon = Icons.opacity_outlined;
        title = l10n.dryoff;
        final startDate = DateTime.tryParse(dryoff.startDate);
        if (startDate != null) {
          addRow(l10n.startDate, dateFormat.format(startDate.toLocal()));
        }
        final endDate = dryoff.endDate != null ? DateTime.tryParse(dryoff.endDate!) : null;
        if (endDate != null) {
          addRow(l10n.endDate, dateFormat.format(endDate.toLocal()));
        }
        addRow(l10n.reason, dryoff.reason);
        addRow(l10n.remarks, dryoff.remarks);
        createdDate = DateTime.tryParse(dryoff.createdAt);
        break;
      case EventLogTypes.insemination:
        final insemination = log as InseminationModel;
        icon = Icons.favorite;
        title = l10n.insemination;
        final lastHeatDate = insemination.lastHeatDate != null ? DateTime.tryParse(insemination.lastHeatDate!) : null;
        if (lastHeatDate != null) {
          addRow(l10n.lastHeatDate, dateFormat.format(lastHeatDate.toLocal()));
        }
        final heatTypeName = _resolveHeatTypeName(insemination.currentHeatTypeId);
        if (heatTypeName != null) {
          addRow(l10n.heatType, heatTypeName);
        }
        final inseminationServiceName = _resolveInseminationServiceName(insemination.inseminationServiceId);
        if (inseminationServiceName != null) {
          addRow(l10n.inseminationService, inseminationServiceName);
        }
        final semenStrawTypeName = _resolveSemenStrawTypeName(insemination.semenStrawTypeId);
        if (semenStrawTypeName != null) {
          addRow(l10n.semenStrawType, semenStrawTypeName);
        }
        final inseminationDate = insemination.inseminationDate != null ? DateTime.tryParse(insemination.inseminationDate!) : null;
        if (inseminationDate != null) {
          addRow(l10n.inseminationDate, dateFormat.format(inseminationDate.toLocal()));
        }
        addRow(l10n.bullCode, insemination.bullCode);
        addRow(l10n.bullBreed, insemination.bullBreed);
        final semenProductionDate = insemination.semenProductionDate != null ? DateTime.tryParse(insemination.semenProductionDate!) : null;
        if (semenProductionDate != null) {
          addRow(l10n.semenProductionDate, dateFormat.format(semenProductionDate.toLocal()));
        }
        addRow(l10n.productionCountry, insemination.productionCountry);
        addRow(l10n.semenBatchNumber, insemination.semenBatchNumber);
        addRow(l10n.internationalId, insemination.internationalId);
        addRow(l10n.aiCode, insemination.aiCode);
        addRow(l10n.manufacturerName, insemination.manufacturerName);
        addRow(l10n.semenSupplier, insemination.semenSupplier);
        createdDate = DateTime.tryParse(insemination.createdAt);
        break;
      case EventLogTypes.pregnancy:
        final pregnancy = log as PregnancyModel;
        icon = Icons.pregnant_woman;
        title = l10n.pregnancy;
        final testResultName = _resolveTestResultName(pregnancy.testResultId);
        if (testResultName != null) {
          addRow(l10n.testResult, testResultName);
        }
        if (pregnancy.noOfMonths != null && pregnancy.noOfMonths!.trim().isNotEmpty) {
          addRow(l10n.numberOfMonths, pregnancy.noOfMonths);
        }
        final testDate = pregnancy.testDate != null ? DateTime.tryParse(pregnancy.testDate!) : null;
        if (testDate != null) {
          addRow(l10n.testDate, dateFormat.format(testDate.toLocal()));
        }
        addRow(l10n.status, pregnancy.status);
        addRow(l10n.remarks, pregnancy.remarks);
        createdDate = DateTime.tryParse(pregnancy.createdAt);
        break;
      case EventLogTypes.transfer:
        final transfer = log as TransferModel;
        icon = Icons.swap_horiz;
        title = l10n.transfer;
        if (transfer.farmName != null && transfer.farmName!.trim().isNotEmpty) {
          addRow(l10n.fromFarmLabel, transfer.farmName);
        }
        if (transfer.toFarmName != null && transfer.toFarmName!.trim().isNotEmpty) {
          addRow(l10n.toFarmLabel, transfer.toFarmName);
        }
        final transferDate = DateTime.tryParse(transfer.transferDate);
        if (transferDate != null) {
          addRow(l10n.transferDateLabel, dateFormat.format(transferDate.toLocal()));
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
        createdDate = DateTime.tryParse(transfer.createdAt);
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

