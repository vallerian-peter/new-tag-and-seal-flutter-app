import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../features/bills/data/tables/bill_table.dart';

part 'bill_dao.g.dart';

@DriftAccessor(tables: [Bills])
class BillDao extends DatabaseAccessor<AppDatabase> with _$BillDaoMixin {
  BillDao(AppDatabase db) : super(db);

  Future<void> upsertBills(List<BillsCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(bills, entries);
    });
  }

  Future<Bill?> getBillByUuid(String uuid) {
    return (select(bills)..where((tbl) => tbl.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<List<Bill>> getBills({String? farmUuid}) {
    final query = select(bills);
    if (farmUuid != null) {
      query.where((tbl) => tbl.farmUuid.equals(farmUuid));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<Bill>> getUnsyncedBills() {
    return (select(bills)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<void> markBillsAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await (update(bills)..where((tbl) => tbl.uuid.isIn(uuids))).write(
      const BillsCompanion(
        synced: Value(true),
        syncAction: Value('server-update'),
      ),
    );
  }

  Future<int> deleteServerBillsNotIn(Set<String> uuids) {
    final query = delete(bills)
      ..where((tbl) {
        var condition = tbl.synced.equals(true) & tbl.syncAction.like('server%');
        if (uuids.isNotEmpty) {
          condition = condition & tbl.uuid.isNotIn(uuids.toList());
        }
        return condition;
      });
    return query.go();
  }

  Future<int> deleteBillByUuid(String uuid) {
    return (delete(bills)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }
}
