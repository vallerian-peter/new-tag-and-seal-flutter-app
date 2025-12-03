import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:new_tag_and_seal_flutter_app/core/constants/endpoints.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/data/repository/all.additional.data_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/data/repository/farm_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/data/repository/livestock_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/events/data/repository/events_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/data/repository/log_additional_data_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/vaccines/data/repository/vaccines_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/data/repository/farm_user_repository.dart';
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
  /// **Supported User Roles:**
  /// - ✅ **Farmer**: Syncs all their farms, livestock, logs, vaccines, farm users
  /// - ✅ **Farm Invited User / Extension Officer / Vet**: Syncs data for assigned farms only
  /// - ✅ **System User**: Gets reference data only (uses admin endpoints)
  /// 
  /// **Flow:**
  /// 1. Validates authentication token
  /// 2. POST: Sends unsynced data to server (farms, livestock, etc.) - Works for all roles
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
  /// - Location & reference data (countries, regions, identity types, etc.) - All roles
  /// - Livestock reference data (species, types, breeds, methods) - All roles
  /// - User-specific data based on role:
  ///   - **Farmer**: All farms, livestock, 13 log types, vaccines, farm users
  ///   - **Farm Invited User / Extension Officer / Vet**: Assigned farms only, livestock in those farms, logs, vaccines
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
  /// It handles multiple data collections (farms, livestock, vaccines, farm users, etc.) in a single request.
  /// 
  /// **Supported User Roles:**
  /// - ✅ **Farmer**: Can sync all their farms, livestock, logs, vaccines, and farm users
  /// - ✅ **Farm Invited User / Extension Officer / Vet**: Can sync data for their assigned farms only
  ///   (Backend validates access based on FarmUser.farmUuids assignment)
  /// 
  /// **Flow:**
  /// 1. Validates authentication token
  /// 2. Collects all unsynced data from repositories
  /// 3. Sends POST request to `/api/v1/farmers/sync/full-post-sync` with structured payload
  /// 4. Marks successfully synced items as synced in local database
  /// 
  /// **Important Notes:**
  /// - Farm users: When farm users are synced, the backend automatically sends invitation emails
  ///   to the email addresses provided. Emails are sent asynchronously during the sync process.
  /// - Backend validates that users can only sync data they have access to
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
  ///   "logs": {
  ///     "feedings": [...],
  ///     "weightChanges": [...],
  ///     // ... 13 log types total
  ///   },
  ///   "vaccines": [...],
  ///   "farmUsers": [...]
  /// }
  /// ```
  /// 
  /// **PHASE 1:** Authentication validation
  /// **PHASE 2:** Collect all unsynced data (Farms, Livestock, 13 Log Types, Vaccines, FarmUsers)
  /// **PHASE 3:** Send data to backend API
  /// **PHASE 4:** Mark items as synced in local database
  /// 
  /// This is called during logout flow and can be called manually for sync operations.
  static Future<void> fullSyncPostData(AppDatabase database) async {
    try {
      log('🔄 [PHASE 1] Starting full sync post data - Validating authentication...');
      // Phase 1: Validate authentication
      final authData = await _validateAuthentication();
      log('✅ [PHASE 1] Authentication validated - User ID: ${authData['userId']}');
      
      log('🔄 [PHASE 2] Collecting all unsynced data from repositories...');
      // Phase 2: Collect unsynced data from repositories
      final payload = await _collectUnsyncedData(database);
      log('✅ [PHASE 2] Unsynced data collection complete');
      
      // Phase 2.1: Check if there's data to sync
      if (_isPayloadEmpty(payload)) {
        log('✅ [PHASE 2.1] No unsynced data found - sync complete');
        return;
      }
      log('📦 [PHASE 2.1] Found unsynced data - proceeding with sync');
      
      log('🔄 [PHASE 3] Sending unsynced data to backend API...');
      // Phase 3: Send data to server
      final syncedData = await _sendPostSyncData(
        authData['userId'] as String,
        authData['token'] as String,
        payload,
      );
      log('✅ [PHASE 3] Data successfully sent to backend');
      
      log('🔄 [PHASE 4] Marking synced items in local database...');
      // Phase 4: Mark synced items in local database
      await _markItemsAsSynced(database, syncedData);
      log('✅ [PHASE 4] All items marked as synced locally');
      
      log('✅ [COMPLETE] Full sync post data completed successfully');
      
    } catch (e) {
      log('❌ [ERROR] Full sync post data error: $e');
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
  /// 
  /// Collects unsynced data from:
  /// - Farms
  /// - Livestock
  /// - Log types (all 13 unique types supported for sync):
  ///   1. Feedings ✅
  ///   2. Pregnancies ✅
  ///   3. Inseminations ✅
  ///   4. Dewormings ✅
  ///   5. WeightChanges ✅
  ///   6. Medications ✅
  ///   7. Vaccinations ✅
  ///   8. Disposals ✅
  ///   9. BirthEvents ✅ (covers both calving & farrowing)
  ///   10. AbortedPregnancies ✅
  ///   11. Milkings ✅
  ///   12. Dryoffs ✅
  ///   13. Transfers ✅
  /// - Vaccines
  /// - FarmUsers
  static Future<Map<String, dynamic>> _collectUnsyncedData(
    AppDatabase database,
  ) async {
    log('📤 Checking all unsynced data before sync...');
    
    final farmRepository = FarmRepository(database);
    final livestockRepository = LivestockRepository(database);
    final eventsRepository = EventsRepository(database);
    final vaccinesRepository = VaccinesRepository(database);
    final farmUserRepository = FarmUserRepository(database);
    
    log('📤 Fetching unsynced farms for API...');
    final unsyncedFarms = await farmRepository.getUnsyncedFarmsForApi();
    
    log('📤 Fetching unsynced livestock for API...');
    final unsyncedLivestock = await livestockRepository.getUnsyncedLivestockForApi();
    
    log('📤 Fetching unsynced feedings for API...');
    final unsyncedFeedings = await eventsRepository.getUnsyncedFeedingsForApi();
    
    log('📤 Fetching unsynced weight changes for API...');
    final unsyncedWeightChanges = await eventsRepository.getUnsyncedWeightChangesForApi();
    
    log('📤 Fetching unsynced dewormings for API...');
    final unsyncedDewormings = await eventsRepository.getUnsyncedDewormingsForApi();
    
    log('📤 Fetching unsynced medications for API...');
    final unsyncedMedications = await eventsRepository.getUnsyncedMedicationsForApi();
    
    log('📤 Fetching unsynced vaccinations for API...');
    final unsyncedVaccinations = await eventsRepository.getUnsyncedVaccinationsForApi();
    
    log('📤 Fetching unsynced disposals for API...');
    final unsyncedDisposals = await eventsRepository.getUnsyncedDisposalsForApi();
    
    log('📤 Fetching unsynced birth events for API...');
    final unsyncedBirthEvents = await eventsRepository.getUnsyncedBirthEventsForApi();
    
    log('📤 Fetching unsynced aborted pregnancies for API...');
    final unsyncedAbortedPregnancies = await eventsRepository.getUnsyncedAbortedPregnanciesForApi();
    
    log('📤 Fetching unsynced milkings for API...');
    final unsyncedMilkings = await eventsRepository.getUnsyncedMilkingsForApi();
    
    log('📤 Fetching unsynced pregnancies for API...');
    final unsyncedPregnancies = await eventsRepository.getUnsyncedPregnanciesForApi();
    
    log('📤 Fetching unsynced inseminations for API...');
    final unsyncedInseminations = await eventsRepository.getUnsyncedInseminationsForApi();
    
    log('📤 Fetching unsynced dryoffs for API...');
    final unsyncedDryoffs = await eventsRepository.getUnsyncedDryoffsForApi();
    
    log('📤 Fetching unsynced transfers for API...');
    final unsyncedTransfers = await eventsRepository.getUnsyncedTransfersForApi();
    
    log('📤 Fetching unsynced vaccines for API...');
    final unsyncedVaccines = await vaccinesRepository.getUnsyncedVaccinesForApi();
    
    log('📤 Fetching unsynced farm users for API...');
    final unsyncedFarmUsers = await farmUserRepository.getUnsyncedFarmUsersForApi();
    
    // TODO: Add other repositories as they're implemented
    // final vaccineRepository = VaccineRepository(database);
    // final unsyncedVaccines = await vaccineRepository.getUnsyncedVaccinesForApi();
    
    // Log detailed summary showing all data types checked
    log('📦 Complete sync payload summary (ALL data types checked):');
    log('  ✅ Farms: ${unsyncedFarms.length}');
    log('  ✅ Livestock: ${unsyncedLivestock.length}');
    log('  ✅ Logs - Feedings: ${unsyncedFeedings.length}');
    log('  ✅ Logs - WeightChanges: ${unsyncedWeightChanges.length}');
    log('  ✅ Logs - Dewormings: ${unsyncedDewormings.length}');
    log('  ✅ Logs - Medications: ${unsyncedMedications.length}');
    log('  ✅ Logs - Vaccinations: ${unsyncedVaccinations.length}');
    log('  ✅ Logs - Disposals: ${unsyncedDisposals.length}');
    log('  ✅ Logs - BirthEvents: ${unsyncedBirthEvents.length}');
    log('  ✅ Logs - AbortedPregnancies: ${unsyncedAbortedPregnancies.length}');
    log('  ✅ Logs - Milkings: ${unsyncedMilkings.length}');
    log('  ✅ Logs - Pregnancies: ${unsyncedPregnancies.length}');
    log('  ✅ Logs - Inseminations: ${unsyncedInseminations.length}');
    log('  ✅ Logs - Dryoffs: ${unsyncedDryoffs.length}');
    log('  ✅ Logs - Transfers: ${unsyncedTransfers.length}');
    log('  ✅ Vaccines: ${unsyncedVaccines.length}');
    log('  ✅ FarmUsers: ${unsyncedFarmUsers.length}');
    
    // Count total log types (now all 13 unique types are synced)
    final totalLogCount = unsyncedFeedings.length +
        unsyncedWeightChanges.length +
        unsyncedDewormings.length +
        unsyncedMedications.length +
        unsyncedVaccinations.length +
        unsyncedDisposals.length +
        unsyncedBirthEvents.length +
        unsyncedAbortedPregnancies.length +
        unsyncedMilkings.length +
        unsyncedPregnancies.length +
        unsyncedInseminations.length +
        unsyncedDryoffs.length +
        unsyncedTransfers.length;
    
    log('  📊 Total unsynced logs: $totalLogCount (across 13 unique log types)');
    
    // Note: Farm users will trigger email notifications when synced to backend
    if (unsyncedFarmUsers.isNotEmpty) {
      log('📧 ${unsyncedFarmUsers.length} farm user(s) will be synced - invitation emails will be sent');
    }
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
        'birthEvents': unsyncedBirthEvents,
        'abortedPregnancies': unsyncedAbortedPregnancies,
        'milkings': unsyncedMilkings,
        'pregnancies': unsyncedPregnancies,
        'inseminations': unsyncedInseminations,
        'dryoffs': unsyncedDryoffs,
        'transfers': unsyncedTransfers,
      },
      'vaccines': unsyncedVaccines,
      'farmUsers': unsyncedFarmUsers,
      // TODO: Add other collections here
      // 'vaccines': unsyncedVaccines,
      // 'feeds': unsyncedFeeds,
    };
  }

  /// Returns a light-weight summary of unsynced entities for UI alerts.
  /// 
  /// **Phase 1: Data Collection**
  /// - Checks all 5 main data types (Farms, Livestock, Logs, Vaccines, FarmUsers)
  /// - Checks all 13 unique log types
  /// 
  /// **Phase 2: Summary Creation**
  /// - Aggregates counts for each data type
  /// - Removes log types with zero counts
  /// - Returns summary object for UI display
  static Future<SyncUnsyncedSummary> getUnsyncedSummary(
    AppDatabase database,
  ) async {
    log('📊 [PHASE 1] Starting unsynced summary collection...');
    
    // Phase 1: Collect all unsynced data
    final farmRepository = FarmRepository(database);
    final livestockRepository = LivestockRepository(database);
    final eventsRepository = EventsRepository(database);
    final vaccinesRepository = VaccinesRepository(database);
    final farmUserRepository = FarmUserRepository(database);

    log('📊 [PHASE 1.1] Checking unsynced farms...');
    final farms = await farmRepository.getUnsyncedFarmsForApi();
    
    log('📊 [PHASE 1.2] Checking unsynced livestock...');
    final livestock = await livestockRepository.getUnsyncedLivestockForApi();
    
    log('📊 [PHASE 1.3] Checking unsynced log types (all 13 types)...');
    final feedings = await eventsRepository.getUnsyncedFeedingsForApi();
    final weightChanges = await eventsRepository.getUnsyncedWeightChangesForApi();
    final dewormings = await eventsRepository.getUnsyncedDewormingsForApi();
    final medications = await eventsRepository.getUnsyncedMedicationsForApi();
    final vaccinations = await eventsRepository.getUnsyncedVaccinationsForApi();
    final disposals = await eventsRepository.getUnsyncedDisposalsForApi();
    final birthEvents = await eventsRepository.getUnsyncedBirthEventsForApi();
    final abortedPregnancies = await eventsRepository.getUnsyncedAbortedPregnanciesForApi();
    final milkings = await eventsRepository.getUnsyncedMilkingsForApi();
    final pregnancies = await eventsRepository.getUnsyncedPregnanciesForApi();
    final inseminations = await eventsRepository.getUnsyncedInseminationsForApi();
    final dryoffs = await eventsRepository.getUnsyncedDryoffsForApi();
    final transfers = await eventsRepository.getUnsyncedTransfersForApi();
    
    log('📊 [PHASE 1.4] Checking unsynced vaccines...');
    final vaccines = await vaccinesRepository.getUnsyncedVaccinesForApi();

    log('📊 [PHASE 1.5] Checking unsynced farm users...');
    final farmUsers = await farmUserRepository.getUnsyncedFarmUsersForApi();

    log('📊 [PHASE 2] Aggregating summary counts...');
    // Phase 2: Create summary with all log types
    final logCounts = <String, int>{
      EventLogTypes.feeding: feedings.length,
      EventLogTypes.pregnancy: pregnancies.length,
      EventLogTypes.insemination: inseminations.length,
      EventLogTypes.deworming: dewormings.length,
      EventLogTypes.weightChange: weightChanges.length,
      EventLogTypes.medication: medications.length,
      EventLogTypes.vaccination: vaccinations.length,
      EventLogTypes.disposal: disposals.length,
      EventLogTypes.calving: birthEvents.length, // Count calvings and farrowings together
      EventLogTypes.farrowing: birthEvents.length, // Count calvings and farrowings together
      EventLogTypes.abortedPregnancy: abortedPregnancies.length,
      EventLogTypes.milking: milkings.length,
      EventLogTypes.dryoff: dryoffs.length,
      EventLogTypes.transfer: transfers.length,
    }..removeWhere((_, count) => count == 0);

    log('📊 [PHASE 2] Summary complete - Found: ${farms.length} farms, ${livestock.length} livestock, ${vaccines.length} vaccines, ${farmUsers.length} farmUsers, and ${logCounts.values.fold(0, (a, b) => a + b)} total logs across ${logCounts.length} log types');

    return SyncUnsyncedSummary(
      farms: farms.length,
      livestock: livestock.length,
      vaccines: vaccines.length,
      farmUsers: farmUsers.length,
      logCounts: logCounts,
    );
  }

  /// Checks if payload has any data to sync
  static bool _isPayloadEmpty(Map<String, dynamic> payload) {
    final farms = payload['farms'] as List? ?? [];
    final livestock = payload['livestock'] as List? ?? [];
    final logs = (payload['logs'] as Map<String, dynamic>?) ?? {};
    final vaccines = payload['vaccines'] as List? ?? [];
    final farmUsers = payload['farmUsers'] as List? ?? [];

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

    return farms.isEmpty &&
        livestock.isEmpty &&
        logsEmpty &&
        vaccines.isEmpty &&
        farmUsers.isEmpty;
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

      final syncedBirthEvents = _extractUuids(syncedLogs['birthEvents']);
      if (syncedBirthEvents.isNotEmpty) {
        await eventsRepository.markBirthEventsAsSynced(syncedBirthEvents);
        log('  ✅ Marked ${syncedBirthEvents.length} birth events as synced');
      }

      final syncedAbortedPregnancies = _extractUuids(syncedLogs['abortedPregnancies']);
      if (syncedAbortedPregnancies.isNotEmpty) {
        await eventsRepository.markAbortedPregnanciesAsSynced(syncedAbortedPregnancies);
        log('  ✅ Marked ${syncedAbortedPregnancies.length} aborted pregnancies as synced');
      }

      final syncedMilkings = _extractUuids(syncedLogs['milkings']);
      if (syncedMilkings.isNotEmpty) {
        await eventsRepository.markMilkingsAsSynced(syncedMilkings);
        log('  ✅ Marked ${syncedMilkings.length} milkings as synced');
      }

      final syncedPregnancies = _extractUuids(syncedLogs['pregnancies']);
      if (syncedPregnancies.isNotEmpty) {
        await eventsRepository.markPregnanciesAsSynced(syncedPregnancies);
        log('  ✅ Marked ${syncedPregnancies.length} pregnancies as synced');
      }

      final syncedInseminations = _extractUuids(syncedLogs['inseminations']);
      if (syncedInseminations.isNotEmpty) {
        await eventsRepository.markInseminationsAsSynced(syncedInseminations);
        log('  ✅ Marked ${syncedInseminations.length} inseminations as synced');
      }

      final syncedDryoffs = _extractUuids(syncedLogs['dryoffs']);
      if (syncedDryoffs.isNotEmpty) {
        await eventsRepository.markDryoffsAsSynced(syncedDryoffs);
        log('  ✅ Marked ${syncedDryoffs.length} dryoffs as synced');
      }

      final syncedTransfers = _extractUuids(syncedLogs['transfers']);
      if (syncedTransfers.isNotEmpty) {
        await eventsRepository.markTransfersAsSynced(syncedTransfers);
        log('  ✅ Marked ${syncedTransfers.length} transfers as synced');
      }
    }

    // Mark vaccines as synced (if backend returns them)
    final syncedVaccineUuids = (syncedData['syncedVaccines'] as List<dynamic>?)
        ?.map((item) => item['uuid'] as String)
        .toList() ?? [];
    if (syncedVaccineUuids.isNotEmpty) {
      final vaccinesRepository = VaccinesRepository(database);
      await vaccinesRepository.markVaccinesAsSynced(syncedVaccineUuids);
      log('  ✅ Marked ${syncedVaccineUuids.length} vaccines as synced');
    }

    // Mark farm users as synced (if backend returns them)
    final syncedFarmUserUuids = (syncedData['syncedFarmUsers'] as List<dynamic>?)
        ?.map((item) => item['uuid'] as String)
        .toList() ?? [];
    if (syncedFarmUserUuids.isNotEmpty) {
      final farmUserRepository = FarmUserRepository(database);
      await farmUserRepository.markFarmUsersAsSynced(syncedFarmUserUuids);
      log('  ✅ Marked ${syncedFarmUserUuids.length} farm user(s) as synced');
      log('  📧 Invitation emails have been sent to the synced farm users');
    }
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
  /// **Supported User Roles:**
  /// 
  /// **1. Farmer Role (`farmer`):**
  /// - Stores all farms owned by the farmer (with UUID & timestamp conflict resolution)
  /// - Stores all livestock in those farms (with UUID & timestamp conflict resolution)
  /// - Stores all logs (13 types) for their livestock
  /// - Stores all vaccines for their farms
  /// - Stores all farm users they've created
  /// 
  /// **2. Farm Invited User / Extension Officer / Vet Role (`field_worker`):**
  /// - Stores assigned farms (based on farmUuids in FarmUser profile)
  /// - Stores livestock in assigned farms only
  /// - Stores all logs (13 types) for assigned livestock only
  /// - Stores vaccines for assigned farms only
  /// - Stores their own farm user profile for reference
  /// 
  /// **3. System User Role (`system_user`):**
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
    // Safely extract userSpecificData - handle both Map and unexpected types
    Map<String, dynamic> userSpecificData = const {};
    try {
      final rawUserSpecificData = data['userSpecificData'];
      if (rawUserSpecificData is Map<String, dynamic>) {
        userSpecificData = rawUserSpecificData;
      } else if (rawUserSpecificData is List) {
        // Backend sometimes returns empty array [] instead of empty object {}
        log('⚠️ userSpecificData is a List (array) instead of Map - converting to empty map');
        userSpecificData = const {};
      } else if (rawUserSpecificData == null) {
        userSpecificData = const {};
      } else {
        log('⚠️ Unexpected userSpecificData type: ${rawUserSpecificData.runtimeType}, defaulting to empty map');
        userSpecificData = const {};
      }
    } catch (e, stackTrace) {
      log('⚠️ Error parsing userSpecificData structure: $e\n$stackTrace');
      userSpecificData = const {};
    }
    
    final userType = (userSpecificData['type'] as String?) ?? '';

    log('📋 [SYNC] Processing user-specific data for role: ${userType.isEmpty ? "unknown" : userType}');

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

      final farmUsers = (userSpecificData['farmUsers'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
      await FarmUserRepository(database).syncFarmUsers(farmUsers);
      
      // Safely get counts with type checking
      int _safeGetCount(dynamic value) {
        if (value is int) return value;
        if (value is String) {
          return int.tryParse(value) ?? 0;
        }
        return 0;
      }
      
      int _safeGetLogCount(String key) {
        try {
          final value = logs[key];
          if (value is List) {
            return value.length;
          }
          return 0;
        } catch (e) {
          return 0;
        }
      }
      
      final farmsCount = _safeGetCount(userSpecificData['farmsCount']);
      final livestockCount = _safeGetCount(userSpecificData['livestockCount']);
      final feedingsCount = _safeGetLogCount('feedings');
      final weightChangesCount = _safeGetLogCount('weightChanges');
      final dewormingsCount = _safeGetLogCount('dewormings');
      final medicationsCount = _safeGetLogCount('medications');
      final vaccinationsCount = _safeGetLogCount('vaccinations');
      final disposalsCount = _safeGetLogCount('disposals');
      final birthEventsCount = _safeGetLogCount('birthEvents');
      final abortedPregnanciesCount = _safeGetLogCount('abortedPregnancies');
      final vaccinesCount = vaccines.length;
      final farmUsersCount = farmUsers.length;
      log(
        '  ✅ Farmer data stored (Farms: $farmsCount, Livestock: $livestockCount, '
        'Feedings: $feedingsCount, WeightChanges: $weightChangesCount, '
        'Dewormings: $dewormingsCount, Medications: $medicationsCount, '
        'Vaccinations: $vaccinationsCount, Disposals: $disposalsCount, '
        'BirthEvents: $birthEventsCount, AbortedPregnancies: $abortedPregnanciesCount, '
        'Vaccines: $vaccinesCount, FarmUsers: $farmUsersCount)',
      );
      
    } else if (userType == 'field_worker') {
      log('  👷 [SYNC] Storing field worker (farm invited user/extension officer/vet) data...');
      
      // Store assigned farms
      await FarmRepository(database).syncAndStoreLocally(data);
      
      // Store accessible livestock
      await LivestockRepository(database).syncAndStoreLocally(data);
      
      // Store logs (all logs for assigned livestock)
      Map<String, dynamic> logs = const {};
      try {
        final rawLogs = userSpecificData['logs'];
        if (rawLogs is Map<String, dynamic>) {
          logs = rawLogs;
        } else if (rawLogs == null ||
            (rawLogs is List && rawLogs.isEmpty)) {
          logs = const {};
        } else {
          log('⚠️ Unexpected logs payload type: ${rawLogs.runtimeType}, defaulting to empty map');
          logs = const {};
        }
      } catch (e, stackTrace) {
        log('⚠️ Error parsing logs structure: $e\n$stackTrace');
        logs = const {};
      }
      
      try {
        await EventsRepository(database).syncLogs(logs.isEmpty ? null : logs);
      } catch (e, stackTrace) {
        log('⚠️ Error syncing logs: $e\n$stackTrace');
        rethrow;
      }
      
      // Store vaccines
      final vaccines = (userSpecificData['vaccines'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
      await VaccinesRepository(database).syncVaccines(vaccines);
      
      // Store farm user profile info (optional - for reference)
      final farmUserData = userSpecificData['farmUser'] as Map<String, dynamic>?;
      if (farmUserData != null) {
        try {
          final firstName = farmUserData['firstName'] ?? '';
          final lastName = farmUserData['lastName'] ?? '';
          final roleTitle = farmUserData['roleTitle'] ?? '';
          
          // Safely parse farmUuids - handle both List and JSON string formats
          List<String> farmUuids = [];
          final farmUuidsValue = farmUserData['farmUuids'];
          if (farmUuidsValue is List) {
            farmUuids = farmUuidsValue.cast<String>();
          } else if (farmUuidsValue is String && farmUuidsValue.isNotEmpty) {
            // Try to parse as JSON string
            try {
              final decoded = jsonDecode(farmUuidsValue);
              if (decoded is List) {
                farmUuids = decoded.cast<String>();
              }
            } catch (e) {
              log('⚠️ Failed to parse farmUuids JSON string: $e');
            }
          }
          
          log('  📋 Farm User Profile: $firstName $lastName ($roleTitle) - Assigned to ${farmUuids.length} farm(s)');
        } catch (e, stackTrace) {
          log('⚠️ Error parsing farm user data: $e\n$stackTrace');
        }
      }
      
      // Count logs by type for logging - safely access map values
      int _safeGetLogCount(String key) {
        try {
          final value = logs[key];
          if (value is List) {
            return value.length;
          }
          return 0;
        } catch (e) {
          return 0;
        }
      }
      
      final feedingsCount = _safeGetLogCount('feedings');
      final weightChangesCount = _safeGetLogCount('weightChanges');
      final dewormingsCount = _safeGetLogCount('dewormings');
      final medicationsCount = _safeGetLogCount('medications');
      final vaccinationsCount = _safeGetLogCount('vaccinations');
      final disposalsCount = _safeGetLogCount('disposals');
      final birthEventsCount = _safeGetLogCount('birthEvents');
      final abortedPregnanciesCount = _safeGetLogCount('abortedPregnancies');
      final milkingsCount = _safeGetLogCount('milkings');
      final pregnanciesCount = _safeGetLogCount('pregnancies');
      final inseminationsCount = _safeGetLogCount('inseminations');
      final dryoffsCount = _safeGetLogCount('dryoffs');
      final transfersCount = _safeGetLogCount('transfers');
      
      final farmsCount = userSpecificData['farmsCount'] ?? 0;
      final livestockCount = userSpecificData['livestockCount'] ?? 0;
      final vaccinesCount = vaccines.length;
      
      log(
        '  ✅ Field worker data stored (Farms: $farmsCount, Livestock: $livestockCount, '
        'Feedings: $feedingsCount, WeightChanges: $weightChangesCount, '
        'Dewormings: $dewormingsCount, Medications: $medicationsCount, '
        'Vaccinations: $vaccinationsCount, Disposals: $disposalsCount, '
        'BirthEvents: $birthEventsCount, AbortedPregnancies: $abortedPregnanciesCount, '
        'Milkings: $milkingsCount, Pregnancies: $pregnanciesCount, '
        'Inseminations: $inseminationsCount, Dryoffs: $dryoffsCount, '
        'Transfers: $transfersCount, Vaccines: $vaccinesCount)',
      );
      
    } else if (userType == 'system_user') {
      log('  👨‍💼 [SYNC] System user - uses admin endpoints (no local data storage)');
    } else {
      log('  ⚠️ [SYNC] Unknown or missing user type: "$userType" - no user-specific data stored');
    }
  }
}

class SyncUnsyncedSummary {
  final int farms;
  final int livestock;
  final int vaccines;
  final int farmUsers;
  final Map<String, int> logCounts;

  const SyncUnsyncedSummary({
    required this.farms,
    required this.livestock,
    required this.vaccines,
    required this.farmUsers,
    required this.logCounts,
  });

  const SyncUnsyncedSummary.empty()
      : farms = 0,
        livestock = 0,
        vaccines = 0,
        farmUsers = 0,
        logCounts = const {};

  int get totalPending =>
      farms + livestock + vaccines + farmUsers + logCounts.values.fold<int>(0, (acc, value) => acc + value);

  bool get hasPending => totalPending > 0;
}
