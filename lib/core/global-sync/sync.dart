import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:new_tag_and_seal_flutter_app/core/global-sync/endpoints.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/data/repository/all.additional.data_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/data/repository/farm_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/data/repository/livestock_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/data/repository/events_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/data/repository/log_additional_data_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/data/repository/vaccines_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/domain/constants/event_log_types.dart';

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
    final livestockRepository = LivestockRepository(database);
    final eventsRepository = EventsRepository(database);
    final vaccinesRepository = VaccinesRepository(database);
    
    final unsyncedFarms = await farmRepository.getUnsyncedFarmsForApi();
    final unsyncedLivestock = await livestockRepository.getUnsyncedLivestockForApi();
    final unsyncedFeedings = await eventsRepository.getUnsyncedFeedingsForApi();
    final unsyncedWeightChanges = await eventsRepository.getUnsyncedWeightChangesForApi();
    final unsyncedDewormings = await eventsRepository.getUnsyncedDewormingsForApi();
    final unsyncedMedications = await eventsRepository.getUnsyncedMedicationsForApi();
    final unsyncedVaccinations = await eventsRepository.getUnsyncedVaccinationsForApi();
    final unsyncedDisposals = await eventsRepository.getUnsyncedDisposalsForApi();
    final unsyncedVaccines = await vaccinesRepository.getUnsyncedVaccinesForApi();
    
    // TODO: Add other repositories as they're implemented
    // final vaccineRepository = VaccineRepository(database);
    // final unsyncedVaccines = await vaccineRepository.getUnsyncedVaccinesForApi();
    
    // Log summary
    log('📦 Payload summary:');
    log('  - Farms: ${unsyncedFarms.length}');
    log('  - Livestock: ${unsyncedLivestock.length}');
    log('  - Feedings: ${unsyncedFeedings.length}');
    log('  - WeightChanges: ${unsyncedWeightChanges.length}');
    log('  - Dewormings: ${unsyncedDewormings.length}');
    log('  - Medications: ${unsyncedMedications.length}');
    log('  - Vaccinations: ${unsyncedVaccinations.length}');
    log('  - Disposals: ${unsyncedDisposals.length}');
    log('  - Vaccines: ${unsyncedVaccines.length}');
    // TODO: Log other collections
    
    return {
      'farms': unsyncedFarms,
      'livestock': unsyncedLivestock,
      'logs': {
        'feedings': unsyncedFeedings,
        'weightChanges': unsyncedWeightChanges,
        'dewormings': unsyncedDewormings,
        'medications': unsyncedMedications,
        'vaccinations': unsyncedVaccinations,
        'disposals': unsyncedDisposals,
      },
      'vaccines': unsyncedVaccines,
      // TODO: Add other collections here
      // 'vaccines': unsyncedVaccines,
      // 'feeds': unsyncedFeeds,
    };
  }

  /// Returns a light-weight summary of unsynced entities for UI alerts.
  static Future<SyncUnsyncedSummary> getUnsyncedSummary(
    AppDatabase database,
  ) async {
    final farmRepository = FarmRepository(database);
    final livestockRepository = LivestockRepository(database);
    final eventsRepository = EventsRepository(database);
    final vaccinesRepository = VaccinesRepository(database);

    final farms = await farmRepository.getUnsyncedFarmsForApi();
    final livestock = await livestockRepository.getUnsyncedLivestockForApi();
    final feedings = await eventsRepository.getUnsyncedFeedingsForApi();
    final weightChanges = await eventsRepository.getUnsyncedWeightChangesForApi();
    final dewormings = await eventsRepository.getUnsyncedDewormingsForApi();
    final medications = await eventsRepository.getUnsyncedMedicationsForApi();
    final vaccinations = await eventsRepository.getUnsyncedVaccinationsForApi();
    final disposals = await eventsRepository.getUnsyncedDisposalsForApi();
    final vaccines = await vaccinesRepository.getUnsyncedVaccinesForApi();

    final logCounts = <String, int>{
      EventLogTypes.feeding: feedings.length,
      EventLogTypes.weightChange: weightChanges.length,
      EventLogTypes.deworming: dewormings.length,
      EventLogTypes.medication: medications.length,
      EventLogTypes.vaccination: vaccinations.length,
      EventLogTypes.disposal: disposals.length,
    }..removeWhere((_, count) => count == 0);

    return SyncUnsyncedSummary(
      farms: farms.length,
      livestock: livestock.length,
      vaccines: vaccines.length,
      logCounts: logCounts,
    );
  }

  /// Checks if payload has any data to sync
  static bool _isPayloadEmpty(Map<String, dynamic> payload) {
    final farms = payload['farms'] as List? ?? [];
    final livestock = payload['livestock'] as List? ?? [];
    final logs = (payload['logs'] as Map<String, dynamic>?) ?? {};
    final vaccines = payload['vaccines'] as List? ?? [];

    bool logsEmpty = true;
    if (logs.isNotEmpty) {
      logsEmpty = logs.values.every((entries) {
        if (entries is List) {
          return entries.isEmpty;
        }
        return true;
      });
    }

    // TODO: Check other collections when added

    return farms.isEmpty && livestock.isEmpty && logsEmpty && vaccines.isEmpty;
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
    
    // Mark livestock as synced
    final syncedLivestockUuids = (syncedData['syncedLivestock'] as List<dynamic>?)
        ?.map((item) => item['uuid'] as String)
        .toList() ?? [];
    
    if (syncedLivestockUuids.isNotEmpty) {
      final livestockRepository = LivestockRepository(database);
      await livestockRepository.markLivestockAsSynced(syncedLivestockUuids);
      log('  ✅ Marked ${syncedLivestockUuids.length} livestock as synced');
    }

    final syncedLogs = syncedData['syncedLogs'] as Map<String, dynamic>?;
    if (syncedLogs != null && syncedLogs.isNotEmpty) {
      final eventsRepository = EventsRepository(database);

      List<String> _extractUuids(dynamic source) {
        if (source is List) {
          return source
              .map((item) {
                if (item is String) return item;
                if (item is Map<String, dynamic>) {
                  final value = item['uuid'];
                  return value is String ? value : null;
                }
                return null;
              })
              .whereType<String>()
              .toList();
        }
        return const [];
      }

      final syncedFeedings = _extractUuids(syncedLogs['feedings']);
      if (syncedFeedings.isNotEmpty) {
        await eventsRepository.markFeedingsAsSynced(syncedFeedings);
        log('  ✅ Marked ${syncedFeedings.length} feedings as synced');
      }

      final syncedWeightChanges = _extractUuids(syncedLogs['weightChanges']);
      if (syncedWeightChanges.isNotEmpty) {
        await eventsRepository.markWeightChangesAsSynced(syncedWeightChanges);
        log('  ✅ Marked ${syncedWeightChanges.length} weight changes as synced');
      }

      final syncedDewormings = _extractUuids(syncedLogs['dewormings']);
      if (syncedDewormings.isNotEmpty) {
        await eventsRepository.markDewormingsAsSynced(syncedDewormings);
        log('  ✅ Marked ${syncedDewormings.length} dewormings as synced');
      }

      final syncedMedications = _extractUuids(syncedLogs['medications']);
      if (syncedMedications.isNotEmpty) {
        await eventsRepository.markMedicationsAsSynced(syncedMedications);
        log('  ✅ Marked ${syncedMedications.length} medications as synced');
      }

      final syncedVaccinations = _extractUuids(syncedLogs['vaccinations']);
      if (syncedVaccinations.isNotEmpty) {
        await eventsRepository.markVaccinationsAsSynced(syncedVaccinations);
        log('  ✅ Marked ${syncedVaccinations.length} vaccinations as synced');
      }

      final syncedDisposals = _extractUuids(syncedLogs['disposals']);
      if (syncedDisposals.isNotEmpty) {
        await eventsRepository.markDisposalsAsSynced(syncedDisposals);
        log('  ✅ Marked ${syncedDisposals.length} disposals as synced');
      }
    }
    
    // TODO: Mark other collections as synced
    // final syncedVaccineUuids = ...
    // if (syncedVaccineUuids.isNotEmpty) {
    //   await vaccineRepository.markVaccinesAsSynced(syncedVaccineUuids);
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

    final referenceData = (data['referenceData'] as Map<String, dynamic>?) ?? {};
    await LogAdditionalDataRepository(database).storeLogAdditionalData(referenceData);
    
    log('  ✅ Locations & reference data stored (UPSERT)');
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

      // Store log events (feedings, weight changes, dewormings)
      final rawLogs = userSpecificData['logs'];
      Map<String, dynamic> logs = const {};
      if (rawLogs is Map<String, dynamic>) {
        logs = rawLogs;
      } else if (rawLogs == null ||
          (rawLogs is List && rawLogs.isEmpty)) {
        logs = const {};
      } else {
        log('⚠️ Unexpected logs payload type: ${rawLogs.runtimeType}, defaulting to empty map');
        logs = const {};
      }
      await EventsRepository(database).syncLogs(logs.isEmpty ? null : logs);
      
      final vaccines = (userSpecificData['vaccines'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
      await VaccinesRepository(database).syncVaccines(vaccines);
      
      final farmsCount = userSpecificData['farmsCount'] ?? 0;
      final livestockCount = userSpecificData['livestockCount'] ?? 0;
      final feedingsCount = (logs['feedings'] as List?)?.length ?? 0;
      final weightChangesCount = (logs['weightChanges'] as List?)?.length ?? 0;
      final dewormingsCount = (logs['dewormings'] as List?)?.length ?? 0;
      final medicationsCount = (logs['medications'] as List?)?.length ?? 0;
      final vaccinationsCount = (logs['vaccinations'] as List?)?.length ?? 0;
      final disposalsCount = (logs['disposals'] as List?)?.length ?? 0;
      final vaccinesCount = vaccines.length;
      log(
        '  ✅ Farmer data stored (Farms: $farmsCount, Livestock: $livestockCount, '
        'Feedings: $feedingsCount, WeightChanges: $weightChangesCount, '
        'Dewormings: $dewormingsCount, Medications: $medicationsCount, '
        'Vaccinations: $vaccinationsCount, Disposals: $disposalsCount, Vaccines: $vaccinesCount)',
      );
      
    } else if (userType == 'field_worker') {
      log('  👷 Field worker - no data to sync yet');
      
    } else if (userType == 'system_user') {
      log('  👨‍💼 System user - uses admin endpoints');
    }
  }
}

class SyncUnsyncedSummary {
  final int farms;
  final int livestock;
  final int vaccines;
  final Map<String, int> logCounts;

  const SyncUnsyncedSummary({
    required this.farms,
    required this.livestock,
    required this.vaccines,
    required this.logCounts,
  });

  const SyncUnsyncedSummary.empty()
      : farms = 0,
        livestock = 0,
        vaccines = 0,
        logCounts = const {};

  int get totalPending =>
      farms + livestock + vaccines + logCounts.values.fold<int>(0, (acc, value) => acc + value);

  bool get hasPending => totalPending > 0;
}
