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
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/transfer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/calving_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/dryoff_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/insemination_model.dart';
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
  List<FeedingModel> _allFeedings = const [];
  List<WeightChangeModel> _allWeightChanges = const [];
  List<DewormingModel> _allDewormings = const [];
  List<MedicationModel> _allMedications = const [];
  List<VaccinationModel> _allVaccinations = const [];
  List<DisposalModel> _allDisposals = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeedingModel> get feedings => _feedings;
  List<WeightChangeModel> get weightChanges => _weightChanges;
  List<DewormingModel> get dewormings => _dewormings;
  List<MedicationModel> get medications => _medications;
  List<VaccinationModel> get vaccinations => _vaccinations;
  List<DisposalModel> get disposals => _disposals;
  List<FeedingModel> get allFeedings => _allFeedings;
  List<WeightChangeModel> get allWeightChanges => _allWeightChanges;
  List<DewormingModel> get allDewormings => _allDewormings;
  List<MedicationModel> get allMedications => _allMedications;
  List<VaccinationModel> get allVaccinations => _allVaccinations;
  List<DisposalModel> get allDisposals => _allDisposals;
  
  Future<Map<String, int>> loadLogCounts({
    String? farmUuid,
    required String livestockUuid,
  }) =>
      _eventsRepository.getLogCounts(
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
    } catch (e) {
      _error = e.toString();
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

  Future<T?> _showComingSoonDialog<T>(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialogs.showError<T>(
      context: context,
      title: l10n.comingSoon,
      message: l10n.comingSoon,
      buttonText: l10n.ok,
      onPressed: () => Navigator.of(context).pop(),
    );
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
    required String nextFeedingTime,
    required String amount,
    String? remarks,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (livestockUuids.isEmpty) return const [];

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: l10n.bulkOperationInProgress,
      isDismissible: false,
    );

    try {
      final created = <FeedingModel>[];
      for (final livestockUuid in livestockUuids) {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'feeding-${DateTime.now().microsecondsSinceEpoch}-${livestockUuid.hashCode}-$feedingTypeId';
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
          createdAt: now,
          updatedAt: now,
        );
        created.add(await addFeeding(model));
      }

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
      return const [];
    }
  }

  Future<MilkingModel?> addMilkingWithDialog(
    BuildContext context,
    MilkingModel model,
  ) async {
    return _showComingSoonDialog<MilkingModel?>(context);
  }

  Future<MilkingModel?> updateMilkingWithDialog(
    BuildContext context,
    MilkingModel model,
  ) async {
    return _showComingSoonDialog<MilkingModel?>(context);
  }

  Future<List<MilkingModel>> addMilkingBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    int? milkingMethodId,
    String? amount,
    String? lactometerReading,
    String? solid,
    String? solidNonFat,
    String? protein,
    String? correctedLactometerReading,
    String? totalSolids,
    String? colonyFormingUnits,
    String? acidity,
    String? session,
    String? status,
  }) async {
    await _showComingSoonDialog(context);
    return const [];
  }

  Future<DryoffModel?> addDryoffWithDialog(
    BuildContext context,
    DryoffModel model,
  ) async {
    return _showComingSoonDialog<DryoffModel?>(context);
  }

  Future<DryoffModel?> updateDryoffWithDialog(
    BuildContext context,
    DryoffModel model,
  ) async {
    return _showComingSoonDialog<DryoffModel?>(context);
  }

  Future<PregnancyModel?> addPregnancyWithDialog(
    BuildContext context,
    PregnancyModel model,
  ) async {
    return _showComingSoonDialog<PregnancyModel?>(context);
  }

  Future<PregnancyModel?> updatePregnancyWithDialog(
    BuildContext context,
    PregnancyModel model,
  ) async {
    return _showComingSoonDialog<PregnancyModel?>(context);
  }

  Future<TransferModel?> addTransferWithDialog(
    BuildContext context,
    TransferModel model,
  ) async {
    return _showComingSoonDialog<TransferModel?>(context);
  }

  Future<TransferModel?> updateTransferWithDialog(
    BuildContext context,
    TransferModel model,
  ) async {
    return _showComingSoonDialog<TransferModel?>(context);
  }

  Future<List<TransferModel>> addTransferBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    String? toFarmUuid,
    int? transporterId,
    String? reason,
    String? price,
    String? transferDate,
    String? remarks,
    String? status,
  }) async {
    await _showComingSoonDialog(context);
    return const [];
  }

  Future<InseminationModel?> addInseminationWithDialog(
    BuildContext context,
    InseminationModel model,
  ) async {
    return _showComingSoonDialog<InseminationModel?>(context);
  }

  Future<InseminationModel?> updateInseminationWithDialog(
    BuildContext context,
    InseminationModel model,
  ) async {
    return _showComingSoonDialog<InseminationModel?>(context);
  }

  Future<CalvingModel?> addCalvingWithDialog(
    BuildContext context,
    CalvingModel model,
  ) async {
    return _showComingSoonDialog<CalvingModel?>(context);
  }

  Future<CalvingModel?> updateCalvingWithDialog(
    BuildContext context,
    CalvingModel model,
  ) async {
    return _showComingSoonDialog<CalvingModel?>(context);
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

  Future<List<WeightChangeModel>> addWeightChangeBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    String? oldWeight,
    required String newWeight,
    String? remarks,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (livestockUuids.isEmpty) return const [];

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: l10n.bulkOperationInProgress,
      isDismissible: false,
    );

    try {
      final created = <WeightChangeModel>[];
      for (final livestockUuid in livestockUuids) {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'weight-${DateTime.now().microsecondsSinceEpoch}-${livestockUuid.hashCode}';
        final model = WeightChangeModel(
          uuid: uuid,
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
          oldWeight: oldWeight,
          newWeight: newWeight,
          remarks: remarks,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );
        created.add(await addWeightChange(model));
      }

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
      return const [];
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
    String? quantity,
    String? dose,
    String? nextAdministrationDate,
    String? vetId,
    String? extensionOfficerId,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (livestockUuids.isEmpty) return const [];

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: l10n.bulkOperationInProgress,
      isDismissible: false,
    );

    try {
      final created = <DewormingModel>[];
      for (final livestockUuid in livestockUuids) {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'deworming-${DateTime.now().microsecondsSinceEpoch}-${livestockUuid.hashCode}';
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
          createdAt: now,
          updatedAt: now,
        );
        created.add(await addDeworming(model));
      }

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
      return const [];
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
    if (livestockUuids.isEmpty) return const [];

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: l10n.bulkOperationInProgress,
      isDismissible: false,
    );

    try {
      final created = <MedicationModel>[];
      for (final animalUuid in livestockUuids) {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'medication-${DateTime.now().microsecondsSinceEpoch}-${animalUuid.hashCode}';
        final model = MedicationModel(
          uuid: uuid,
          farmUuid: farmUuid,
          livestockUuid: animalUuid,
          medicineId: medicineId,
          diseaseId: diseaseId,
          quantity: quantity,
          withdrawalPeriod: withdrawalPeriod,
          medicationDate: medicationDate ?? now,
          remarks: remarks,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );
        created.add(await addMedication(model));
      }

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
      return const [];
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
    String status = 'completed',
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (livestockUuids.isEmpty) return const [];

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: l10n.bulkOperationInProgress,
      isDismissible: false,
    );

    try {
      final created = <VaccinationModel>[];
      for (final animalUuid in livestockUuids) {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'vaccination-${DateTime.now().microsecondsSinceEpoch}-${animalUuid.hashCode}';
        final model = VaccinationModel(
          uuid: uuid,
          vaccinationNo: vaccinationNo,
          farmUuid: farmUuid,
          livestockUuid: animalUuid,
          vaccineId: vaccineId,
          diseaseId: diseaseId,
          vetId: vetId,
          extensionOfficerId: extensionOfficerId,
          status: status,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );
        created.add(await addVaccination(model));
      }

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
      return const [];
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

  Future<List<DisposalModel>> addDisposalBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    int? disposalTypeId,
    required String reasons,
    String? remarks,
    String status = 'completed',
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (livestockUuids.isEmpty) return const [];

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: l10n.bulkOperationInProgress,
      isDismissible: false,
    );

    try {
      final created = <DisposalModel>[];
      for (final animalUuid in livestockUuids) {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'disposal-${DateTime.now().microsecondsSinceEpoch}-${animalUuid.hashCode}';
        final model = DisposalModel(
          uuid: uuid,
          farmUuid: farmUuid,
          livestockUuid: animalUuid,
          disposalTypeId: disposalTypeId,
          reasons: reasons,
          remarks: remarks,
          status: status,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );
        created.add(await addDisposal(model));
      }

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
      return const [];
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
    required String livestockUuid,
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
    _allFeedings = const [];
    _allWeightChanges = const [];
    _allDewormings = const [];
    _allMedications = const [];
    _allVaccinations = const [];
    _allDisposals = const [];
    _error = null;
    notifyListeners();
  }

}

