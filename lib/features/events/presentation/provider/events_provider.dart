import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
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
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/transfer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/repo/events_repo.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/summary/event_summary.dart';

class EventsProvider extends ChangeNotifier {
  final EventsRepositoryInterface _eventsRepository;

  EventsProvider({required EventsRepositoryInterface eventsRepository})
    : _eventsRepository = eventsRepository;

  bool _isLoading = false;
  String? _error;

  List<FeedingModel> _feedings = const [];
  List<WeightChangeModel> _weightChanges = const [];
  List<DewormingModel> _dewormings = const [];
  List<MedicationModel> _medications = const [];
  List<VaccinationModel> _vaccinations = const [];
  List<DisposalModel> _disposals = const [];
  List<MilkingModel> _milkings = const [];
  List<PregnancyModel> _pregnancies = const [];
  List<CalvingModel> _calvings = const [];
  List<DryoffModel> _dryoffs = const [];
  List<InseminationModel> _inseminations = const [];
  List<TransferModel> _transfers = const [];
  List<FeedingModel> _allFeedings = const [];
  List<WeightChangeModel> _allWeightChanges = const [];
  List<DewormingModel> _allDewormings = const [];
  List<MedicationModel> _allMedications = const [];
  List<VaccinationModel> _allVaccinations = const [];
  List<DisposalModel> _allDisposals = const [];
  List<MilkingModel> _allMilkings = const [];
  List<PregnancyModel> _allPregnancies = const [];
  List<CalvingModel> _allCalvings = const [];
  List<DryoffModel> _allDryoffs = const [];
  List<InseminationModel> _allInseminations = const [];
  List<TransferModel> _allTransfers = const [];
  final Map<String, String> _farmNameCache = {};
  final Map<String, String> _livestockNameCache = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeedingModel> get feedings => _feedings;
  List<WeightChangeModel> get weightChanges => _weightChanges;
  List<DewormingModel> get dewormings => _dewormings;
  List<MedicationModel> get medications => _medications;
  List<VaccinationModel> get vaccinations => _vaccinations;
  List<DisposalModel> get disposals => _disposals;
  List<MilkingModel> get milkings => _milkings;
  List<PregnancyModel> get pregnancies => _pregnancies;
  List<CalvingModel> get calvings => _calvings;
  List<DryoffModel> get dryoffs => _dryoffs;
  List<InseminationModel> get inseminations => _inseminations;
  List<TransferModel> get transfers => _transfers;
  List<FeedingModel> get allFeedings => _allFeedings;
  List<WeightChangeModel> get allWeightChanges => _allWeightChanges;
  List<DewormingModel> get allDewormings => _allDewormings;
  List<MedicationModel> get allMedications => _allMedications;
  List<VaccinationModel> get allVaccinations => _allVaccinations;
  List<DisposalModel> get allDisposals => _allDisposals;
  List<MilkingModel> get allMilkings => _allMilkings;
  List<PregnancyModel> get allPregnancies => _allPregnancies;
  List<CalvingModel> get allCalvings => _allCalvings;
  List<DryoffModel> get allDryoffs => _allDryoffs;
  List<InseminationModel> get allInseminations => _allInseminations;
  List<TransferModel> get allTransfers => _allTransfers;

  Future<Map<String, int>> loadLogCounts({
    String? farmUuid,
    required String livestockUuid,
  }) => _eventsRepository.getLogCounts(
    farmUuid: farmUuid,
    livestockUuid: livestockUuid,
  );

  Future<EventSummary> getEventSummary() => _eventsRepository.getEventSummary();

  Future<void> loadEventsForLivestock({
    required String farmUuid,
    required String livestockUuid,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _feedings = await _eventsRepository.getFeedings(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _weightChanges = await _eventsRepository.getWeightChanges(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _dewormings = await _eventsRepository.getDewormings(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _medications = await _eventsRepository.getMedications(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _vaccinations = await _eventsRepository.getVaccinations(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _disposals = await _eventsRepository.getDisposals(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _milkings = await _eventsRepository.getMilkings(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _pregnancies = await _eventsRepository.getPregnancies(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _calvings = await _eventsRepository.getCalvings(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _dryoffs = await _eventsRepository.getDryoffs(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _inseminations = await _eventsRepository.getInseminations(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _transfers = await _enrichTransfers(
        await _eventsRepository.getTransfers(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        ),
      );
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadAllEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allFeedings = await _eventsRepository.getAllFeedings();
      _allWeightChanges = await _eventsRepository.getAllWeightChanges();
      _allDewormings = await _eventsRepository.getAllDewormings();
      _allMedications = await _eventsRepository.getAllMedications();
      _allVaccinations = await _eventsRepository.getAllVaccinations();
      _allDisposals = await _eventsRepository.getAllDisposals();
      _allMilkings = await _eventsRepository.getAllMilkings();
      _allPregnancies = await _eventsRepository.getAllPregnancies();
      _allCalvings = await _eventsRepository.getAllCalvings();
      _allDryoffs = await _eventsRepository.getAllDryoffs();
      _allInseminations = await _eventsRepository.getAllInseminations();
      _allTransfers = await _enrichTransfers(
        await _eventsRepository.getAllTransfers(),
      );
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<FeedingModel> addFeeding(FeedingModel model) async {
    try {
      log('📝 Creating feeding log locally: ${model.uuid}');
      final created = await _eventsRepository.createFeeding(model);
      log('✅ Feeding log created locally: ${created.uuid}');
      _feedings = [..._feedings, created];
      _allFeedings = [..._allFeedings, created];
      notifyListeners();
      return created;
    } catch (e) {
      log('❌ Failed to create feeding log locally: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<FeedingModel> updateFeeding(FeedingModel model) async {
    try {
      final updated = await _eventsRepository.updateFeedingLocally(model);
      _feedings = _feedings
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allFeedings = _allFeedings
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e, stackTrace) {
      _error = e.toString();
      log('❌ Failed to save transfer log batch: $e', stackTrace: stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<WeightChangeModel> addWeightChange(WeightChangeModel model) async {
    try {
      final created = await _eventsRepository.createWeightChange(model);
      _weightChanges = [..._weightChanges, created];
      _allWeightChanges = [..._allWeightChanges, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<WeightChangeModel> updateWeightChange(WeightChangeModel model) async {
    try {
      final updated = await _eventsRepository.updateWeightChangeLocally(model);
      _weightChanges = _weightChanges
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allWeightChanges = _allWeightChanges
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<DewormingModel> addDeworming(DewormingModel model) async {
    try {
      final created = await _eventsRepository.createDeworming(model);
      _dewormings = [..._dewormings, created];
      _allDewormings = [..._allDewormings, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<DewormingModel> updateDeworming(DewormingModel model) async {
    try {
      final updated = await _eventsRepository.updateDewormingLocally(model);
      _dewormings = _dewormings
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allDewormings = _allDewormings
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<MedicationModel> addMedication(MedicationModel model) async {
    try {
      final created = await _eventsRepository.createMedication(model);
      _medications = [..._medications, created];
      _allMedications = [..._allMedications, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<MedicationModel> updateMedication(MedicationModel model) async {
    try {
      final updated = await _eventsRepository.updateMedicationLocally(model);
      _medications = _medications
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allMedications = _allMedications
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<MedicationModel?> addMedicationWithDialog(
    BuildContext context,
    MedicationModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addMedication(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.medicationLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e, stackTrace) {
      _error = e.toString();
      log('❌ Failed to save transfer log: $e', stackTrace: stackTrace);
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.medicationLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<MedicationModel?> updateMedicationWithDialog(
    BuildContext context,
    MedicationModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateMedication(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.medicationLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.medicationLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<List<MedicationModel>> addMedicationBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    int? medicineId,
    int? diseaseId,
    String? quantity,
    String? withdrawalPeriod,
    String? medicationDate,
    String? remarks,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    final created = <MedicationModel>[];

    try {
      for (final livestockUuid in livestockUuids) {
        final timestamp = DateTime.now();
        final uuid =
            'medication-${timestamp.microsecondsSinceEpoch}-$livestockUuid';
        final model = MedicationModel(
          uuid: uuid,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          medicineId: medicineId,
          diseaseId: diseaseId,
          quantity: quantity,
          withdrawalPeriod: withdrawalPeriod,
          medicationDate: medicationDate ?? timestamp.toIso8601String(),
          remarks: remarks,
          synced: false,
          syncAction: 'create',
          createdAt: timestamp.toIso8601String(),
          updatedAt: timestamp.toIso8601String(),
        );

        final log = await addMedication(model);
        created.add(log);
      }

      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.medicationLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.medicationLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    }
  }

  Future<VaccinationModel> addVaccination(VaccinationModel model) async {
    try {
      final created = await _eventsRepository.createVaccination(model);
      _vaccinations = [..._vaccinations, created];
      _allVaccinations = [..._allVaccinations, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<VaccinationModel> updateVaccination(VaccinationModel model) async {
    try {
      final updated = await _eventsRepository.updateVaccinationLocally(model);
      _vaccinations = _vaccinations
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allVaccinations = _allVaccinations
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<DisposalModel?> addDisposalWithDialog(
    BuildContext context,
    DisposalModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addDisposal(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.disposalLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.disposalLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<DisposalModel?> updateDisposalWithDialog(
    BuildContext context,
    DisposalModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateDisposal(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.disposalLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.disposalLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<VaccinationModel?> addVaccinationWithDialog(
    BuildContext context,
    VaccinationModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addVaccination(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.vaccinationLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.vaccinationLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<VaccinationModel?> updateVaccinationWithDialog(
    BuildContext context,
    VaccinationModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateVaccination(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.vaccinationLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.vaccinationLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return null;
    }
  }

  Future<List<VaccinationModel>> addVaccinationBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    String? vaccinationNo,
    int? vaccineId,
    int? diseaseId,
    String? vetId,
    String? extensionOfficerId,
    required String status,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    final created = <VaccinationModel>[];

    try {
      for (final livestockUuid in livestockUuids) {
        final timestamp = DateTime.now();
        final uuid =
            'vaccination-${timestamp.microsecondsSinceEpoch}-$livestockUuid';
        final model = VaccinationModel(
          uuid: uuid,
          vaccinationNo: vaccinationNo,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          vaccineId: vaccineId,
          diseaseId: diseaseId,
          vetId: vetId,
          extensionOfficerId: extensionOfficerId,
          status: status,
          synced: false,
          syncAction: 'create',
          createdAt: timestamp.toIso8601String(),
          updatedAt: timestamp.toIso8601String(),
        );

        final log = await addVaccination(model);
        created.add(log);
      }

      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.vaccinationLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.vaccinationLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    }
  }

  Future<MilkingModel?> addMilkingWithDialog(
    BuildContext context,
    MilkingModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addMilking(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.milkingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.milkingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<List<MilkingModel>> addMilkingBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    required int milkingMethodId,
    required String amount,
    required String lactometerReading,
    required String solid,
    required String solidNonFat,
    required String protein,
    required String correctedLactometerReading,
    required String totalSolids,
    required String colonyFormingUnits,
    String? acidity,
    required String session,
    required String status,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    final created = <MilkingModel>[];

    try {
      for (final livestockUuid in livestockUuids) {
        final timestamp = DateTime.now();
        final uuid =
            '${timestamp.microsecondsSinceEpoch}-$livestockUuid-$milkingMethodId';
        final model = MilkingModel(
          uuid: uuid,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          milkingMethodId: milkingMethodId,
          amount: amount,
          lactometerReading: lactometerReading,
          solid: solid,
          solidNonFat: solidNonFat,
          protein: protein,
          correctedLactometerReading: correctedLactometerReading,
          totalSolids: totalSolids,
          colonyFormingUnits: colonyFormingUnits,
          acidity: acidity,
          session: session,
          status: status,
          synced: false,
          syncAction: 'create',
          createdAt: timestamp.toIso8601String(),
          updatedAt: timestamp.toIso8601String(),
        );

        final log = await addMilking(model);
        created.add(log);
      }

      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.milkingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.milkingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    }
  }

  Future<MilkingModel?> updateMilkingWithDialog(
    BuildContext context,
    MilkingModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateMilking(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.milkingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.milkingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<PregnancyModel?> addPregnancyWithDialog(
    BuildContext context,
    PregnancyModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addPregnancy(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.pregnancyLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pregnancyLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<PregnancyModel?> updatePregnancyWithDialog(
    BuildContext context,
    PregnancyModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updatePregnancy(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.pregnancyLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.pregnancyLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<CalvingModel?> addCalvingWithDialog(
    BuildContext context,
    CalvingModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addCalving(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.calvingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.calvingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<CalvingModel?> updateCalvingWithDialog(
    BuildContext context,
    CalvingModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateCalving(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.calvingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.calvingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<DryoffModel?> addDryoffWithDialog(
    BuildContext context,
    DryoffModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addDryoff(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.dryoffLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.dryoffLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<DryoffModel?> updateDryoffWithDialog(
    BuildContext context,
    DryoffModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateDryoff(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.dryoffLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.dryoffLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<InseminationModel?> addInseminationWithDialog(
    BuildContext context,
    InseminationModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addInsemination(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.inseminationLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.inseminationLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<InseminationModel?> updateInseminationWithDialog(
    BuildContext context,
    InseminationModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateInsemination(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.inseminationLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.inseminationLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<DisposalModel> addDisposal(DisposalModel model) async {
    try {
      final created = await _eventsRepository.createDisposal(model);
      _disposals = [..._disposals, created];
      _allDisposals = [..._allDisposals, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<DisposalModel> updateDisposal(DisposalModel model) async {
    try {
      final updated = await _eventsRepository.updateDisposalLocally(model);
      _disposals = _disposals
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allDisposals = _allDisposals
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<MilkingModel> addMilking(MilkingModel model) async {
    try {
      final created = await _eventsRepository.createMilking(model);
      _milkings = [..._milkings, created];
      _allMilkings = [..._allMilkings, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<MilkingModel> updateMilking(MilkingModel model) async {
    try {
      final updated = await _eventsRepository.updateMilkingLocally(model);
      _milkings = _milkings
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allMilkings = _allMilkings
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<PregnancyModel> addPregnancy(PregnancyModel model) async {
    try {
      final created = await _eventsRepository.createPregnancy(model);
      _pregnancies = [..._pregnancies, created];
      _allPregnancies = [..._allPregnancies, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<PregnancyModel> updatePregnancy(PregnancyModel model) async {
    try {
      final updated = await _eventsRepository.updatePregnancyLocally(model);
      _pregnancies = _pregnancies
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allPregnancies = _allPregnancies
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<CalvingModel> addCalving(CalvingModel model) async {
    try {
      final created = await _eventsRepository.createCalving(model);
      _calvings = [..._calvings, created];
      _allCalvings = [..._allCalvings, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<CalvingModel> updateCalving(CalvingModel model) async {
    try {
      final updated = await _eventsRepository.updateCalvingLocally(model);
      _calvings = _calvings
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allCalvings = _allCalvings
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<DryoffModel> addDryoff(DryoffModel model) async {
    try {
      final created = await _eventsRepository.createDryoff(model);
      _dryoffs = [..._dryoffs, created];
      _allDryoffs = [..._allDryoffs, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<DryoffModel> updateDryoff(DryoffModel model) async {
    try {
      final updated = await _eventsRepository.updateDryoffLocally(model);
      _dryoffs = _dryoffs
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allDryoffs = _allDryoffs
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<InseminationModel> addInsemination(InseminationModel model) async {
    try {
      final created = await _eventsRepository.createInsemination(model);
      _inseminations = [..._inseminations, created];
      _allInseminations = [..._allInseminations, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<InseminationModel> updateInsemination(InseminationModel model) async {
    try {
      final updated = await _eventsRepository.updateInseminationLocally(model);
      _inseminations = _inseminations
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allInseminations = _allInseminations
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<TransferModel> addTransfer(TransferModel model) async {
    try {
      final created = await _eventsRepository.createTransfer(model);
      final enriched = await _enrichTransfers([created]);
      final result = enriched.isNotEmpty ? enriched.first : created;
      _transfers = [..._transfers, result];
      _allTransfers = [..._allTransfers, result];
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<TransferModel> updateTransfer(TransferModel model) async {
    try {
      final updated = await _eventsRepository.updateTransferLocally(model);
      final enriched = await _enrichTransfers([updated]);
      final result = enriched.isNotEmpty ? enriched.first : updated;
      _transfers = _transfers
          .map((item) => item.uuid == result.uuid ? result : item)
          .toList();
      _allTransfers = _allTransfers
          .map((item) => item.uuid == result.uuid ? result : item)
          .toList();
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<TransferModel?> addTransferWithDialog(
    BuildContext context,
    TransferModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addTransfer(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.transferLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.transferLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return null;
    }
  }

  Future<TransferModel?> updateTransferWithDialog(
    BuildContext context,
    TransferModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateTransfer(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.transferLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.transferLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return null;
    }
  }

  Future<void> loadEventsForLivestockWithDialog(
    BuildContext context, {
    required String farmUuid,
    required String livestockUuid,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.loading,
      message: '',
      isDismissible: false,
    );

    try {
      await loadEventsForLivestock(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.eventsLoadedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.eventsLoadFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
    }
  }

  Future<void> loadAllEventsWithDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.loading,
      message: '',
      isDismissible: false,
    );

    try {
      await loadAllEvents();
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.allEventsLoadedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.eventsLoadFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
    }
  }

  Future<FeedingModel?> addFeedingWithDialog(
    BuildContext context,
    FeedingModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addFeeding(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.feedingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.feedingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<List<FeedingModel>> addFeedingBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    required int feedingTypeId,
    required String amount,
    required String nextFeedingTime,
    String? remarks,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    final created = <FeedingModel>[];

    try {
      for (final livestockUuid in livestockUuids) {
        final timestamp = DateTime.now();
        final uuid =
            '${timestamp.microsecondsSinceEpoch}-$livestockUuid-$feedingTypeId';
        final model = FeedingModel(
          uuid: uuid,
          feedingTypeId: feedingTypeId,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          nextFeedingTime: nextFeedingTime,
          amount: amount,
          remarks: remarks,
          synced: false,
          syncAction: 'create',
          createdAt: timestamp.toIso8601String(),
          updatedAt: timestamp.toIso8601String(),
        );

        final log = await addFeeding(model);
        created.add(log);
      }

      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.feedingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.feedingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    }
  }

  Future<FeedingModel?> updateFeedingWithDialog(
    BuildContext context,
    FeedingModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateFeeding(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.feedingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.feedingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return null;
    }
  }

  Future<WeightChangeModel?> addWeightChangeWithDialog(
    BuildContext context,
    WeightChangeModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addWeightChange(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.weightLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.weightLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<WeightChangeModel?> updateWeightChangeWithDialog(
    BuildContext context,
    WeightChangeModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateWeightChange(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.weightLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.weightLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<DewormingModel?> addDewormingWithDialog(
    BuildContext context,
    DewormingModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addDeworming(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.dewormingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.dewormingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<DewormingModel?> updateDewormingWithDialog(
    BuildContext context,
    DewormingModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateDeworming(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.dewormingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.dewormingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      return null;
    }
  }

  Future<List<DewormingModel>> addDewormingBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    int? administrationRouteId,
    int? medicineId,
    String? vetId,
    String? extensionOfficerId,
    String? quantity,
    String? dose,
    String? nextAdministrationDate,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    final created = <DewormingModel>[];

    try {
      for (final livestockUuid in livestockUuids) {
        final timestamp = DateTime.now();
        final uuid =
            '${timestamp.microsecondsSinceEpoch}-$livestockUuid-deworming';
        final model = DewormingModel(
          uuid: uuid,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          administrationRouteId: administrationRouteId,
          medicineId: medicineId,
          vetId: vetId,
          extensionOfficerId: extensionOfficerId,
          quantity: quantity,
          dose: dose,
          nextAdministrationDate: nextAdministrationDate,
          synced: false,
          syncAction: 'create',
          createdAt: timestamp.toIso8601String(),
          updatedAt: timestamp.toIso8601String(),
        );

        final log = await addDeworming(model);
        created.add(log);
      }

      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.dewormingLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.dewormingLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    }
  }

  Future<List<DisposalModel>> addDisposalBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    int? disposalTypeId,
    required String reasons,
    String? remarks,
    required String status,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    final created = <DisposalModel>[];

    try {
      for (final livestockUuid in livestockUuids) {
        final timestamp = DateTime.now();
        final uuid =
            'disposal-${timestamp.microsecondsSinceEpoch}-$livestockUuid';
        final model = DisposalModel(
          uuid: uuid,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          disposalTypeId: disposalTypeId,
          reasons: reasons,
          remarks: remarks,
          status: status,
          synced: false,
          syncAction: 'create',
          createdAt: timestamp.toIso8601String(),
          updatedAt: timestamp.toIso8601String(),
        );

        final log = await addDisposal(model);
        created.add(log);
      }

      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.disposalLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.disposalLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    }
  }

  Future<List<TransferModel>> addTransferBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    required String toFarmUuid,
    int? transporterId,
    String? reason,
    String? price,
    String? transferDate,
    String? remarks,
    String? status,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    final created = <TransferModel>[];

    try {
      for (final livestockUuid in livestockUuids) {
        final timestamp = DateTime.now();
        final uuid =
            'transfer-${timestamp.microsecondsSinceEpoch}-$livestockUuid';
        final model = TransferModel(
          uuid: uuid,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          toFarmUuid: toFarmUuid,
          transporterId: transporterId,
          reason: reason,
          price: price,
          transferDate: transferDate ?? timestamp.toIso8601String(),
          remarks: remarks,
          status: status ?? 'completed',
          synced: false,
          syncAction: 'create',
          createdAt: timestamp.toIso8601String(),
          updatedAt: timestamp.toIso8601String(),
          farmName: null,
          toFarmName: null,
          livestockName: null,
        );

        final log = await addTransfer(model);
        created.add(log);
      }

      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.transferLogSaved,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.transferLogSaveFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }

      return created;
    }
  }

  // Future<Map<String, int>> loadLogCounts({
  //   String? farmUuid,
  //   required String livestockUuid,
  // }) async {
  //   final feedings = await _eventsRepository.getFeedings(
  //     farmUuid: farmUuid,
  //     livestockUuid: livestockUuid,
  //   );
  //   final weightChanges = await _eventsRepository.getWeightChanges(
  //     farmUuid: farmUuid,
  //     livestockUuid: livestockUuid,
  //   );
  //   final dewormings = await _eventsRepository.getDewormings(
  //     farmUuid: farmUuid,
  //     livestockUuid: livestockUuid,
  //   );

  //   return {
  //     EventLogTypes.feeding: feedings.length,
  //     EventLogTypes.weightChange: weightChanges.length,
  //     EventLogTypes.deworming: dewormings.length,
  //   };
  // }

  Future<List<dynamic>> loadLogsForType({
    String? farmUuid,
    String? livestockUuid,
    required String logType,
  }) async {
    switch (logType) {
      case EventLogTypes.feeding:
        return await _eventsRepository.getFeedings(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.weightChange:
        return await _eventsRepository.getWeightChanges(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.deworming:
        return await _eventsRepository.getDewormings(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.medication:
        return await _eventsRepository.getMedications(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.vaccination:
        return await _eventsRepository.getVaccinations(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.disposal:
        return await _eventsRepository.getDisposals(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.milking:
        return await _eventsRepository.getMilkings(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.pregnancy:
        return await _eventsRepository.getPregnancies(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.calving:
        return await _eventsRepository.getCalvings(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.dryoff:
        return await _eventsRepository.getDryoffs(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.insemination:
        return await _eventsRepository.getInseminations(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.transfer:
        return await _enrichTransfers(
          await _eventsRepository.getTransfers(
            farmUuid: farmUuid,
            livestockUuid: livestockUuid,
          ),
        );
      default:
        return [];
    }
  }

  void clear() {
    _feedings = const [];
    _weightChanges = const [];
    _dewormings = const [];
    _medications = const [];
    _vaccinations = const [];
    _disposals = const [];
    _milkings = const [];
    _pregnancies = const [];
    _calvings = const [];
    _dryoffs = const [];
    _inseminations = const [];
    _transfers = const [];
    _allFeedings = const [];
    _allWeightChanges = const [];
    _allDewormings = const [];
    _allMedications = const [];
    _allVaccinations = const [];
    _allDisposals = const [];
    _allMilkings = const [];
    _allPregnancies = const [];
    _allCalvings = const [];
    _allDryoffs = const [];
    _allInseminations = const [];
    _allTransfers = const [];
    _error = null;
    notifyListeners();
  }

  Future<List<TransferModel>> _enrichTransfers(
    List<TransferModel> transfers,
  ) async {
    if (transfers.isEmpty) return transfers;

    final farmUuids = <String>{
      for (final transfer in transfers) transfer.farmUuid,
      for (final transfer in transfers)
        if (transfer.toFarmUuid != null && transfer.toFarmUuid!.isNotEmpty)
          transfer.toFarmUuid!,
    };

    final livestockUuids = transfers
        .map((transfer) => transfer.livestockUuid)
        .where((uuid) => uuid.trim().isNotEmpty)
        .toSet();

    final farmNames = await resolveFarmNames(farmUuids);
    final livestockNames = await resolveLivestockNames(livestockUuids);

    return transfers
        .map(
          (transfer) => transfer.copyWith(
            farmName: farmNames[transfer.farmUuid] ?? transfer.farmName,
            toFarmName: transfer.toFarmUuid != null
                ? farmNames[transfer.toFarmUuid!] ?? transfer.toFarmName
                : transfer.toFarmName,
            livestockName:
                livestockNames[transfer.livestockUuid] ?? transfer.livestockName,
          ),
        )
        .toList();
  }

  Future<Map<String, String>> resolveFarmNames(
    Iterable<String> farmUuids,
  ) async {
    final requested = farmUuids
        .map((uuid) => uuid.trim())
        .where((uuid) => uuid.isNotEmpty)
        .toSet();

    final missing = requested.where((uuid) => !_farmNameCache.containsKey(uuid)).toSet();

    if (missing.isNotEmpty) {
      final fetched = await _eventsRepository.getFarmNamesByUuid(missing);
      _farmNameCache.addAll(fetched);
    }

    return {
      for (final uuid in requested)
        if (_farmNameCache[uuid]?.trim().isNotEmpty ?? false)
          uuid: _farmNameCache[uuid]!,
    };
  }

  Future<Map<String, String>> resolveLivestockNames(
    Iterable<String> livestockUuids,
  ) async {
    final requested = livestockUuids
        .map((uuid) => uuid.trim())
        .where((uuid) => uuid.isNotEmpty)
        .toSet();

    final missing =
        requested.where((uuid) => !_livestockNameCache.containsKey(uuid)).toSet();

    if (missing.isNotEmpty) {
      final fetched = await _eventsRepository.getLivestockNamesByUuid(missing);
      _livestockNameCache.addAll(fetched);
    }

    return {
      for (final uuid in requested)
        if (_livestockNameCache[uuid]?.trim().isNotEmpty ?? false)
          uuid: _livestockNameCache[uuid]!,
    };
  }
}
