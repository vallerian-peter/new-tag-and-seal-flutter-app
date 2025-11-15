import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/medication_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/vaccination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
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

  /// Retrieve feedings optionally filtered by farm/livestock.
  Future<List<FeedingModel>> getFeedings({String? farmUuid, String? livestockUuid});

  /// Retrieve weight change logs optionally filtered by farm/livestock.
  Future<List<WeightChangeModel>> getWeightChanges({String? farmUuid, String? livestockUuid});

  /// Retrieve deworming logs optionally filtered by farm/livestock.
  Future<List<DewormingModel>> getDewormings({String? farmUuid, String? livestockUuid});

  /// Retrieve medication logs optionally filtered by farm/livestock.
  Future<List<MedicationModel>> getMedications({String? farmUuid, String? livestockUuid});

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
  Future<List<MedicationModel>> getAllMedications();
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

  /// Get unsynced medication logs formatted for API submission.
  Future<List<Map<String, dynamic>>> getUnsyncedMedicationsForApi();

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

  /// Mark medication logs as synced or delete them if marked for deletion.
  Future<void> markMedicationsAsSynced(List<String> uuids);

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

  /// Flag a medication log for deletion during next sync.
  Future<bool> markMedicationAsDeleted(String uuid);

  /// Flag a vaccination log for deletion during next sync.
  Future<bool> markVaccinationAsDeleted(String uuid);

  /// Flag a disposal log for deletion during next sync.
  Future<bool> markDisposalAsDeleted(String uuid);

  /// Mark every log associated with a livestock UUID as deleted.
  Future<void> markAllLogsForLivestockAsDeleted(String livestockUuid);
}


