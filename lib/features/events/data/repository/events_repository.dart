import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/database/daos/event_dao.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/medication_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/vaccination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/disposal_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/repo/events_repo.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/summary/event_summary.dart';

class EventsRepository implements EventsRepositoryInterface {
  final AppDatabase _database;
  late final EventDao _eventDao;

  EventsRepository(this._database) {
    _eventDao = _database.eventDao;
  }

  // ===========================================================================
  // Sync from server
  // ===========================================================================

  @override
  Future<void> syncLogs(Map<String, dynamic>? logs) async {
    if (logs == null) return;

    final feedingsCount = (logs['feedings'] as List?)?.length ?? 0;
    final weightChangesCount = (logs['weightChanges'] as List?)?.length ?? 0;
    final dewormingsCount = (logs['dewormings'] as List?)?.length ?? 0;
    final medicationsCount = (logs['medications'] as List?)?.length ?? 0;
    final vaccinationsCount = (logs['vaccinations'] as List?)?.length ?? 0;
    final disposalsCount = (logs['disposals'] as List?)?.length ?? 0;
    log(
      '🔄 Syncing event logs (feedings: $feedingsCount, weightChanges: $weightChangesCount, '
      'dewormings: $dewormingsCount, medications: $medicationsCount, '
      'vaccinations: $vaccinationsCount, disposals: $disposalsCount)...',
    );

    await _syncFeedings(logs['feedings']);
    await _syncWeightChanges(logs['weightChanges']);
    await _syncDewormings(logs['dewormings']);
    await _syncMedications(logs['medications']);
    await _syncVaccinations(logs['vaccinations']);
    await _syncDisposals(logs['disposals']);
  }

  Future<void> _syncFeedings(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = FeedingModel.fromJson(raw).copyWith(
          synced: true,
          syncAction: 'server-create',
        );
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getFeedingByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertFeeding(_toFeedingCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(id: existing.id, syncAction: 'server-update');
            await _eventDao.upsertFeeding(_toFeedingCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing feeding log: $e');
      }
    }

    await _eventDao.deleteServerFeedingsNotIn(remoteUuids);
  }

  Future<void> _syncWeightChanges(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = WeightChangeModel.fromJson(raw).copyWith(
          synced: true,
          syncAction: 'server-create',
        );
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getWeightChangeByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertWeightChange(_toWeightChangeCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(id: existing.id, syncAction: 'server-update');
            await _eventDao.upsertWeightChange(_toWeightChangeCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing weight change log: $e');
      }
    }

    await _eventDao.deleteServerWeightChangesNotIn(remoteUuids);
  }

  Future<void> _syncDewormings(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = DewormingModel.fromJson(raw).copyWith(
          synced: true,
          syncAction: 'server-create',
        );
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getDewormingByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertDeworming(_toDewormingCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(id: existing.id, syncAction: 'server-update');
            await _eventDao.upsertDeworming(_toDewormingCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing deworming log: $e');
      }
    }

    await _eventDao.deleteServerDewormingsNotIn(remoteUuids);
  }

  Future<void> _syncMedications(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = MedicationModel.fromJson(raw).copyWith(
          synced: true,
          syncAction: 'server-create',
        );
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getMedicationByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertMedication(_toMedicationCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(id: existing.id, syncAction: 'server-update');
            await _eventDao.upsertMedication(_toMedicationCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing medication log: $e');
      }
    }

    await _eventDao.deleteServerMedicationsNotIn(remoteUuids);
  }

  Future<void> _syncVaccinations(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = VaccinationModel.fromJson(raw).copyWith(
          synced: true,
          syncAction: 'server-create',
        );
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getVaccinationByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertVaccination(_toVaccinationCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(id: existing.id, syncAction: 'server-update');
            await _eventDao.upsertVaccination(_toVaccinationCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing vaccination log: $e');
      }
    }

    await _eventDao.deleteServerVaccinationsNotIn(remoteUuids);
  }

  Future<void> _syncDisposals(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = DisposalModel.fromJson(raw).copyWith(
          synced: true,
          syncAction: 'server-create',
        );
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getDisposalByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertDisposal(_toDisposalCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(id: existing.id, syncAction: 'server-update');
            await _eventDao.upsertDisposal(_toDisposalCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing disposal log: $e');
      }
    }

    await _eventDao.deleteServerDisposalsNotIn(remoteUuids);
  }

  // ===========================================================================
  // Local creation (unsynced defaults)
  // ===========================================================================

  @override
  Future<FeedingModel> createFeeding(FeedingModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating feeding log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertFeeding(_toFeedingCompanion(localModel));
    return _mapFeedingEntity(inserted);
  }

  @override
  Future<FeedingModel> updateFeedingLocally(FeedingModel model) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      synced: false,
      syncAction: model.syncAction == 'create'
          ? 'create'
          : model.syncAction == 'deleted'
              ? 'deleted'
              : 'update',
      updatedAt: now,
    );

    final updated = await _eventDao.upsertFeeding(_toFeedingCompanion(localModel));
    return _mapFeedingEntity(updated);
  }

  @override
  Future<WeightChangeModel> createWeightChange(WeightChangeModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating weight change log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertWeightChange(_toWeightChangeCompanion(localModel));
    return _mapWeightChangeEntity(inserted);
  }

  @override
  Future<WeightChangeModel> updateWeightChangeLocally(WeightChangeModel model) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      synced: false,
      syncAction: model.syncAction == 'create'
          ? 'create'
          : model.syncAction == 'deleted'
              ? 'deleted'
              : 'update',
      updatedAt: now,
    );

    final updated = await _eventDao.upsertWeightChange(_toWeightChangeCompanion(localModel));
    return _mapWeightChangeEntity(updated);
  }

  @override
  Future<DewormingModel> createDeworming(DewormingModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating deworming log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertDeworming(_toDewormingCompanion(localModel));
    return _mapDewormingEntity(inserted);
  }

  @override
  Future<DewormingModel> updateDewormingLocally(DewormingModel model) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      synced: false,
      syncAction: model.syncAction == 'create'
          ? 'create'
          : model.syncAction == 'deleted'
              ? 'deleted'
              : 'update',
      updatedAt: now,
    );

    final updated = await _eventDao.upsertDeworming(_toDewormingCompanion(localModel));
    return _mapDewormingEntity(updated);
  }

  @override
  Future<MedicationModel> createMedication(MedicationModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating medication log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertMedication(_toMedicationCompanion(localModel));
    return _mapMedicationEntity(inserted);
  }

  @override
  Future<MedicationModel> updateMedicationLocally(MedicationModel model) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      synced: false,
      syncAction: model.syncAction == 'create'
          ? 'create'
          : model.syncAction == 'deleted'
              ? 'deleted'
              : 'update',
      updatedAt: now,
    );

    final updated = await _eventDao.upsertMedication(_toMedicationCompanion(localModel));
    return _mapMedicationEntity(updated);
  }

  @override
  Future<VaccinationModel> createVaccination(VaccinationModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating vaccination log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertVaccination(_toVaccinationCompanion(localModel));
    return _mapVaccinationEntity(inserted);
  }

  @override
  Future<VaccinationModel> updateVaccinationLocally(VaccinationModel model) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      synced: false,
      syncAction: model.syncAction == 'create'
          ? 'create'
          : model.syncAction == 'deleted'
              ? 'deleted'
              : 'update',
      updatedAt: now,
    );

    final updated = await _eventDao.upsertVaccination(_toVaccinationCompanion(localModel));
    return _mapVaccinationEntity(updated);
  }

  @override
  Future<DisposalModel> createDisposal(DisposalModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating disposal log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertDisposal(_toDisposalCompanion(localModel));
    return _mapDisposalEntity(inserted);
  }

  @override
  Future<DisposalModel> updateDisposalLocally(DisposalModel model) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      synced: false,
      syncAction: model.syncAction == 'create'
          ? 'create'
          : model.syncAction == 'deleted'
              ? 'deleted'
              : 'update',
      updatedAt: now,
    );

    final updated = await _eventDao.upsertDisposal(_toDisposalCompanion(localModel));
    return _mapDisposalEntity(updated);
  }

  // ===========================================================================
  // Queries
  // ===========================================================================

  @override
  Future<List<FeedingModel>> getFeedings({String? farmUuid, String? livestockUuid}) async {
    final rows = await _eventDao.getFeedings(farmUuid: farmUuid, livestockUuid: livestockUuid);
    return rows.map(_mapFeedingEntity).toList();
  }

  @override
  Future<List<WeightChangeModel>> getWeightChanges({String? farmUuid, String? livestockUuid}) async {
    final rows = await _eventDao.getWeightChanges(farmUuid: farmUuid, livestockUuid: livestockUuid);
    return rows.map(_mapWeightChangeEntity).toList();
  }

  @override
  Future<List<DewormingModel>> getDewormings({String? farmUuid, String? livestockUuid}) async {
    final rows = await _eventDao.getDewormings(farmUuid: farmUuid, livestockUuid: livestockUuid);
    return rows.map(_mapDewormingEntity).toList();
  }

  @override
  Future<List<MedicationModel>> getMedications({String? farmUuid, String? livestockUuid}) async {
    final rows = await _eventDao.getMedications(farmUuid: farmUuid, livestockUuid: livestockUuid);
    return rows.map(_mapMedicationEntity).toList();
  }

  @override
  Future<List<VaccinationModel>> getVaccinations({String? farmUuid, String? livestockUuid}) async {
    final rows = await _eventDao.getVaccinations(farmUuid: farmUuid, livestockUuid: livestockUuid);
    return rows.map(_mapVaccinationEntity).toList();
  }

  @override
  Future<List<DisposalModel>> getDisposals({String? farmUuid, String? livestockUuid}) async {
    final rows = await _eventDao.getDisposals(farmUuid: farmUuid, livestockUuid: livestockUuid);
    return rows.map(_mapDisposalEntity).toList();
  }

  @override
  Future<List<FeedingModel>> getAllFeedings() => getFeedings();

  @override
  Future<List<WeightChangeModel>> getAllWeightChanges() => getWeightChanges();

  @override
  Future<List<DewormingModel>> getAllDewormings() => getDewormings();
  @override
  Future<List<MedicationModel>> getAllMedications() => getMedications();
  @override
  Future<List<VaccinationModel>> getAllVaccinations() => getVaccinations();
  @override
  Future<List<DisposalModel>> getAllDisposals() => getDisposals();

  @override
  Future<Map<String, int>> getLogCounts({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final feedings = await getFeedings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final weightChanges = await getWeightChanges(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final dewormings = await getDewormings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final medications = await getMedications(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final vaccinations = await getVaccinations(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final disposals = await getDisposals(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );

    return {
      EventLogTypes.feeding: feedings.length,
      EventLogTypes.weightChange: weightChanges.length,
      EventLogTypes.deworming: dewormings.length,
      EventLogTypes.medication: medications.length,
      EventLogTypes.vaccination: vaccinations.length,
      EventLogTypes.disposal: disposals.length,
    };
  }
  
  @override
  Future<EventSummary> getEventSummary() async {
    final feedingsCount = (await getFeedings()).length;
    final weightChangesCount = (await getWeightChanges()).length;
    final dewormingsCount = (await getDewormings()).length;
    final medicationsCount = (await getMedications()).length;
    final vaccinationsCount = (await getVaccinations()).length;
    final disposalsCount = (await getDisposals()).length;
    return EventSummary(
      byType: {
        EventLogTypes.feeding: feedingsCount,
        EventLogTypes.weightChange: weightChangesCount,
        EventLogTypes.deworming: dewormingsCount,
        EventLogTypes.medication: medicationsCount,
        EventLogTypes.vaccination: vaccinationsCount,
        EventLogTypes.disposal: disposalsCount,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedFeedingsForApi() async {
    final rows = await _eventDao.getUnsyncedFeedings();
    if (rows.isEmpty) {
      log('✅ No unsynced feeding logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} feeding logs for sync');
    return rows.map((row) => _mapFeedingEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedWeightChangesForApi() async {
    final rows = await _eventDao.getUnsyncedWeightChanges();
    if (rows.isEmpty) {
      log('✅ No unsynced weight change logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} weight change logs for sync');
    return rows.map((row) => _mapWeightChangeEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedDewormingsForApi() async {
    final rows = await _eventDao.getUnsyncedDewormings();
    if (rows.isEmpty) {
      log('✅ No unsynced deworming logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} deworming logs for sync');
    return rows.map((row) => _mapDewormingEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedMedicationsForApi() async {
    final rows = await _eventDao.getUnsyncedMedications();
    if (rows.isEmpty) {
      log('✅ No unsynced medication logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} medication logs for sync');
    return rows.map((row) => _mapMedicationEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedVaccinationsForApi() async {
    final rows = await _eventDao.getUnsyncedVaccinations();
    if (rows.isEmpty) {
      log('✅ No unsynced vaccination logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} vaccination logs for sync');
    return rows.map((row) => _mapVaccinationEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedDisposalsForApi() async {
    final rows = await _eventDao.getUnsyncedDisposals();
    if (rows.isEmpty) {
      log('✅ No unsynced disposal logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} disposal logs for sync');
    return rows.map((row) => _mapDisposalEntity(row).toApiJson()).toList();
  }

  @override
  Future<void> markFeedingsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getFeedingByUuid(uuid);
      if (existing == null) {
        log('⚠️ Feeding log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteFeedingByUuid(uuid);
        log('🗑️ Removed feeding log after synced delete: $uuid');
      } else {
        final model = _mapFeedingEntity(existing).copyWith(
          synced: true,
          syncAction: existing.syncAction,
        );
        await _eventDao.upsertFeeding(_toFeedingCompanion(model));
        log('✅ Marked feeding log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markWeightChangesAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getWeightChangeByUuid(uuid);
      if (existing == null) {
        log('⚠️ Weight change log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteWeightChangeByUuid(uuid);
        log('🗑️ Removed weight change log after synced delete: $uuid');
      } else {
        final model = _mapWeightChangeEntity(existing).copyWith(
          synced: true,
          syncAction: existing.syncAction,
        );
        await _eventDao.upsertWeightChange(_toWeightChangeCompanion(model));
        log('✅ Marked weight change log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markDewormingsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getDewormingByUuid(uuid);
      if (existing == null) {
        log('⚠️ Deworming log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteDewormingByUuid(uuid);
        log('🗑️ Removed deworming log after synced delete: $uuid');
      } else {
        final model = _mapDewormingEntity(existing).copyWith(
          synced: true,
          syncAction: existing.syncAction,
        );
        await _eventDao.upsertDeworming(_toDewormingCompanion(model));
        log('✅ Marked deworming log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markMedicationsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getMedicationByUuid(uuid);
      if (existing == null) {
        log('⚠️ Medication log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteMedicationByUuid(uuid);
        log('🗑️ Removed medication log after synced delete: $uuid');
      } else {
        final model = _mapMedicationEntity(existing).copyWith(
          synced: true,
          syncAction: existing.syncAction,
        );
        await _eventDao.upsertMedication(_toMedicationCompanion(model));
        log('✅ Marked medication log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markVaccinationsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getVaccinationByUuid(uuid);
      if (existing == null) {
        log('⚠️ Vaccination log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteVaccinationByUuid(uuid);
        log('🗑️ Removed vaccination log after synced delete: $uuid');
      } else {
        final model = _mapVaccinationEntity(existing).copyWith(
          synced: true,
          syncAction: existing.syncAction,
        );
        await _eventDao.upsertVaccination(_toVaccinationCompanion(model));
        log('✅ Marked vaccination log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markDisposalsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getDisposalByUuid(uuid);
      if (existing == null) {
        log('⚠️ Disposal log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteDisposalByUuid(uuid);
        log('🗑️ Removed disposal log after synced delete: $uuid');
      } else {
        final model = _mapDisposalEntity(existing).copyWith(
          synced: true,
          syncAction: existing.syncAction,
        );
        await _eventDao.upsertDisposal(_toDisposalCompanion(model));
        log('✅ Marked disposal log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markAllLogsForLivestockAsDeleted(String livestockUuid) async {
    final feedings = await _eventDao.getFeedings(livestockUuid: livestockUuid);
    for (final log in feedings) {
      await markFeedingAsDeleted(log.uuid);
    }

    final weightChanges =
        await _eventDao.getWeightChanges(livestockUuid: livestockUuid);
    for (final log in weightChanges) {
      await markWeightChangeAsDeleted(log.uuid);
    }

    final dewormings =
        await _eventDao.getDewormings(livestockUuid: livestockUuid);
    for (final log in dewormings) {
      await markDewormingAsDeleted(log.uuid);
    }

    final medications =
        await _eventDao.getMedications(livestockUuid: livestockUuid);
    for (final log in medications) {
      await markMedicationAsDeleted(log.uuid);
    }

    final vaccinations =
        await _eventDao.getVaccinations(livestockUuid: livestockUuid);
    for (final log in vaccinations) {
      await markVaccinationAsDeleted(log.uuid);
    }

    final disposals =
        await _eventDao.getDisposals(livestockUuid: livestockUuid);
    for (final log in disposals) {
      await markDisposalAsDeleted(log.uuid);
    }
  }

  @override
  Future<bool> markFeedingAsDeleted(String uuid) async {
    final existing = await _eventDao.getFeedingByUuid(uuid);
    if (existing == null) {
      log('⚠️ Feeding log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapFeedingEntity(existing).copyWith(
      synced: false,
      syncAction: 'deleted',
      updatedAt: now,
    );
    await _eventDao.upsertFeeding(_toFeedingCompanion(model));
    log('🗑️ Marked feeding log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markWeightChangeAsDeleted(String uuid) async {
    final existing = await _eventDao.getWeightChangeByUuid(uuid);
    if (existing == null) {
      log('⚠️ Weight change log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapWeightChangeEntity(existing).copyWith(
      synced: false,
      syncAction: 'deleted',
      updatedAt: now,
    );
    await _eventDao.upsertWeightChange(_toWeightChangeCompanion(model));
    log('🗑️ Marked weight change log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markDewormingAsDeleted(String uuid) async {
    final existing = await _eventDao.getDewormingByUuid(uuid);
    if (existing == null) {
      log('⚠️ Deworming log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapDewormingEntity(existing).copyWith(
      synced: false,
      syncAction: 'deleted',
      updatedAt: now,
    );
    await _eventDao.upsertDeworming(_toDewormingCompanion(model));
    log('🗑️ Marked deworming log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markMedicationAsDeleted(String uuid) async {
    final existing = await _eventDao.getMedicationByUuid(uuid);
    if (existing == null) {
      log('⚠️ Medication log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapMedicationEntity(existing).copyWith(
      synced: false,
      syncAction: 'deleted',
      updatedAt: now,
    );
    await _eventDao.upsertMedication(_toMedicationCompanion(model));
    log('🗑️ Marked medication log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markVaccinationAsDeleted(String uuid) async {
    final existing = await _eventDao.getVaccinationByUuid(uuid);
    if (existing == null) {
      log('⚠️ Vaccination log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapVaccinationEntity(existing).copyWith(
      synced: false,
      syncAction: 'deleted',
      updatedAt: now,
    );
    await _eventDao.upsertVaccination(_toVaccinationCompanion(model));
    log('🗑️ Marked vaccination log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markDisposalAsDeleted(String uuid) async {
    final existing = await _eventDao.getDisposalByUuid(uuid);
    if (existing == null) {
      log('⚠️ Disposal log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapDisposalEntity(existing).copyWith(
      synced: false,
      syncAction: 'deleted',
      updatedAt: now,
    );
    await _eventDao.upsertDisposal(_toDisposalCompanion(model));
    log('🗑️ Marked disposal log as deleted (pending sync): $uuid');
    return true;
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  FeedingsCompanion _toFeedingCompanion(FeedingModel model) {
    return FeedingsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      feedingTypeId: Value(model.feedingTypeId),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      nextFeedingTime: Value(model.nextFeedingTime),
      amount: Value(model.amount),
      remarks: model.remarks != null ? Value(model.remarks!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  WeightChangesCompanion _toWeightChangeCompanion(WeightChangeModel model) {
    return WeightChangesCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      oldWeight: model.oldWeight != null ? Value(model.oldWeight!) : const Value.absent(),
      newWeight: Value(model.newWeight),
      remarks: model.remarks != null ? Value(model.remarks!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  DewormingsCompanion _toDewormingCompanion(DewormingModel model) {
    return DewormingsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      administrationRouteId: model.administrationRouteId != null
          ? Value(model.administrationRouteId!)
          : const Value.absent(),
      medicineId: model.medicineId != null ? Value(model.medicineId!) : const Value.absent(),
      vetId: model.vetId != null ? Value(model.vetId!) : const Value.absent(),
      extensionOfficerId: model.extensionOfficerId != null
          ? Value(model.extensionOfficerId!)
          : const Value.absent(),
      quantity: model.quantity != null ? Value(model.quantity!) : const Value.absent(),
      dose: model.dose != null ? Value(model.dose!) : const Value.absent(),
      nextAdministrationDate: model.nextAdministrationDate != null
          ? Value(model.nextAdministrationDate!)
          : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  MedicationsCompanion _toMedicationCompanion(MedicationModel model) {
    return MedicationsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      diseaseId: model.diseaseId != null ? Value(model.diseaseId!) : const Value.absent(),
      medicineId: model.medicineId != null ? Value(model.medicineId!) : const Value.absent(),
      quantity: model.quantity != null ? Value(model.quantity!) : const Value.absent(),
      withdrawalPeriod:
          model.withdrawalPeriod != null ? Value(model.withdrawalPeriod!) : const Value.absent(),
      medicationDate:
          model.medicationDate != null ? Value(model.medicationDate!) : const Value.absent(),
      remarks: model.remarks != null ? Value(model.remarks!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  VaccinationsCompanion _toVaccinationCompanion(VaccinationModel model) {
    return VaccinationsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      vaccinationNo:
          model.vaccinationNo != null ? Value(model.vaccinationNo!) : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      vaccineId: model.vaccineId != null ? Value(model.vaccineId!) : const Value.absent(),
      diseaseId: model.diseaseId != null ? Value(model.diseaseId!) : const Value.absent(),
      vetId: model.vetId != null ? Value(model.vetId!) : const Value.absent(),
      extensionOfficerId: model.extensionOfficerId != null
          ? Value(model.extensionOfficerId!)
          : const Value.absent(),
      status: Value(model.status),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  DisposalsCompanion _toDisposalCompanion(DisposalModel model) {
    return DisposalsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      disposalTypeId:
          model.disposalTypeId != null ? Value(model.disposalTypeId!) : const Value.absent(),
      reasons: Value(model.reasons),
      remarks: model.remarks != null ? Value(model.remarks!) : const Value.absent(),
      status: Value(model.status),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  FeedingModel _mapFeedingEntity(Feeding entity) {
    return FeedingModel(
      id: entity.id,
      uuid: entity.uuid,
      feedingTypeId: entity.feedingTypeId,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      nextFeedingTime: entity.nextFeedingTime,
      amount: entity.amount,
      remarks: entity.remarks,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  WeightChangeModel _mapWeightChangeEntity(WeightChange entity) {
    return WeightChangeModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      oldWeight: entity.oldWeight,
      newWeight: entity.newWeight,
      remarks: entity.remarks,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  DewormingModel _mapDewormingEntity(Deworming entity) {
    return DewormingModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      administrationRouteId: entity.administrationRouteId,
      medicineId: entity.medicineId,
      vetId: entity.vetId,
      extensionOfficerId: entity.extensionOfficerId,
      quantity: entity.quantity,
      dose: entity.dose,
      nextAdministrationDate: entity.nextAdministrationDate,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  MedicationModel _mapMedicationEntity(Medication entity) {
    return MedicationModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      diseaseId: entity.diseaseId,
      medicineId: entity.medicineId,
      quantity: entity.quantity,
      withdrawalPeriod: entity.withdrawalPeriod,
      medicationDate: entity.medicationDate,
      remarks: entity.remarks,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  VaccinationModel _mapVaccinationEntity(Vaccination entity) {
    return VaccinationModel(
      id: entity.id,
      uuid: entity.uuid,
      vaccinationNo: entity.vaccinationNo,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      vaccineId: entity.vaccineId,
      diseaseId: entity.diseaseId,
      vetId: entity.vetId,
      extensionOfficerId: entity.extensionOfficerId,
      status: entity.status,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  DisposalModel _mapDisposalEntity(Disposal entity) {
    return DisposalModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      disposalTypeId: entity.disposalTypeId,
      reasons: entity.reasons,
      remarks: entity.remarks,
      status: entity.status,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}


