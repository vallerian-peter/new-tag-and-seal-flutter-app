import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

/// Domain repository interface for livestock operations
/// This defines the contract that the data layer must implement
abstract class LivestockRepo {
  /// Get all active livestock (excluding deleted ones)
  Future<List<Livestock>> getAllActiveLivestock();
  
  /// Get livestock by ID
  Future<Livestock?> getLivestockById(int id);
  
  /// Get livestock by UUID
  Future<Livestock?> getLivestockByUuid(String uuid);
  
  /// Get livestock by identification number
  Future<Livestock?> getLivestockByIdentificationNumber(String identificationNumber);
  
  /// Get active livestock by farm UUID
  Future<List<Livestock>> getActiveLivestockByFarmUuid(String farmUuid);
  
  /// Create livestock
  Future<Livestock> createLivestock(Map<String, dynamic> livestockData);
  
  /// Update livestock
  Future<bool> updateLivestock(int id, Map<String, dynamic> livestockData);
  
  /// Mark livestock as deleted (soft delete)
  Future<bool> markLivestockAsDeleted(int livestockId);
  
  /// Mark livestock by farm UUID as deleted
  Future<int> markLivestockByFarmUuidAsDeleted(String farmUuid);
  
  /// Get unsynced livestock for API
  Future<List<Map<String, dynamic>>> getUnsyncedLivestockForApi();
  
  /// Mark livestock as synced
  Future<int> markLivestockAsSynced(List<String> uuids);
}
