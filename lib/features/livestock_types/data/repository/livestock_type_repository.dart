import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestock_types/domain/models/livestock_type_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestock_types/data/mapper/livestock_type_mapper.dart';
import 'dart:developer';

/// Repository for Livestock Types data management
class LivestockTypeRepository {
  final AppDatabase _database;

  LivestockTypeRepository(this._database);

  /// Sync livestock types data from provided data and store locally
  Future<void> syncAndStoreLocally(Map<String, dynamic> syncData) async {
    try {
      log('🔄 Syncing livestock types...');
      
      // Extract livestock types from livestockReferenceData
      final livestockReferenceData = syncData['livestockReferenceData'] ?? {};
      final List<dynamic> livestockTypesData = livestockReferenceData['livestockTypes'] ?? [];
      
      if (livestockTypesData.isEmpty) {
        log('⚠️ No livestock types data found - skipping');
        return;
      }

      final livestockTypes = livestockTypesData
          .map((json) => LivestockTypeModel.fromJson(json))
          .toList();

      final livestockTypeCompanions = livestockTypes
          .map((type) => LivestockTypeMapper.livestockTypeToSql(type))
          .map((data) => LivestockTypesCompanion.insert(
                id: Value(data['id'] as int),  // Use server-provided ID
                name: data['name'] ?? '',
              ))
          .toList();

      await _database.livestockTypeDao.insertLivestockTypes(livestockTypeCompanions);
      
      log('✅ Livestock types synced (${livestockTypes.length} records)');
      
    } catch (e) {
      log('❌ Error syncing livestock types: $e');
      throw Exception('Failed to sync livestock types: $e');
    }
  }

  /// Get all livestock types from local database
  Future<List<LivestockType>> getAllLivestockTypes() async {
    return await _database.livestockTypeDao.getAllLivestockTypes();
  }

  /// Get livestock type by ID
  Future<LivestockType?> getLivestockTypeById(int id) async {
    return await _database.livestockTypeDao.getLivestockTypeById(id);
  }

  /// Search livestock types by name
  Future<List<LivestockType>> searchLivestockTypesByName(String name) async {
    return await _database.livestockTypeDao.searchLivestockTypesByName(name);
  }

  /// Clear all livestock types (for clean sync)
  Future<void> clearAllLivestockTypes() async {
    try {
      log('🗑️ Deleting all livestock types...');
      await _database.livestockTypeDao.deleteAllLivestockTypes();
      log('✅ All livestock types deleted');
    } catch (e) {
      log('❌ Error deleting livestock types: $e');
      throw Exception('Failed to delete livestock types: $e');
    }
  }
}
