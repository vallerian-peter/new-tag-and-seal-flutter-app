import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../features/livestock_types/data/tables/livestock_type_table.dart';

part 'livestock_type_dao.g.dart';

/// DAO for handling livestock type-related data
@DriftAccessor(tables: [LivestockTypes])
class LivestockTypeDao extends DatabaseAccessor<AppDatabase> with _$LivestockTypeDaoMixin {
  LivestockTypeDao(AppDatabase db) : super(db);

  // ==================== LIVESTOCK TYPE CRUD OPERATIONS ====================

  /// Get all livestock types
  Future<List<LivestockType>> getAllLivestockTypes() => select(livestockTypes).get();

  /// Get livestock type by ID
  Future<LivestockType?> getLivestockTypeById(int id) => 
      (select(livestockTypes)..where((lt) => lt.id.equals(id))).getSingleOrNull();

  /// Insert a new livestock type
  Future<int> insertLivestockType(LivestockTypesCompanion entry) => into(livestockTypes).insert(entry);

  /// Update a livestock type
  Future<bool> updateLivestockType(LivestockType entry) => update(livestockTypes).replace(entry);

  /// Delete a livestock type
  Future<int> deleteLivestockType(int id) => 
      (delete(livestockTypes)..where((lt) => lt.id.equals(id))).go();

  /// Delete all livestock types (for clean sync)
  Future<int> deleteAllLivestockTypes() => delete(livestockTypes).go();

  // ==================== BATCH OPERATIONS ====================

  /// Insert multiple livestock types at once
  Future<void> insertLivestockTypes(List<LivestockTypesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(livestockTypes, entries, mode: InsertMode.insertOrReplace);
    });
  }

  // ==================== SEARCH OPERATIONS ====================

  /// Search livestock types by name
  Future<List<LivestockType>> searchLivestockTypesByName(String name) => 
      (select(livestockTypes)..where((lt) => lt.name.like('%$name%'))).get();
}
