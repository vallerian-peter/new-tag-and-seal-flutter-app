import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestock_obtained_methods/domain/models/livestock_obtained_method_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestock_obtained_methods/data/mapper/livestock_obtained_method_mapper.dart';
import 'dart:developer';

/// Repository for Livestock Obtained Methods data management
class LivestockObtainedMethodRepository {
  final AppDatabase _database;

  LivestockObtainedMethodRepository(this._database);

  /// Sync livestock obtained methods data from provided data and store locally
  Future<void> syncAndStoreLocally(Map<String, dynamic> syncData) async {
    try {
      log('🔄 Syncing livestock obtained methods...');
      
      // Extract livestock obtained methods from livestockReferenceData
      final livestockReferenceData = syncData['livestockReferenceData'] ?? {};
      final List<dynamic> methodsData = livestockReferenceData['livestockObtainedMethods'] ?? [];
      
      if (methodsData.isEmpty) {
        log('⚠️ No livestock obtained methods data found - skipping');
        return;
      }

      final methods = methodsData
          .map((json) => LivestockObtainedMethodModel.fromJson(json))
          .toList();

      final methodCompanions = methods
          .map((method) => LivestockObtainedMethodMapper.livestockObtainedMethodToSql(method))
          .map((data) => LivestockObtainedMethodsCompanion.insert(
                id: Value(data['id'] as int),  // Use server-provided ID
                name: data['name'] ?? '',
              ))
          .toList();

      await _database.livestockObtainedMethodDao.insertLivestockObtainedMethods(methodCompanions);
      
      log('✅ Livestock obtained methods synced (${methods.length} records)');
      
    } catch (e) {
      log('❌ Error syncing livestock obtained methods: $e');
      throw Exception('Failed to sync livestock obtained methods: $e');
    }
  }

  /// Get all livestock obtained methods from local database
  Future<List<LivestockObtainedMethod>> getAllLivestockObtainedMethods() async {
    return await _database.livestockObtainedMethodDao.getAllLivestockObtainedMethods();
  }

  /// Get livestock obtained method by ID
  Future<LivestockObtainedMethod?> getLivestockObtainedMethodById(int id) async {
    return await _database.livestockObtainedMethodDao.getLivestockObtainedMethodById(id);
  }

  /// Search livestock obtained methods by name
  Future<List<LivestockObtainedMethod>> searchLivestockObtainedMethodsByName(String name) async {
    return await _database.livestockObtainedMethodDao.searchLivestockObtainedMethodsByName(name);
  }

  /// Clear all livestock obtained methods (for clean sync)
  Future<void> clearAllLivestockObtainedMethods() async {
    try {
      log('🗑️ Deleting all livestock obtained methods...');
      await _database.livestockObtainedMethodDao.deleteAllLivestockObtainedMethods();
      log('✅ All livestock obtained methods deleted');
    } catch (e) {
      log('❌ Error deleting livestock obtained methods: $e');
      throw Exception('Failed to delete livestock obtained methods: $e');
    }
  }
}
