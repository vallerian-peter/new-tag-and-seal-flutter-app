import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/domain/models/farm_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/domain/repo/farm_repo.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/data/mapper/farm_mapper.dart';
import 'dart:developer';

/// Repository for Farms data management
/// 
/// Implements FarmRepositoryInterface to provide concrete implementation
/// of farm data operations including local storage and server sync.
class FarmRepository implements FarmRepositoryInterface {
  final AppDatabase _database;

  FarmRepository(this._database);

  /// Sync farms data from provided data and store locally
  /// 
  /// **Strategy:**
  /// - If farm doesn't exist → INSERT
  /// - If farm exists but server data is newer → UPDATE
  /// - If farm exists and local data is newer or same → SKIP
  @override
  Future<void> syncAndStoreLocally(Map<String, dynamic> syncData) async {
    try {
      log('🔄 Syncing farms...');
      
      // Extract farms data from user-specific data
      final userSpecificData = syncData['userSpecificData'] ?? {};
      final List<dynamic> farmsData = userSpecificData['farms'] ?? [];
      
      if (farmsData.isEmpty) {
        log('⚠️ No farms data found in sync response');
        return;
      }

      int inserted = 0;
      int updated = 0;
      int skipped = 0;

      // Process each farm
      for (final json in farmsData) {
        try {
          final farm = FarmModel.fromJson(json);
          
          // Check if farm already exists by UUID
          final existingFarm = await _database.farmDao.getFarmByUuid(farm.uuid);
          
          if (existingFarm == null) {
            // INSERT: Farm doesn't exist locally
            await _insertFarm(farm);
            inserted++;
            log('  ✅ Inserted: ${farm.name} (${farm.uuid})');
            
          } else {
            // Compare timestamps to decide: UPDATE or SKIP
            final serverUpdatedAt = DateTime.parse(farm.updatedAt);
            final localUpdatedAt = DateTime.parse(existingFarm.updatedAt);
            
            if (serverUpdatedAt.isAfter(localUpdatedAt)) {
              // UPDATE: Server data is newer
              await _updateFarm(existingFarm.id, farm);
              updated++;
              log('  🔄 Updated: ${farm.name} (server newer)');
              
            } else {
              // SKIP: Local data is same or newer
              skipped++;
              log('  ⏭️ Skipped: ${farm.name} (local is current)');
            }
          }
          
        } catch (e) {
          log('❌ Error processing farm: $e');
        }
      }
      
      log('✅ Farm sync complete - Inserted: $inserted, Updated: $updated, Skipped: $skipped');
      
    } catch (e) {
      log('❌ Error syncing farms: $e');
      throw Exception('Failed to sync farms: $e');
    }
  }

  /// Insert new farm from server
  Future<void> _insertFarm(FarmModel farm) async {
    final farmData = FarmMapper.farmToSql(farm);
    
    await _database.farmDao.insertFarm(FarmsCompanion.insert(
      farmerId: farmData['farmerId'] as int,
      uuid: farmData['uuid'] as String,
      referenceNo: farmData['referenceNo'] as String,
      regionalRegNo: farmData['regionalRegNo'] as String,
      name: farmData['name'] as String,
      size: farmData['size'] as String,  // Changed to String
      sizeUnit: farmData['sizeUnit'] as String,
      latitudes: farmData['latitudes'] as String,  // Changed to String
      longitudes: farmData['longitudes'] as String,  // Changed to String
      physicalAddress: farmData['physicalAddress'] as String,
      villageId: Value(farmData['villageId'] as int?),
      wardId: farmData['wardId'] as int,
      districtId: farmData['districtId'] as int,
      regionId: farmData['regionId'] as int,
      countryId: farmData['countryId'] as int,
      legalStatusId: farmData['legalStatusId'] as int,
      status: Value(farmData['status'] as String),
      synced: const Value(true),
      syncAction: const Value('server-create'),
      createdAt: farmData['createdAt'] as String,
      updatedAt: farmData['updatedAt'] as String,
    ));
  }

  /// Update existing farm with server data
  Future<void> _updateFarm(int id, FarmModel farm) async {
    final farmData = FarmMapper.farmToSql(farm);
    
    // Create updated Farm object (data class, not companion)
    final updatedFarm = Farm(
      id: id,
      farmerId: farmData['farmerId'] as int,
      uuid: farmData['uuid'] as String,
      referenceNo: farmData['referenceNo'] as String,
      regionalRegNo: farmData['regionalRegNo'] as String,
      name: farmData['name'] as String,
      size: farmData['size'] as String,  // Changed to String
      sizeUnit: farmData['sizeUnit'] as String,
      latitudes: farmData['latitudes'] as String,  // Changed to String
      longitudes: farmData['longitudes'] as String,  // Changed to String
      physicalAddress: farmData['physicalAddress'] as String,
      villageId: farmData['villageId'] as int?,
      wardId: farmData['wardId'] as int,
      districtId: farmData['districtId'] as int,
      regionId: farmData['regionId'] as int,
      countryId: farmData['countryId'] as int,
      legalStatusId: farmData['legalStatusId'] as int,
      status: farmData['status'] as String,
      synced: true,
      syncAction: 'server-update',
      createdAt: farmData['createdAt'] as String,
      updatedAt: farmData['updatedAt'] as String,
    );
    
    await _database.farmDao.updateFarm(updatedFarm);
  }

  /// Get all farms from local database
  @override
  Future<List<Farm>> getAllFarms() async {
    return await _database.farmDao.getAllFarms();
  }

  /// Get farm by ID
  @override
  Future<Farm?> getFarmById(int id) async {
    return await _database.farmDao.getFarmById(id);
  }

  /// Get farms by farmer ID
  @override
  Future<List<Farm>> getFarmsByFarmerId(int farmerId) async {
    return await _database.farmDao.getFarmsByFarmerId(farmerId);
  }

  /// Search farms by name
  @override
  Future<List<Farm>> searchFarmsByName(String name) async {
    return await _database.farmDao.searchFarmsByName(name);
  }

  /// Get farm with livestock by farm ID
  @override
  Future<Map<String, dynamic>?> getFarmWithLivestock(int farmId) async {
    try {
      log('🔍 Fetching farm with livestock: Farm ID $farmId');
      
      // Get farm data
      final farm = await _database.farmDao.getFarmById(farmId);
      if (farm == null) {
        log('⚠️ Farm not found: $farmId');
        return null;
      }
      
      // Get livestock for this farm using farm UUID
      final livestockList = await _database.livestockDao.getLivestockByFarmUuid(farm.uuid);
      
      log('✅ Found farm "${farm.name}" with ${livestockList.length} livestock');
      
      return {
        'farm': farm,
        'livestock': livestockList,
        'livestockCount': livestockList.length,
      };
    } catch (e) {
      log('❌ Error fetching farm with livestock: $e');
      rethrow;
    }
  }

  /// Get all farms with their livestock (excluding deleted farms)
  @override
  Future<List<Map<String, dynamic>>> getAllFarmsWithLivestock() async {
    try {
      log('🔍 Fetching all active farms with livestock...');
      
      // Get all farms excluding deleted ones
      final farms = await _database.farmDao.getAllActiveFarms();
      
      // For each farm, get its livestock
      final List<Map<String, dynamic>> farmsWithLivestock = [];
      
      for (final farm in farms) {
        final livestockList = await _database.livestockDao.getLivestockByFarmUuid(farm.uuid);
        
        farmsWithLivestock.add({
          'farm': farm,
          'livestock': livestockList,
          'livestockCount': livestockList.length,
        });
      }
      
      log('✅ Found ${farms.length} active farms with total ${farmsWithLivestock.fold<int>(0, (sum, item) => sum + (item['livestockCount'] as int))} livestock');
      
      return farmsWithLivestock;
    } catch (e) {
      log('❌ Error fetching all farms with livestock: $e');
      rethrow;
    }
  }

  /// Create a new farm locally (for offline-first app)
  /// 
  /// This method creates a farm in the local database with sync flag set to false.
  /// The farm will be synced to the server later when connection is available.
  /// 
  /// **Parameters:**
  /// - `farmData`: Map containing farm data (from form)
  /// 
  /// **Returns:**
  /// - The created Farm object
  /// 
  /// **Throws:**
  /// - Exception if farm creation fails
  @override
  Future<Farm> createFarmLocally(Map<String, dynamic> farmData) async {
    try {
      log('📝 Creating farm locally: ${farmData['name']}');
      
      // Get farmer ID from secure storage
      const secureStorage = FlutterSecureStorage();
      final farmerIdStr = await secureStorage.read(key: 'userId') ?? '0';
      final farmerId = int.tryParse(farmerIdStr) ?? 0;
      
      if (farmerId == 0) {
        throw Exception('Farmer ID not found. Please login again.');
      }
      
      // Generate timestamps
      final now = DateTime.now().toIso8601String();
      
      // Prepare farm companion for insertion
      final farmCompanion = FarmsCompanion.insert(
        farmerId: farmerId,
        uuid: farmData['uuid'] as String,
        referenceNo: farmData['referenceNo'] as String,
        regionalRegNo: farmData['regionalRegNo'] as String,
        name: farmData['name'] as String,
        size: farmData['size'] as String,  // Changed to String
        sizeUnit: farmData['sizeUnit'] as String,
        latitudes: farmData['latitudes'] as String,  // Changed to String
        longitudes: farmData['longitudes'] as String,  // Changed to String
        physicalAddress: farmData['physicalAddress'] as String,
        villageId: Value(farmData['villageId'] as int?),
        wardId: farmData['wardId'] as int,
        districtId: farmData['districtId'] as int,
        regionId: farmData['regionId'] as int,
        countryId: farmData['countryId'] as int,
        legalStatusId: farmData['legalStatusId'] as int,
        status: Value(farmData['status'] as String? ?? 'active'),
        synced: const Value(false),  // Not synced yet
        syncAction: const Value('create'),  // Pending creation
        createdAt: now,
        updatedAt: now,
      );
      
      // Insert farm
      final farmId = await _database.farmDao.insertFarm(farmCompanion);
      
      // Fetch and return the created farm
      final createdFarm = await _database.farmDao.getFarmById(farmId);
      
      if (createdFarm == null) {
        throw Exception('Failed to retrieve created farm');
      }
      
      log('✅ Farm created locally: ${createdFarm.name} (ID: $farmId)');
      
      return createdFarm;
    } catch (e) {
      log('❌ Error creating farm locally: $e');
      throw Exception('Failed to create farm: $e');
    }
  }

  /// Mark farm as deleted (soft delete)
  @override
  Future<bool> markFarmAsDeleted(int farmId) async {
    try {
      log('🗑️ Marking farm as deleted: Farm ID $farmId');
      
      // Get the farm first
      final farm = await _database.farmDao.getFarmById(farmId);
      
      if (farm == null) {
        log('⚠️ Farm not found: ID $farmId');
        return false;
      }
      
      // Create updated farm with syncAction='deleted'
      final updatedFarm = Farm(
        id: farm.id,
        farmerId: farm.farmerId,
        uuid: farm.uuid,
        referenceNo: farm.referenceNo,
        regionalRegNo: farm.regionalRegNo,
        name: farm.name,
        size: farm.size,  // Already String
        sizeUnit: farm.sizeUnit,
        latitudes: farm.latitudes,  // Already String
        longitudes: farm.longitudes,  // Already String
        physicalAddress: farm.physicalAddress,
        villageId: farm.villageId,
        wardId: farm.wardId,
        districtId: farm.districtId,
        regionId: farm.regionId,
        countryId: farm.countryId,
        legalStatusId: farm.legalStatusId,
        status: farm.status,
        synced: false, // Mark as unsynced so it gets synced to server
        syncAction: 'deleted', // Mark sync action as deleted
        createdAt: farm.createdAt,
        updatedAt: DateTime.now().toIso8601String(), // Update timestamp
      );
      
      // Update the farm in database
      final success = await _database.farmDao.updateFarm(updatedFarm);
      
      if (success) {
        log('✅ Farm marked as deleted: ${farm.name} (ID: $farmId)');
      } else {
        log('⚠️ Failed to mark farm as deleted: ID $farmId');
      }
      
      return success;
    } catch (e) {
      log('❌ Error marking farm as deleted: $e');
      return false;
    }
  }

  /// Update a farm
  @override
  Future<Farm> updateFarm(int farmId, Map<String, dynamic> farmData, {String? syncAction, bool? synced}) async {
    try {
      log('✏️ Updating farm: Farm ID $farmId');
      
      // Get the farm first
      final farm = await _database.farmDao.getFarmById(farmId);
      
      if (farm == null) {
        throw Exception('Farm not found: ID $farmId');
      }
      
      // Create updated farm with new data from farmData map
      final updatedFarm = Farm(
        id: farm.id,
        farmerId: farmData['farmerId'] as int? ?? farm.farmerId,
        uuid: farmData['uuid'] as String? ?? farm.uuid,
        referenceNo: farmData['referenceNo'] as String? ?? farm.referenceNo,
        regionalRegNo: farmData['regionalRegNo'] as String? ?? farm.regionalRegNo,
        name: farmData['name'] as String? ?? farm.name,
        size: farmData['size'] as String? ?? farm.size,  // Changed to String
        sizeUnit: farmData['sizeUnit'] as String? ?? farm.sizeUnit,
        latitudes: farmData['latitudes'] as String? ?? farm.latitudes,  // Changed to String
        longitudes: farmData['longitudes'] as String? ?? farm.longitudes,  // Changed to String
        physicalAddress: farmData['physicalAddress'] as String? ?? farm.physicalAddress,
        villageId: farmData['villageId'] as int? ?? farm.villageId,
        wardId: farmData['wardId'] as int? ?? farm.wardId,
        districtId: farmData['districtId'] as int? ?? farm.districtId,
        regionId: farmData['regionId'] as int? ?? farm.regionId,
        countryId: farmData['countryId'] as int? ?? farm.countryId,
        legalStatusId: farmData['legalStatusId'] as int? ?? farm.legalStatusId,
        status: farmData['status'] as String? ?? farm.status,
        synced: synced ?? false, // Use provided synced value or default to false
        syncAction: syncAction ?? 'update', // Use provided syncAction or default to 'update'
        createdAt: farm.createdAt, // Keep original creation time
        updatedAt: DateTime.now().toIso8601String(), // Update timestamp
      );
      
      // Update the farm in database
      final success = await _database.farmDao.updateFarm(updatedFarm);
      
      if (!success) {
        throw Exception('Failed to update farm in database');
      }
      
      // Fetch and return the updated farm
      final result = await _database.farmDao.getFarmById(farmId);
      
      if (result == null) {
        throw Exception('Failed to retrieve updated farm');
      }
      
      log('✅ Farm updated: ${result.name} (ID: $farmId)');
      
      return result;
    } catch (e) {
      log('❌ Error updating farm: $e');
      throw Exception('Failed to update farm: $e');
    }
  }

  /// Get unsynced farms formatted for API submission
  /// 
  /// Returns a list of farms where synced=false, formatted for API consumption.
  /// This method is used during sync operations to send local changes to the server.
  /// 
  /// **Returns:**
  /// - List of farm data in API format (excludes local ID)
  /// 
  /// **Usage:**
  /// ```dart
  /// final unsyncedFarms = await farmRepository.getUnsyncedFarmsForApi();
  /// ```
  Future<List<Map<String, dynamic>>> getUnsyncedFarmsForApi() async {
    try {
      log('📤 Fetching unsynced farms for API...');
      
      // Get all unsynced farms from database
      final unsyncedFarms = await _database.farmDao.getUnsyncedFarms();
      
      if (unsyncedFarms.isEmpty) {
        log('✅ No unsynced farms found');
        return [];
      }
      
      // Convert to FarmModel and then to API JSON format
      final List<Map<String, dynamic>> apiData = [];
      
      for (final farm in unsyncedFarms) {
        final farmModel = FarmMapper.farmToEntity(farm.toJson());
        apiData.add(farmModel.toApiJson());
      }
      
      log('✅ Found ${apiData.length} unsynced farms');
      
      return apiData;
    } catch (e) {
      log('❌ Error fetching unsynced farms: $e');
      throw Exception('Failed to get unsynced farms: $e');
    }
  }

  /// Mark farms as synced by their UUIDs
  /// 
  /// This method updates the synced status of farms after successful API submission.
  /// 
  /// **Parameters:**
  /// - `uuids`: List of farm UUIDs that were successfully synced
  /// 
  /// **Returns:**
  /// - Number of farms updated
  Future<int> markFarmsAsSynced(List<String> uuids) async {
    try {
      log('✅ Marking ${uuids.length} farms as synced...');
      
      int updatedCount = 0;
      
      for (final uuid in uuids) {
        final farm = await _database.farmDao.getFarmByUuid(uuid);
        
        if (farm != null) {
          final updatedFarm = Farm(
            id: farm.id,
            farmerId: farm.farmerId,
            uuid: farm.uuid,
            referenceNo: farm.referenceNo,
            regionalRegNo: farm.regionalRegNo,
            name: farm.name,
            size: farm.size,  // Already String
            sizeUnit: farm.sizeUnit,
            latitudes: farm.latitudes,  // Already String
            longitudes: farm.longitudes,  // Already String
            physicalAddress: farm.physicalAddress,
            villageId: farm.villageId,
            wardId: farm.wardId,
            districtId: farm.districtId,
            regionId: farm.regionId,
            countryId: farm.countryId,
            legalStatusId: farm.legalStatusId,
            status: farm.status,
            synced: true, // Mark as synced
            syncAction: farm.syncAction,
            createdAt: farm.createdAt,
            updatedAt: farm.updatedAt,
          );
          
          final success = await _database.farmDao.updateFarm(updatedFarm);
          if (success) updatedCount++;
        }
      }
      
      log('✅ Successfully marked $updatedCount farms as synced');
      return updatedCount;
    } catch (e) {
      log('❌ Error marking farms as synced: $e');
      throw Exception('Failed to mark farms as synced: $e');
    }
  }
}
