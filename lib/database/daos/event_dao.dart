import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../features/events/data/tables/feeding_table.dart';
import '../../features/events/data/tables/weight_change_table.dart';
import '../../features/events/data/tables/deworming_table.dart';
import '../../features/events/data/tables/medication_table.dart';
import '../../features/events/data/tables/vaccination_table.dart';
import '../../features/events/data/tables/disposal_table.dart';

part 'event_dao.g.dart';

@DriftAccessor(tables: [
  Feedings,
  WeightChanges,
  Dewormings,
  Medications,
  Vaccinations,
  Disposals,
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

  Future<void> upsertMedications(List<MedicationsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(medications, entries);
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

  Future<Medication> upsertMedication(MedicationsCompanion entry) {
    return into(medications).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  Future<Vaccination> upsertVaccination(VaccinationsCompanion entry) {
    return into(vaccinations).insertReturning(entry, mode: InsertMode.insertOrReplace);
  }

  Future<Disposal> upsertDisposal(DisposalsCompanion entry) {
    return into(disposals).insertReturning(entry, mode: InsertMode.insertOrReplace);
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

  Future<Medication?> getMedicationByUuid(String uuid) {
    return (select(medications)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Vaccination?> getVaccinationByUuid(String uuid) {
    return (select(vaccinations)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Disposal?> getDisposalByUuid(String uuid) {
    return (select(disposals)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
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

  Future<List<Medication>> getMedications({String? farmUuid, String? livestockUuid}) {
    final query = select(medications);
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

  Future<List<Feeding>> getUnsyncedFeedings() {
    return (select(feedings)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<WeightChange>> getUnsyncedWeightChanges() {
    return (select(weightChanges)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Deworming>> getUnsyncedDewormings() {
    return (select(dewormings)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Medication>> getUnsyncedMedications() {
    return (select(medications)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Vaccination>> getUnsyncedVaccinations() {
    return (select(vaccinations)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<List<Disposal>> getUnsyncedDisposals() {
    return (select(disposals)..where((tbl) => tbl.synced.equals(false))).get();
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

  Future<bool> updateMedication(Medication entry) {
    return update(medications).replace(entry);
  }

  Future<bool> updateVaccination(Vaccination entry) {
    return update(vaccinations).replace(entry);
  }

  Future<bool> updateDisposal(Disposal entry) {
    return update(disposals).replace(entry);
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

  Future<int> deleteMedicationByUuid(String uuid) {
    return (delete(medications)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteVaccinationByUuid(String uuid) {
    return (delete(vaccinations)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }

  Future<int> deleteDisposalByUuid(String uuid) {
    return (delete(disposals)..where((tbl) => tbl.uuid.equals(uuid))).go();
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

  Future<int> deleteServerMedicationsNotIn(Set<String> uuids) async {
    return (delete(medications)
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

  // ==================== BULK OPERATIONS ====================

  Future<void> clearAllLogs() async {
    await batch((batch) {
      batch.deleteWhere(feedings, (_) => const Constant(true));
      batch.deleteWhere(weightChanges, (_) => const Constant(true));
      batch.deleteWhere(dewormings, (_) => const Constant(true));
      batch.deleteWhere(medications, (_) => const Constant(true));
      batch.deleteWhere(vaccinations, (_) => const Constant(true));
      batch.deleteWhere(disposals, (_) => const Constant(true));
    });
  }
}

