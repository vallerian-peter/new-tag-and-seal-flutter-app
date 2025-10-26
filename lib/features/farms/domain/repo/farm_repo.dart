import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

/// Farm Repository Interface
/// 
/// Defines the contract for farm data operations.
/// This abstract class ensures consistency between repository implementations.
abstract class FarmRepositoryInterface {
  /// Get all farms from local database
  Future<List<Farm>> getAllFarms();

  /// Get farm by ID
  Future<Farm?> getFarmById(int id);

  /// Get farms by farmer ID
  Future<List<Farm>> getFarmsByFarmerId(int farmerId);

  /// Search farms by name
  Future<List<Farm>> searchFarmsByName(String name);

  /// Get farm with livestock by farm ID
  /// 
  /// Returns farm data along with all associated livestock.
  /// Useful for displaying farm details with livestock list.
  /// 
  /// **Parameters:**
  /// - `farmId`: The ID of the farm
  /// 
  /// **Returns:**
  /// - Map containing farm data and livestock list, or null if farm not found
  Future<Map<String, dynamic>?> getFarmWithLivestock(int farmId);

  /// Get all farms with their livestock
  /// 
  /// Returns all farms with associated livestock data.
  /// Useful for dashboard or farm overview screens.
  /// 
  /// **Returns:**
  /// - List of maps, each containing farm data and livestock list
  Future<List<Map<String, dynamic>>> getAllFarmsWithLivestock();

  /// Create a new farm locally
  /// 
  /// Saves the farm to local database with sync flag set to false.
  /// The farm will be synced to server later when connection is available.
  /// 
  /// **Parameters:**
  /// - `farmData`: Map containing farm data from form
  /// 
  /// **Returns:**
  /// - The created Farm object
  /// 
  /// **Throws:**
  /// - Exception if farm creation fails
  Future<Farm> createFarmLocally(Map<String, dynamic> farmData);

  /// Sync farms data from server and store locally
  /// 
  /// This method handles merging server data with local data,
  /// respecting timestamps to avoid data loss.
  Future<void> syncAndStoreLocally(Map<String, dynamic> syncData);

  /// Mark farm as deleted (soft delete)
  /// 
  /// Updates the farm's syncAction to 'deleted' without removing it from the database.
  /// The farm will be synced to server and actually deleted during sync.
  /// 
  /// **Parameters:**
  /// - `farmId`: The ID of the farm to mark as deleted
  /// 
  /// **Returns:**
  /// - true if update was successful, false otherwise
  Future<bool> markFarmAsDeleted(int farmId);

  /// Update a farm
  /// 
  /// Updates an existing farm in the local database.
  /// 
  /// **Parameters:**
  /// - `farmId`: The ID of the farm to update
  /// - `farmData`: Map containing updated farm data
  /// - `syncAction`: Optional sync action ('update', 'deleted', etc.)
  /// - `synced`: Optional sync status
  /// 
  /// **Returns:**
  /// - The updated Farm object
  /// 
  /// **Throws:**
  /// - Exception if farm update fails
  Future<Farm> updateFarm(int farmId, Map<String, dynamic> farmData, {String? syncAction, bool? synced});
}

