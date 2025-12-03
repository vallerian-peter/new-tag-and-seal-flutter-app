import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../features/farmUser/data/tables/farm_user_table.dart';

part 'farm_user_dao.g.dart';

@DriftAccessor(tables: [FarmUsers])
class FarmUserDao extends DatabaseAccessor<AppDatabase> with _$FarmUserDaoMixin {
  FarmUserDao(AppDatabase db) : super(db);

  Future<void> upsertFarmUsers(List<FarmUsersCompanion> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(farmUsers, entries);
    });
  }

  Future<FarmUser?> getFarmUserByUuid(String uuid) {
    return (select(farmUsers)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<List<FarmUser>> getFarmUsers({String? farmUuid}) {
    final query = select(farmUsers);
    
    if (farmUuid != null) {
      // Filter by farmUuid - handles both single UUID string and JSON array format
      // Using LIKE to match single UUID or JSON array containing the UUID
      query.where((tbl) => 
        tbl.farmUuid.equals(farmUuid) | // Exact match (single UUID)
        tbl.farmUuid.like('%$farmUuid%') // Partial match (JSON array)
      );
    }
    
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<List<FarmUser>> getUnsyncedFarmUsers() {
    return (select(farmUsers)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<void> markFarmUsersAsSynced(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await (update(farmUsers)..where((tbl) => tbl.uuid.isIn(uuids))).write(
      const FarmUsersCompanion(
        synced: Value(true),
        syncAction: Value('server-update'),
      ),
    );
  }

  Future<int> deleteServerFarmUsersNotIn(Set<String> uuids) {
    final query = delete(farmUsers)
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

  Future<int> deleteFarmUserByUuid(String uuid) {
    return (delete(farmUsers)..where((tbl) => tbl.uuid.equals(uuid))).go();
  }
}


