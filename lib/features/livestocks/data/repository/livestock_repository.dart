import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/domain/models/livestock_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/data/mapper/livestock_mapper.dart';
import 'dart:developer';

/// Repository for Livestocks data management
class LivestockRepository {
  final AppDatabase _database;

  LivestockRepository(this._database);

  /// Sync livestock data from provided data and store locally
  /// 
  /// **Strategy:**
  /// - If livestock doesn't exist → INSERT
  /// - If livestock exists but server data is newer → UPDATE
  /// - If livestock exists and local data is newer or same → SKIP
  Future<void> syncAndStoreLocally(Map<String, dynamic> syncData) async {
    try {
      log('🔄 Syncing livestock...');
      
      // Extract livestock data from user-specific data
      final userSpecificData = syncData['userSpecificData'] ?? {};
      final List<dynamic> livestockData = userSpecificData['livestock'] ?? [];
      
      if (livestockData.isEmpty) {
        log('⚠️ No livestock data found in sync response');
        return;
      }

      int inserted = 0;
      int updated = 0;
      int skipped = 0;

      // Process each livestock
      for (final json in livestockData) {
        try {
          final livestockItem = LivestockModel.fromJson(json);
          
          // Check if livestock already exists by UUID
          final existingLivestock = await _database.livestockDao.getLivestockByUuid(livestockItem.uuid);
          
          if (existingLivestock == null) {
            // INSERT: Livestock doesn't exist locally
            await _insertLivestock(livestockItem);
            inserted++;
            log('  ✅ Inserted: ${livestockItem.name} (${livestockItem.uuid})');
            
          } else {
            // Compare timestamps to decide: UPDATE or SKIP
            final serverUpdatedAt = DateTime.parse(livestockItem.updatedAt);
            final localUpdatedAt = DateTime.parse(existingLivestock.updatedAt);
            
            if (serverUpdatedAt.isAfter(localUpdatedAt)) {
              // UPDATE: Server data is newer
              await _updateLivestock(existingLivestock.id, livestockItem);
              updated++;
              log('  🔄 Updated: ${livestockItem.name} (server newer)');
              
            } else {
              // SKIP: Local data is same or newer
              skipped++;
              log('  ⏭️ Skipped: ${livestockItem.name} (local is current)');
            }
          }
          
        } catch (e) {
          log('❌ Error processing livestock: $e');
        }
      }
      
      log('✅ Livestock sync complete - Inserted: $inserted, Updated: $updated, Skipped: $skipped');
      
    } catch (e) {
      log('❌ Error syncing livestock: $e');
      throw Exception('Failed to sync livestock: $e');
    }
  }

  /// Insert new livestock from server
  Future<void> _insertLivestock(LivestockModel livestockItem) async {
    final livestockData = LivestockMapper.livestockToSql(livestockItem);
    
    await _database.livestockDao.insertLivestock(LivestocksCompanion.insert(
      farmUuid: livestockData['farmUuid'] as String,  // Farm UUID
      uuid: livestockData['uuid'] as String,
      identificationNumber: livestockData['identificationNumber'] as String,
      dummyTagId: livestockData['dummyTagId'] as String,
      barcodeTagId: livestockData['barcodeTagId'] as String,
      rfidTagId: livestockData['rfidTagId'] as String,
      livestockTypeId: livestockData['livestockTypeId'] as int,
      name: livestockData['name'] as String,
      dateOfBirth: livestockData['dateOfBirth'] as String,
      motherUuid: Value(livestockData['motherUuid'] as String?),  // Mother UUID
      fatherUuid: Value(livestockData['fatherUuid'] as String?),  // Father UUID
      gender: livestockData['gender'] as String,
      breedId: livestockData['breedId'] as int,
      speciesId: livestockData['speciesId'] as int,
      status: Value(livestockData['status'] as String),
      livestockObtainedMethodId: livestockData['livestockObtainedMethodId'] as int,
      dateFirstEnteredToFarm: DateTime.parse(livestockData['dateFirstEnteredToFarm'] as String),
      weightAsOnRegistration: livestockData['weightAsOnRegistration'] as double,
      synced: const Value(true),
      syncAction: const Value('server-create'),
      createdAt: livestockData['createdAt'] as String,
      updatedAt: livestockData['updatedAt'] as String,
    ));
  }

  /// Update existing livestock with server data
  Future<void> _updateLivestock(int id, LivestockModel livestockItem) async {
    final livestockData = LivestockMapper.livestockToSql(livestockItem);
    
    // Create updated Livestock object (data class, not companion)
    final updatedLivestock = Livestock(
      id: id,
      farmUuid: livestockData['farmUuid'] as String,  // Farm UUID
      uuid: livestockData['uuid'] as String,
      identificationNumber: livestockData['identificationNumber'] as String,
      dummyTagId: livestockData['dummyTagId'] as String,
      barcodeTagId: livestockData['barcodeTagId'] as String,
      rfidTagId: livestockData['rfidTagId'] as String,
      livestockTypeId: livestockData['livestockTypeId'] as int,
      name: livestockData['name'] as String,
      dateOfBirth: livestockData['dateOfBirth'] as String,
      motherUuid: livestockData['motherUuid'] as String?,  // Mother UUID
      fatherUuid: livestockData['fatherUuid'] as String?,  // Father UUID
      gender: livestockData['gender'] as String,
      breedId: livestockData['breedId'] as int,
      speciesId: livestockData['speciesId'] as int,
      status: livestockData['status'] as String,
      livestockObtainedMethodId: livestockData['livestockObtainedMethodId'] as int,
      dateFirstEnteredToFarm: DateTime.parse(livestockData['dateFirstEnteredToFarm'] as String),
      weightAsOnRegistration: livestockData['weightAsOnRegistration'] as double,
      synced: true,
      syncAction: 'server-update',
      createdAt: livestockData['createdAt'] as String,
      updatedAt: livestockData['updatedAt'] as String,
    );
    
    await _database.livestockDao.updateLivestock(updatedLivestock);
  }

  /// Get all livestock from local database
  Future<List<Livestock>> getAllLivestock() async {
    return await _database.livestockDao.getAllLivestock();
  }

  /// Get livestock by ID
  Future<Livestock?> getLivestockById(int id) async {
    return await _database.livestockDao.getLivestockById(id);
  }

  /// Get livestock by farm UUID
  Future<List<Livestock>> getLivestockByFarmUuid(String farmUuid) async {
    return await _database.livestockDao.getLivestockByFarmUuid(farmUuid);
  }

  /// Search livestock by name
  Future<List<Livestock>> searchLivestockByName(String name) async {
    return await _database.livestockDao.searchLivestockByName(name);
  }

}
