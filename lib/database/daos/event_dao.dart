import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../features/events/data/tables/feeding_table.dart';
import '../../features/events/data/tables/weight_change_table.dart';
import '../../features/events/data/tables/deworming_table.dart';
import '../../features/events/data/tables/treatment_table.dart';
import '../../features/events/data/tables/vaccination_table.dart';
import '../../features/events/data/tables/disposal_table.dart';
import '../../features/events/data/tables/birth_event_table.dart';
import '../../features/events/data/tables/aborted_pregnancy_table.dart';
import '../../features/events/data/tables/milking_table.dart';
import '../../features/events/data/tables/pregnancy_table.dart';
import '../../features/events/data/tables/insemination_table.dart';
import '../../features/events/data/tables/dryoff_table.dart';
import '../../features/events/data/tables/transfer_table.dart';

part 'event_dao.g.dart';

@DriftAccessor(tables: [
  Feedings,
  WeightChanges,
  Dewormings,
  Treatments,
  Vaccinations,
  Disposals,
  BirthEvents,
  AbortedPregnancies,
  // Newly added event log tables
  Milkings,
  Pregnancies,
  Inseminations,
  Dryoffs,
  Transfers,
])
class EventDao extends DatabaseAccessor<AppDatabase> with _$EventDaoMixin {
  EventDao(AppDatabase db) : super(db);

  // ==================== UPSERT LISTS (REMOTE SYNC) ====================

  Future<void> upsertFeedings(List<FeedingsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(feedings, entries);
    });
  }

  Future<void> upsertWeightChanges(List<WeightChangesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(weightChanges, entries);
    });
  }

  Future<void> upsertDewormings(List<DewormingsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(dewormings, entries);
    });
  }

  Future<void> upsertTreatments(List<TreatmentsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(treatments, entries);
    });
  }

  Future<void> upsertVaccinations(List<VaccinationsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(vaccinations, entries);
    });
  }

  Future<void> upsertDisposals(List<DisposalsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(disposals, entries);
    });
  }

  Future<void> upsertBirthEvents(List<BirthEventsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(birthEvents, entries);
    });
  }

  Future<void> upsertAbortedPregnancies(List<AbortedPregnanciesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(abortedPregnancies, entries);
    });
  }

  Future<void> upsertMilkings(List<MilkingsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(milkings, entries);
    });
  }

  Future<void> upsertPregnancies(List<PregnanciesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(pregnancies, entries);
    });
  }

  Future<void> upsertInseminations(List<InseminationsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(inseminations, entries);
    });
  }

  Future<void> upsertDryoffs(List<DryoffsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(dryoffs, entries);
    });
  }

  Future<void> upsertTransfers(List<TransfersCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(transfers, entries);
    });
  }

  // ==================== SINGLE UPSERT/INSERT ====================

  Future<Feeding> upsertFeeding(FeedingsCompanion entry) {
    return into(feedings).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  Future<WeightChange> upsertWeightChange(WeightChangesCompanion entry) {
    return into(weightChanges).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  Future<Deworming> upsertDeworming(DewormingsCompanion entry) {
    return into(dewormings).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  Future<Treatment> upsertTreatment(TreatmentsCompanion entry) {
    return into(treatments).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  Future<Vaccination> upsertVaccination(VaccinationsCompanion entry) {
    return into(vaccinations).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  Future<Disposal> upsertDisposal(DisposalsCompanion entry) {
    return into(disposals).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  Future<BirthEvent> upsertBirthEvent(BirthEventsCompanion entry) {
    return into(birthEvents).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  Future<AbortedPregnancy> upsertAbortedPregnancy(AbortedPregnanciesCompanion entry) {
    return into(abortedPregnancies).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  /// Upsert milking event (insert or update by primary key).
  Future<Milking> upsertMilking(MilkingsCompanion entry) {
    return into(milkings).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  /// Upsert pregnancy event (insert or update by primary key).
  Future<Pregnancy> upsertPregnancy(PregnanciesCompanion entry) {
    return into(pregnancies).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  /// Upsert insemination event (insert or update by primary key).
  Future<Insemination> upsertInsemination(InseminationsCompanion entry) {
    return into(inseminations).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  /// Upsert dryoff event (insert or update by primary key).
  Future<Dryoff> upsertDryoff(DryoffsCompanion entry) {
    return into(dryoffs).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  /// Upsert transfer event (insert or update by primary key).
  Future<Transfer> upsertTransfer(TransfersCompanion entry) {
    return into(transfers).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  // ==================== GETTERS ====================

  Future<Feeding?> getFeedingByUuid(String uuid) {
    return (select(feedings)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<WeightChange?> getWeightChangeByUuid(String uuid) {
    return (select(weightChanges)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Deworming?> getDewormingByUuid(String uuid) {
    return (select(dewormings)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Treatment?> getTreatmentByUuid(String uuid) {
    return (select(treatments)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Vaccination?> getVaccinationByUuid(String uuid) {
    return (select(vaccinations)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Disposal?> getDisposalByUuid(String uuid) {
    return (select(disposals)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<BirthEvent?> getBirthEventByUuid(String uuid) {
    return (select(birthEvents)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<AbortedPregnancy?> getAbortedPregnancyByUuid(String uuid) {
    return (select(abortedPregnancies)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Milking?> getMilkingByUuid(String uuid) {
    return (select(milkings)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Pregnancy?> getPregnancyByUuid(String uuid) {
    return (select(pregnancies)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Insemination?> getInseminationByUuid(String uuid) {
    return (select(inseminations)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Dryoff?> getDryoffByUuid(String uuid) {
    return (select(dryoffs)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Transfer?> getTransferByUuid(String uuid) {
    return (select(transfers)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<List<Feeding>> getFeedings({String? farmUuid, String? livestockUuid}) {
    final query = select(feedings);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<WeightChange>> getWeightChanges({String? farmUuid, String? livestockUuid}) {
    final query = select(weightChanges);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Deworming>> getDewormings({String? farmUuid, String? livestockUuid}) {
    final query = select(dewormings);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Treatment>> getTreatments({String? farmUuid, String? livestockUuid}) {
    final query = select(treatments);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Vaccination>> getVaccinations({String? farmUuid, String? livestockUuid}) {
    final query = select(vaccinations);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Disposal>> getDisposals({String? farmUuid, String? livestockUuid}) {
    final query = select(disposals);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<BirthEvent>> getBirthEvents({String? farmUuid, String? livestockUuid}) {
    final query = select(birthEvents);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<AbortedPregnancy>> getAbortedPregnancies({String? farmUuid, String? livestockUuid}) {
    final query = select(abortedPregnancies);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Feeding>> getUnsyncedFeedings() {
    return (select(feedings)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<WeightChange>> getUnsyncedWeightChanges() {
    return (select(weightChanges)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Deworming>> getUnsyncedDewormings() {
    return (select(dewormings)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Treatment>> getUnsyncedTreatments() {
    return (select(treatments)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Vaccination>> getUnsyncedVaccinations() {
    return (select(vaccinations)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Disposal>> getUnsyncedDisposals() {
    return (select(disposals)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<BirthEvent>> getUnsyncedBirthEvents() {
    return (select(birthEvents)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<AbortedPregnancy>> getUnsyncedAbortedPregnancies() {
    return (select(abortedPregnancies)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Milking>> getMilkings({String? farmUuid, String? livestockUuid}) {
    final query = select(milkings);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Pregnancy>> getPregnancies({String? farmUuid, String? livestockUuid}) {
    final query = select(pregnancies);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Insemination>> getInseminations({String? farmUuid, String? livestockUuid}) {
    final query = select(inseminations);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Dryoff>> getDryoffs({String? farmUuid, String? livestockUuid}) {
    final query = select(dryoffs);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Transfer>> getTransfers({String? farmUuid, String? livestockUuid}) {
    final query = select(transfers);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    if (livestockUuid != null) {
      query.where((tbl) => tbl.livestockUuid.equals(livestockUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Milking>> getUnsyncedMilkings() {
    return (select(milkings)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Pregnancy>> getUnsyncedPregnancies() {
    return (select(pregnancies)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Insemination>> getUnsyncedInseminations() {
    return (select(inseminations)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Dryoff>> getUnsyncedDryoffs() {
    return (select(dryoffs)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Transfer>> getUnsyncedTransfers() {
    return (select(transfers)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<bool> updateFeeding(Feeding entry) {
    return update(feedings).replace(entry);
  }

  Future<bool> updateWeightChange(WeightChange entry) {
    return update(weightChanges).replace(entry);
  }

  Future<bool> updateDeworming(Deworming entry) {
    return update(dewormings).replace(entry);
  }

  Future<bool> updateTreatment(Treatment entry) {
    return update(treatments).replace(entry);
  }

  Future<bool> updateVaccination(Vaccination entry) {
    return update(vaccinations).replace(entry);
  }

  Future<bool> updateDisposal(Disposal entry) {
    return update(disposals).replace(entry);
  }

  Future<bool> updateMilking(Milking entry) {
    return update(milkings).replace(entry);
  }

  Future<bool> updatePregnancy(Pregnancy entry) {
    return update(pregnancies).replace(entry);
  }

  Future<bool> updateInsemination(Insemination entry) {
    return update(inseminations).replace(entry);
  }

  Future<bool> updateDryoff(Dryoff entry) {
    return update(dryoffs).replace(entry);
  }

  Future<bool> updateTransfer(Transfer entry) {
    return update(transfers).replace(entry);
  }

  Future<int> deleteFeedingByUuid(String uuid) {
    return (delete(feedings)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteWeightChangeByUuid(String uuid) {
    return (delete(weightChanges)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteDewormingByUuid(String uuid) {
    return (delete(dewormings)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteTreatmentByUuid(String uuid) {
    return (delete(treatments)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteVaccinationByUuid(String uuid) {
    return (delete(vaccinations)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteDisposalByUuid(String uuid) {
    return (delete(disposals)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteBirthEventByUuid(String uuid) {
    return (delete(birthEvents)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteAbortedPregnancyByUuid(String uuid) {
    return (delete(abortedPregnancies)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteMilkingByUuid(String uuid) {
    return (delete(milkings)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deletePregnancyByUuid(String uuid) {
    return (delete(pregnancies)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteInseminationByUuid(String uuid) {
    return (delete(inseminations)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteDryoffByUuid(String uuid) {
    return (delete(dryoffs)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteTransferByUuid(String uuid) {
    return (delete(transfers)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<void> markBirthEventsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await (update(birthEvents)..where((tbl) => tbl.uuid.isIn(uuids)))
        .write(const BirthEventsCompanion(synced: Value(true)));
  }

  Future<void> markAbortedPregnanciesAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await (update(abortedPregnancies)..where((tbl) => tbl.uuid.isIn(uuids)))
        .write(const AbortedPregnanciesCompanion(synced: Value(true)));
  }

  Future<int> deleteServerFeedingsNotIn(Set<String> uuids) async {
    return (delete(feedings)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerWeightChangesNotIn(Set<String> uuids) async {
    return (delete(weightChanges)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerDewormingsNotIn(Set<String> uuids) async {
    return (delete(dewormings)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerTreatmentsNotIn(Set<String> uuids) async {
    return (delete(treatments)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerVaccinationsNotIn(Set<String> uuids) async {
    return (delete(vaccinations)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerDisposalsNotIn(Set<String> uuids) async {
    return (delete(disposals)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerMilkingsNotIn(Set<String> uuids) async {
    return (delete(milkings)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerPregnanciesNotIn(Set<String> uuids) async {
    return (delete(pregnancies)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerInseminationsNotIn(Set<String> uuids) async {
    return (delete(inseminations)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerDryoffsNotIn(Set<String> uuids) async {
    return (delete(dryoffs)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  Future<int> deleteServerTransfersNotIn(Set<String> uuids) async {
    return (delete(transfers)
          ..where((tbl) {
            var condition =
                tbl.synced.equals(true) & tbl.syncAction.like('server%');
            if (uuids.isNotEmpty) {
              condition = condition & tbl.uuid.isNotIn(uuids.toList());
            }
            return condition;
          }))
        .go();
  }

  // ==================== BULK OPERATIONS ====================

  Future<void> clearAllLogs() async {
    await batch((batch) {
      batch.deleteWhere(feedings, (_) => const Constant(true));
      batch.deleteWhere(weightChanges, (_) => const Constant(true));
      batch.deleteWhere(dewormings, (_) => const Constant(true));
      batch.deleteWhere(treatments, (_) => const Constant(true));
      batch.deleteWhere(vaccinations, (_) => const Constant(true));
      batch.deleteWhere(disposals, (_) => const Constant(true));
      batch.deleteWhere(birthEvents, (_) => const Constant(true));
      batch.deleteWhere(abortedPregnancies, (_) => const Constant(true));
      batch.deleteWhere(milkings, (_) => const Constant(true));
      batch.deleteWhere(pregnancies, (_) => const Constant(true));
      batch.deleteWhere(inseminations, (_) => const Constant(true));
      batch.deleteWhere(dryoffs, (_) => const Constant(true));
      batch.deleteWhere(transfers, (_) => const Constant(true));
    });
  }
}

