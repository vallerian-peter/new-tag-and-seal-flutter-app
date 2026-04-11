import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/treatment_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/vaccination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/milking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/transfer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/teeth_clipping_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/tail_docking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/iron_injection_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/livestock_marking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/stage_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/prepuce_condition_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/calving_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/birth_event_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/aborted_pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/dryoff_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/insemination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/repo/events_repo.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/summary/event_summary.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/presentation/provider/notification_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/domain/model/notification_model.dart';

class EventsProvider extends ChangeNotifier {
  final EventsRepositoryInterface _eventsRepository;
  final NotificationProvider? _notificationProvider;

  EventsProvider({
    required EventsRepositoryInterface eventsRepository,
    NotificationProvider? notificationProvider,
  })  : _eventsRepository = eventsRepository,
        _notificationProvider = notificationProvider;

  bool _isLoading = false;
  String? _error;

  List<FeedingModel> _feedings = const [];
  List<WeightChangeModel> _weightChanges = const [];
  List<DewormingModel> _dewormings = const [];
  List<TreatmentModel> _treatments = const [];
  List<VaccinationModel> _vaccinations = const [];
  List<DisposalModel> _disposals = const [];
  List<FeedingModel> _allFeedings = const [];
  List<WeightChangeModel> _allWeightChanges = const [];
  List<DewormingModel> _allDewormings = const [];
  List<TreatmentModel> _allTreatments = const [];
  List<VaccinationModel> _allVaccinations = const [];
  List<DisposalModel> _allDisposals = const [];
  List<BirthEventModel> _allBirthEvents = const [];
  List<AbortedPregnancyModel> _allAbortedPregnancies = const [];
  List<MilkingModel> _milkings = const [];
  List<PregnancyModel> _pregnancies = const [];
  List<InseminationModel> _inseminations = const [];
  List<DryoffModel> _dryoffs = const [];
  List<TransferModel> _transfers = const [];
  List<MilkingModel> _allMilkings = const [];
  List<PregnancyModel> _allPregnancies = const [];
  List<InseminationModel> _allInseminations = const [];
  List<DryoffModel> _allDryoffs = const [];
  List<TransferModel> _allTransfers = const [];
  List<TeethClippingModel> _allTeethClippings = const [];
  List<TailDockingModel> _allTailDockings = const [];
  List<IronInjectionModel> _allIronInjections = const [];
  List<LivestockMarkingModel> _allLivestockMarkings = const [];
  List<StageChangeModel> _allStageChanges = const [];
  List<PrepuceConditionModel> _allPrepuceConditions = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeedingModel> get feedings => _feedings;
  List<WeightChangeModel> get weightChanges => _weightChanges;
  List<DewormingModel> get dewormings => _dewormings;
  List<TreatmentModel> get treatments => _treatments;
  List<VaccinationModel> get vaccinations => _vaccinations;
  List<DisposalModel> get disposals => _disposals;
  List<FeedingModel> get allFeedings => _allFeedings;
  List<WeightChangeModel> get allWeightChanges => _allWeightChanges;
  List<DewormingModel> get allDewormings => _allDewormings;
  List<TreatmentModel> get allTreatments => _allTreatments;
  List<VaccinationModel> get allVaccinations => _allVaccinations;
  List<DisposalModel> get allDisposals => _allDisposals;
  List<BirthEventModel> get allBirthEvents => _allBirthEvents;
  List<AbortedPregnancyModel> get allAbortedPregnancies => _allAbortedPregnancies;
  List<MilkingModel> get milkings => _milkings;
  List<PregnancyModel> get pregnancies => _pregnancies;
  List<InseminationModel> get inseminations => _inseminations;
  List<DryoffModel> get dryoffs => _dryoffs;
  List<TransferModel> get transfers => _transfers;
  List<MilkingModel> get allMilkings => _allMilkings;
  List<PregnancyModel> get allPregnancies => _allPregnancies;
  List<InseminationModel> get allInseminations => _allInseminations;
  List<DryoffModel> get allDryoffs => _allDryoffs;
  List<TransferModel> get allTransfers => _allTransfers;
  List<TeethClippingModel> get allTeethClippings => _allTeethClippings;
  List<TailDockingModel> get allTailDockings => _allTailDockings;
  List<IronInjectionModel> get allIronInjections => _allIronInjections;
  List<LivestockMarkingModel> get allLivestockMarkings => _allLivestockMarkings;
  List<StageChangeModel> get allStageChanges => _allStageChanges;
  List<PrepuceConditionModel> get allPrepuceConditions => _allPrepuceConditions;
  
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
      _treatments = await _eventsRepository.getTreatments(
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
      _inseminations = await _eventsRepository.getInseminations(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _dryoffs = await _eventsRepository.getDryoffs(
        farmUuid: farmUuid,
        livestockUuid: livestockUuid,
      );
      _transfers = await _eventsRepository.getTransfers(
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
      _allTreatments = await _eventsRepository.getAllTreatments();
      _allVaccinations = await _eventsRepository.getAllVaccinations();
      _allDisposals = await _eventsRepository.getAllDisposals();
      _allBirthEvents = await _eventsRepository.getAllBirthEvents();
      _allAbortedPregnancies = await _eventsRepository.getAllAbortedPregnancies();
      _allMilkings = await _eventsRepository.getAllMilkings();
      _allPregnancies = await _eventsRepository.getAllPregnancies();
      _allInseminations = await _eventsRepository.getAllInseminations();
      _allDryoffs = await _eventsRepository.getAllDryoffs();
      _allTransfers = await _eventsRepository.getAllTransfers();
      _allTeethClippings = await _eventsRepository.getAllTeethClippings();
      _allTailDockings = await _eventsRepository.getAllTailDockings();
      _allIronInjections = await _eventsRepository.getAllIronInjections();
      _allLivestockMarkings = await _eventsRepository.getAllLivestockMarkings();
      _allStageChanges = await _eventsRepository.getAllStageChanges();
      _allPrepuceConditions = await _eventsRepository.getAllPrepuceConditions();
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
      
      // Create notification for next feeding time if it's in the future
      await _createFeedingNotification(created);
      
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
      
      // Update notification for next feeding time if it changed
      await _createFeedingNotification(updated);
      
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
      
      // Create notification for next deworming date if it's in the future
      await _createDewormingNotification(created);
      
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
      
      // Update notification for next administration date if it changed
      await _createDewormingNotification(updated);
      
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<TreatmentModel> addTreatment(TreatmentModel model) async {
    try {
      final created = await _eventsRepository.createTreatment(model);
      _treatments = [..._treatments, created];
      _allTreatments = [..._allTreatments, created];
      notifyListeners();
      
      // Create notification for next treatment date if it's in the future
      await _createTreatmentNotification(created);
      
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<TreatmentModel> updateTreatment(TreatmentModel model) async {
    try {
      final updated = await _eventsRepository.updateTreatmentLocally(model);
      _treatments = _treatments
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allTreatments = _allTreatments
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      
      // Update notification for next treatment date if it changed
      await _createTreatmentNotification(updated);
      
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

  Future<TeethClippingModel> addTeethClipping(TeethClippingModel model) async {
    try {
      final created = await _eventsRepository.createTeethClipping(model);
      _allTeethClippings = [..._allTeethClippings, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<TeethClippingModel> updateTeethClipping(
    TeethClippingModel model,
  ) async {
    try {
      final updated = await _eventsRepository.updateTeethClippingLocally(model);
      _allTeethClippings = _allTeethClippings
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

  Future<TailDockingModel> addTailDocking(TailDockingModel model) async {
    try {
      final created = await _eventsRepository.createTailDocking(model);
      _allTailDockings = [..._allTailDockings, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<TailDockingModel> updateTailDocking(TailDockingModel model) async {
    try {
      final updated = await _eventsRepository.updateTailDockingLocally(model);
      _allTailDockings = _allTailDockings
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

  Future<IronInjectionModel> addIronInjection(IronInjectionModel model) async {
    try {
      final created = await _eventsRepository.createIronInjection(model);
      _allIronInjections = [..._allIronInjections, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<IronInjectionModel> updateIronInjection(IronInjectionModel model) async {
    try {
      final updated = await _eventsRepository.updateIronInjectionLocally(model);
      _allIronInjections = _allIronInjections
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

  Future<LivestockMarkingModel> addLivestockMarking(
    LivestockMarkingModel model,
  ) async {
    try {
      final created = await _eventsRepository.createLivestockMarking(model);
      _allLivestockMarkings = [..._allLivestockMarkings, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<LivestockMarkingModel> updateLivestockMarking(
    LivestockMarkingModel model,
  ) async {
    try {
      final updated = await _eventsRepository.updateLivestockMarkingLocally(
        model,
      );
      _allLivestockMarkings = _allLivestockMarkings
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

  Future<StageChangeModel> addStageChange(StageChangeModel model) async {
    try {
      final created = await _eventsRepository.createStageChange(model);
      _allStageChanges = [..._allStageChanges, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<StageChangeModel> updateStageChange(StageChangeModel model) async {
    try {
      final updated = await _eventsRepository.updateStageChangeLocally(model);
      _allStageChanges = _allStageChanges
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

  Future<PrepuceConditionModel> addPrepuceCondition(
    PrepuceConditionModel model,
  ) async {
    try {
      final created = await _eventsRepository.createPrepuceCondition(model);
      _allPrepuceConditions = [..._allPrepuceConditions, created];
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<PrepuceConditionModel> updatePrepuceCondition(
    PrepuceConditionModel model,
  ) async {
    try {
      final updated =
          await _eventsRepository.updatePrepuceConditionLocally(model);
      _allPrepuceConditions = _allPrepuceConditions
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
        );
      }
      return const [];
    }
  }

  Future<MilkingModel> addMilking(MilkingModel model) async {
    try {
      log('📝 Creating milking log locally: ${model.uuid}');
      final created = await _eventsRepository.createMilking(model);
      log('✅ Milking log created locally: ${created.uuid}');
      _milkings = [..._milkings, created];
      _allMilkings = [..._allMilkings, created];
      notifyListeners();
      return created;
    } catch (e) {
      log('❌ Failed to create milking log locally: $e');
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
          message: 'Milking log saved successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to save milking log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
  }

  Future<MilkingModel?> updateMilkingWithDialog(
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
      final updated = await updateMilking(model);
      _error = null;
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: 'Milking log updated successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to update milking log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
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

  Future<DryoffModel> addDryoff(DryoffModel model) async {
    try {
      log('📝 Creating dryoff log locally: ${model.uuid}');
      final created = await _eventsRepository.createDryoff(model);
      log('✅ Dryoff log created locally: ${created.uuid}');
      _dryoffs = [..._dryoffs, created];
      _allDryoffs = [..._allDryoffs, created];
      notifyListeners();
      return created;
    } catch (e) {
      log('❌ Failed to create dryoff log locally: $e');
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
          message: 'Dryoff log saved successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to save dryoff log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
      title: l10n.save,
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
          message: 'Dryoff log updated successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to update dryoff log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
  }

  Future<PregnancyModel> addPregnancy(PregnancyModel model) async {
    try {
      log('📝 Creating pregnancy log locally: ${model.uuid}');
      final created = await _eventsRepository.createPregnancy(model);
      log('✅ Pregnancy log created locally: ${created.uuid}');
      _pregnancies = [..._pregnancies, created];
      _allPregnancies = [..._allPregnancies, created];
      notifyListeners();
      return created;
    } catch (e) {
      log('❌ Failed to create pregnancy log locally: $e');
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
          message: 'Pregnancy log saved successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to save pregnancy log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
      title: l10n.save,
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
          message: 'Pregnancy log updated successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to update pregnancy log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
  }

  Future<TransferModel> addTransfer(TransferModel model) async {
    try {
      log('📝 Creating transfer log locally: ${model.uuid}');
      final created = await _eventsRepository.createTransfer(model);
      log('✅ Transfer log created locally: ${created.uuid}');
      _transfers = [..._transfers, created];
      _allTransfers = [..._allTransfers, created];
      notifyListeners();
      return created;
    } catch (e) {
      log('❌ Failed to create transfer log locally: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<TransferModel> updateTransfer(TransferModel model) async {
    try {
      final updated = await _eventsRepository.updateTransferLocally(model);
      _transfers = _transfers
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      _allTransfers = _allTransfers
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
          message: 'Transfer log saved successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to save transfer log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
      title: l10n.save,
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
          message: 'Transfer log updated successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to update transfer log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
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

  Future<InseminationModel> addInsemination(InseminationModel model) async {
    try {
      log('📝 Creating insemination log locally: ${model.uuid}');
      final created = await _eventsRepository.createInsemination(model);
      log('✅ Insemination log created locally: ${created.uuid}');
      _inseminations = [..._inseminations, created];
      _allInseminations = [..._allInseminations, created];
      notifyListeners();
      return created;
    } catch (e) {
      log('❌ Failed to create insemination log locally: $e');
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
          message: 'Insemination log saved successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to save insemination log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
      title: l10n.save,
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
          message: 'Insemination log updated successfully',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: 'Failed to update insemination log',
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
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

  // ============================================================================
  // BIRTH EVENTS (replaces calvings)
  // ============================================================================

  Future<BirthEventModel> addBirthEvent(BirthEventModel model) async {
    try {
      log('📝 Creating birth event locally: ${model.uuid}');
      final created = await _eventsRepository.createBirthEvent(model);
      log('✅ Birth event created locally: ${created.uuid}');
      _allBirthEvents = [..._allBirthEvents, created];
      notifyListeners();
      return created;
    } catch (e) {
      log('❌ Failed to create birth event locally: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<BirthEventModel> updateBirthEvent(BirthEventModel model) async {
    try {
      final updated = await _eventsRepository.updateBirthEventLocally(model);
      _allBirthEvents = _allBirthEvents
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      log('❌ Failed to update birth event locally: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<BirthEventModel?> addBirthEventWithDialog(
    BuildContext context,
    BirthEventModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addBirthEvent(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.birthEventSaved,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: l10n.birthEventSaveFailed,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
  }

  Future<BirthEventModel?> updateBirthEventWithDialog(
    BuildContext context,
    BirthEventModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateBirthEvent(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.birthEventUpdated,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: l10n.birthEventUpdateFailed,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
  }

  // ============================================================================
  // ABORTED PREGNANCIES
  // ============================================================================

  Future<AbortedPregnancyModel> addAbortedPregnancy(AbortedPregnancyModel model) async {
    try {
      log('📝 Creating aborted pregnancy locally: ${model.uuid}');
      final created = await _eventsRepository.createAbortedPregnancy(model);
      log('✅ Aborted pregnancy created locally: ${created.uuid}');
      _allAbortedPregnancies = [..._allAbortedPregnancies, created];
      notifyListeners();
      return created;
    } catch (e) {
      log('❌ Failed to create aborted pregnancy locally: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<AbortedPregnancyModel> updateAbortedPregnancy(AbortedPregnancyModel model) async {
    try {
      final updated = await _eventsRepository.updateAbortedPregnancyLocally(model);
      _allAbortedPregnancies = _allAbortedPregnancies
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e) {
      log('❌ Failed to update aborted pregnancy locally: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<AbortedPregnancyModel?> addAbortedPregnancyWithDialog(
    BuildContext context,
    AbortedPregnancyModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addAbortedPregnancy(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.abortedPregnancySaved,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: l10n.abortedPregnancySaveFailed,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
  }

  Future<AbortedPregnancyModel?> updateAbortedPregnancyWithDialog(
    BuildContext context,
    AbortedPregnancyModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateAbortedPregnancy(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.abortedPregnancyUpdated,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: l10n.abortedPregnancyUpdateFailed,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
        );
      }
      return const [];
    }
  }

  Future<TreatmentModel?> addTreatmentWithDialog(
    BuildContext context,
    TreatmentModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addTreatment(model);
      _error = null;
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.treatmentLogSaved,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: l10n.treatmentLogSaveFailed,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
  }

  Future<TreatmentModel?> updateTreatmentWithDialog(
    BuildContext context,
    TreatmentModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    AlertDialogs.showLoading(
      context: context,
      title: l10n.update,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateTreatment(model);
      _error = null;
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.treatmentLogSaved,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: l10n.treatmentLogSaveFailed,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
  }

  Future<List<TreatmentModel>> addTreatmentBatchWithDialog({
    required BuildContext context,
    required String farmUuid,
    required List<String> livestockUuids,
    int? medicineId,
    int? diseaseId,
    String? quantity,
    String? withdrawalPeriod,
    String? medicationDate,
    String? nextMedicationDate,
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
      final created = <TreatmentModel>[];
      for (final animalUuid in livestockUuids) {
        final now = DateTime.now().toIso8601String();
        final uuid =
            'treatment-${DateTime.now().microsecondsSinceEpoch}-${animalUuid.hashCode}';
        final model = TreatmentModel(
          uuid: uuid,
          farmUuid: farmUuid,
          livestockUuid: animalUuid,
          medicineId: medicineId,
          diseaseId: diseaseId,
          quantity: quantity,
          withdrawalPeriod: withdrawalPeriod,
          medicationDate: medicationDate ?? now,
          nextMedicationDate: nextMedicationDate,
          remarks: remarks,
          synced: false,
          syncAction: 'create',
          createdAt: now,
          updatedAt: now,
        );
        created.add(await addTreatment(model));
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.treatmentLogSaved,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          message: l10n.treatmentLogSaveFailed,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
        );
      }
      return created;
    } catch (e, stackTrace) {
      _error = e.toString();
      log('❌ Failed to save vaccination log in provider: $e', stackTrace: stackTrace);
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.vaccinationLogSaveFailed,
          buttonText: l10n.ok,
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
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
    String? vaccineUuid,
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
          vaccineUuid: vaccineUuid,
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
          // Dialog already pops itself, no need for onPressed
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
          // Dialog already pops itself, no need for onPressed
        );
      }
      return const [];
    }
  }

  Future<DisposalModel?> addDisposalWithDialog(
    BuildContext context,
    DisposalModel model, {
    VoidCallback? onSuccess,
  }) async {
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
          onPressed: onSuccess,
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
          // Dialog already pops itself, no need for onPressed
        );
      }
      return null;
    }
  }

  Future<DisposalModel?> updateDisposalWithDialog(
    BuildContext context,
    DisposalModel model, {
    VoidCallback? onSuccess,
  }) async {
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
          onPressed: onSuccess,
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
          // Dialog already pops itself, no need for onPressed
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
    VoidCallback? onSuccess,
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
          onPressed: onSuccess,
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
          // Dialog already pops itself, no need for onPressed
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
      case EventLogTypes.treatment:
        return await _eventsRepository.getTreatments(
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
      case EventLogTypes.calving:
        // Filter birth events to only show calving events
        final allBirthEvents = await _eventsRepository.getBirthEvents(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
        return allBirthEvents
            .where((event) => event.eventType == EventLogTypes.calving)
            .toList();
      case EventLogTypes.farrowing:
        // Filter birth events to only show farrowing events
        final allBirthEvents = await _eventsRepository.getBirthEvents(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
        return allBirthEvents
            .where((event) => event.eventType == EventLogTypes.farrowing)
            .toList();
      case EventLogTypes.abortedPregnancy:
        return await _eventsRepository.getAbortedPregnancies(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.insemination:
        return await _eventsRepository.getInseminations(
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
      case EventLogTypes.dryoff:
        return await _eventsRepository.getDryoffs(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.transfer:
        return await _eventsRepository.getTransfers(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.teethClipping:
        return await _eventsRepository.getTeethClippings(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.tailDocking:
        return await _eventsRepository.getTailDockings(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.ironInjection:
        return await _eventsRepository.getIronInjections(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.livestockMarking:
        return await _eventsRepository.getLivestockMarkings(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.stageChange:
        return await _eventsRepository.getStageChanges(
          farmUuid: farmUuid,
          livestockUuid: livestockUuid,
        );
      case EventLogTypes.prepuceCondition:
        return await _eventsRepository.getPrepuceConditions(
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
    _treatments = const [];
    _vaccinations = const [];
    _disposals = const [];
    _allFeedings = const [];
    _allWeightChanges = const [];
    _allDewormings = const [];
    _allTreatments = const [];
    _allVaccinations = const [];
    _allDisposals = const [];
    _allBirthEvents = const [];
    _allAbortedPregnancies = const [];
    _milkings = const [];
    _pregnancies = const [];
    _inseminations = const [];
    _dryoffs = const [];
    _transfers = const [];
    _allMilkings = const [];
    _allPregnancies = const [];
    _allInseminations = const [];
    _allDryoffs = const [];
    _allTransfers = const [];
    _allTeethClippings = const [];
    _allTailDockings = const [];
    _allIronInjections = const [];
    _allLivestockMarkings = const [];
    _allStageChanges = const [];
    _allPrepuceConditions = const [];
    _error = null;
    notifyListeners();
  }

  // Helper method to create or update notification for feeding events
  Future<void> _createFeedingNotification(FeedingModel feeding) async {
    if (_notificationProvider == null) {
      log('⚠️ NotificationProvider not available, skipping notification creation');
      return;
    }

    try {
      final nextFeedingTime = DateTime.tryParse(feeding.nextFeedingTime);
      if (nextFeedingTime == null) {
        log('⚠️ Invalid nextFeedingTime format: ${feeding.nextFeedingTime}');
        return;
      }

      final now = DateTime.now();
      if (nextFeedingTime.isBefore(now)) {
        log('⚠️ Next feeding time is in the past, skipping notification');
        return;
      }

      // Check if notification already exists for this feeding event
      final existingNotifications = _notificationProvider.notifications
          .where((n) =>
              n.title == 'feeding_reminder' &&
              n.farmUuid == feeding.farmUuid &&
              n.livestockUuid == feeding.livestockUuid &&
              !n.isCompleted)
          .toList();

      NotificationModel notification;
      if (existingNotifications.isNotEmpty) {
        // Update existing notification with new scheduled time
        final existing = existingNotifications.first;
        notification = existing.copyWith(
          scheduledAt: nextFeedingTime.toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          synced: false,
          syncAction: 'update',
        );
        log('🔄 Updating existing feeding notification');
      } else {
        // Create new notification
        notification = NotificationModel(
        farmUuid: feeding.farmUuid,
        farmName: null, // Will be populated when displaying
        livestockUuid: feeding.livestockUuid,
        livestockName: null, // Will be populated when displaying
        title: 'feeding_reminder', // Key for localization
        description: 'time_to_feed_livestock', // Key for localization
        scheduledAt: nextFeedingTime.toIso8601String(),
        isCompleted: false,
        synced: false,
        syncAction: 'create',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        repeatDaily: false,
      );
        log('➕ Creating new feeding notification');
      }

      await _notificationProvider.saveNotification(notification);
      log('✅ Feeding notification saved for ${nextFeedingTime.toLocal()}');
    } catch (e) {
      log('❌ Failed to create feeding notification: $e');
      // Don't rethrow - notification creation failure shouldn't fail the feeding event
    }
  }

  // Helper method to create or update notification for deworming events
  Future<void> _createDewormingNotification(DewormingModel deworming) async {
    if (_notificationProvider == null) {
      log('⚠️ NotificationProvider not available, skipping notification creation');
      return;
    }

    try {
      final nextAdminDate = deworming.nextAdministrationDate;
      if (nextAdminDate == null || nextAdminDate.isEmpty) {
        log('⚠️ No next administration date set for deworming');
        return;
      }

      final nextDate = DateTime.tryParse(nextAdminDate);
      if (nextDate == null) {
        log('⚠️ Invalid nextAdministrationDate format: $nextAdminDate');
        return;
      }

      final now = DateTime.now();
      if (nextDate.isBefore(now)) {
        log('⚠️ Next deworming date is in the past, skipping notification');
        return;
      }

      // Check if notification already exists for this deworming event
      final existingNotifications = _notificationProvider.notifications
          .where((n) =>
              n.title == 'deworming_reminder' &&
              n.farmUuid == deworming.farmUuid &&
              n.livestockUuid == deworming.livestockUuid &&
              !n.isCompleted)
          .toList();

      NotificationModel notification;
      if (existingNotifications.isNotEmpty) {
        // Update existing notification with new scheduled time
        final existing = existingNotifications.first;
        notification = existing.copyWith(
          scheduledAt: nextDate.toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          synced: false,
          syncAction: 'update',
        );
        log('🔄 Updating existing deworming notification');
      } else {
        // Create new notification
        notification = NotificationModel(
        farmUuid: deworming.farmUuid,
        farmName: null, // Will be populated when displaying
        livestockUuid: deworming.livestockUuid,
        livestockName: null, // Will be populated when displaying
        title: 'deworming_reminder', // Key for localization
        description: 'time_to_deworm_livestock', // Key for localization
        scheduledAt: nextDate.toIso8601String(),
        isCompleted: false,
        synced: false,
        syncAction: 'create',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        repeatDaily: false,
      );
        log('➕ Creating new deworming notification');
      }

      await _notificationProvider.saveNotification(notification);
      log('✅ Deworming notification saved for ${nextDate.toLocal()}');
    } catch (e) {
      log('❌ Failed to create deworming notification: $e');
      // Don't rethrow - notification creation failure shouldn't fail the deworming event
    }
  }

  // Helper method to create or update notification for treatment events
  Future<void> _createTreatmentNotification(TreatmentModel treatment) async {
    if (_notificationProvider == null) {
      log('⚠️ NotificationProvider not available, skipping notification creation');
      return;
    }

    try {
      final nextMedicationDate = treatment.nextMedicationDate;
      if (nextMedicationDate == null || nextMedicationDate.isEmpty) {
        log('⚠️ No next medication date set for treatment');
        return;
      }

      final nextDate = DateTime.tryParse(nextMedicationDate);
      if (nextDate == null) {
        log('⚠️ Invalid nextMedicationDate format: $nextMedicationDate');
        return;
      }

      final now = DateTime.now();
      if (nextDate.isBefore(now)) {
        log('⚠️ Next treatment date is in the past, skipping notification');
        return;
      }

      // Check if notification already exists for this treatment event
      final existingNotifications = _notificationProvider.notifications
          .where((n) =>
              n.title == 'treatment_reminder' &&
              n.farmUuid == treatment.farmUuid &&
              n.livestockUuid == treatment.livestockUuid &&
              !n.isCompleted)
          .toList();

      NotificationModel notification;
      if (existingNotifications.isNotEmpty) {
        // Update existing notification with new scheduled time
        final existing = existingNotifications.first;
        notification = existing.copyWith(
          scheduledAt: nextDate.toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          synced: false,
          syncAction: 'update',
        );
        log('🔄 Updating existing treatment notification');
      } else {
        // Create new notification
        notification = NotificationModel(
          farmUuid: treatment.farmUuid,
          farmName: null, // Will be populated when displaying
          livestockUuid: treatment.livestockUuid,
          livestockName: null, // Will be populated when displaying
          title: 'treatment_reminder', // Key for localization
          description: 'time_to_treat_livestock', // Key for localization
          scheduledAt: nextDate.toIso8601String(),
          isCompleted: false,
          synced: false,
          syncAction: 'create',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          repeatDaily: false,
        );
        log('➕ Creating new treatment notification');
      }

      await _notificationProvider.saveNotification(notification);
      log('✅ Treatment notification saved for ${nextDate.toLocal()}');
    } catch (e) {
      log('❌ Failed to create treatment notification: $e');
      // Don't rethrow - notification creation failure shouldn't fail the treatment event
    }
  }

}

