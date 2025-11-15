import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/domain/models/livestock_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/domain/repo/livestock_repo.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/data/mapper/livestock_mapper.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/data/repository/events_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/repo/events_repo.dart';
import 'dart:developer';

/// Repository for Livestocks data management
/// Implements the domain repository interface
class LivestockRepository implements LivestockRepo {
  final AppDatabase _database;
  late final EventsRepositoryInterface _eventsRepository;

  LivestockRepository(this._database) {
    _eventsRepository = EventsRepository(_database);
  }

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
      final List<String> serverUuids = [];

      // Process each livestock
      for (final json in livestockData) {
        try {
          final uuid = json['uuid'] as String?;
          if (uuid == null || uuid.isEmpty) {
            log('⚠️ Skipping livestock without UUID: $json');
            continue;
          }

          serverUuids.add(uuid);
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

      // Remove livestock that exist locally but were removed on the server
      await _database.livestockDao.deleteServerLivestockNotIn(serverUuids);
      
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

  /// Get all active livestock (excluding deleted ones)
  @override
  Future<List<Livestock>> getAllActiveLivestock() async {
    return await _database.livestockDao.getAllActiveLivestock();
  }

  /// Get livestock by ID
  @override
  Future<Livestock?> getLivestockById(int id) async {
    return await _database.livestockDao.getLivestockById(id);
  }

  /// Get livestock by UUID
  @override
  Future<Livestock?> getLivestockByUuid(String uuid) async {
    return await _database.livestockDao.getLivestockByUuid(uuid);
  }

  /// Get livestock by identification number
  @override
  Future<Livestock?> getLivestockByIdentificationNumber(String identificationNumber) async {
    return await _database.livestockDao.getLivestockByIdentificationNumber(identificationNumber);
  }

  /// Get active livestock by farm UUID (excluding deleted ones)
  @override
  Future<List<Livestock>> getActiveLivestockByFarmUuid(String farmUuid) async {
    return await _database.livestockDao.getActiveLivestockByFarmUuid(farmUuid);
  }

  /// Get livestock by farm UUID
  Future<List<Livestock>> getLivestockByFarmUuid(String farmUuid) async {
    return await _database.livestockDao.getLivestockByFarmUuid(farmUuid);
  }

  /// Search livestock by name
  Future<List<Livestock>> searchLivestockByName(String name) async {
    return await _database.livestockDao.searchLivestockByName(name);
  }

  /// Create livestock (stub implementation - to be implemented)
  @override
  Future<Livestock> createLivestock(Map<String, dynamic> livestockData) async {
    // TODO: Implement create livestock
    throw UnimplementedError('createLivestock not yet implemented');
  }

  /// Update livestock (stub implementation - to be implemented)
  @override
  Future<bool> updateLivestock(int id, Map<String, dynamic> livestockData) async {
    // TODO: Implement update livestock
    throw UnimplementedError('updateLivestock not yet implemented');
  }

  /// Get unsynced livestock for API submission
  /// 
  /// This method fetches all livestock that haven't been synced to the server yet
  /// and converts them to API-compatible JSON format (excluding local IDs).
  /// 
  /// **Returns:**
  /// - List of livestock data in API format (excludes local ID)
  /// 
  /// **Usage:**
  /// ```dart
  /// final unsyncedLivestock = await livestockRepository.getUnsyncedLivestockForApi();
  /// ```
  @override
  Future<List<Map<String, dynamic>>> getUnsyncedLivestockForApi() async {
    try {
      log('📤 Fetching unsynced livestock for API...');
      
      // Get all unsynced livestock from database
      final unsyncedLivestock = await _database.livestockDao.getUnsyncedLivestock();
      
      if (unsyncedLivestock.isEmpty) {
        log('✅ No unsynced livestock found');
        return [];
      }
      
      log('🔍 Processing ${unsyncedLivestock.length} unsynced livestock...');
      
      // Convert to LivestockModel and then to API JSON format
      final List<Map<String, dynamic>> apiData = [];
      
      for (final livestock in unsyncedLivestock) {
        try {
          // Debug: Print raw data from database
          final rawJson = livestock.toJson();
          log('🔍 Raw livestock data from DB: $rawJson');
          
          final livestockModel = LivestockMapper.livestockToEntity(rawJson);
          final apiJson = livestockModel.toApiJson();
          
          log('📤 API JSON for ${livestock.name}: $apiJson');
          apiData.add(apiJson);
        } catch (e, stackTrace) {
          log('❌ Error processing livestock ${livestock.name}: $e');
          log('Stack trace: $stackTrace');
          rethrow;
        }
      }
      
      log('✅ Found ${apiData.length} unsynced livestock');
      
      return apiData;
    } catch (e, stackTrace) {
      log('❌ Error fetching unsynced livestock: $e');
      log('Stack trace: $stackTrace');
      throw Exception('Failed to get unsynced livestock: $e');
    }
  }

  /// Mark a single livestock as deleted (soft delete)
  /// 
  /// Sets syncAction='deleted' and synced=false so it will be synced to server
  /// 
  /// **Parameters:**
  /// - `livestockId`: Local ID of the livestock to mark as deleted
  /// 
  /// **Returns:**
  /// - `true` if successful, `false` otherwise
  @override
  Future<bool> markLivestockAsDeleted(int livestockId) async {
    try {
      log('🗑️ Marking livestock as deleted: Livestock ID $livestockId');
      
      // Get the livestock first
      final livestock = await _database.livestockDao.getLivestockById(livestockId);
      
      if (livestock == null) {
        log('⚠️ Livestock not found: ID $livestockId');
        return false;
      }

      try {
        await _eventsRepository.markAllLogsForLivestockAsDeleted(livestock.uuid);
      } catch (e) {
        log('⚠️ Failed to mark logs as deleted for livestock ${livestock.uuid}: $e');
      }
      
      // Create updated livestock with syncAction='deleted'
      final updatedLivestock = Livestock(
        id: livestock.id,
        farmUuid: livestock.farmUuid,
        uuid: livestock.uuid,
        identificationNumber: livestock.identificationNumber,
        dummyTagId: livestock.dummyTagId,
        barcodeTagId: livestock.barcodeTagId,
        rfidTagId: livestock.rfidTagId,
        livestockTypeId: livestock.livestockTypeId,
        name: livestock.name,
        dateOfBirth: livestock.dateOfBirth,
        motherUuid: livestock.motherUuid,
        fatherUuid: livestock.fatherUuid,
        gender: livestock.gender,
        breedId: livestock.breedId,
        speciesId: livestock.speciesId,
        status: livestock.status,
        livestockObtainedMethodId: livestock.livestockObtainedMethodId,
        dateFirstEnteredToFarm: livestock.dateFirstEnteredToFarm,
        weightAsOnRegistration: livestock.weightAsOnRegistration,
        synced: false, // Mark as unsynced so it gets synced to server
        syncAction: 'deleted', // Mark sync action as deleted
        createdAt: livestock.createdAt,
        updatedAt: DateTime.now().toIso8601String(), // Update timestamp
      );
      
      // Update the livestock in database
      final success = await _database.livestockDao.updateLivestock(updatedLivestock);
      
      if (success) {
        log('✅ Livestock marked as deleted: ${livestock.name} (ID: $livestockId)');
      } else {
        log('⚠️ Failed to mark livestock as deleted: ID $livestockId');
      }
      
      return success;
    } catch (e) {
      log('❌ Error marking livestock as deleted: $e');
      return false;
    }
  }

  /// Mark all livestock belonging to a farm as deleted (soft delete)
  /// 
  /// Sets syncAction='deleted' and synced=false for all livestock with the given farmUuid
  /// 
  /// **Parameters:**
  /// - `farmUuid`: UUID of the farm whose livestock should be marked as deleted
  /// 
  /// **Returns:**
  /// - Number of livestock marked as deleted
  @override
  Future<int> markLivestockByFarmUuidAsDeleted(String farmUuid) async {
    try {
      log('🗑️ Marking all livestock as deleted for farm: $farmUuid');
      
      // Get all livestock for this farm
      final livestockList = await _database.livestockDao.getLivestockByFarmUuid(farmUuid);
      
      if (livestockList.isEmpty) {
        log('⚠️ No livestock found for farm: $farmUuid');
        return 0;
      }
      
      int deletedCount = 0;
      
      // Mark each livestock as deleted
      for (final livestock in livestockList) {
        final success = await markLivestockAsDeleted(livestock.id);
        if (success) deletedCount++;
      }
      
      log('✅ Marked $deletedCount livestock as deleted for farm: $farmUuid');
      return deletedCount;
    } catch (e) {
      log('❌ Error marking livestock as deleted for farm: $e');
      return 0;
    }
  }

  /// Mark livestock as synced by their UUIDs
  /// 
  /// This method updates the synced status of livestock after successful API submission.
  /// 
  /// **Parameters:**
  /// - `uuids`: List of livestock UUIDs that were successfully synced
  /// 
  /// **Returns:**
  /// - Number of livestock updated
  @override
  Future<int> markLivestockAsSynced(List<String> uuids) async {
    try {
      log('✅ Marking ${uuids.length} livestock as synced...');
      
      int updatedCount = 0;
      int deletedCount = 0;
      
      for (final uuid in uuids) {
        final livestock = await _database.livestockDao.getLivestockByUuid(uuid);
        
        if (livestock != null) {
          // If syncAction is 'deleted', actually delete the livestock from local DB
          if (livestock.syncAction == 'deleted') {
            final rowsDeleted = await _database.livestockDao.deleteLivestock(livestock.id);
            if (rowsDeleted > 0) {
              deletedCount++;
              log('  🗑️ Deleted livestock from local DB: ${livestock.name} (${uuid})');
            }
          } else {
            // Otherwise, just mark as synced
            String newSyncAction = livestock.syncAction;
            if (livestock.syncAction == 'create') {
              newSyncAction = 'server-create';
            } else if (livestock.syncAction == 'update') {
              newSyncAction = 'server-update';
            }

            final updatedLivestock = Livestock(
              id: livestock.id,
              farmUuid: livestock.farmUuid,
              uuid: livestock.uuid,
              identificationNumber: livestock.identificationNumber,
              dummyTagId: livestock.dummyTagId,
              barcodeTagId: livestock.barcodeTagId,
              rfidTagId: livestock.rfidTagId,
              livestockTypeId: livestock.livestockTypeId,
              name: livestock.name,
              dateOfBirth: livestock.dateOfBirth,
              motherUuid: livestock.motherUuid,
              fatherUuid: livestock.fatherUuid,
              gender: livestock.gender,
              breedId: livestock.breedId,
              speciesId: livestock.speciesId,
              status: livestock.status,
              livestockObtainedMethodId: livestock.livestockObtainedMethodId,
              dateFirstEnteredToFarm: livestock.dateFirstEnteredToFarm,
              weightAsOnRegistration: livestock.weightAsOnRegistration,
              synced: true, // Mark as synced
              syncAction: newSyncAction,
              createdAt: livestock.createdAt,
              updatedAt: livestock.updatedAt,
            );
            
            final success = await _database.livestockDao.updateLivestock(updatedLivestock);
            if (success) updatedCount++;
          }
        }
      }
      
      log('✅ Successfully marked $updatedCount livestock as synced');
      if (deletedCount > 0) {
        log('✅ Successfully deleted $deletedCount livestock from local DB');
      }
      return updatedCount + deletedCount;
    } catch (e) {
      log('❌ Error marking livestock as synced: $e');
      throw Exception('Failed to mark livestock as synced: $e');
    }
  }
}
