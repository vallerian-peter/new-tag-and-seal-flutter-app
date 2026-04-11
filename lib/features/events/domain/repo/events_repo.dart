import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/treatment_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/vaccination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/birth_event_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/aborted_pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/milking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/insemination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/dryoff_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/transfer_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/teeth_clipping_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/tail_docking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/iron_injection_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/livestock_marking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/stage_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/prepuce_condition_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/summary/event_summary.dart';

/// Contract for all event (logs) repository operations.
///
/// Ensures communication follows provider → domain repo → data repository flow.
abstract class EventsRepositoryInterface {
  /// Merge server-provided logs into local storage with conflict resolution.
  Future<void> syncLogs(Map<String, dynamic>? logs);

  /// Store a feeding event locally (unsynced, marked for create).
  Future<FeedingModel> createFeeding(FeedingModel model);

  /// Update a feeding event locally (unsynced, marked for update).
  Future<FeedingModel> updateFeedingLocally(FeedingModel model);

  /// Store a weight change event locally (unsynced, marked for create).
  Future<WeightChangeModel> createWeightChange(WeightChangeModel model);

  /// Update a weight change event locally (unsynced, marked for update).
  Future<WeightChangeModel> updateWeightChangeLocally(WeightChangeModel model);

  /// Store a deworming event locally (unsynced, marked for create).
  Future<DewormingModel> createDeworming(DewormingModel model);

  /// Update a deworming event locally (unsynced, marked for update).
  Future<DewormingModel> updateDewormingLocally(DewormingModel model);

  /// Store a treatment event locally (unsynced, marked for create).
  Future<TreatmentModel> createTreatment(TreatmentModel model);

  /// Update a treatment event locally (unsynced, marked for update).
  Future<TreatmentModel> updateTreatmentLocally(TreatmentModel model);

  /// Store a vaccination event locally (unsynced, marked for create).
  Future<VaccinationModel> createVaccination(VaccinationModel model);

  /// Update a vaccination event locally (unsynced, marked for update).
  Future<VaccinationModel> updateVaccinationLocally(VaccinationModel model);

  /// Store a disposal event locally (unsynced, marked for create).
  Future<DisposalModel> createDisposal(DisposalModel model);

  /// Update a disposal event locally (unsynced, marked for update).
  Future<DisposalModel> updateDisposalLocally(DisposalModel model);

  /// Retrieve feedings optionally filtered by farm/livestock.
  Future<List<FeedingModel>> getFeedings({String? farmUuid, String? livestockUuid});

  /// Retrieve weight change logs optionally filtered by farm/livestock.
  Future<List<WeightChangeModel>> getWeightChanges({String? farmUuid, String? livestockUuid});

  /// Retrieve deworming logs optionally filtered by farm/livestock.
  Future<List<DewormingModel>> getDewormings({String? farmUuid, String? livestockUuid});

  /// Retrieve treatment logs optionally filtered by farm/livestock.
  Future<List<TreatmentModel>> getTreatments({String? farmUuid, String? livestockUuid});

  /// Retrieve vaccination logs optionally filtered by farm/livestock.
  Future<List<VaccinationModel>> getVaccinations({String? farmUuid, String? livestockUuid});

  /// Retrieve disposal logs optionally filtered by farm/livestock.
  Future<List<DisposalModel>> getDisposals({String? farmUuid, String? livestockUuid});

  /// Retrieve all local feedings.
  Future<List<FeedingModel>> getAllFeedings();

  /// Retrieve all local weight change logs.
  Future<List<WeightChangeModel>> getAllWeightChanges();

  /// Retrieve all local deworming logs.
  Future<List<DewormingModel>> getAllDewormings();
  Future<List<TreatmentModel>> getAllTreatments();
  Future<List<VaccinationModel>> getAllVaccinations();
  Future<List<DisposalModel>> getAllDisposals();
  Future<Map<String, int>> getLogCounts({
    String? farmUuid,
    String? livestockUuid,
  });
  Future<EventSummary> getEventSummary();

  /// Get unsynced feedings formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedFeedingsForApi();

  /// Get unsynced weight change logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedWeightChangesForApi();

  /// Get unsynced deworming logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedDewormingsForApi();

  /// Get unsynced treatment logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedTreatmentsForApi();

  /// Get unsynced vaccination logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedVaccinationsForApi();

  /// Get unsynced disposal logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedDisposalsForApi();

  /// Mark feedings as synced or delete them if marked for deletion.
  Future<void> markFeedingsAsSynced(List<String> uuids);

  /// Mark weight change logs as synced or delete them if marked for deletion.
  Future<void> markWeightChangesAsSynced(List<String> uuids);

  /// Mark deworming logs as synced or delete them if marked for deletion.
  Future<void> markDewormingsAsSynced(List<String> uuids);

  /// Mark treatment logs as synced or delete them if marked for deletion.
  Future<void> markTreatmentsAsSynced(List<String> uuids);

  /// Mark vaccination logs as synced or delete them if marked for deletion.
  Future<void> markVaccinationsAsSynced(List<String> uuids);

  /// Mark disposal logs as synced or delete them if marked for deletion.
  Future<void> markDisposalsAsSynced(List<String> uuids);

  /// Flag a feeding log for deletion during next sync.
  Future<bool> markFeedingAsDeleted(String uuid);

  /// Flag a weight change log for deletion during next sync.
  Future<bool> markWeightChangeAsDeleted(String uuid);

  /// Flag a deworming log for deletion during next sync.
  Future<bool> markDewormingAsDeleted(String uuid);

  /// Flag a treatment log for deletion during next sync.
  Future<bool> markTreatmentAsDeleted(String uuid);

  /// Flag a vaccination log for deletion during next sync.
  Future<bool> markVaccinationAsDeleted(String uuid);

  /// Flag a disposal log for deletion during next sync.
  Future<bool> markDisposalAsDeleted(String uuid);

  /// Mark every log associated with a livestock UUID as deleted.
  Future<void> markAllLogsForLivestockAsDeleted(String livestockUuid);

  // ============================================================================
  // BIRTH EVENTS (replaces calvings)
  // ============================================================================

  /// Store a birth event locally (unsynced, marked for create).
  Future<BirthEventModel> createBirthEvent(BirthEventModel model);

  /// Update a birth event locally (unsynced, marked for update).
  Future<BirthEventModel> updateBirthEventLocally(BirthEventModel model);

  /// Retrieve birth events optionally filtered by farm/livestock.
  Future<List<BirthEventModel>> getBirthEvents({String? farmUuid, String? livestockUuid});

  /// Retrieve all local birth events.
  Future<List<BirthEventModel>> getAllBirthEvents();

  /// Get unsynced birth events formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedBirthEventsForApi();

  /// Mark birth events as synced or delete them if marked for deletion.
  Future<void> markBirthEventsAsSynced(List<String> uuids);

  /// Flag a birth event log for deletion during next sync.
  Future<bool> markBirthEventAsDeleted(String uuid);

  // ============================================================================
  // ABORTED PREGNANCIES
  // ============================================================================

  /// Store an aborted pregnancy event locally (unsynced, marked for create).
  Future<AbortedPregnancyModel> createAbortedPregnancy(AbortedPregnancyModel model);

  /// Update an aborted pregnancy event locally (unsynced, marked for update).
  Future<AbortedPregnancyModel> updateAbortedPregnancyLocally(AbortedPregnancyModel model);

  /// Retrieve aborted pregnancies optionally filtered by farm/livestock.
  Future<List<AbortedPregnancyModel>> getAbortedPregnancies({String? farmUuid, String? livestockUuid});

  /// Retrieve all local aborted pregnancies.
  Future<List<AbortedPregnancyModel>> getAllAbortedPregnancies();

  /// Get unsynced aborted pregnancies formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedAbortedPregnanciesForApi();

  /// Mark aborted pregnancies as synced or delete them if marked for deletion.
  Future<void> markAbortedPregnanciesAsSynced(List<String> uuids);

  /// Flag an aborted pregnancy log for deletion during next sync.
  Future<bool> markAbortedPregnancyAsDeleted(String uuid);

  // ============================================================================
  // MILKING
  // ============================================================================

  /// Store a milking event locally (unsynced, marked for create).
  Future<MilkingModel> createMilking(MilkingModel model);

  /// Update a milking event locally (unsynced, marked for update).
  Future<MilkingModel> updateMilkingLocally(MilkingModel model);

  /// Retrieve milking logs optionally filtered by farm/livestock.
  Future<List<MilkingModel>> getMilkings({String? farmUuid, String? livestockUuid});

  /// Retrieve all local milking logs.
  Future<List<MilkingModel>> getAllMilkings();

  /// Get unsynced milking logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedMilkingsForApi();

  /// Mark milking logs as synced or delete them if marked for deletion.
  Future<void> markMilkingsAsSynced(List<String> uuids);

  // ============================================================================
  // PREGNANCY
  // ============================================================================

  /// Store a pregnancy event locally (unsynced, marked for create).
  Future<PregnancyModel> createPregnancy(PregnancyModel model);

  /// Update a pregnancy event locally (unsynced, marked for update).
  Future<PregnancyModel> updatePregnancyLocally(PregnancyModel model);

  /// Retrieve pregnancy logs optionally filtered by farm/livestock.
  Future<List<PregnancyModel>> getPregnancies({String? farmUuid, String? livestockUuid});

  /// Retrieve all local pregnancy logs.
  Future<List<PregnancyModel>> getAllPregnancies();

  /// Get unsynced pregnancy logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedPregnanciesForApi();

  /// Mark pregnancy logs as synced or delete them if marked for deletion.
  Future<void> markPregnanciesAsSynced(List<String> uuids);

  // ============================================================================
  // INSEMINATION
  // ============================================================================

  /// Store an insemination event locally (unsynced, marked for create).
  Future<InseminationModel> createInsemination(InseminationModel model);

  /// Update an insemination event locally (unsynced, marked for update).
  Future<InseminationModel> updateInseminationLocally(InseminationModel model);

  /// Retrieve insemination logs optionally filtered by farm/livestock.
  Future<List<InseminationModel>> getInseminations({String? farmUuid, String? livestockUuid});

  /// Retrieve all local insemination logs.
  Future<List<InseminationModel>> getAllInseminations();

  /// Get unsynced insemination logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedInseminationsForApi();

  /// Mark insemination logs as synced or delete them if marked for deletion.
  Future<void> markInseminationsAsSynced(List<String> uuids);

  // ============================================================================
  // DRYOFF
  // ============================================================================

  /// Store a dryoff event locally (unsynced, marked for create).
  Future<DryoffModel> createDryoff(DryoffModel model);

  /// Update a dryoff event locally (unsynced, marked for update).
  Future<DryoffModel> updateDryoffLocally(DryoffModel model);

  /// Retrieve dryoff logs optionally filtered by farm/livestock.
  Future<List<DryoffModel>> getDryoffs({String? farmUuid, String? livestockUuid});

  /// Retrieve all local dryoff logs.
  Future<List<DryoffModel>> getAllDryoffs();

  /// Get unsynced dryoff logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedDryoffsForApi();

  /// Mark dryoff logs as synced or delete them if marked for deletion.
  Future<void> markDryoffsAsSynced(List<String> uuids);

  // ============================================================================
  // TRANSFER
  // ============================================================================

  /// Store a transfer event locally (unsynced, marked for create).
  Future<TransferModel> createTransfer(TransferModel model);

  /// Update a transfer event locally (unsynced, marked for update).
  Future<TransferModel> updateTransferLocally(TransferModel model);

  /// Retrieve transfer logs optionally filtered by farm/livestock.
  Future<List<TransferModel>> getTransfers({String? farmUuid, String? livestockUuid});

  /// Retrieve all local transfer logs.
  Future<List<TransferModel>> getAllTransfers();

  /// Get unsynced transfer logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedTransfersForApi();

  /// Mark transfer logs as synced or delete them if marked for deletion.
  Future<void> markTransfersAsSynced(List<String> uuids);

  // ============================================================================
  // HUSBANDRY / NOTEBOOK (per-head procedures)
  // ============================================================================

  Future<TeethClippingModel> createTeethClipping(TeethClippingModel model);
  Future<TeethClippingModel> updateTeethClippingLocally(
    TeethClippingModel model,
  );
  Future<List<TeethClippingModel>> getTeethClippings({
    String? farmUuid,
    String? livestockUuid,
  });

  Future<List<TeethClippingModel>> getAllTeethClippings();

  Future<List<Map<String, dynamic>>> getUnsyncedTeethClippingsForApi();

  Future<void> markTeethClippingsAsSynced(List<String> uuids);

  Future<TailDockingModel> createTailDocking(TailDockingModel model);
  Future<TailDockingModel> updateTailDockingLocally(TailDockingModel model);
  Future<List<TailDockingModel>> getTailDockings({
    String? farmUuid,
    String? livestockUuid,
  });

  Future<List<TailDockingModel>> getAllTailDockings();

  Future<List<Map<String, dynamic>>> getUnsyncedTailDockingsForApi();

  Future<void> markTailDockingsAsSynced(List<String> uuids);

  Future<IronInjectionModel> createIronInjection(IronInjectionModel model);
  Future<IronInjectionModel> updateIronInjectionLocally(IronInjectionModel model);
  Future<List<IronInjectionModel>> getIronInjections({
    String? farmUuid,
    String? livestockUuid,
  });

  Future<List<IronInjectionModel>> getAllIronInjections();

  Future<List<Map<String, dynamic>>> getUnsyncedIronInjectionsForApi();

  Future<void> markIronInjectionsAsSynced(List<String> uuids);

  Future<LivestockMarkingModel> createLivestockMarking(
    LivestockMarkingModel model,
  );
  Future<LivestockMarkingModel> updateLivestockMarkingLocally(
    LivestockMarkingModel model,
  );
  Future<List<LivestockMarkingModel>> getLivestockMarkings({
    String? farmUuid,
    String? livestockUuid,
  });

  Future<List<LivestockMarkingModel>> getAllLivestockMarkings();

  Future<List<Map<String, dynamic>>> getUnsyncedLivestockMarkingsForApi();

  Future<void> markLivestockMarkingsAsSynced(List<String> uuids);

  Future<StageChangeModel> createStageChange(StageChangeModel model);
  Future<StageChangeModel> updateStageChangeLocally(StageChangeModel model);
  Future<List<StageChangeModel>> getStageChanges({
    String? farmUuid,
    String? livestockUuid,
  });

  Future<List<StageChangeModel>> getAllStageChanges();

  Future<List<Map<String, dynamic>>> getUnsyncedStageChangesForApi();

  Future<void> markStageChangesAsSynced(List<String> uuids);

  Future<PrepuceConditionModel> createPrepuceCondition(PrepuceConditionModel model);

  Future<PrepuceConditionModel> updatePrepuceConditionLocally(
    PrepuceConditionModel model,
  );

  Future<List<PrepuceConditionModel>> getPrepuceConditions({
    String? farmUuid,
    String? livestockUuid,
  });

  Future<List<PrepuceConditionModel>> getAllPrepuceConditions();

  Future<List<Map<String, dynamic>>> getUnsyncedPrepuceConditionsForApi();

  Future<void> markPrepuceConditionsAsSynced(List<String> uuids);
}


