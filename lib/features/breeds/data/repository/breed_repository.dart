import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/breeds/domain/models/breed_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/breeds/data/mapper/breed_mapper.dart';
import 'dart:developer';

/// Repository for Breeds data management
class BreedRepository {
  final AppDatabase _database;

  BreedRepository(this._database);

  /// Sync breeds data from provided data and store locally
  Future<void> syncAndStoreLocally(Map<String, dynamic> syncData) async {
    try {
      log('🔄 Syncing breeds...');
      
      // Extract breeds from livestockReferenceData
      final livestockReferenceData = syncData['livestockReferenceData'] ?? {};
      final List<dynamic> breedsData = livestockReferenceData['breeds'] ?? [];
      
      if (breedsData.isEmpty) {
        log('⚠️ No breeds data found - skipping');
        return;
      }

      final breeds = breedsData
          .map((json) => BreedModel.fromJson(json))
          .toList();

      final breedCompanions = breeds
          .map((breed) => BreedMapper.breedToSql(breed))
          .map((data) => BreedsCompanion.insert(
                id: Value(data['id'] as int),  // Use server-provided ID
                name: data['name'] ?? '',
                group: data['group'] ?? '',
                livestockTypeId: data['livestockTypeId'] ?? 0,
              ))
          .toList();

      await _database.breedDao.insertBreeds(breedCompanions);
      
      log('✅ Breeds synced (${breeds.length} records)');
      
    } catch (e) {
      log('❌ Error syncing breeds: $e');
      throw Exception('Failed to sync breeds: $e');
    }
  }

  /// Get all breeds from local database
  Future<List<Breed>> getAllBreeds() async {
    return await _database.breedDao.getAllBreeds();
  }

  /// Get breed by ID
  Future<Breed?> getBreedById(int id) async {
    return await _database.breedDao.getBreedById(id);
  }

  /// Get breeds by livestock type ID
  Future<List<Breed>> getBreedsByLivestockTypeId(int livestockTypeId) async {
    return await _database.breedDao.getBreedsByLivestockTypeId(livestockTypeId);
  }

  /// Search breeds by name
  Future<List<Breed>> searchBreedsByName(String name) async {
    return await _database.breedDao.searchBreedsByName(name);
  }

  /// Clear all breeds (for clean sync)
  Future<void> clearAllBreeds() async {
    try {
      log('🗑️ Deleting all breeds...');
      await _database.breedDao.deleteAllBreeds();
      log('✅ All breeds deleted');
    } catch (e) {
      log('❌ Error deleting breeds: $e');
      throw Exception('Failed to delete breeds: $e');
    }
  }
}
