import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../features/vaccines/data/tables/vaccine_table.dart';

part 'vaccine_dao.g.dart';

@DriftAccessor(tables: [Vaccines])
class VaccineDao extends DatabaseAccessor<AppDatabase> with _$VaccineDaoMixin {
  VaccineDao(AppDatabase db) : super(db);

  Future<void> upsertVaccines(List<VaccinesCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(vaccines, entries);
    });
  }

  Future<Vaccine?> getVaccineByUuid(String uuid) {
    return (select(vaccines)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<List<Vaccine>> getVaccines({String? farmUuid}) {
    final query = select(vaccines);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Vaccine>> getUnsyncedVaccines() {
    return (select(vaccines)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<void> markVaccinesAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await (update(vaccines)..where((tbl) => tbl.uuid.isIn(uuids))).write(
      const VaccinesCompanion(
        synced: Value(true),
        syncAction: Value('server-update'),
      ),
    );
  }

  Future<int> deleteServerVaccinesNotIn(Set<String> uuids) {
    final query = delete(vaccines)
      ..where((tbl) {
        var condition =
            tbl.synced.equals(true) & tbl.syncAction.like('server%');
        if (uuids.isNotEmpty) {
          condition = condition & tbl.uuid.isNotIn(uuids.toList());
        }
        return condition;
      });
    return query.go();
  }

  Future<int> deleteVaccineByUuid(String uuid) {
    return (delete(vaccines)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }
}

