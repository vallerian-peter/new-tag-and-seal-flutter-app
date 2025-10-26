import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:new_tag_and_seal_flutter_app/core/global-sync/endpoints.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/data/repository/all.additional.data_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/species/data/repository/specie_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestock_types/data/repository/livestock_type_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/breeds/data/repository/breed_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestock_obtained_methods/data/repository/livestock_obtained_method_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/data/repository/farm_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/data/repository/livestock_repository.dart';

/// Global synchronization service for the application
/// 
/// Handles all data sync operations between the mobile app and backend server.
/// This service is responsible for fetching and storing data locally for offline access.
class Sync {
  
  // ============================================================================
  // PUBLIC SYNC METHODS
  // ============================================================================
  
  /// Performs complete data synchronization on app startup (splash screen)
  /// 
  /// This method performs a full bi-directional sync:
  /// - First, sends any unsynced local changes to the server
  /// - Then, fetches the latest data from server and stores locally
  /// 
  /// **Flow:**
  /// 1. Validates authentication token
  /// 2. POST: Sends unsynced data to server (farms, livestock, etc.)
  /// 3. GET: Fetches all latest data from server based on user role
  /// 4. Store: Saves fetched data locally with timestamp-based conflict resolution
  /// 
  /// **Conflict Resolution:**
  /// - Uses UUID as unique identifier across devices
  /// - Compares `updatedAt` timestamps
  /// - Only updates if server data is newer than local data
  /// - Skips update if local data is newer (prevents overwriting recent changes)
  /// 
  /// **Data Synchronized:**
  /// - Location & reference data (countries, regions, identity types, etc.)
  /// - Livestock reference data (species, types, breeds, methods)
  /// - User-specific data based on role (farms & livestock for farmers)
  /// 
  /// **Parameters:**
  /// - `database`: The app's Drift database instance
  /// 
  /// **Throws:**
  /// - `Exception` if user is not authenticated
  /// - `Exception` if API call fails or returns invalid data
  /// 
  /// **Usage:**
  /// ```dart
  /// await Sync.splashSync(database);
  /// ```
  static Future<void> splashSync(AppDatabase database) async {
    try {
      // 1. Validate authentication
      final authData = await _validateAuthentication();
      
      log('🔄 Starting splash sync for user: ${authData['userId']}');

      // 2. POST: Send unsynced local data to server first
      log('📤 Step 1/2: Sending unsynced data to server...');
      await fullSyncPostData(database);
      
      // 3. GET: Fetch latest data from server
      log('📥 Step 2/2: Fetching latest data from server...');
      final data = await _fetchSplashSyncData(
        authData['userId'] as String,
        authData['token'] as String,
      );
      
      // 4. Store all data locally with conflict resolution
      await _storeAllSyncData(database, data);
      
      log('✅ Splash sync completed successfully');
      
    } catch (e) {
      log('❌ Splash sync error: $e');
      rethrow;
    }
  }


  /// Performs full data synchronization by sending unsynced data to server
  /// 
  /// This method sends all locally created/modified data to the server for synchronization.
  /// It handles multiple data collections (farms, livestock, vaccines, etc.) in a single request.
  /// 
  /// **Flow:**
  /// 1. Validates authentication token
  /// 2. Collects all unsynced data from repositories
  /// 3. Sends POST request to `/api/v1/farmers/sync/full-post-sync` with structured payload
  /// 4. Marks successfully synced items as synced in local database
  /// 
  /// **Parameters:**
  /// - `database`: The app's Drift database instance
  /// 
  /// **Throws:**
  /// - `Exception` if user is not authenticated
  /// - `Exception` if API call fails
  /// 
  /// **Payload Format:**
  /// ```json
  /// {
  ///   "farms": [...],
  ///   "livestock": [...],
  ///   "vaccines": [...],
  ///   // ... other collections
  /// }
  /// ```
  static Future<void> fullSyncPostData(AppDatabase database) async {
    try {
      // 1. Validate authentication
      final authData = await _validateAuthentication();
      
      log('🔄 Starting full sync post data...');
      
      // 2. Collect unsynced data from repositories
      final payload = await _collectUnsyncedData(database);
      log('✅ Unsynced data collected: ${payload.toString()}');
      
      // 3. Check if there's data to sync
      if (_isPayloadEmpty(payload)) {
        log('✅ No data to sync');
        return;
      }
      
      // 4. Send data to server
      final syncedData = await _sendPostSyncData(
        authData['userId'] as String,
        authData['token'] as String,
        payload,
      );
      
      // 5. Mark synced items in local database
      await _markItemsAsSynced(database, syncedData);
      
      log('✅ Full sync post data completed successfully');
      
    } catch (e) {
      log('❌ Full sync post data error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - Authentication
  // ============================================================================

  /// Validates user authentication and returns auth data
  /// 
  /// Returns a map containing userId and token
  /// Throws Exception if authentication fails
  static Future<Map<String, String>> _validateAuthentication() async {
    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'auth_token') ?? '';
    final userId = await secureStorage.read(key: 'userId') ?? '';

    if (token.isEmpty) {
      log('❌ No auth token - user not authenticated');
      throw Exception('User not authenticated');
    }
    
    if (userId.isEmpty) {
      log('❌ No user ID - user not authenticated');
      throw Exception('User ID not found');
    }

    return {
      'userId': userId,
      'token': token,
    };
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - Splash Sync (GET)
  // ============================================================================

  /// Fetches splash sync data from server
  static Future<Map<String, dynamic>> _fetchSplashSyncData(
    String userId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.splashSyncAll}/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return _handleSyncResponse(response, 'splash sync');
    } on SocketException catch (e) {
      log('❌ Socket error: ${e.message}');
      throw Exception('Failed to connect to server. Please check your internet connection.');
    } on FormatException catch (e) {
      log('❌ Invalid response format: ${e.message}');
      throw Exception('Invalid server response. Please try again.');
    }
  }

  /// Stores all fetched sync data locally with timestamp-based conflict resolution
  /// 
  /// **Conflict Resolution Strategy:**
  /// - Each repository checks `createdAt` and `updatedAt` timestamps
  /// - Only updates if server data is newer than local data
  /// - Uses UUID as unique identifier across devices
  /// - Prevents overwriting recent local changes with stale server data
  static Future<void> _storeAllSyncData(
    AppDatabase database,
    Map<String, dynamic> data,
  ) async {
    await _storeLocationAndReferenceData(database, data);
    await _storeLivestockReferenceData(database, data);
    await _storeUserSpecificData(database, data);
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - Post Sync (POST)
  // ============================================================================

  /// Collects all unsynced data from repositories
  static Future<Map<String, dynamic>> _collectUnsyncedData(
    AppDatabase database,
  ) async {
    final farmRepository = FarmRepository(database);
    final unsyncedFarms = await farmRepository.getUnsyncedFarmsForApi();
    
    // TODO: Add other repositories as they're implemented
    // final livestockRepository = LivestockRepository(database);
    // final unsyncedLivestock = await livestockRepository.getUnsyncedLivestockForApi();
    
    // Log summary
    log('📦 Payload summary:');
    log('  - Farms: ${unsyncedFarms.length}');
    // TODO: Log other collections
    
    return {
      'farms': unsyncedFarms,
      // TODO: Add other collections here
      // 'livestock': unsyncedLivestock,
      // 'vaccines': unsyncedVaccines,
    };
  }

  /// Checks if payload has any data to sync
  static bool _isPayloadEmpty(Map<String, dynamic> payload) {
    final farms = payload['farms'] as List? ?? [];
    // TODO: Check other collections when added
    
    return farms.isEmpty;
  }

  /// Sends post sync data to server
  static Future<Map<String, dynamic>> _sendPostSyncData(
    String userId,
    String token,
    Map<String, dynamic> payload,
  ) async {
    try {
      log('📤 Sending data to server...');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.fullSyncPostData}/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      log('✅ Response From Server Sync Post Data: ${response.body}');
      final data = _handleSyncResponse(response, 'post sync');
      log('✅ Data synced successfully');
      
      return data['data'] as Map<String, dynamic>? ?? {};
    } on SocketException catch (e) {
      log('❌ Socket error: ${e.message}');
      throw Exception('Failed to connect to server. Please check your internet connection.');
    } on FormatException catch (e) {
      log('❌ Invalid response format: ${e.message}');
      throw Exception('Invalid server response. Please try again.');
    }
  }

  /// Marks synced items as synced in local database
  static Future<void> _markItemsAsSynced(
    AppDatabase database,
    Map<String, dynamic> syncedData,
  ) async {
    // Mark farms as synced
    final syncedFarmUuids = (syncedData['syncedFarms'] as List<dynamic>?)
        ?.map((item) => item['uuid'] as String)
        .toList() ?? [];
    
    if (syncedFarmUuids.isNotEmpty) {
      final farmRepository = FarmRepository(database);
      await farmRepository.markFarmsAsSynced(syncedFarmUuids);
      log('  ✅ Marked ${syncedFarmUuids.length} farms as synced');
    }
    
    // TODO: Mark other collections as synced
    // final syncedLivestockUuids = ...
    // if (syncedLivestockUuids.isNotEmpty) {
    //   await livestockRepository.markLivestockAsSynced(syncedLivestockUuids);
    // }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - Response Handling
  // ============================================================================

  /// Handles HTTP response from sync endpoints
  static Map<String, dynamic> _handleSyncResponse(
    http.Response response,
    String syncType,
  ) {
    log('📥 $syncType response: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      
      if (responseBody['status'] != true) {
        log('❌ $syncType failed: ${responseBody['message']}');
        throw Exception(responseBody['message'] ?? '$syncType failed');
      }

      return responseBody['data'] as Map<String, dynamic>? ?? {};
    } else if (response.statusCode == 401) {
      log('❌ Unauthorized - invalid or expired token');
      throw Exception('Unauthorized - Please login again');
    } else {
      log('❌ $syncType error: ${response.statusCode}');
      throw Exception('Failed to $syncType: ${response.statusCode}');
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - Data Storage
  // ============================================================================

  /// Stores location and reference data locally
  /// 
  /// **Strategy: UPSERT (Update if exists, Insert if not)**
  /// - If ID exists in local DB → UPDATE with server data
  /// - If ID doesn't exist → INSERT new record
  /// - Uses server-provided IDs (no autoIncrement)
  /// - No duplicates possible (unique ID constraint)
  /// 
  /// **Handles:**
  /// - Locations: countries, regions, districts, wards, villages, streets, divisions
  /// - Reference data: identity card types, school levels, legal statuses
  /// 
  /// **Performance:** Single repository call handles all location & reference data
  static Future<void> _storeLocationAndReferenceData(
    AppDatabase database, 
    Map<String, dynamic> data
  ) async {
    log('  📍 Storing locations & reference data...');
    final repository = AllAdditionalDataRepository(database);
    
    // UPSERT: Insert or Replace based on ID
    await repository.storeDataLocally(data);
    
    log('  ✅ Locations & reference data stored (UPSERT)');
  }

  /// Stores livestock reference data locally
  /// 
  /// **Strategy: UPSERT (Update if exists, Insert if not)**
  /// - If ID exists in local DB → UPDATE with server data
  /// - If ID doesn't exist → INSERT new record
  /// - Uses server-provided IDs (no autoIncrement)
  /// - No duplicates possible (unique ID constraint)
  /// 
  /// **Handles:**
  /// - Species (cattle, goats, sheep, etc.)
  /// - Livestock types (dairy, beef, etc.)
  /// - Breeds (Holstein, Angus, etc.)
  /// - Obtained methods (purchased, bred, gifted, etc.)
  /// 
  /// **Performance:** Parallel repository calls for faster processing
  static Future<void> _storeLivestockReferenceData(
    AppDatabase database, 
    Map<String, dynamic> data
  ) async {
    log('  🐄 Storing livestock reference data...');
    
    // UPSERT: Insert or Replace based on ID (parallel for speed)
    await Future.wait([
      SpecieRepository(database).syncAndStoreLocally(data),
      LivestockTypeRepository(database).syncAndStoreLocally(data),
      BreedRepository(database).syncAndStoreLocally(data),
      LivestockObtainedMethodRepository(database).syncAndStoreLocally(data),
    ]);
    
    log('  ✅ Livestock reference data stored (UPSERT)');
  }

  /// Stores user-specific data based on role with timestamp-based conflict resolution
  /// 
  /// **Farmer Role:**
  /// - Stores all farms owned by the farmer (with UUID & timestamp conflict resolution)
  /// - Stores all livestock in those farms (with UUID & timestamp conflict resolution)
  /// 
  /// **Extension Officer/Vet Role:**
  /// - Stores assigned farms (not yet implemented)
  /// 
  /// **System User Role:**
  /// - No data stored (accesses via admin endpoints)
  /// 
  /// **Conflict Resolution for Farms & Livestock:**
  /// - Compares `updatedAt` timestamps
  /// - INSERT: If item doesn't exist locally (by UUID)
  /// - UPDATE: If server data is newer than local data
  /// - SKIP: If local data is newer or same (prevents data loss)
  /// 
  /// **Performance:** Sequential calls to avoid database conflicts
  static Future<void> _storeUserSpecificData(
    AppDatabase database, 
    Map<String, dynamic> data
  ) async {
    final userSpecificData = data['userSpecificData'] ?? {};
    final userType = userSpecificData['type'] ?? '';

    if (userType == 'farmer') {
      log('  👨‍🌾 Storing farmer data with conflict resolution...');
      
      // Farm repository handles timestamp-based conflict resolution
      await FarmRepository(database).syncAndStoreLocally(data);
      
      // Livestock repository handles timestamp-based conflict resolution
      await LivestockRepository(database).syncAndStoreLocally(data);
      
      final farmsCount = userSpecificData['farmsCount'] ?? 0;
      final livestockCount = userSpecificData['livestockCount'] ?? 0;
      log('  ✅ Farmer data stored (Farms: $farmsCount, Livestock: $livestockCount)');
      
    } else if (userType == 'field_worker') {
      log('  👷 Field worker - no data to sync yet');
      
    } else if (userType == 'system_user') {
      log('  👨‍💼 System user - uses admin endpoints');
    }
  }
}
