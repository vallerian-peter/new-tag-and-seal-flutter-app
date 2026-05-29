import 'dart:convert';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/database/daos/event_dao.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';
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
import 'package:new_tag_and_seal_flutter_app/features/events/domain/repo/events_repo.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/summary/event_summary.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/presentation/provider/notification_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/domain/model/notification_model.dart';

class EventsRepository implements EventsRepositoryInterface {
  final AppDatabase _database;
  late final EventDao _eventDao;
  final NotificationProvider? _notificationProvider;
  static const Set<String> _earlyStageNames = {
    'piglet',
    'calf',
    'kid',
    'lamb',
    'chick',
    'newborn',
    'neonate',
  };

  EventsRepository(this._database, {NotificationProvider? notificationProvider})
    : _notificationProvider = notificationProvider {
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
    final treatmentsCount = (logs['treatments'] as List?)?.length ?? 0;
    final vaccinationsCount = (logs['vaccinations'] as List?)?.length ?? 0;
    final disposalsCount = (logs['disposals'] as List?)?.length ?? 0;
    final birthEventsCount = (logs['birthEvents'] as List?)?.length ?? 0;
    final abortedPregnanciesCount =
        (logs['abortedPregnancies'] as List?)?.length ?? 0;
    final milkingsCount = (logs['milkings'] as List?)?.length ?? 0;
    final pregnanciesCount = (logs['pregnancies'] as List?)?.length ?? 0;
    final inseminationsCount = (logs['inseminations'] as List?)?.length ?? 0;
    final dryoffsCount = (logs['dryoffs'] as List?)?.length ?? 0;
    final transfersCount = (logs['transfers'] as List?)?.length ?? 0;

    log(
      '🔄 Syncing event logs (feedings: $feedingsCount, weightChanges: $weightChangesCount, '
      'dewormings: $dewormingsCount, treatments: $treatmentsCount, '
      'vaccinations: $vaccinationsCount, disposals: $disposalsCount, '
      'birthEvents: $birthEventsCount, abortedPregnancies: $abortedPregnanciesCount, '
      'milkings: $milkingsCount, pregnancies: $pregnanciesCount, '
      'inseminations: $inseminationsCount, dryoffs: $dryoffsCount, transfers: $transfersCount)...',
    );

    await _syncFeedings(logs['feedings']);
    await _syncWeightChanges(logs['weightChanges']);
    await _syncDewormings(logs['dewormings']);
    await _syncTreatments(logs['treatments']);
    await _syncVaccinations(logs['vaccinations']);
    await _syncDisposals(logs['disposals']);
    await _syncBirthEvents(logs['birthEvents']);
    await _syncAbortedPregnancies(logs['abortedPregnancies']);
    await _syncMilkings(logs['milkings']);
    await _syncPregnancies(logs['pregnancies']);
    await _syncInseminations(logs['inseminations']);
    await _syncDryoffs(logs['dryoffs']);
    await _syncTransfers(logs['transfers']);
    await _syncTeethClippings(logs['teethClippings']);
    await _syncTailDockings(logs['tailDockings']);
    await _syncIronInjections(logs['ironInjections']);
    await _syncLivestockMarkings(logs['livestockMarkings']);
    await _syncStageChanges(logs['stageChanges']);
    await _syncPrepuceConditions(logs['prepuceConditions']);
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
        bool wasInsertedOrUpdated = false;
        if (existing == null) {
          await _eventDao.upsertFeeding(_toFeedingCompanion(remote));
          wasInsertedOrUpdated = true;
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertFeeding(_toFeedingCompanion(updated));
            wasInsertedOrUpdated = true;
          }
        }

        // Create/update notification for next feeding time if present and was inserted/updated
        if (wasInsertedOrUpdated) {
          await _createFeedingNotificationFromSync(remote);
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
        bool wasInsertedOrUpdated = false;
        if (existing == null) {
          await _eventDao.upsertDeworming(_toDewormingCompanion(remote));
          wasInsertedOrUpdated = true;
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertDeworming(_toDewormingCompanion(updated));
            wasInsertedOrUpdated = true;
          }
        }

        // Create/update notification for next administration date if present and was inserted/updated
        if (wasInsertedOrUpdated) {
          await _createDewormingNotificationFromSync(remote);
        }
      } catch (e) {
        log('❌ Error syncing deworming log: $e');
      }
    }

    await _eventDao.deleteServerDewormingsNotIn(remoteUuids);
  }

  Future<void> _syncTreatments(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = TreatmentModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getTreatmentByUuid(remote.uuid);
        bool wasInsertedOrUpdated = false;
        if (existing == null) {
          await _eventDao.upsertTreatment(_toTreatmentCompanion(remote));
          wasInsertedOrUpdated = true;
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertTreatment(_toTreatmentCompanion(updated));
            wasInsertedOrUpdated = true;
          }
        }

        // Create/update notification for next medication date if present and was inserted/updated
        if (wasInsertedOrUpdated) {
          await _createTreatmentNotificationFromSync(remote);
        }
      } catch (e) {
        log('❌ Error syncing treatment log: $e');
      }
    }

    await _eventDao.deleteServerTreatmentsNotIn(remoteUuids);
  }

  Future<void> _syncVaccinations(dynamic payload) async {
    if (payload is! List) {
      log('⚠️ Vaccinations payload is not a List: ${payload.runtimeType}');
      return;
    }

    final vaccinations = payload.cast<Map<String, dynamic>>();
    log('💉 Syncing ${vaccinations.length} vaccination logs from server...');

    final remoteUuids = <String>{};

    for (final raw in vaccinations) {
      try {
        log(
          '💉 Processing vaccination from server: ${raw['uuid']}, vaccineUuid: ${raw['vaccineUuid']}',
        );
        final remote = VaccinationModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        log(
          '💉 Parsed vaccination model: uuid=${remote.uuid}, vaccineUuid=${remote.vaccineUuid}',
        );
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getVaccinationByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertVaccination(_toVaccinationCompanion(remote));
          log('  ✅ Inserted vaccination: ${remote.uuid}');
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertVaccination(_toVaccinationCompanion(updated));
            log('  ✅ Updated vaccination: ${remote.uuid}');
          } else {
            log('  ⏭️ Skipped vaccination (local is newer): ${remote.uuid}');
          }
        }
      } catch (e, stackTrace) {
        log('❌ Error syncing vaccination log: $e', stackTrace: stackTrace);
      }
    }

    await _eventDao.deleteServerVaccinationsNotIn(remoteUuids);
    log(
      '✅ Vaccination sync complete - Processed ${remoteUuids.length} vaccination(s)',
    );
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

  Future<void> _syncBirthEvents(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = BirthEventModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getBirthEventByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertBirthEvent(_toBirthEventCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertBirthEvent(_toBirthEventCompanion(updated));
          }
        }
      } catch (e) {
        log('❌ Error syncing birth event: $e');
      }
    }

    // Note: We don't delete server birth events not in remoteUuids to avoid data loss
    // The backend handles this through proper sync mechanisms
  }

  Future<void> _syncAbortedPregnancies(dynamic payload) async {
    if (payload is! List) return;

    final remoteUuids = <String>{};

    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = AbortedPregnancyModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);

        final existing = await _eventDao.getAbortedPregnancyByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertAbortedPregnancy(
            _toAbortedPregnancyCompanion(remote),
          );
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertAbortedPregnancy(
              _toAbortedPregnancyCompanion(updated),
            );
          }
        }
      } catch (e) {
        log('❌ Error syncing aborted pregnancy: $e');
      }
    }

    // Note: We don't delete server aborted pregnancies not in remoteUuids to avoid data loss
    // The backend handles this through proper sync mechanisms
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

  Future<void> _syncTeethClippings(dynamic payload) async {
    if (payload is! List) return;
    final remoteUuids = <String>{};
    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = TeethClippingModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);
        final existing = await _eventDao.getTeethClippingByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertTeethClipping(
            _toTeethClippingCompanion(remote),
          );
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            await _eventDao.upsertTeethClipping(
              _toTeethClippingCompanion(
                remote.copyWith(id: existing.id, syncAction: 'server-update'),
              ),
            );
          }
        }
      } catch (e) {
        log('❌ Error syncing teeth clipping log: $e');
      }
    }
    await _eventDao.deleteServerTeethClippingsNotIn(remoteUuids);
  }

  Future<void> _syncTailDockings(dynamic payload) async {
    if (payload is! List) return;
    final remoteUuids = <String>{};
    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = TailDockingModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);
        final existing = await _eventDao.getTailDockingByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertTailDocking(_toTailDockingCompanion(remote));
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            await _eventDao.upsertTailDocking(
              _toTailDockingCompanion(
                remote.copyWith(id: existing.id, syncAction: 'server-update'),
              ),
            );
          }
        }
      } catch (e) {
        log('❌ Error syncing tail docking log: $e');
      }
    }
    await _eventDao.deleteServerTailDockingsNotIn(remoteUuids);
  }

  Future<void> _syncIronInjections(dynamic payload) async {
    if (payload is! List) return;
    final remoteUuids = <String>{};
    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = IronInjectionModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);
        final existing = await _eventDao.getIronInjectionByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertIronInjection(
            _toIronInjectionCompanion(remote),
          );
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            await _eventDao.upsertIronInjection(
              _toIronInjectionCompanion(
                remote.copyWith(id: existing.id, syncAction: 'server-update'),
              ),
            );
          }
        }
      } catch (e) {
        log('❌ Error syncing iron injection log: $e');
      }
    }
    await _eventDao.deleteServerIronInjectionsNotIn(remoteUuids);
  }

  Future<void> _syncLivestockMarkings(dynamic payload) async {
    if (payload is! List) return;
    final remoteUuids = <String>{};
    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = LivestockMarkingModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);
        final existing = await _eventDao.getLivestockMarkingByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertLivestockMarking(
            _toLivestockMarkingCompanion(remote),
          );
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            await _eventDao.upsertLivestockMarking(
              _toLivestockMarkingCompanion(
                remote.copyWith(id: existing.id, syncAction: 'server-update'),
              ),
            );
          }
        }
      } catch (e) {
        log('❌ Error syncing livestock marking log: $e');
      }
    }
    await _eventDao.deleteServerLivestockMarkingsNotIn(remoteUuids);
  }

  Future<void> _syncStageChanges(dynamic payload) async {
    if (payload is! List) return;
    final remoteUuids = <String>{};
    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = StageChangeModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);
        final existing = await _eventDao.getStageChangeByUuid(remote.uuid);
        if (existing == null) {
          await _eventDao.upsertStageChange(_toStageChangeCompanion(remote));
          await _applyServerStageChangeToLivestock(remote);
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            final updated = remote.copyWith(
              id: existing.id,
              syncAction: 'server-update',
            );
            await _eventDao.upsertStageChange(_toStageChangeCompanion(updated));
            await _applyServerStageChangeToLivestock(updated);
          }
        }
      } catch (e) {
        log('❌ Error syncing stage change log: $e');
      }
    }
    await _eventDao.deleteServerStageChangesNotIn(remoteUuids);
  }

  Future<void> _syncPrepuceConditions(dynamic payload) async {
    if (payload is! List) return;
    final remoteUuids = <String>{};
    for (final raw in payload.cast<Map<String, dynamic>>()) {
      try {
        final remote = PrepuceConditionModel.fromJson(
          raw,
        ).copyWith(synced: true, syncAction: 'server-create');
        remoteUuids.add(remote.uuid);
        final existing = await _eventDao.getPrepuceConditionByUuid(remote.uuid);
        var wasInsertedOrUpdated = false;
        if (existing == null) {
          await _eventDao.upsertPrepuceCondition(
            _toPrepuceConditionCompanion(remote),
          );
          wasInsertedOrUpdated = true;
        } else {
          final serverUpdated = DateTime.parse(remote.updatedAt);
          final localUpdated = DateTime.parse(existing.updatedAt);
          if (serverUpdated.isAfter(localUpdated)) {
            await _eventDao.upsertPrepuceCondition(
              _toPrepuceConditionCompanion(
                remote.copyWith(id: existing.id, syncAction: 'server-update'),
              ),
            );
            wasInsertedOrUpdated = true;
          }
        }
        if (wasInsertedOrUpdated) {
          await _applyPrepuceFollowUpNotification(remote);
        }
      } catch (e) {
        log('❌ Error syncing prepuce condition log: $e');
      }
    }
    await _eventDao.deleteServerPrepuceConditionsNotIn(remoteUuids);
  }

  Future<void> _applyServerStageChangeToLivestock(
    StageChangeModel model,
  ) async {
    final to = model.toStageId;
    if (to == null) return;
    await _database.livestockDao.updateLivestockStageId(
      model.livestockUuid,
      to,
    );

    final stage = await _database.stageDao.getStageById(to);
    if (stage == null) return;

    final normalized = stage.name.trim().toLowerCase();
    if (_earlyStageNames.contains(normalized)) {
      await _database.livestockDao.updateLivestockIdentificationByUuid(
        model.livestockUuid,
        isIdentified: false,
        dummyTagId: null,
        barcodeTagId: null,
        rfidTagId: null,
      );
    }
  }

  // ===========================================================================
  // Notification creation helpers for sync
  // ===========================================================================

  Future<void> _reloadNotificationCacheSafely() async {
    final provider = _notificationProvider;
    if (provider == null) return;
    try {
      await provider.loadNotifications();
    } catch (_) {}
  }

  Future<bool> _existsInNotificationTable({
    required String title,
    required String scheduledAt,
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final existing = await _database.notificationDao.findByAttributes(
      title: title,
      scheduledAt: scheduledAt,
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return existing != null;
  }

  /// One local notification per prepuce log [uuid], keyed by [NotificationModel.prepuceFollowUpTitleForLog].
  Future<void> _applyPrepuceFollowUpNotification(
    PrepuceConditionModel model,
  ) async {
    final provider = _notificationProvider;
    if (provider == null) return;

    await _reloadNotificationCacheSafely();

    final title = NotificationModel.prepuceFollowUpTitleForLog(model.uuid);
    final trimmed = model.followUpDate?.trim();
    final nextDate = trimmed != null && trimmed.isNotEmpty
        ? DateTime.tryParse(trimmed)
        : null;
    final now = DateTime.now();

    Future<void> removeIncompleteWithTitle() async {
      final ids = provider.notifications
          .where((n) => n.title == title && !n.isCompleted && n.id != null)
          .map((n) => n.id!)
          .toList();
      for (final id in ids) {
        await provider.deleteNotification(id);
      }
    }

    try {
      if (nextDate == null || !nextDate.isAfter(now)) {
        await removeIncompleteWithTitle();
        return;
      }

      var incomplete = provider.notifications
          .where((n) => n.title == title && !n.isCompleted)
          .toList();

      while (incomplete.length > 1) {
        final id = incomplete.last.id;
        if (id != null) await provider.deleteNotification(id);
        await provider.loadNotifications();
        incomplete = provider.notifications
            .where((n) => n.title == title && !n.isCompleted)
            .toList();
      }

      final scheduledIso = nextDate.toIso8601String();
      final nowIso = DateTime.now().toIso8601String();

      // Skip creating duplicates from repeated sync payloads.
      if (incomplete.isEmpty &&
          await _existsInNotificationTable(
            title: title,
            scheduledAt: scheduledIso,
            farmUuid: model.farmUuid,
            livestockUuid: model.livestockUuid,
          )) {
        return;
      }

      if (incomplete.isNotEmpty) {
        final existing = incomplete.first;
        await provider.saveNotification(
          existing.copyWith(
            scheduledAt: scheduledIso,
            farmUuid: model.farmUuid,
            livestockUuid: model.livestockUuid,
            updatedAt: nowIso,
            synced: false,
            syncAction: existing.id != null ? 'update' : 'create',
          ),
        );
        log(
          '✅ Prepuce follow-up notification updated for ${model.uuid} at ${nextDate.toLocal()}',
        );
        return;
      }

      await provider.saveNotification(
        NotificationModel(
          farmUuid: model.farmUuid,
          farmName: null,
          livestockUuid: model.livestockUuid,
          livestockName: null,
          title: title,
          description: NotificationModel.prepuceFollowUpDescriptionKey,
          scheduledAt: scheduledIso,
          isCompleted: false,
          synced: false,
          syncAction: 'create',
          createdAt: nowIso,
          updatedAt: nowIso,
          repeatDaily: false,
        ),
      );
      log(
        '✅ Prepuce follow-up notification created for ${model.uuid} at ${nextDate.toLocal()}',
      );
    } catch (e) {
      log('⚠️ Prepuce follow-up notification failed: $e');
    }
  }

  /// Create or update notification for feeding events during sync
  Future<void> _createFeedingNotificationFromSync(FeedingModel feeding) async {
    if (_notificationProvider == null) return;

    try {
      final nextFeedingTime = DateTime.tryParse(feeding.nextFeedingTime);
      if (nextFeedingTime == null) return;

      final now = DateTime.now();
      if (!nextFeedingTime.isAfter(now)) return;

      await _reloadNotificationCacheSafely();
      final scheduledIso = nextFeedingTime.toIso8601String();

      // Skip duplicate notification that already exists in local NotificationTable.
      if (await _existsInNotificationTable(
        title: 'feeding_reminder',
        scheduledAt: scheduledIso,
        farmUuid: feeding.farmUuid,
        livestockUuid: feeding.livestockUuid,
      )) {
        return;
      }

      // Check if notification already exists
      final existingNotifications = _notificationProvider.notifications
          .where(
            (n) =>
                n.title == 'feeding_reminder' &&
                n.farmUuid == feeding.farmUuid &&
                n.livestockUuid == feeding.livestockUuid &&
                !n.isCompleted,
          )
          .toList();

      NotificationModel notification;
      if (existingNotifications.isNotEmpty) {
        final existing = existingNotifications.first;
        notification = existing.copyWith(
          scheduledAt: scheduledIso,
          updatedAt: DateTime.now().toIso8601String(),
          synced: false,
          syncAction: 'update',
        );
      } else {
        notification = NotificationModel(
          farmUuid: feeding.farmUuid,
          farmName: null,
          livestockUuid: feeding.livestockUuid,
          livestockName: null,
          title: 'feeding_reminder',
          description: 'time_to_feed_livestock',
          scheduledAt: scheduledIso,
          isCompleted: false,
          synced: false,
          syncAction: 'create',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          repeatDaily: false,
        );
      }

      await _notificationProvider.saveNotification(notification);
      log(
        '✅ Sync: Feeding notification created/updated for ${nextFeedingTime.toLocal()}',
      );
    } catch (e) {
      log('⚠️ Sync: Failed to create feeding notification: $e');
      // Don't rethrow - notification creation failure shouldn't fail sync
    }
  }

  /// Create or update notification for deworming events during sync
  Future<void> _createDewormingNotificationFromSync(
    DewormingModel deworming,
  ) async {
    if (_notificationProvider == null) return;

    try {
      final nextAdminDate = deworming.nextAdministrationDate;
      if (nextAdminDate == null || nextAdminDate.isEmpty) return;

      final nextDate = DateTime.tryParse(nextAdminDate);
      if (nextDate == null) return;

      final now = DateTime.now();
      if (!nextDate.isAfter(now)) return;

      await _reloadNotificationCacheSafely();
      final scheduledIso = nextDate.toIso8601String();

      if (await _existsInNotificationTable(
        title: 'deworming_reminder',
        scheduledAt: scheduledIso,
        farmUuid: deworming.farmUuid,
        livestockUuid: deworming.livestockUuid,
      )) {
        return;
      }

      // Check if notification already exists
      final existingNotifications = _notificationProvider.notifications
          .where(
            (n) =>
                n.title == 'deworming_reminder' &&
                n.farmUuid == deworming.farmUuid &&
                n.livestockUuid == deworming.livestockUuid &&
                !n.isCompleted,
          )
          .toList();

      NotificationModel notification;
      if (existingNotifications.isNotEmpty) {
        final existing = existingNotifications.first;
        notification = existing.copyWith(
          scheduledAt: scheduledIso,
          updatedAt: DateTime.now().toIso8601String(),
          synced: false,
          syncAction: 'update',
        );
      } else {
        notification = NotificationModel(
          farmUuid: deworming.farmUuid,
          farmName: null,
          livestockUuid: deworming.livestockUuid,
          livestockName: null,
          title: 'deworming_reminder',
          description: 'time_to_deworm_livestock',
          scheduledAt: scheduledIso,
          isCompleted: false,
          synced: false,
          syncAction: 'create',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          repeatDaily: false,
        );
      }

      await _notificationProvider.saveNotification(notification);
      log(
        '✅ Sync: Deworming notification created/updated for ${nextDate.toLocal()}',
      );
    } catch (e) {
      log('⚠️ Sync: Failed to create deworming notification: $e');
      // Don't rethrow - notification creation failure shouldn't fail sync
    }
  }

  /// Create or update notification for treatment events during sync
  Future<void> _createTreatmentNotificationFromSync(
    TreatmentModel treatment,
  ) async {
    if (_notificationProvider == null) return;

    try {
      final nextMedicationDate = treatment.nextMedicationDate;
      if (nextMedicationDate == null || nextMedicationDate.isEmpty) return;

      final nextDate = DateTime.tryParse(nextMedicationDate);
      if (nextDate == null) return;

      final now = DateTime.now();
      if (!nextDate.isAfter(now)) return;

      await _reloadNotificationCacheSafely();
      final scheduledIso = nextDate.toIso8601String();

      if (await _existsInNotificationTable(
        title: 'treatment_reminder',
        scheduledAt: scheduledIso,
        farmUuid: treatment.farmUuid,
        livestockUuid: treatment.livestockUuid,
      )) {
        return;
      }

      // Check if notification already exists
      final existingNotifications = _notificationProvider.notifications
          .where(
            (n) =>
                n.title == 'treatment_reminder' &&
                n.farmUuid == treatment.farmUuid &&
                n.livestockUuid == treatment.livestockUuid &&
                !n.isCompleted,
          )
          .toList();

      NotificationModel notification;
      if (existingNotifications.isNotEmpty) {
        final existing = existingNotifications.first;
        notification = existing.copyWith(
          scheduledAt: scheduledIso,
          updatedAt: DateTime.now().toIso8601String(),
          synced: false,
          syncAction: 'update',
        );
      } else {
        notification = NotificationModel(
          farmUuid: treatment.farmUuid,
          farmName: null,
          livestockUuid: treatment.livestockUuid,
          livestockName: null,
          title: 'treatment_reminder',
          description: 'time_to_treat_livestock',
          scheduledAt: scheduledIso,
          isCompleted: false,
          synced: false,
          syncAction: 'create',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          repeatDaily: false,
        );
      }

      await _notificationProvider.saveNotification(notification);
      log(
        '✅ Sync: Treatment notification created/updated for ${nextDate.toLocal()}',
      );
    } catch (e) {
      log('⚠️ Sync: Failed to create treatment notification: $e');
      // Don't rethrow - notification creation failure shouldn't fail sync
    }
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
  Future<TreatmentModel> createTreatment(TreatmentModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating treatment log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertTreatment(
      _toTreatmentCompanion(localModel),
    );
    return _mapTreatmentEntity(inserted);
  }

  @override
  Future<TreatmentModel> updateTreatmentLocally(TreatmentModel model) async {
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

    final updated = await _eventDao.upsertTreatment(
      _toTreatmentCompanion(localModel),
    );
    return _mapTreatmentEntity(updated);
  }

  @override
  Future<VaccinationModel> createVaccination(VaccinationModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating vaccination log locally: ${model.uuid}');
    log(
      '💉 Vaccination model: farmUuid=${model.farmUuid}, livestockUuid=${model.livestockUuid}, vaccineUuid=${model.vaccineUuid}',
    );
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    try {
      final companion = _toVaccinationCompanion(localModel);
      log(
        '💉 Vaccination companion: vaccineUuid=${companion.vaccineUuid.value}, vetId=${companion.vetId.value}, extensionOfficerId=${companion.extensionOfficerId.value}',
      );
      final inserted = await _eventDao.upsertVaccination(companion);
      log(
        '✅ Vaccination inserted successfully: uuid=${inserted.uuid}, vaccineUuid=${inserted.vaccineUuid}',
      );
      final mapped = _mapVaccinationEntity(inserted);
      log(
        '✅ Vaccination mapped: uuid=${mapped.uuid}, vaccineUuid=${mapped.vaccineUuid}',
      );
      return mapped;
    } catch (e, stackTrace) {
      log('❌ Error inserting vaccination: $e', stackTrace: stackTrace);
      rethrow;
    }
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

    // Update livestock status to 'notActive' if disposal type exists
    // All disposal types (Dead, Slaughtered, Lost, Culled) mean livestock is no longer active
    if (model.disposalTypeId != null) {
      await _updateLivestockStatusForDisposal(model.livestockUuid, 'notActive');
    }

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
  Future<TransferModel> createTransfer(TransferModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating transfer log locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertTransfer(
      _toTransferCompanion(localModel),
    );
    return _mapTransferEntity(inserted);
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

    final updated = await _eventDao.upsertTransfer(
      _toTransferCompanion(localModel),
    );
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
  Future<List<TreatmentModel>> getTreatments({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getTreatments(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapTreatmentEntity).toList();
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
    final models = rows.map(_mapVaccinationEntity).toList();
    log(
      '💉 Repository: Retrieved ${models.length} vaccination(s) from local DB (farmUuid: $farmUuid, livestockUuid: $livestockUuid)',
    );
    return models;
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
    return rows
        .map(_mapMilkingEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
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
    return rows
        .map(_mapPregnancyEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
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
    return rows
        .map(_mapInseminationEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
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
    return rows
        .map(_mapDryoffEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
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
    return rows
        .map(_mapTransferEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
  }

  @override
  Future<TeethClippingModel> createTeethClipping(
    TeethClippingModel model,
  ) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );
    final inserted = await _eventDao.upsertTeethClipping(
      _toTeethClippingCompanion(localModel),
    );
    return _mapTeethClippingEntity(inserted);
  }

  @override
  Future<TeethClippingModel> updateTeethClippingLocally(
    TeethClippingModel model,
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
    final updated = await _eventDao.upsertTeethClipping(
      _toTeethClippingCompanion(localModel),
    );
    return _mapTeethClippingEntity(updated);
  }

  @override
  Future<List<TeethClippingModel>> getTeethClippings({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getTeethClippings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows
        .map(_mapTeethClippingEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
  }

  @override
  Future<TailDockingModel> createTailDocking(TailDockingModel model) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );
    final inserted = await _eventDao.upsertTailDocking(
      _toTailDockingCompanion(localModel),
    );
    return _mapTailDockingEntity(inserted);
  }

  @override
  Future<TailDockingModel> updateTailDockingLocally(
    TailDockingModel model,
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
    final updated = await _eventDao.upsertTailDocking(
      _toTailDockingCompanion(localModel),
    );
    return _mapTailDockingEntity(updated);
  }

  @override
  Future<List<TailDockingModel>> getTailDockings({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getTailDockings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows
        .map(_mapTailDockingEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
  }

  @override
  Future<IronInjectionModel> createIronInjection(
    IronInjectionModel model,
  ) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );
    final inserted = await _eventDao.upsertIronInjection(
      _toIronInjectionCompanion(localModel),
    );
    return _mapIronInjectionEntity(inserted);
  }

  @override
  Future<IronInjectionModel> updateIronInjectionLocally(
    IronInjectionModel model,
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
    final updated = await _eventDao.upsertIronInjection(
      _toIronInjectionCompanion(localModel),
    );
    return _mapIronInjectionEntity(updated);
  }

  @override
  Future<List<IronInjectionModel>> getIronInjections({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getIronInjections(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows
        .map(_mapIronInjectionEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
  }

  @override
  Future<LivestockMarkingModel> createLivestockMarking(
    LivestockMarkingModel model,
  ) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );
    final inserted = await _eventDao.upsertLivestockMarking(
      _toLivestockMarkingCompanion(localModel),
    );
    return _mapLivestockMarkingEntity(inserted);
  }

  @override
  Future<LivestockMarkingModel> updateLivestockMarkingLocally(
    LivestockMarkingModel model,
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
    final updated = await _eventDao.upsertLivestockMarking(
      _toLivestockMarkingCompanion(localModel),
    );
    return _mapLivestockMarkingEntity(updated);
  }

  @override
  Future<List<LivestockMarkingModel>> getLivestockMarkings({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getLivestockMarkings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows
        .map(_mapLivestockMarkingEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
  }

  @override
  Future<StageChangeModel> createStageChange(StageChangeModel model) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );
    final inserted = await _eventDao.upsertStageChange(
      _toStageChangeCompanion(localModel),
    );
    return _mapStageChangeEntity(inserted);
  }

  @override
  Future<StageChangeModel> updateStageChangeLocally(
    StageChangeModel model,
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
    final updated = await _eventDao.upsertStageChange(
      _toStageChangeCompanion(localModel),
    );
    return _mapStageChangeEntity(updated);
  }

  @override
  Future<List<StageChangeModel>> getStageChanges({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getStageChanges(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows
        .map(_mapStageChangeEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
  }

  @override
  Future<PrepuceConditionModel> createPrepuceCondition(
    PrepuceConditionModel model,
  ) async {
    final now = DateTime.now().toIso8601String();
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );
    final inserted = await _eventDao.upsertPrepuceCondition(
      _toPrepuceConditionCompanion(localModel),
    );
    final mapped = _mapPrepuceConditionEntity(inserted);
    await _applyPrepuceFollowUpNotification(mapped);
    return mapped;
  }

  @override
  Future<PrepuceConditionModel> updatePrepuceConditionLocally(
    PrepuceConditionModel model,
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
    final updated = await _eventDao.upsertPrepuceCondition(
      _toPrepuceConditionCompanion(localModel),
    );
    final mapped = _mapPrepuceConditionEntity(updated);
    await _applyPrepuceFollowUpNotification(mapped);
    return mapped;
  }

  @override
  Future<List<PrepuceConditionModel>> getPrepuceConditions({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getPrepuceConditions(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows
        .map(_mapPrepuceConditionEntity)
        .where((model) => model.syncAction != 'deleted')
        .toList();
  }

  @override
  Future<List<PrepuceConditionModel>> getAllPrepuceConditions() =>
      getPrepuceConditions();

  @override
  Future<List<FeedingModel>> getAllFeedings() => getFeedings();

  @override
  Future<List<WeightChangeModel>> getAllWeightChanges() => getWeightChanges();

  @override
  Future<List<DewormingModel>> getAllDewormings() => getDewormings();
  @override
  Future<List<TreatmentModel>> getAllTreatments() => getTreatments();
  @override
  Future<List<VaccinationModel>> getAllVaccinations() => getVaccinations();
  @override
  Future<List<DisposalModel>> getAllDisposals() => getDisposals();

  @override
  Future<List<MilkingModel>> getAllMilkings() => getMilkings();

  @override
  Future<List<PregnancyModel>> getAllPregnancies() => getPregnancies();

  @override
  Future<List<InseminationModel>> getAllInseminations() => getInseminations();

  @override
  Future<List<DryoffModel>> getAllDryoffs() => getDryoffs();

  @override
  Future<List<TransferModel>> getAllTransfers() => getTransfers();

  @override
  Future<List<TeethClippingModel>> getAllTeethClippings() =>
      getTeethClippings();

  @override
  Future<List<TailDockingModel>> getAllTailDockings() => getTailDockings();

  @override
  Future<List<IronInjectionModel>> getAllIronInjections() =>
      getIronInjections();

  @override
  Future<List<LivestockMarkingModel>> getAllLivestockMarkings() =>
      getLivestockMarkings();

  @override
  Future<List<StageChangeModel>> getAllStageChanges() => getStageChanges();

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
    final treatments = await getTreatments(
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
    final birthEvents = await getBirthEvents(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final abortedPregnancies = await getAbortedPregnancies(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final inseminations = await getInseminations(
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
    final dryoffs = await getDryoffs(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final transfers = await getTransfers(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final teethClippings = await getTeethClippings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final tailDockings = await getTailDockings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final ironInjections = await getIronInjections(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final livestockMarkings = await getLivestockMarkings(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final stageChanges = await getStageChanges(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    final prepuceConditions = await getPrepuceConditions(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );

    // Count calving and farrowing separately
    final calvingCount = birthEvents
        .where((e) => e.eventType == EventLogTypes.calving)
        .length;
    final farrowingCount = birthEvents
        .where((e) => e.eventType == EventLogTypes.farrowing)
        .length;

    return {
      EventLogTypes.feeding: feedings.length,
      EventLogTypes.weightChange: weightChanges.length,
      EventLogTypes.deworming: dewormings.length,
      EventLogTypes.treatment: treatments.length,
      EventLogTypes.vaccination: vaccinations.length,
      EventLogTypes.disposal: disposals.length,
      EventLogTypes.calving: calvingCount,
      EventLogTypes.farrowing: farrowingCount,
      EventLogTypes.abortedPregnancy: abortedPregnancies.length,
      EventLogTypes.insemination: inseminations.length,
      EventLogTypes.milking: milkings.length,
      EventLogTypes.pregnancy: pregnancies.length,
      EventLogTypes.dryoff: dryoffs.length,
      EventLogTypes.transfer: transfers.length,
      EventLogTypes.teethClipping: teethClippings.length,
      EventLogTypes.tailDocking: tailDockings.length,
      EventLogTypes.ironInjection: ironInjections.length,
      EventLogTypes.livestockMarking: livestockMarkings.length,
      EventLogTypes.stageChange: stageChanges.length,
      EventLogTypes.prepuceCondition: prepuceConditions.length,
    };
  }

  @override
  Future<EventSummary> getEventSummary() async {
    final feedingsCount = (await getFeedings()).length;
    final weightChangesCount = (await getWeightChanges()).length;
    final dewormingsCount = (await getDewormings()).length;
    final treatmentsCount = (await getTreatments()).length;
    final vaccinationsCount = (await getVaccinations()).length;
    final disposalsCount = (await getDisposals()).length;
    final birthEvents = await getBirthEvents();
    final abortedPregnanciesCount = (await getAbortedPregnancies()).length;
    final inseminationsCount = (await getInseminations()).length;
    final milkingsCount = (await getMilkings()).length;
    final pregnanciesCount = (await getPregnancies()).length;
    final dryoffsCount = (await getDryoffs()).length;
    final transfersCount = (await getTransfers()).length;
    final teethClippingsCount = (await getTeethClippings()).length;
    final tailDockingsCount = (await getTailDockings()).length;
    final ironInjectionsCount = (await getIronInjections()).length;
    final livestockMarkingsCount = (await getLivestockMarkings()).length;
    final stageChangesCount = (await getStageChanges()).length;
    final prepuceConditionsCount = (await getPrepuceConditions()).length;

    // Count calving and farrowing separately from birthEvents
    final calvingCount = birthEvents
        .where((e) => e.eventType == EventLogTypes.calving)
        .length;
    final farrowingCount = birthEvents
        .where((e) => e.eventType == EventLogTypes.farrowing)
        .length;

    return EventSummary(
      byType: {
        EventLogTypes.feeding: feedingsCount,
        EventLogTypes.weightChange: weightChangesCount,
        EventLogTypes.deworming: dewormingsCount,
        EventLogTypes.treatment: treatmentsCount,
        EventLogTypes.vaccination: vaccinationsCount,
        EventLogTypes.disposal: disposalsCount,
        EventLogTypes.calving: calvingCount,
        EventLogTypes.farrowing: farrowingCount,
        EventLogTypes.abortedPregnancy: abortedPregnanciesCount,
        EventLogTypes.insemination: inseminationsCount,
        EventLogTypes.milking: milkingsCount,
        EventLogTypes.pregnancy: pregnanciesCount,
        EventLogTypes.dryoff: dryoffsCount,
        EventLogTypes.transfer: transfersCount,
        EventLogTypes.teethClipping: teethClippingsCount,
        EventLogTypes.tailDocking: tailDockingsCount,
        EventLogTypes.ironInjection: ironInjectionsCount,
        EventLogTypes.livestockMarking: livestockMarkingsCount,
        EventLogTypes.stageChange: stageChangesCount,
        EventLogTypes.prepuceCondition: prepuceConditionsCount,
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
  Future<List<Map<String, dynamic>>> getUnsyncedTreatmentsForApi() async {
    final rows = await _eventDao.getUnsyncedTreatments();
    if (rows.isEmpty) {
      log('✅ No unsynced treatment logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} treatment logs for sync');
    return rows.map((row) => _mapTreatmentEntity(row).toApiJson()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedVaccinationsForApi() async {
    final rows = await _eventDao.getUnsyncedVaccinations();
    if (rows.isEmpty) {
      log('✅ No unsynced vaccination logs found');
      return [];
    }

    log('📤 Preparing ${rows.length} vaccination logs for sync');
    final apiData = rows.map((row) {
      final model = _mapVaccinationEntity(row);
      final json = model.toApiJson();
      log(
        '  💉 Vaccination for sync: uuid=${json['uuid']}, vaccineUuid=${json['vaccineUuid']}, farmUuid=${json['farmUuid']}, livestockUuid=${json['livestockUuid']}',
      );
      return json;
    }).toList();
    return apiData;
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
  Future<void> markTreatmentsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getTreatmentByUuid(uuid);
      if (existing == null) {
        log('⚠️ Treatment log not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteTreatmentByUuid(uuid);
        log('🗑️ Removed treatment log after synced delete: $uuid');
      } else {
        final model = _mapTreatmentEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertTreatment(_toTreatmentCompanion(model));
        log('✅ Marked treatment log as synced: $uuid');
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
  Future<void> markAllLogsForLivestockAsDeleted(String livestockUuid) async {
    final feedings = await _eventDao.getFeedings(livestockUuid: livestockUuid);
    for (final log in feedings) {
      await markFeedingAsDeleted(log.uuid);
    }

    final weightChanges = await _eventDao.getWeightChanges(
      livestockUuid: livestockUuid,
    );
    for (final log in weightChanges) {
      await markWeightChangeAsDeleted(log.uuid);
    }

    final dewormings = await _eventDao.getDewormings(
      livestockUuid: livestockUuid,
    );
    for (final log in dewormings) {
      await markDewormingAsDeleted(log.uuid);
    }

    final treatments = await _eventDao.getTreatments(
      livestockUuid: livestockUuid,
    );
    for (final log in treatments) {
      await markTreatmentAsDeleted(log.uuid);
    }

    final vaccinations = await _eventDao.getVaccinations(
      livestockUuid: livestockUuid,
    );
    for (final log in vaccinations) {
      await markVaccinationAsDeleted(log.uuid);
    }

    final disposals = await _eventDao.getDisposals(
      livestockUuid: livestockUuid,
    );
    for (final log in disposals) {
      await markDisposalAsDeleted(log.uuid);
    }

    // Birth events (calving / farrowing)
    final birthEvents = await _eventDao.getBirthEvents(
      livestockUuid: livestockUuid,
    );
    for (final log in birthEvents) {
      await markBirthEventAsDeleted(log.uuid);
    }

    // Aborted pregnancies
    final abortedPregnancies = await _eventDao.getAbortedPregnancies(
      livestockUuid: livestockUuid,
    );
    for (final log in abortedPregnancies) {
      await markAbortedPregnancyAsDeleted(log.uuid);
    }

    // Milking logs
    final milkings = await _eventDao.getMilkings(livestockUuid: livestockUuid);
    for (final log in milkings) {
      final now = DateTime.now().toIso8601String();
      final model = _mapMilkingEntity(
        log,
      ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
      await _eventDao.upsertMilking(_toMilkingCompanion(model));
    }

    // Pregnancy logs
    final pregnancies = await _eventDao.getPregnancies(
      livestockUuid: livestockUuid,
    );
    for (final log in pregnancies) {
      final now = DateTime.now().toIso8601String();
      final model = _mapPregnancyEntity(
        log,
      ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
      await _eventDao.upsertPregnancy(_toPregnancyCompanion(model));
    }

    // Insemination logs
    final inseminations = await _eventDao.getInseminations(
      livestockUuid: livestockUuid,
    );
    for (final log in inseminations) {
      final now = DateTime.now().toIso8601String();
      final model = _mapInseminationEntity(
        log,
      ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
      await _eventDao.upsertInsemination(_toInseminationCompanion(model));
    }

    // Dryoff logs
    final dryoffs = await _eventDao.getDryoffs(livestockUuid: livestockUuid);
    for (final log in dryoffs) {
      final now = DateTime.now().toIso8601String();
      final model = _mapDryoffEntity(
        log,
      ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
      await _eventDao.upsertDryoff(_toDryoffCompanion(model));
    }

    // Transfer logs
    final transfers = await _eventDao.getTransfers(
      livestockUuid: livestockUuid,
    );
    for (final log in transfers) {
      final now = DateTime.now().toIso8601String();
      final model = _mapTransferEntity(
        log,
      ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
      await _eventDao.upsertTransfer(_toTransferCompanion(model));
    }

    for (final log in await _eventDao.getTeethClippings(
      livestockUuid: livestockUuid,
    )) {
      final now = DateTime.now().toIso8601String();
      await _eventDao.upsertTeethClipping(
        _toTeethClippingCompanion(
          _mapTeethClippingEntity(
            log,
          ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now),
        ),
      );
    }
    for (final log in await _eventDao.getTailDockings(
      livestockUuid: livestockUuid,
    )) {
      final now = DateTime.now().toIso8601String();
      await _eventDao.upsertTailDocking(
        _toTailDockingCompanion(
          _mapTailDockingEntity(
            log,
          ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now),
        ),
      );
    }
    for (final log in await _eventDao.getIronInjections(
      livestockUuid: livestockUuid,
    )) {
      final now = DateTime.now().toIso8601String();
      await _eventDao.upsertIronInjection(
        _toIronInjectionCompanion(
          _mapIronInjectionEntity(
            log,
          ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now),
        ),
      );
    }
    for (final log in await _eventDao.getLivestockMarkings(
      livestockUuid: livestockUuid,
    )) {
      final now = DateTime.now().toIso8601String();
      await _eventDao.upsertLivestockMarking(
        _toLivestockMarkingCompanion(
          _mapLivestockMarkingEntity(
            log,
          ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now),
        ),
      );
    }
    for (final log in await _eventDao.getStageChanges(
      livestockUuid: livestockUuid,
    )) {
      final now = DateTime.now().toIso8601String();
      await _eventDao.upsertStageChange(
        _toStageChangeCompanion(
          _mapStageChangeEntity(
            log,
          ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now),
        ),
      );
    }
    for (final log in await _eventDao.getPrepuceConditions(
      livestockUuid: livestockUuid,
    )) {
      final now = DateTime.now().toIso8601String();
      await _eventDao.upsertPrepuceCondition(
        _toPrepuceConditionCompanion(
          _mapPrepuceConditionEntity(
            log,
          ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now),
        ),
      );
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
  Future<bool> markTreatmentAsDeleted(String uuid) async {
    final existing = await _eventDao.getTreatmentByUuid(uuid);
    if (existing == null) {
      log('⚠️ Treatment log not found when marking as deleted: $uuid');
      return false;
    }

    final now = DateTime.now().toIso8601String();
    final model = _mapTreatmentEntity(
      existing,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertTreatment(_toTreatmentCompanion(model));
    log('🗑️ Marked treatment log as deleted (pending sync): $uuid');
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
    await _database.financeIncomeDao.markDisposalIncomeAsDeleted(uuid);
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
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
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
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
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
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
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

  TreatmentsCompanion _toTreatmentCompanion(TreatmentModel model) {
    return TreatmentsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
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
      nextMedicationDate: model.nextMedicationDate != null
          ? Value(model.nextMedicationDate!)
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
    log(
      '💉 Creating VaccinationsCompanion: uuid=${model.uuid}, vaccineUuid=${model.vaccineUuid}, vetId=${model.vetId}, extensionOfficerId=${model.extensionOfficerId}',
    );
    return VaccinationsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      vaccinationNo: model.vaccinationNo != null
          ? Value(model.vaccinationNo!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      vaccineUuid: model.vaccineUuid != null
          ? Value(model.vaccineUuid!)
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
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      disposalTypeId: model.disposalTypeId != null
          ? Value(model.disposalTypeId!)
          : const Value.absent(),
      reasons: Value(model.reasons),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
      saleWeight: Value(model.saleWeight),
      salePrice: Value(model.salePrice),
      buyerName: model.buyerName != null
          ? Value(model.buyerName!)
          : const Value.absent(),
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
      eventDate: entity.eventDate,
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
      eventDate: entity.eventDate,
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
      eventDate: entity.eventDate,
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

  TreatmentModel _mapTreatmentEntity(Treatment entity) {
    return TreatmentModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
      diseaseId: entity.diseaseId,
      medicineId: entity.medicineId,
      quantity: entity.quantity,
      withdrawalPeriod: entity.withdrawalPeriod,
      medicationDate: entity.medicationDate,
      nextMedicationDate: entity.nextMedicationDate,
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
      eventDate: entity.eventDate,
      livestockUuid: entity.livestockUuid,
      vaccineUuid: entity.vaccineUuid,
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
      eventDate: entity.eventDate,
      disposalTypeId: entity.disposalTypeId,
      reasons: entity.reasons,
      remarks: entity.remarks,
      saleWeight: entity.saleWeight,
      salePrice: entity.salePrice,
      buyerName: entity.buyerName,
      status: entity.status,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TeethClippingsCompanion _toTeethClippingCompanion(TeethClippingModel model) {
    return TeethClippingsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      method: model.method != null
          ? Value(model.method!)
          : const Value.absent(),
      notes: model.notes != null ? Value(model.notes!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  TailDockingsCompanion _toTailDockingCompanion(TailDockingModel model) {
    return TailDockingsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      method: model.method != null
          ? Value(model.method!)
          : const Value.absent(),
      notes: model.notes != null ? Value(model.notes!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  IronInjectionsCompanion _toIronInjectionCompanion(IronInjectionModel model) {
    return IronInjectionsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      dosage: model.dosage != null
          ? Value(model.dosage!)
          : const Value.absent(),
      medicineId: model.medicineId != null
          ? Value(model.medicineId!)
          : const Value.absent(),
      notes: model.notes != null ? Value(model.notes!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  LivestockMarkingsCompanion _toLivestockMarkingCompanion(
    LivestockMarkingModel model,
  ) {
    return LivestockMarkingsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      markingType: Value(model.markingType),
      description: model.description != null
          ? Value(model.description!)
          : const Value.absent(),
      notes: model.notes != null ? Value(model.notes!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  StageChangesCompanion _toStageChangeCompanion(StageChangeModel model) {
    return StageChangesCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      fromStageId: model.fromStageId != null
          ? Value(model.fromStageId!)
          : const Value.absent(),
      toStageId: model.toStageId != null
          ? Value(model.toStageId!)
          : const Value.absent(),
      notes: model.notes != null ? Value(model.notes!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  PrepuceConditionsCompanion _toPrepuceConditionCompanion(
    PrepuceConditionModel model,
  ) {
    return PrepuceConditionsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      conditionTypeId: Value(model.conditionTypeId),
      severityId: Value(model.severityId),
      clinicalSignIdsJson: Value(jsonEncode(model.clinicalSignIds)),
      causeRiskId: model.causeRiskId != null
          ? Value(model.causeRiskId!)
          : const Value.absent(),
      treatmentGivenIdsJson: Value(jsonEncode(model.treatmentGivenIds)),
      medicineId: model.medicineId != null
          ? Value(model.medicineId!)
          : const Value.absent(),
      administrationRouteId: model.administrationRouteId != null
          ? Value(model.administrationRouteId!)
          : const Value.absent(),
      vetId: model.vetId != null ? Value(model.vetId!) : const Value.absent(),
      extensionOfficerId: model.extensionOfficerId != null
          ? Value(model.extensionOfficerId!)
          : const Value.absent(),
      quantity: model.quantity != null
          ? Value(model.quantity!)
          : const Value.absent(),
      dose: model.dose != null ? Value(model.dose!) : const Value.absent(),
      breedingStatusId: Value(model.breedingStatusId),
      healingStatusId: model.healingStatusId != null
          ? Value(model.healingStatusId!)
          : const Value.absent(),
      followUpDate: model.followUpDate != null
          ? Value(model.followUpDate!)
          : const Value.absent(),
      notes: model.notes != null ? Value(model.notes!) : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  TeethClippingModel _mapTeethClippingEntity(TeethClipping entity) {
    return TeethClippingModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
      method: entity.method,
      notes: entity.notes,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TailDockingModel _mapTailDockingEntity(TailDocking entity) {
    return TailDockingModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
      method: entity.method,
      notes: entity.notes,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  IronInjectionModel _mapIronInjectionEntity(IronInjection entity) {
    return IronInjectionModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
      dosage: entity.dosage,
      medicineId: entity.medicineId,
      notes: entity.notes,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  LivestockMarkingModel _mapLivestockMarkingEntity(LivestockMarking entity) {
    return LivestockMarkingModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
      markingType: entity.markingType,
      description: entity.description,
      notes: entity.notes,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  StageChangeModel _mapStageChangeEntity(StageChange entity) {
    return StageChangeModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
      fromStageId: entity.fromStageId,
      toStageId: entity.toStageId,
      notes: entity.notes,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  List<int> _decodeJsonIntList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final out = <int>[];
        for (final e in decoded) {
          if (e == null) continue;
          if (e is int) {
            if (e > 0) out.add(e);
          } else if (e is num) {
            final i = e.toInt();
            if (i > 0) out.add(i);
          } else {
            final i = int.tryParse(e.toString());
            if (i != null && i > 0) out.add(i);
          }
        }
        return out;
      }
    } catch (_) {}
    return [];
  }

  PrepuceConditionModel _mapPrepuceConditionEntity(PrepuceCondition entity) {
    return PrepuceConditionModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      conditionTypeId: entity.conditionTypeId,
      severityId: entity.severityId,
      clinicalSignIds: _decodeJsonIntList(entity.clinicalSignIdsJson),
      causeRiskId: entity.causeRiskId,
      treatmentGivenIds: _decodeJsonIntList(entity.treatmentGivenIdsJson),
      medicineId: entity.medicineId,
      administrationRouteId: entity.administrationRouteId,
      vetId: entity.vetId,
      extensionOfficerId: entity.extensionOfficerId,
      quantity: entity.quantity,
      dose: entity.dose,
      breedingStatusId: entity.breedingStatusId,
      healingStatusId: entity.healingStatusId,
      followUpDate: entity.followUpDate,
      notes: entity.notes,
      eventDate: entity.eventDate,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // ===========================================================================
  // BIRTH EVENTS (replaces calvings)
  // ===========================================================================

  @override
  Future<BirthEventModel> createBirthEvent(BirthEventModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating birth event locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertBirthEvent(
      _toBirthEventCompanion(localModel),
    );
    return _mapBirthEventEntity(inserted);
  }

  @override
  Future<BirthEventModel> updateBirthEventLocally(BirthEventModel model) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Updating birth event locally: ${model.uuid}');
    final localModel = model.copyWith(
      synced: false,
      syncAction: model.syncAction == 'create'
          ? 'create'
          : model.syncAction == 'deleted'
          ? 'deleted'
          : 'update',
      updatedAt: now,
    );

    final updated = await _eventDao.upsertBirthEvent(
      _toBirthEventCompanion(localModel),
    );
    log('✅ Birth event updated locally: ${updated.uuid}');
    return _mapBirthEventEntity(updated);
  }

  @override
  Future<List<BirthEventModel>> getBirthEvents({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getBirthEvents(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapBirthEventEntity).toList();
  }

  @override
  Future<List<BirthEventModel>> getAllBirthEvents() => getBirthEvents();

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedBirthEventsForApi() async {
    final events = await _eventDao.getUnsyncedBirthEvents();
    return events.map((e) => _mapBirthEventEntity(e).toApiJson()).toList();
  }

  @override
  Future<void> markBirthEventsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getBirthEventByUuid(uuid);
      if (existing == null) {
        log('⚠️ Birth event not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteBirthEventByUuid(uuid);
        log('🗑️ Removed birth event after synced delete: $uuid');
      } else {
        final model = _mapBirthEventEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertBirthEvent(_toBirthEventCompanion(model));
        log('✅ Marked birth event as synced: $uuid');
      }
    }
  }

  @override
  Future<bool> markBirthEventAsDeleted(String uuid) async {
    final event = await _eventDao.getBirthEventByUuid(uuid);
    if (event == null) return false;

    final now = DateTime.now().toIso8601String();
    final deleted = _mapBirthEventEntity(
      event,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertBirthEvent(_toBirthEventCompanion(deleted));
    return true;
  }

  BirthEventsCompanion _toBirthEventCompanion(BirthEventModel model) {
    return BirthEventsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      eventType: Value(model.eventType),
      startDate: Value(model.startDate),
      endDate: model.endDate != null
          ? Value(model.endDate!)
          : const Value.absent(),
      birthTypeId: Value(model.birthTypeId),
      birthProblemsId: model.birthProblemsId != null
          ? Value(model.birthProblemsId!)
          : const Value.absent(),
      reproductiveProblemId: model.reproductiveProblemId != null
          ? Value(model.reproductiveProblemId!)
          : const Value.absent(),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
      totalBorn: model.totalBorn != null
          ? Value(model.totalBorn!)
          : const Value.absent(),
      aliveCount: model.aliveCount != null
          ? Value(model.aliveCount!)
          : const Value.absent(),
      deadCount: model.deadCount != null
          ? Value(model.deadCount!)
          : const Value.absent(),
      status: Value(model.status),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  BirthEventModel _mapBirthEventEntity(BirthEvent entity) {
    return BirthEventModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
      eventType: entity.eventType,
      startDate: entity.startDate,
      endDate: entity.endDate,
      birthTypeId: entity.birthTypeId,
      birthProblemsId: entity.birthProblemsId,
      reproductiveProblemId: entity.reproductiveProblemId,
      remarks: entity.remarks,
      totalBorn: entity.totalBorn,
      aliveCount: entity.aliveCount,
      deadCount: entity.deadCount,
      status: entity.status,
      synced: entity.synced,
      syncAction: entity.syncAction,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // ===========================================================================
  // ABORTED PREGNANCIES
  // ===========================================================================

  @override
  Future<AbortedPregnancyModel> createAbortedPregnancy(
    AbortedPregnancyModel model,
  ) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Creating aborted pregnancy locally: ${model.uuid}');
    final localModel = model.copyWith(
      createdAt: model.createdAt.isNotEmpty ? model.createdAt : now,
      updatedAt: model.updatedAt.isNotEmpty ? model.updatedAt : now,
      synced: false,
      syncAction: 'create',
    );

    final inserted = await _eventDao.upsertAbortedPregnancy(
      _toAbortedPregnancyCompanion(localModel),
    );
    return _mapAbortedPregnancyEntity(inserted);
  }

  @override
  Future<AbortedPregnancyModel> updateAbortedPregnancyLocally(
    AbortedPregnancyModel model,
  ) async {
    final now = DateTime.now().toIso8601String();
    log('📝 Updating aborted pregnancy locally: ${model.uuid}');
    final localModel = model.copyWith(
      synced: false,
      syncAction: model.syncAction == 'create'
          ? 'create'
          : model.syncAction == 'deleted'
          ? 'deleted'
          : 'update',
      updatedAt: now,
    );

    final updated = await _eventDao.upsertAbortedPregnancy(
      _toAbortedPregnancyCompanion(localModel),
    );
    log('✅ Aborted pregnancy updated locally: ${updated.uuid}');
    return _mapAbortedPregnancyEntity(updated);
  }

  @override
  Future<List<AbortedPregnancyModel>> getAbortedPregnancies({
    String? farmUuid,
    String? livestockUuid,
  }) async {
    final rows = await _eventDao.getAbortedPregnancies(
      farmUuid: farmUuid,
      livestockUuid: livestockUuid,
    );
    return rows.map(_mapAbortedPregnancyEntity).toList();
  }

  @override
  Future<List<AbortedPregnancyModel>> getAllAbortedPregnancies() =>
      getAbortedPregnancies();

  @override
  Future<List<Map<String, dynamic>>>
  getUnsyncedAbortedPregnanciesForApi() async {
    final pregnancies = await _eventDao.getUnsyncedAbortedPregnancies();
    return pregnancies
        .map((p) => _mapAbortedPregnancyEntity(p).toApiJson())
        .toList();
  }

  @override
  Future<void> markAbortedPregnanciesAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getAbortedPregnancyByUuid(uuid);
      if (existing == null) {
        log('⚠️ Aborted pregnancy not found while marking as synced: $uuid');
        continue;
      }

      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteAbortedPregnancyByUuid(uuid);
        log('🗑️ Removed aborted pregnancy after synced delete: $uuid');
      } else {
        final model = _mapAbortedPregnancyEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertAbortedPregnancy(
          _toAbortedPregnancyCompanion(model),
        );
        log('✅ Marked aborted pregnancy as synced: $uuid');
      }
    }
  }

  @override
  Future<bool> markAbortedPregnancyAsDeleted(String uuid) async {
    final pregnancy = await _eventDao.getAbortedPregnancyByUuid(uuid);
    if (pregnancy == null) return false;

    final now = DateTime.now().toIso8601String();
    final deleted = _mapAbortedPregnancyEntity(
      pregnancy,
    ).copyWith(synced: false, syncAction: 'deleted', updatedAt: now);
    await _eventDao.upsertAbortedPregnancy(
      _toAbortedPregnancyCompanion(deleted),
    );
    return true;
  }

  AbortedPregnanciesCompanion _toAbortedPregnancyCompanion(
    AbortedPregnancyModel model,
  ) {
    return AbortedPregnanciesCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: Value(model.farmUuid),
      livestockUuid: Value(model.livestockUuid),
      abortionDate: Value(model.abortionDate),
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

  AbortedPregnancyModel _mapAbortedPregnancyEntity(AbortedPregnancy entity) {
    return AbortedPregnancyModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
      abortionDate: entity.abortionDate,
      reproductiveProblemId: entity.reproductiveProblemId,
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
      eventDate: entity.eventDate,
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

  MilkingsCompanion _toMilkingCompanion(MilkingModel model) {
    return MilkingsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
      farmUuid: model.farmUuid != null
          ? Value(model.farmUuid!)
          : const Value.absent(),
      livestockUuid: Value(model.livestockUuid),
      milkingMethodId: model.milkingMethodId != null
          ? Value(model.milkingMethodId!)
          : const Value.absent(),
      amount: Value(model.amount),
      lactometerReading: model.lactometerReading != null
          ? Value(model.lactometerReading!)
          : const Value.absent(),
      solid: model.solid != null ? Value(model.solid!) : const Value.absent(),
      solidNonFat: model.solidNonFat != null
          ? Value(model.solidNonFat!)
          : const Value.absent(),
      protein: model.protein != null
          ? Value(model.protein!)
          : const Value.absent(),
      correctedLactometerReading: model.correctedLactometerReading != null
          ? Value(model.correctedLactometerReading!)
          : const Value.absent(),
      totalSolids: model.totalSolids != null
          ? Value(model.totalSolids!)
          : const Value.absent(),
      colonyFormingUnits: model.colonyFormingUnits != null
          ? Value(model.colonyFormingUnits!)
          : const Value.absent(),
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

  PregnancyModel _mapPregnancyEntity(Pregnancy entity) {
    return PregnancyModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
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

  PregnanciesCompanion _toPregnancyCompanion(PregnancyModel model) {
    return PregnanciesCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
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

  InseminationModel _mapInseminationEntity(Insemination entity) {
    return InseminationModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
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

  InseminationsCompanion _toInseminationCompanion(InseminationModel model) {
    return InseminationsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
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

  DryoffModel _mapDryoffEntity(Dryoff entity) {
    return DryoffModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
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

  DryoffsCompanion _toDryoffCompanion(DryoffModel model) {
    return DryoffsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
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

  TransferModel _mapTransferEntity(Transfer entity) {
    return TransferModel(
      id: entity.id,
      uuid: entity.uuid,
      farmUuid: entity.farmUuid,
      livestockUuid: entity.livestockUuid,
      eventDate: entity.eventDate,
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

  TransfersCompanion _toTransferCompanion(TransferModel model) {
    return TransfersCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      uuid: Value(model.uuid),
      eventDate: model.eventDate != null
          ? Value(model.eventDate!)
          : const Value.absent(),
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
      price: model.price != null ? Value(model.price!) : const Value.absent(),
      transferDate: Value(model.transferDate),
      remarks: model.remarks != null
          ? Value(model.remarks!)
          : const Value.absent(),
      status: model.status != null
          ? Value(model.status!)
          : const Value.absent(),
      synced: Value(model.synced),
      syncAction: Value(model.syncAction),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  // ============================================================================
  // MILKING
  // ============================================================================

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

  // ============================================================================
  // PREGNANCY
  // ============================================================================

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

  // ============================================================================
  // INSEMINATION
  // ============================================================================

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

  // ============================================================================
  // DRYOFF
  // ============================================================================

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

  // ============================================================================
  // TRANSFER
  // ============================================================================

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
  Future<List<Map<String, dynamic>>> getUnsyncedTeethClippingsForApi() async {
    final rows = await _eventDao.getUnsyncedTeethClippings();
    if (rows.isEmpty) return [];
    return rows.map((row) => _mapTeethClippingEntity(row).toApiJson()).toList();
  }

  @override
  Future<void> markTeethClippingsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getTeethClippingByUuid(uuid);
      if (existing == null) continue;
      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteTeethClippingByUuid(uuid);
      } else {
        final model = _mapTeethClippingEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertTeethClipping(_toTeethClippingCompanion(model));
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedTailDockingsForApi() async {
    final rows = await _eventDao.getUnsyncedTailDockings();
    if (rows.isEmpty) return [];
    return rows.map((row) => _mapTailDockingEntity(row).toApiJson()).toList();
  }

  @override
  Future<void> markTailDockingsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getTailDockingByUuid(uuid);
      if (existing == null) continue;
      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteTailDockingByUuid(uuid);
      } else {
        final model = _mapTailDockingEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertTailDocking(_toTailDockingCompanion(model));
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedIronInjectionsForApi() async {
    final rows = await _eventDao.getUnsyncedIronInjections();
    if (rows.isEmpty) return [];
    return rows.map((row) => _mapIronInjectionEntity(row).toApiJson()).toList();
  }

  @override
  Future<void> markIronInjectionsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getIronInjectionByUuid(uuid);
      if (existing == null) continue;
      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteIronInjectionByUuid(uuid);
      } else {
        final model = _mapIronInjectionEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertIronInjection(_toIronInjectionCompanion(model));
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>>
  getUnsyncedLivestockMarkingsForApi() async {
    final rows = await _eventDao.getUnsyncedLivestockMarkings();
    if (rows.isEmpty) return [];
    return rows
        .map((row) => _mapLivestockMarkingEntity(row).toApiJson())
        .toList();
  }

  @override
  Future<void> markLivestockMarkingsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getLivestockMarkingByUuid(uuid);
      if (existing == null) continue;
      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteLivestockMarkingByUuid(uuid);
      } else {
        final model = _mapLivestockMarkingEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertLivestockMarking(
          _toLivestockMarkingCompanion(model),
        );
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedStageChangesForApi() async {
    final rows = await _eventDao.getUnsyncedStageChanges();
    if (rows.isEmpty) return [];
    return rows.map((row) => _mapStageChangeEntity(row).toApiJson()).toList();
  }

  @override
  Future<void> markStageChangesAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getStageChangeByUuid(uuid);
      if (existing == null) continue;
      if (existing.syncAction == 'deleted') {
        await _eventDao.deleteStageChangeByUuid(uuid);
      } else {
        final model = _mapStageChangeEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertStageChange(_toStageChangeCompanion(model));
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>>
  getUnsyncedPrepuceConditionsForApi() async {
    final rows = await _eventDao.getUnsyncedPrepuceConditions();
    if (rows.isEmpty) return [];
    return rows
        .map((row) => _mapPrepuceConditionEntity(row).toApiJson())
        .toList();
  }

  @override
  Future<void> markPrepuceConditionsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    for (final uuid in uuids.toSet()) {
      final existing = await _eventDao.getPrepuceConditionByUuid(uuid);
      if (existing == null) continue;
      if (existing.syncAction == 'deleted') {
        await _eventDao.deletePrepuceConditionByUuid(uuid);
      } else {
        final model = _mapPrepuceConditionEntity(
          existing,
        ).copyWith(synced: true, syncAction: existing.syncAction);
        await _eventDao.upsertPrepuceCondition(
          _toPrepuceConditionCompanion(model),
        );
      }
    }
  }

  /// Update livestock status to 'notActive' when a disposal is created.
  ///
  /// All disposal types (Dead, Slaughtered, Lost, Culled) indicate that the livestock
  /// is no longer active in the farm, so the status should be updated to 'notActive'.
  ///
  /// **Parameters:**
  /// - `livestockUuid`: UUID of the livestock to update
  /// - `newStatus`: New status to set (default: 'notActive')
  ///
  /// **Returns:**
  /// - `true` if update was successful, `false` otherwise
  Future<bool> _updateLivestockStatusForDisposal(
    String livestockUuid,
    String newStatus,
  ) async {
    try {
      // Get livestock from database
      final livestock = await _database.livestockDao.getLivestockByUuid(
        livestockUuid,
      );

      if (livestock == null) {
        log(
          '⚠️ Livestock not found for disposal status update: UUID $livestockUuid',
        );
        return false;
      }

      // Check if livestock is already not-active
      if (livestock.status == 'notActive' || livestock.status == 'not-active') {
        log('ℹ️ Livestock already not-active: UUID $livestockUuid');
        return true;
      }

      // Create updated livestock object with new status and mark as unsynced
      final updatedLivestock = Livestock(
        id: livestock.id,
        farmUuid: livestock.farmUuid,
        uuid: livestock.uuid,
        identificationNumber: livestock.identificationNumber,
        dummyTagId: livestock.dummyTagId,
        barcodeTagId: livestock.barcodeTagId,
        rfidTagId: livestock.rfidTagId,
        livestockTypeId: livestock.livestockTypeId,
        name: livestock.name,
        dateOfBirth: livestock.dateOfBirth,
        motherUuid: livestock.motherUuid,
        fatherUuid: livestock.fatherUuid,
        birthEventUuid: livestock.birthEventUuid,
        stageId: livestock.stageId,
        isIdentified: livestock.isIdentified,
        gender: livestock.gender,
        breedId: livestock.breedId,
        speciesId: livestock.speciesId,
        status: newStatus, // Update status to 'notActive'
        livestockObtainedMethodId: livestock.livestockObtainedMethodId,
        dateFirstEnteredToFarm: livestock.dateFirstEnteredToFarm,
        weightAsOnRegistration: livestock.weightAsOnRegistration,
        primaryColor: livestock.primaryColor,
        secondaryColor: livestock.secondaryColor,
        synced:
            false, // Mark as unsynced so status update gets synced to server
        syncAction: 'update', // Mark sync action as update
        createdAt: livestock.createdAt,
        updatedAt: DateTime.now().toIso8601String(), // Update timestamp
      );

      final success = await _database.livestockDao.updateLivestock(
        updatedLivestock,
      );

      if (success) {
        log(
          '✅ Livestock status updated to $newStatus for disposal: UUID $livestockUuid',
        );
      } else {
        log(
          '⚠️ Failed to update livestock status for disposal: UUID $livestockUuid',
        );
      }

      return success;
    } catch (e, stackTrace) {
      log(
        '❌ Error updating livestock status for disposal: $e',
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
