import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../features/all.additional.data/data/local/tables/livestock_obtained_method_table.dart';

part 'livestock_obtained_method_dao.g.dart';

/// DAO for handling livestock obtained method-related data
@DriftAccessor(tables: [LivestockObtainedMethods])
class LivestockObtainedMethodDao extends DatabaseAccessor<AppDatabase> with _$LivestockObtainedMethodDaoMixin {
  LivestockObtainedMethodDao(AppDatabase db) : super(db);

  // ==================== LIVESTOCK OBTAINED METHOD CRUD OPERATIONS ====================

  /// Get all livestock obtained methods
  Future<List<LivestockObtainedMethod>> getAllLivestockObtainedMethods() => select(livestockObtainedMethods).get();

  /// Get livestock obtained method by ID
  Future<LivestockObtainedMethod?> getLivestockObtainedMethodById(int id) => 
      (select(livestockObtainedMethods)..where((lom) => lom.id.equals(id))).getSingleOrNull();

  /// Insert a new livestock obtained method
  Future<int> insertLivestockObtainedMethod(LivestockObtainedMethodsCompanion entry) => into(livestockObtainedMethods).insert(entry);

  /// Update a livestock obtained method
  Future<bool> updateLivestockObtainedMethod(LivestockObtainedMethod entry) => update(livestockObtainedMethods).replace(entry);

  /// Delete a livestock obtained method
  Future<int> deleteLivestockObtainedMethod(int id) => 
      (delete(livestockObtainedMethods)..where((lom) => lom.id.equals(id))).go();

  /// Delete all livestock obtained methods (for clean sync)
  Future<int> deleteAllLivestockObtainedMethods() => delete(livestockObtainedMethods).go();

  // ==================== BATCH OPERATIONS ====================

  /// Insert multiple livestock obtained methods at once
  Future<void> insertLivestockObtainedMethods(List<LivestockObtainedMethodsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(livestockObtainedMethods, entries, mode: InsertMode.insertOrReplace);
    });
  }

  // ==================== SEARCH OPERATIONS ====================

  /// Search livestock obtained methods by name
  Future<List<LivestockObtainedMethod>> searchLivestockObtainedMethodsByName(String name) => 
      (select(livestockObtainedMethods)..where((lom) => lom.name.like('%$name%'))).get();
}
