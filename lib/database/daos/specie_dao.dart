import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../features/all.additional.data/data/local/tables/specie_table.dart';

part 'specie_dao.g.dart';

/// DAO for handling specie-related data
@DriftAccessor(tables: [Species])
class SpecieDao extends DatabaseAccessor<AppDatabase> with _$SpecieDaoMixin {
  SpecieDao(AppDatabase db) : super(db);

  // ==================== SPECIE CRUD OPERATIONS ====================

  /// Get all species
  Future<List<Specie>> getAllSpecies() => select(species).get();

  /// Get specie by ID
  Future<Specie?> getSpecieById(int id) => 
      (select(species)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Insert a new specie
  Future<int> insertSpecie(SpeciesCompanion entry) => into(species).insert(entry);

  /// Update a specie
  Future<bool> updateSpecie(Specie entry) => update(species).replace(entry);

  /// Delete a specie
  Future<int> deleteSpecie(int id) => 
      (delete(species)..where((s) => s.id.equals(id))).go();

  /// Delete all species (for clean sync)
  Future<int> deleteAllSpecies() => delete(species).go();

  // ==================== BATCH OPERATIONS ====================

  /// Insert multiple species at once
  Future<void> insertSpecies(List<SpeciesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(species, entries, mode: InsertMode.insertOrReplace);
    });
  }

  // ==================== SEARCH OPERATIONS ====================

  /// Search species by name
  Future<List<Specie>> searchSpeciesByName(String name) => 
      (select(species)..where((s) => s.name.like('%$name%'))).get();
}
