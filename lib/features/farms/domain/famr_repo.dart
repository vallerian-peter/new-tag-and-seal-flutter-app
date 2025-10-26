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
}

