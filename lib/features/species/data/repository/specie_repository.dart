import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/species/domain/models/specie_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/species/data/mapper/specie_mapper.dart';
import 'dart:developer';

/// Repository for Species data management
class SpecieRepository {
  final AppDatabase _database;

  SpecieRepository(this._database);

  /// Sync species data from provided data and store locally
  Future<void> syncAndStoreLocally(Map<String, dynamic> syncData) async {
    try {
      log('🔄 Syncing species...');
      
      // Extract species from livestockReferenceData
      final livestockReferenceData = syncData['livestockReferenceData'] ?? {};
      final List<dynamic> speciesData = livestockReferenceData['species'] ?? [];
      
      if (speciesData.isEmpty) {
        log('⚠️ No species data found - skipping');
        return;
      }

      final species = speciesData
          .map((json) => SpecieModel.fromJson(json))
          .toList();

      final specieCompanions = species
          .map((specie) => SpecieMapper.specieToSql(specie))
          .map((data) => SpeciesCompanion.insert(
                id: Value(data['id'] as int),  // Use server-provided ID
                name: data['name'] ?? '',
              ))
          .toList();

      await _database.specieDao.insertSpecies(specieCompanions);
      
      log('✅ Species synced (${species.length} records)');
      
    } catch (e) {
      log('❌ Error syncing species: $e');
      throw Exception('Failed to sync species: $e');
    }
  }

  /// Get all species from local database
  Future<List<Specie>> getAllSpecies() async {
    return await _database.specieDao.getAllSpecies();
  }

  /// Get species by ID
  Future<Specie?> getSpecieById(int id) async {
    return await _database.specieDao.getSpecieById(id);
  }

  /// Search species by name
  Future<List<Specie>> searchSpeciesByName(String name) async {
    return await _database.specieDao.searchSpeciesByName(name);
  }

  /// Clear all species (for clean sync)
  Future<void> clearAllSpecies() async {
    try {
      log('🗑️ Deleting all species...');
      await _database.specieDao.deleteAllSpecies();
      log('✅ All species deleted');
    } catch (e) {
      log('❌ Error deleting species: $e');
      throw Exception('Failed to delete species: $e');
    }
  }
}
