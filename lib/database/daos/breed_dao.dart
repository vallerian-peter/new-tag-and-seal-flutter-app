import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../features/breeds/data/tables/breed_table.dart';
import '../../features/livestock_types/data/tables/livestock_type_table.dart';

part 'breed_dao.g.dart';

/// DAO for handling breed-related data with livestock type relationships
@DriftAccessor(tables: [Breeds, LivestockTypes])
class BreedDao extends DatabaseAccessor<AppDatabase> with _$BreedDaoMixin {
  BreedDao(AppDatabase db) : super(db);

  // ==================== BREED CRUD OPERATIONS ====================

  /// Get all breeds
  Future<List<Breed>> getAllBreeds() => select(breeds).get();

  /// Get breed by ID
  Future<Breed?> getBreedById(int id) => 
      (select(breeds)..where((b) => b.id.equals(id))).getSingleOrNull();

  /// Insert a new breed
  Future<int> insertBreed(BreedsCompanion entry) => into(breeds).insert(entry);

  /// Update a breed
  Future<bool> updateBreed(Breed entry) => update(breeds).replace(entry);

  /// Delete a breed
  Future<int> deleteBreed(int id) => 
      (delete(breeds)..where((b) => b.id.equals(id))).go();

  /// Delete all breeds (for clean sync)
  Future<int> deleteAllBreeds() => delete(breeds).go();

  /// Get breeds by livestock type ID
  Future<List<Breed>> getBreedsByLivestockTypeId(int livestockTypeId) => 
      (select(breeds)..where((b) => b.livestockTypeId.equals(livestockTypeId))).get();

  // ==================== BATCH OPERATIONS ====================

  /// Insert multiple breeds at once
  Future<void> insertBreeds(List<BreedsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(breeds, entries, mode: InsertMode.insertOrReplace);
    });
  }

  // ==================== SEARCH OPERATIONS ====================

  /// Search breeds by name
  Future<List<Breed>> searchBreedsByName(String name) => 
      (select(breeds)..where((b) => b.name.like('%$name%'))).get();

  /// Search breeds by group
  Future<List<Breed>> searchBreedsByGroup(String group) => 
      (select(breeds)..where((b) => b.group.like('%$group%'))).get();

  /// Search breeds by livestock type
  Future<List<Breed>> searchBreedsByLivestockType(int livestockTypeId) => 
      (select(breeds)..where((b) => b.livestockTypeId.equals(livestockTypeId))).get();
}
