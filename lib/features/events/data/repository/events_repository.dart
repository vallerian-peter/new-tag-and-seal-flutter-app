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
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/milking_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/pregnancy_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/calving_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/dryoff_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/insemination_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/transfer_model.dart';
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
    final milkingsCount = (logs['milkings'] as List?)?.length ?? 0;
    final pregnanciesCount = (logs['pregnancies'] as List?)?.length ?? 0;
    final calvingsCount = (logs['calvings'] as List?)?.length ?? 0;
    final dryoffsCount = (logs['dryoffs'] as List?)?.length ?? 0;
    final inseminationsCount = (logs['inseminations'] as List?)?.length ?? 0;
    final transfersCount = (logs['transfers'] as List?)?.length ?? 0;
    log(
      '🔄 Syncing event logs (feedings: $feedingsCount, weightChanges: $weightChangesCount, '
      'dewormings: $dewormingsCount, medications: $medicationsCount, '
      'vaccinations: $vaccinationsCount, disposals: $disposalsCount, '
      'milkings: $milkingsCount, pregnancies: $pregnanciesCount, '
      'calvings: $calvingsCount, dryoffs: $dryoffsCount, '
      'inseminations: $inseminationsCount, transfers: $transfersCount)...',
    );

    await _syncFeedings(logs['feedings']);
    await _syncWeightChanges(logs['weightChanges']);
    await _syncDewormings(logs['dewormings']);
    await _syncMedications(logs['medications']);
    await _syncVaccinations(logs['vaccinations']);
    await _syncDisposals(logs['disposals']);
    await _syncMilkings(logs['milkings']);
    await _syncPregnancies(logs['pregnancies']);
    await _syncCalvings(logs['calvings']);
    await _syncDryoffs(logs['dryoffs']);
    await _syncInseminations(logs['inseminations']);
    await _syncTransfers(logs['transfers']);
  }

  Future<void> _syncFeedings(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = FeedingModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getFeedingByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertFeeding(_toFeedingCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
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
        final remote = WeightChangeModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getWeightChangeByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertWeightChange(_toWeightChangeCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertWeightChange(
              _toWeightChangeCompanion(updated),
            );
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
        final remote = DewormingModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getDewormingByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertDeworming(_toDewormingCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
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
        final remote = MedicationModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getMedicationByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertMedication(_toMedicationCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
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
        final remote = VaccinationModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getVaccinationByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertVaccination(_toVaccinationCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
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
        final remote = DisposalModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getDisposalByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertDisposal(_toDisposalCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertDisposal(_toDisposalCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing disposal log: $e');
      }
    }

    await _eventDao.deleteServerDisposalsNotIn(remoteUuids);
  }

  Future<void> _syncMilkings(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = MilkingModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getMilkingByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertMilking(_toMilkingCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertMilking(_toMilkingCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing milking log: $e');
      }
    }

    await _eventDao.deleteServerMilkingsNotIn(remoteUuids);
  }

  Future<void> _syncPregnancies(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = PregnancyModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getPregnancyByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertPregnancy(_toPregnancyCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertPregnancy(_toPregnancyCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing pregnancy log: $e');
      }
    }

    await _eventDao.deleteServerPregnanciesNotIn(remoteUuids);
  }

  Future<void> _syncCalvings(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = CalvingModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getCalvingByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertCalving(_toCalvingCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertCalving(_toCalvingCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing calving log: $e');
      }
    }

    await _eventDao.deleteServerCalvingsNotIn(remoteUuids);
  }

  Future<void> _syncDryoffs(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = DryoffModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getDryoffByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertDryoff(_toDryoffCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertDryoff(_toDryoffCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing dryoff log: $e');
      }
    }

    await _eventDao.deleteServerDryoffsNotIn(remoteUuids);
  }

  Future<void> _syncInseminations(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = InseminationModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getInseminationByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertInsemination(_toInseminationCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertInsemination(
              _toInseminationCompanion(updated),
            );
          }
        }
      } catch (e) {
        log('❌ Error syncing insemination log: $e');
      }
    }

    await _eventDao.deleteServerInseminationsNotIn(remoteUuids);
  }

  Future<void> _syncTransfers(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = TransferModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getTransferByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertTransfer(_toTransferCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertTransfer(_toTransferCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing transfer log: $e');
      }
    }

    await _eventDao.deleteServerTransfersNotIn(remoteUuids);
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

    final inserted = await _eventDao.upsertFeeding(
      _toFeedingCompanion(localModel),
    );
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

    final updated = await _eventDao.upsertFeeding(
      _toFeedingCompanion(localModel),
    );
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

    final inserted = await _eventDao.upsertWeightChange(
      _toWeightChangeCompanion(localModel),
    );
    return _mapWeightChangeEntity(inserted);
  }

  @override
  Future<WeightChangeModel> updateWeightChangeLocally(
    WeightChangeModel model,
  ) async {
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

    final updated = await _eventDao.upsertWeightChange(
      _toWeightChangeCompanion(localModel),
    );
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

    final inserted = await _eventDao.upsertDeworming(
      _toDewormingCompanion(localModel),
    );
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

    final updated = await _eventDao.upsertDeworming(
      _toDewormingCompanion(localModel),
    );
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

    final inserted = await _eventDao.upsertMedication(
      _toMedicationCompanion(localModel),
    );
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

    final updated = await _eventDao.upsertMedication(
      _toMedicationCompanion(localModel),
    );
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

    final inserted = await _eventDao.upsertVaccination(
      _toVaccinationCompanion(localModel),
    );
    return _mapVaccinationEntity(inserted);
  }

  @override
  Future<VaccinationModel> updateVaccinationLocally(
    VaccinationModel model,
  ) async {
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

    final updated = await _eventDao.upsertVaccination(
      _toVaccinationCompanion(localModel),
    );
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

    final inserted = await _eventDao.upsertDisposal(
      _toDisposalCompanion(localModel),
    );
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

    final updated = await _eventDao.upsertDisposal(
      _toDisposalCompanion(localModel),
    );
    return _mapDisposalEntity(updated);
  }

  @override
  Future<MilkingModel> createMilking(MilkingModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating milking log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertMilking(
      _toMilkingCompanion(localModel),
    );
    return _mapMilkingEntity(inserted);
  }

  @override
  Future<MilkingModel> updateMilkingLocally(MilkingModel model) async {
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

    final updated = await _eventDao.upsertMilking(
      _toMilkingCompanion(localModel),
    );
    return _mapMilkingEntity(updated);
  }

  @override
  Future<PregnancyModel> createPregnancy(PregnancyModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating pregnancy log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertPregnancy(
      _toPregnancyCompanion(localModel),
    );
    return _mapPregnancyEntity(inserted);
  }

  @override
  Future<PregnancyModel> updatePregnancyLocally(PregnancyModel model) async {
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

    final updated = await _eventDao.upsertPregnancy(
      _toPregnancyCompanion(localModel),
    );
    return _mapPregnancyEntity(updated);
  }

  @override
  Future<CalvingModel> createCalving(CalvingModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating calving log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertCalving(
      _toCalvingCompanion(localModel),
    );
    return _mapCalvingEntity(inserted);
  }

  @override
  Future<CalvingModel> updateCalvingLocally(CalvingModel model) async {
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

    final updated = await _eventDao.upsertCalving(
      _toCalvingCompanion(localModel),
    );
    return _mapCalvingEntity(updated);
  }

  @override
  Future<DryoffModel> createDryoff(DryoffModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating dryoff log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertDryoff(
      _toDryoffCompanion(localModel),
    );
    return _mapDryoffEntity(inserted);
  }

  @override
  Future<DryoffModel> updateDryoffLocally(DryoffModel model) async {
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

    final updated = await _eventDao.upsertDryoff(
      _toDryoffCompanion(localModel),
    );
    return _mapDryoffEntity(updated);
  }

  @override
  Future<InseminationModel> createInsemination(InseminationModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating insemination log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertInsemination(
      _toInseminationCompanion(localModel),
    );
    return _mapInseminationEntity(inserted);
  }

  @override
  Future<InseminationModel> updateInseminationLocally(
    InseminationModel model,
  ) async {
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

    final updated = await _eventDao.upsertInsemination(
      _toInseminationCompanion(localModel),
    );
    return _mapInseminationEntity(updated);
  }

  @override
  Future<TransferModel> createTransfer(TransferModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating transfer log locally: ${model.uuid}');

    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    log('📝 transfer log: ${localModel.toJson()}');

    final inserted =
        await _eventDao.upsertTransfer(_toTransferCompanion(localModel));
    final mapped = _mapTransferEntity(inserted);

    if ((mapped.toFarmUuid ?? '').isNotEmpty) {
      try {
        await _reassignLivestockAndLogs(
          livestockUuid: mapped.livestockUuid,
          newFarmUuid: mapped.toFarmUuid!,
          updatedAt: mapped.updatedAt,
        );
      } catch (e, stackTrace) {
        log(
          '❌ Failed to reassign livestock/logs for transfer ${mapped.uuid}: $e',
          stackTrace: stackTrace,
        );
      }
    }

    return mapped;
  }
  
  Future<void> _reassignLivestockAndLogs({
    required String livestockUuid,
    required String newFarmUuid,
    required String updatedAt,
  }) async {
    await _database.transaction(() async {
      await _database.livestockDao.moveLivestockToFarm(
        livestockUuid: livestockUuid,
        newFarmUuid: newFarmUuid,
        updatedAt: updatedAt,
      );

      await _eventDao.moveLogsToFarm(
        livestockUuid: livestockUuid,
        newFarmUuid: newFarmUuid,
        updatedAt: updatedAt,
      );
    });
  }


  @override
  Future<TransferModel> updateTransferLocally(TransferModel model) async {
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

    final updated =
        await _eventDao.upsertTransfer(_toTransferCompanion(localModel));
    return _mapTransferEntity(updated);
  }

  // ===========================================================================
  // Queries
  // ===========================================================================

  @override
  Future<List<FeedingModel>> getFeedings({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getFeedings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapFeedingEntity).toList();
  }

  @override
  Future<List<WeightChangeModel>> getWeightChanges({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getWeightChanges(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapWeightChangeEntity).toList();
  }

  @override
  Future<List<DewormingModel>> getDewormings({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getDewormings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapDewormingEntity).toList();
  }

  @override
  Future<List<MedicationModel>> getMedications({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getMedications(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapMedicationEntity).toList();
  }

  @override
  Future<List<VaccinationModel>> getVaccinations({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getVaccinations(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapVaccinationEntity).toList();
  }

  @override
  Future<List<DisposalModel>> getDisposals({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getDisposals(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapDisposalEntity).toList();
  }

  @override
  Future<List<MilkingModel>> getMilkings({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getMilkings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapMilkingEntity).toList();
  }

  @override
  Future<List<PregnancyModel>> getPregnancies({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getPregnancies(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapPregnancyEntity).toList();
  }

  @override
  Future<List<CalvingModel>> getCalvings({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getCalvings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapCalvingEntity).toList();
  }

  @override
  Future<List<DryoffModel>> getDryoffs({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getDryoffs(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapDryoffEntity).toList();
  }

  @override
  Future<List<InseminationModel>> getInseminations({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getInseminations(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapInseminationEntity).toList();
  }

  @override
  Future<List<TransferModel>> getTransfers({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getTransfers(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final models = rows.map(_mapTransferEntity).toList();
    return _hydrateTransferNames(models);
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
  Future<List<MilkingModel>> getAllMilkings() => getMilkings();
  @override
  Future<List<PregnancyModel>> getAllPregnancies() => getPregnancies();
  @override
  Future<List<CalvingModel>> getAllCalvings() => getCalvings();
  @override
  Future<List<DryoffModel>> getAllDryoffs() => getDryoffs();
  @override
  Future<List<InseminationModel>> getAllInseminations() => getInseminations();
  @override
  Future<List<TransferModel>> getAllTransfers() => getTransfers();

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
    final milkings = await getMilkings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final pregnancies = await getPregnancies(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final calvings = await getCalvings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final dryoffs = await getDryoffs(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final inseminations = await getInseminations(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final transfers = await getTransfers(
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
      EventLogTypes.milking: milkings.length,
      EventLogTypes.pregnancy: pregnancies.length,
      EventLogTypes.calving: calvings.length,
      EventLogTypes.dryoff: dryoffs.length,
      EventLogTypes.insemination: inseminations.length,
      EventLogTypes.transfer: transfers.length,
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
    final milkingsCount = (await getMilkings()).length;
    final pregnanciesCount = (await getPregnancies()).length;
    final calvingsCount = (await getCalvings()).length;
    final dryoffsCount = (await getDryoffs()).length;
    final inseminationsCount = (await getInseminations()).length;
    final transfersCount = (await getTransfers()).length;
    return EventSummary(
      byType: {
        EventLogTypes.feeding: feedingsCount,
        EventLogTypes.weightChange: weightChangesCount,
        EventLogTypes.deworming: dewormingsCount,
        EventLogTypes.medication: medicationsCount,
        EventLogTypes.vaccination: vaccinationsCount,
        EventLogTypes.disposal: disposalsCount,
        EventLogTypes.milking: milkingsCount,
        EventLogTypes.pregnancy: pregnanciesCount,
        EventLogTypes.calving: calvingsCount,
        EventLogTypes.dryoff: dryoffsCount,
        EventLogTypes.insemination: inseminationsCount,
        EventLogTypes.transfer: transfersCount,
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
  Future<List<Map<String, dynamic>>> getUnsyncedMilkingsForApi() async {
    final rows = await _eventDao.getUnsyncedMilkings();
    if (rows.isEmpty) {
      log('✅ No unsynced milking logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} milking logs for sync');
    return rows.map((row) => _mapMilkingEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedPregnanciesForApi() async {
    final rows = await _eventDao.getUnsyncedPregnancies();
    if (rows.isEmpty) {
      log('✅ No unsynced pregnancy logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} pregnancy logs for sync');
    return rows.map((row) => _mapPregnancyEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedCalvingsForApi() async {
    final rows = await _eventDao.getUnsyncedCalvings();
    if (rows.isEmpty) {
      log('✅ No unsynced calving logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} calving logs for sync');
    return rows.map((row) => _mapCalvingEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedDryoffsForApi() async {
    final rows = await _eventDao.getUnsyncedDryoffs();
    if (rows.isEmpty) {
      log('✅ No unsynced dryoff logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} dryoff logs for sync');
    return rows.map((row) => _mapDryoffEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedInseminationsForApi() async {
    final rows = await _eventDao.getUnsyncedInseminations();
    if (rows.isEmpty) {
      log('✅ No unsynced insemination logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} insemination logs for sync');
    return rows.map((row) => _mapInseminationEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedTransfersForApi() async {
    final rows = await _eventDao.getUnsyncedTransfers();
    if (rows.isEmpty) {
      log('✅ No unsynced transfer logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} transfer logs for sync');
    return rows.map((row) => _mapTransferEntity(row).toApiJson()).toList();
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
        final model = _mapFeedingEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
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
        final model = _mapWeightChangeEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
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
        final model = _mapDewormingEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
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
        final model = _mapMedicationEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
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
        final model = _mapVaccinationEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
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
        final model = _mapDisposalEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertDisposal(_toDisposalCompanion(model));
        log('✅ Marked disposal log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markMilkingsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getMilkingByUuid(uuid);
      if (existing == null) {
        log('⚠️ Milking log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteMilkingByUuid(uuid);
        log('🗑️ Removed milking log after synced delete: $uuid');
      } else {
        final model = _mapMilkingEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertMilking(_toMilkingCompanion(model));
        log('✅ Marked milking log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markPregnanciesAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getPregnancyByUuid(uuid);
      if (existing == null) {
        log('⚠️ Pregnancy log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deletePregnancyByUuid(uuid);
        log('🗑️ Removed pregnancy log after synced delete: $uuid');
      } else {
        final model = _mapPregnancyEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertPregnancy(_toPregnancyCompanion(model));
        log('✅ Marked pregnancy log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markCalvingsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getCalvingByUuid(uuid);
      if (existing == null) {
        log('⚠️ Calving log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteCalvingByUuid(uuid);
        log('🗑️ Removed calving log after synced delete: $uuid');
      } else {
        final model = _mapCalvingEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertCalving(_toCalvingCompanion(model));
        log('✅ Marked calving log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markDryoffsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getDryoffByUuid(uuid);
      if (existing == null) {
        log('⚠️ Dryoff log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteDryoffByUuid(uuid);
        log('🗑️ Removed dryoff log after synced delete: $uuid');
      } else {
        final model = _mapDryoffEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertDryoff(_toDryoffCompanion(model));
        log('✅ Marked dryoff log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markInseminationsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getInseminationByUuid(uuid);
      if (existing == null) {
        log('⚠️ Insemination log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteInseminationByUuid(uuid);
        log('🗑️ Removed insemination log after synced delete: $uuid');
      } else {
        final model = _mapInseminationEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertInsemination(_toInseminationCompanion(model));
        log('✅ Marked insemination log as synced: $uuid');
      }
    }
  }

  @override
  Future<void> markTransfersAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getTransferByUuid(uuid);
      if (existing == null) {
        log('⚠️ Transfer log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteTransferByUuid(uuid);
        log('🗑️ Removed transfer log after synced delete: $uuid');
      } else {
        final model = _mapTransferEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertTransfer(_toTransferCompanion(model));
        log('✅ Marked transfer log as synced: $uuid');
      }
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
    final model = _mapFeedingEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
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
    final model = _mapWeightChangeEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
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
    final model = _mapDewormingEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
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
    final model = _mapMedicationEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
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
    final model = _mapVaccinationEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
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
    final model = _mapDisposalEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertDisposal(_toDisposalCompanion(model));
    log('🗑️ Marked disposal log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markMilkingAsDeleted(String uuid) async {
    final existing = await _eventDao.getMilkingByUuid(uuid);
    if (existing == null) {
      log('⚠️ Milking log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapMilkingEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertMilking(_toMilkingCompanion(model));
    log('🗑️ Marked milking log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markPregnancyAsDeleted(String uuid) async {
    final existing = await _eventDao.getPregnancyByUuid(uuid);
    if (existing == null) {
      log('⚠️ Pregnancy log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapPregnancyEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertPregnancy(_toPregnancyCompanion(model));
    log('🗑️ Marked pregnancy log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markCalvingAsDeleted(String uuid) async {
    final existing = await _eventDao.getCalvingByUuid(uuid);
    if (existing == null) {
      log('⚠️ Calving log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapCalvingEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertCalving(_toCalvingCompanion(model));
    log('🗑️ Marked calving log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markDryoffAsDeleted(String uuid) async {
    final existing = await _eventDao.getDryoffByUuid(uuid);
    if (existing == null) {
      log('⚠️ Dryoff log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapDryoffEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertDryoff(_toDryoffCompanion(model));
    log('🗑️ Marked dryoff log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markInseminationAsDeleted(String uuid) async {
    final existing = await _eventDao.getInseminationByUuid(uuid);
    if (existing == null) {
      log('⚠️ Insemination log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapInseminationEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertInsemination(_toInseminationCompanion(model));
    log('🗑️ Marked insemination log as deleted (pending sync): $uuid');
    return true;
  }

  @override
  Future<bool> markTransferAsDeleted(String uuid) async {
    final existing = await _eventDao.getTransferByUuid(uuid);
    if (existing == null) {
      log('⚠️ Transfer log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapTransferEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertTransfer(_toTransferCompanion(model));
    log('🗑️ Marked transfer log as deleted (pending sync): $uuid');
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
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
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
      oldWeight: model.oldWeight != null
          ? Value(model.oldWeight!)
          : const Value.absent(),
      newWeight: Value(model.newWeight),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
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
      medicineId: model.medicineId != null
          ? Value(model.medicineId!)
          : const Value.absent(),
      vetId: model.vetId != null ? Value(model.vetId!) : const Value.absent(),
      extensionOfficerId: model.extensionOfficerId != null
          ? Value(model.extensionOfficerId!)
          : const Value.absent(),
      quantity: model.quantity != null
          ? Value(model.quantity!)
          : const Value.absent(),
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
      diseaseId: model.diseaseId != null
          ? Value(model.diseaseId!)
          : const Value.absent(),
      medicineId: model.medicineId != null
          ? Value(model.medicineId!)
          : const Value.absent(),
      quantity: model.quantity != null
          ? Value(model.quantity!)
          : const Value.absent(),
      withdrawalPeriod: model.withdrawalPeriod != null
          ? Value(model.withdrawalPeriod!)
          : const Value.absent(),
      medicationDate: model.medicationDate != null
          ? Value(model.medicationDate!)
          : const Value.absent(),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
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
      vaccinationNo: model.vaccinationNo != null
          ? Value(model.vaccinationNo!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      vaccineId: model.vaccineId != null
          ? Value(model.vaccineId!)
          : const Value.absent(),
      diseaseId: model.diseaseId != null
          ? Value(model.diseaseId!)
          : const Value.absent(),
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
      disposalTypeId: model.disposalTypeId != null
          ? Value(model.disposalTypeId!)
          : const Value.absent(),
      reasons: Value(model.reasons),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
      status: Value(model.status),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  MilkingsCompanion _toMilkingCompanion(MilkingModel model) {
    return MilkingsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: model.farmUuid != null
          ? Value(model.farmUuid!)
          : const Value.absent(),
      livestockUuid: Value(model.livestockUuid),
      milkingMethodId: model.milkingMethodId != null
          ? Value(model.milkingMethodId!)
          : const Value.absent(),
      amount: Value(model.amount),
      lactometerReading: Value(model.lactometerReading),
      solid: Value(model.solid),
      solidNonFat: Value(model.solidNonFat),
      protein: Value(model.protein),
      correctedLactometerReading: Value(model.correctedLactometerReading),
      totalSolids: Value(model.totalSolids),
      colonyFormingUnits: Value(model.colonyFormingUnits),
      acidity: model.acidity != null
          ? Value(model.acidity!)
          : const Value.absent(),
      session: Value(model.session),
      status: Value(model.status),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  PregnanciesCompanion _toPregnancyCompanion(PregnancyModel model) {
    return PregnanciesCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      testResultId: Value(model.testResultId),
      noOfMonths: model.noOfMonths != null
          ? Value(model.noOfMonths!)
          : const Value.absent(),
      testDate: model.testDate != null
          ? Value(model.testDate!)
          : const Value.absent(),
      status: Value(model.status),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  CalvingsCompanion _toCalvingCompanion(CalvingModel model) {
    return CalvingsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      startDate: Value(model.startDate),
      endDate: model.endDate != null
          ? Value(model.endDate!)
          : const Value.absent(),
      calvingTypeId: Value(model.calvingTypeId),
      calvingProblemsId: model.calvingProblemsId != null
          ? Value(model.calvingProblemsId!)
          : const Value.absent(),
      reproductiveProblemId: model.reproductiveProblemId != null
          ? Value(model.reproductiveProblemId!)
          : const Value.absent(),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
      status: Value(model.status),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  DryoffsCompanion _toDryoffCompanion(DryoffModel model) {
    return DryoffsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      startDate: Value(model.startDate),
      endDate: model.endDate != null
          ? Value(model.endDate!)
          : const Value.absent(),
      reason: model.reason != null
          ? Value(model.reason!)
          : const Value.absent(),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  InseminationsCompanion _toInseminationCompanion(InseminationModel model) {
    return InseminationsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: model.farmUuid != null
          ? Value(model.farmUuid!)
          : const Value.absent(),
      livestockUuid: Value(model.livestockUuid),
      lastHeatDate: model.lastHeatDate != null
          ? Value(model.lastHeatDate!)
          : const Value.absent(),
      currentHeatTypeId: Value(model.currentHeatTypeId),
      inseminationServiceId: Value(model.inseminationServiceId),
      semenStrawTypeId: Value(model.semenStrawTypeId),
      inseminationDate: model.inseminationDate != null
          ? Value(model.inseminationDate!)
          : const Value.absent(),
      bullCode: model.bullCode != null
          ? Value(model.bullCode!)
          : const Value.absent(),
      bullBreed: model.bullBreed != null
          ? Value(model.bullBreed!)
          : const Value.absent(),
      semenProductionDate: model.semenProductionDate != null
          ? Value(model.semenProductionDate!)
          : const Value.absent(),
      productionCountry: model.productionCountry != null
          ? Value(model.productionCountry!)
          : const Value.absent(),
      semenBatchNumber: model.semenBatchNumber != null
          ? Value(model.semenBatchNumber!)
          : const Value.absent(),
      internationalId: model.internationalId != null
          ? Value(model.internationalId!)
          : const Value.absent(),
      aiCode: model.aiCode != null
          ? Value(model.aiCode!)
          : const Value.absent(),
      manufacturerName: model.manufacturerName != null
          ? Value(model.manufacturerName!)
          : const Value.absent(),
      semenSupplier: model.semenSupplier != null
          ? Value(model.semenSupplier!)
          : const Value.absent(),
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

  Future<List<TransferModel>> _hydrateTransferNames(
    List<TransferModel> transfers,
  ) async {
    if (transfers.isEmpty) return const [];

    final farmIds = <String>{
      for (final transfer in transfers) transfer.farmUuid,
      for (final transfer in transfers)
        if (transfer.toFarmUuid != null && transfer.toFarmUuid!.isNotEmpty)
          transfer.toFarmUuid!,
    };

    final livestockIds = <String>{
      for (final transfer in transfers) transfer.livestockUuid,
    };

    final farmNames = await getFarmNamesByUuid(farmIds);
    final livestockNames = await getLivestockNamesByUuid(livestockIds);

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

  MilkingModel _mapMilkingEntity(Milking entity) {
    return MilkingModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      milkingMethodId: entity.milkingMethodId,
      amount: entity.amount,
      lactometerReading: entity.lactometerReading,
      solid: entity.solid,
      solidNonFat: entity.solidNonFat,
      protein: entity.protein,
      correctedLactometerReading: entity.correctedLactometerReading,
      totalSolids: entity.totalSolids,
      colonyFormingUnits: entity.colonyFormingUnits,
      acidity: entity.acidity,
      session: entity.session,
      status: entity.status,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  PregnancyModel _mapPregnancyEntity(Pregnancy entity) {
    return PregnancyModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      testResultId: entity.testResultId,
      noOfMonths: entity.noOfMonths,
      testDate: entity.testDate,
      status: entity.status,
      remarks: entity.remarks,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  CalvingModel _mapCalvingEntity(Calving entity) {
    return CalvingModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      startDate: entity.startDate,
      endDate: entity.endDate,
      calvingTypeId: entity.calvingTypeId,
      calvingProblemsId: entity.calvingProblemsId,
      reproductiveProblemId: entity.reproductiveProblemId,
      remarks: entity.remarks,
      status: entity.status,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  DryoffModel _mapDryoffEntity(Dryoff entity) {
    return DryoffModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      startDate: entity.startDate,
      endDate: entity.endDate,
      reason: entity.reason,
      remarks: entity.remarks,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  InseminationModel _mapInseminationEntity(Insemination entity) {
    return InseminationModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      lastHeatDate: entity.lastHeatDate,
      currentHeatTypeId: entity.currentHeatTypeId,
      inseminationServiceId: entity.inseminationServiceId,
      semenStrawTypeId: entity.semenStrawTypeId,
      inseminationDate: entity.inseminationDate,
      bullCode: entity.bullCode,
      bullBreed: entity.bullBreed,
      semenProductionDate: entity.semenProductionDate,
      productionCountry: entity.productionCountry,
      semenBatchNumber: entity.semenBatchNumber,
      internationalId: entity.internationalId,
      aiCode: entity.aiCode,
      manufacturerName: entity.manufacturerName,
      semenSupplier: entity.semenSupplier,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TransfersCompanion _toTransferCompanion(TransferModel model) {
    return TransfersCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      toFarmUuid: model.toFarmUuid != null
          ? Value(model.toFarmUuid!)
          : const Value.absent(),
      transporterId: model.transporterId != null
          ? Value(model.transporterId!)
          : const Value.absent(),
      reason: model.reason != null
          ? Value(model.reason!)
          : const Value.absent(),
      price:
          model.price != null ? Value(model.price!) : const Value.absent(),
      transferDate: Value(model.transferDate),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
      status:
          model.status != null ? Value(model.status!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  TransferModel _mapTransferEntity(Transfer entity) {
    return TransferModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      toFarmUuid: entity.toFarmUuid,
      transporterId: entity.transporterId,
      reason: entity.reason,
      price: entity.price,
      transferDate: entity.transferDate,
      remarks: entity.remarks,
      status: entity.status,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  Future<Map<String, String>> getFarmNamesByUuid(
    Iterable<String> farmUuids,
  ) async {
    final ids = farmUuids
        .map((uuid) => uuid.trim())
        .where((uuid) => uuid.isNotEmpty)
        .toSet();

    if (ids.isEmpty) return const {};

    final rows = await (_database.select(_database.farms)
          ..where((tbl) => tbl.uuid.isIn(ids.toList())))
        .get();

    return {
      for (final row in rows)
        row.uuid: row.name,
    };
  }

  @override
  Future<Map<String, String>> getLivestockNamesByUuid(
    Iterable<String> livestockUuids,
  ) async {
    final ids = livestockUuids
        .map((uuid) => uuid.trim())
        .where((uuid) => uuid.isNotEmpty)
        .toSet();

    if (ids.isEmpty) return const {};

    final rows = await (_database.select(_database.livestocks)
          ..where((tbl) => tbl.uuid.isIn(ids.toList())))
        .get();

    return {
      for (final row in rows)
        row.uuid: row.name,
    };
  }
}
