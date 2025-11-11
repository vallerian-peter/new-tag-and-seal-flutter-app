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

  /// Store a medication event locally (unsynced, marked for create).
  Future<MedicationModel> createMedication(MedicationModel model);

  /// Update a medication event locally (unsynced, marked for update).
  Future<MedicationModel> updateMedicationLocally(MedicationModel model);

  /// Store a vaccination event locally (unsynced, marked for create).
  Future<VaccinationModel> createVaccination(VaccinationModel model);

  /// Update a vaccination event locally (unsynced, marked for update).
  Future<VaccinationModel> updateVaccinationLocally(VaccinationModel model);

  /// Store a disposal event locally (unsynced, marked for create).
  Future<DisposalModel> createDisposal(DisposalModel model);

  /// Update a disposal event locally (unsynced, marked for update).
  Future<DisposalModel> updateDisposalLocally(DisposalModel model);

  Future<MilkingModel> createMilking(MilkingModel model);
  Future<MilkingModel> updateMilkingLocally(MilkingModel model);

  Future<PregnancyModel> createPregnancy(PregnancyModel model);
  Future<PregnancyModel> updatePregnancyLocally(PregnancyModel model);

  Future<CalvingModel> createCalving(CalvingModel model);
  Future<CalvingModel> updateCalvingLocally(CalvingModel model);

  Future<DryoffModel> createDryoff(DryoffModel model);
  Future<DryoffModel> updateDryoffLocally(DryoffModel model);

  Future<InseminationModel> createInsemination(InseminationModel model);
  Future<InseminationModel> updateInseminationLocally(InseminationModel model);
  Future<TransferModel> createTransfer(TransferModel model);
  Future<TransferModel> updateTransferLocally(TransferModel model);

  /// Retrieve feedings optionally filtered by farm/livestock.
  Future<List<FeedingModel>> getFeedings({
    String? farmUuid,
    String? livestockUuid,
  });

  /// Retrieve weight change logs optionally filtered by farm/livestock.
  Future<List<WeightChangeModel>> getWeightChanges({
    String? farmUuid,
    String? livestockUuid,
  });

  /// Retrieve deworming logs optionally filtered by farm/livestock.
  Future<List<DewormingModel>> getDewormings({
    String? farmUuid,
    String? livestockUuid,
  });

  /// Retrieve medication logs optionally filtered by farm/livestock.
  Future<List<MedicationModel>> getMedications({
    String? farmUuid,
    String? livestockUuid,
  });

  /// Retrieve vaccination logs optionally filtered by farm/livestock.
  Future<List<VaccinationModel>> getVaccinations({
    String? farmUuid,
    String? livestockUuid,
  });

  /// Retrieve disposal logs optionally filtered by farm/livestock.
  Future<List<DisposalModel>> getDisposals({
    String? farmUuid,
    String? livestockUuid,
  });

  Future<List<MilkingModel>> getMilkings({
    String? farmUuid,
    String? livestockUuid,
  });
  Future<List<PregnancyModel>> getPregnancies({
    String? farmUuid,
    String? livestockUuid,
  });
  Future<List<CalvingModel>> getCalvings({
    String? farmUuid,
    String? livestockUuid,
  });
  Future<List<DryoffModel>> getDryoffs({
    String? farmUuid,
    String? livestockUuid,
  });
  Future<List<InseminationModel>> getInseminations({
    String? farmUuid,
    String? livestockUuid,
  });
  Future<List<TransferModel>> getTransfers({
    String? farmUuid,
    String? livestockUuid,
  });

  /// Retrieve all local feedings.
  Future<List<FeedingModel>> getAllFeedings();

  /// Retrieve all local weight change logs.
  Future<List<WeightChangeModel>> getAllWeightChanges();

  /// Retrieve all local deworming logs.
  Future<List<DewormingModel>> getAllDewormings();
  Future<List<MedicationModel>> getAllMedications();
  Future<List<VaccinationModel>> getAllVaccinations();
  Future<List<DisposalModel>> getAllDisposals();
  Future<List<MilkingModel>> getAllMilkings();
  Future<List<PregnancyModel>> getAllPregnancies();
  Future<List<CalvingModel>> getAllCalvings();
  Future<List<DryoffModel>> getAllDryoffs();
  Future<List<InseminationModel>> getAllInseminations();
  Future<List<TransferModel>> getAllTransfers();
  Future<Map<String, String>> getFarmNamesByUuid(
      Iterable<String> farmUuids,
  );
  Future<Map<String, String>> getLivestockNamesByUuid(
      Iterable<String> livestockUuids,
  );
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

  /// Get unsynced medication logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedMedicationsForApi();

  /// Get unsynced vaccination logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedVaccinationsForApi();

  /// Get unsynced disposal logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedDisposalsForApi();

  Future<List<Map<String, dynamic>>> getUnsyncedMilkingsForApi();
  Future<List<Map<String, dynamic>>> getUnsyncedPregnanciesForApi();
  Future<List<Map<String, dynamic>>> getUnsyncedCalvingsForApi();
  Future<List<Map<String, dynamic>>> getUnsyncedDryoffsForApi();
  Future<List<Map<String, dynamic>>> getUnsyncedInseminationsForApi();
  Future<List<Map<String, dynamic>>> getUnsyncedTransfersForApi();

  /// Mark feedings as synced or delete them if marked for deletion.
  Future<void> markFeedingsAsSynced(List<String> uuids);

  /// Mark weight change logs as synced or delete them if marked for deletion.
  Future<void> markWeightChangesAsSynced(List<String> uuids);

  /// Mark deworming logs as synced or delete them if marked for deletion.
  Future<void> markDewormingsAsSynced(List<String> uuids);

  /// Mark medication logs as synced or delete them if marked for deletion.
  Future<void> markMedicationsAsSynced(List<String> uuids);

  /// Mark vaccination logs as synced or delete them if marked for deletion.
  Future<void> markVaccinationsAsSynced(List<String> uuids);

  /// Mark disposal logs as synced or delete them if marked for deletion.
  Future<void> markDisposalsAsSynced(List<String> uuids);

  Future<void> markMilkingsAsSynced(List<String> uuids);
  Future<void> markPregnanciesAsSynced(List<String> uuids);
  Future<void> markCalvingsAsSynced(List<String> uuids);
  Future<void> markDryoffsAsSynced(List<String> uuids);
  Future<void> markInseminationsAsSynced(List<String> uuids);
  Future<void> markTransfersAsSynced(List<String> uuids);

  /// Flag a feeding log for deletion during next sync.
  Future<bool> markFeedingAsDeleted(String uuid);

  /// Flag a weight change log for deletion during next sync.
  Future<bool> markWeightChangeAsDeleted(String uuid);

  /// Flag a deworming log for deletion during next sync.
  Future<bool> markDewormingAsDeleted(String uuid);

  /// Flag a medication log for deletion during next sync.
  Future<bool> markMedicationAsDeleted(String uuid);

  /// Flag a vaccination log for deletion during next sync.
  Future<bool> markVaccinationAsDeleted(String uuid);

  /// Flag a disposal log for deletion during next sync.
  Future<bool> markDisposalAsDeleted(String uuid);

  Future<bool> markMilkingAsDeleted(String uuid);
  Future<bool> markPregnancyAsDeleted(String uuid);
  Future<bool> markCalvingAsDeleted(String uuid);
  Future<bool> markDryoffAsDeleted(String uuid);
  Future<bool> markInseminationAsDeleted(String uuid);
  Future<bool> markTransferAsDeleted(String uuid);
}
