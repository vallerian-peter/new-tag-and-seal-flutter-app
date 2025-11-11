import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/data/remote/all.additional.data_api.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/country_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/region_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/district_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/ward_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/village_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/street_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/division_model.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

/// All Additional Data Repository
/// 
/// This repository provides a clean interface for accessing all additional data
/// needed for registration: locations, identity card types, and school levels.
/// It can fetch from remote API or sync and store locally in the database.
class AllAdditionalDataRepository {
  final AppDatabase _database;
  
  // Cache for all additional data (for remote-only operations)
  Map<String, dynamic>? _cachedAllAdditionalData;

  AllAdditionalDataRepository(this._database);

  /// Fetch all additional data from API (REMOTE ONLY - NO LOCAL STORAGE)
  /// 
  /// Returns a map containing:
  /// - countries, regions, districts, wards, villages, streets, divisions
  /// - identityCardTypes
  /// - schoolLevels
  Future<Map<String, dynamic>> getAllAdditionalData() async {
    try {
      _cachedAllAdditionalData = await AllAdditionalDataService.fetchAllAdditionalData();
      return _cachedAllAdditionalData!;
    } catch (e) {
      throw Exception('Repository: Failed to fetch all additional data - $e');
    }
  }

  /// Store additional data locally from provided data (for splash sync)
  /// 
  /// This method takes pre-fetched data and stores it in the local database.
  /// Used when data is already fetched from splash sync endpoint.
  Future<void> storeDataLocally(Map<String, dynamic> data) async {
    try {
      // Extract the relevant sections
      final locations = data['locations'] ?? {};
      final referenceData = data['referenceData'] ?? {};
      final livestockReferenceData = data['livestockReferenceData'] ?? {};
      
      // Combine them into a single map for processing
      final remoteData = {
        'countries': locations['countries'],
        'regions': locations['regions'],
        'districts': locations['districts'],
        'wards': locations['wards'],
        'villages': locations['villages'],
        'streets': locations['streets'],
        'divisions': locations['divisions'],
        'identityCardTypes': referenceData['identityCardTypes'],
        'schoolLevels': referenceData['schoolLevels'],
        'legalStatuses': referenceData['legalStatuses'],
        'vaccineTypes': referenceData['vaccineTypes'],
        'disposalTypes': referenceData['disposalTypes'],
        
        'diseases': referenceData['diseases'],
        'heatTypes': referenceData['heatTypes'],
        'semenStrawTypes': referenceData['semenStrawTypes'],
        'inseminationServices': referenceData['inseminationServices'],
        'milkingMethods': referenceData['milkingMethods'],
        'calvingTypes': referenceData['calvingTypes'],
        'calvingProblems': referenceData['calvingProblems'],
        'reproductiveProblems': referenceData['reproductiveProblems'],
        'testResults': referenceData['testResults'],
        // Livestock reference data
        'species': livestockReferenceData['species'] ?? data['species'],
        'livestockTypes': livestockReferenceData['livestockTypes'] ?? data['livestockTypes'],
        'livestockObtainedMethods': livestockReferenceData['livestockObtainedMethods'] ?? data['livestockObtainedMethods'],
        'breeds': livestockReferenceData['breeds'] ?? data['breeds'],
      };
      
      // Store using the shared logic
      await _storeDataToDatabase(remoteData);
      
    } catch (e) {
      throw Exception('Repository: Failed to store additional data locally - $e');
    }
  }

  /// Sync all additional data from API and store locally in database
  /// 
  /// This method fetches data from remote API and stores it in the local database
  /// for offline access. Used during app initialization/splash sync.
  Future<void> syncAndStoreLocally() async {
    try {
      // Fetch all data from remote API
      final remoteData = await AllAdditionalDataService.fetchAllAdditionalData();
      
      // Store using the shared logic
      await _storeDataToDatabase(remoteData);
      
    } catch (e) {
      throw Exception('Repository: Failed to sync and store additional data locally - $e');
    }
  }

  /// Shared logic to store data to database
  /// 
  /// **Storage Strategy: UPSERT (Insert or Replace)**
  /// - Uses `InsertMode.insertOrReplace` 
  /// - If record exists (by ID) → REPLACE (UPDATE)
  /// - If record doesn't exist → INSERT
  /// - Records not in new data → REMAIN (not deleted)
  /// 
  /// **Why This Strategy:**
  /// - Reference data (countries, regions, etc.) rarely gets deleted
  /// - Preserves local data integrity
  /// - No need to clear and reload entire tables
  /// - Faster than delete-all-insert approach
  /// 
  /// **Note:** If exact server sync is needed (including deletions),
  /// use `clearAllReferenceData()` before calling this method.
  /// 
  /// This private method contains the actual database insertion logic
  /// Used by both storeDataLocally and syncAndStoreLocally
  Future<void> _storeDataToDatabase(Map<String, dynamic> remoteData) async {
    try {
      
      // Store countries (UPSERT by ID - replace if exists)
      if (remoteData['countries'] != null && (remoteData['countries'] as List).isNotEmpty) {
        final countryCompanions = (remoteData['countries'] as List)
            .map((json) => CountriesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  shortName: json['shortName'] ?? '',
                ))
            .toList();
        
        await _database.locationDao.insertCountries(countryCompanions);
      }

      // Store regions (UPSERT by ID - replace if exists)
      if (remoteData['regions'] != null && (remoteData['regions'] as List).isNotEmpty) {
        final regionCompanions = (remoteData['regions'] as List)
            .map((json) => RegionsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  countryId: json['countryId'] ?? 0,
                ))
            .toList();
        
        await _database.locationDao.insertRegions(regionCompanions);
      }

      // Store districts (UPSERT by ID - replace if exists)
      if (remoteData['districts'] != null && (remoteData['districts'] as List).isNotEmpty) {
        final districtCompanions = (remoteData['districts'] as List)
            .map((json) => DistrictsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  regionId: json['regionId'] ?? 0,
                ))
            .toList();
        
        await _database.locationDao.insertDistricts(districtCompanions);
      }

      // Store wards (UPSERT by ID - replace if exists)
      if (remoteData['wards'] != null && (remoteData['wards'] as List).isNotEmpty) {
        final wardCompanions = (remoteData['wards'] as List)
            .map((json) => WardsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  districtId: json['districtId'] ?? 0,
                ))
            .toList();
        
        await _database.locationDao.insertWards(wardCompanions);
      }

      // Store villages (UPSERT by ID - replace if exists)
      if (remoteData['villages'] != null && (remoteData['villages'] as List).isNotEmpty) {
        final villageCompanions = (remoteData['villages'] as List)
            .map((json) => VillagesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  wardId: json['wardId'] ?? 0,
                ))
            .toList();
        
        await _database.locationDao.insertVillages(villageCompanions);
      }
      
      // Store streets (UPSERT by ID - replace if exists)
      if (remoteData['streets'] != null && (remoteData['streets'] as List).isNotEmpty) {
        final streetCompanions = (remoteData['streets'] as List)
            .map((json) => StreetsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  wardId: json['wardId'] ?? 0,
                ))
            .toList();
        
        await _database.locationDao.insertStreets(streetCompanions);
      }

      // Store divisions (UPSERT by ID - replace if exists)
      if (remoteData['divisions'] != null && (remoteData['divisions'] as List).isNotEmpty) {
        final divisionCompanions = (remoteData['divisions'] as List)
            .map((json) => DivisionsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  districtId: json['districtId'] ?? 0,
                ))
            .toList();
        
        await _database.locationDao.insertDivisions(divisionCompanions);
      }

      // Store identity card types (UPSERT by ID - replace if exists)
      if (remoteData['identityCardTypes'] != null && (remoteData['identityCardTypes'] as List).isNotEmpty) {
        final identityCardTypeCompanions = (remoteData['identityCardTypes'] as List)
            .map((json) => IdentityCardTypesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();
        
        await _database.referenceDataDao.insertIdentityCardTypes(identityCardTypeCompanions);
      }

      // Store school levels (UPSERT by ID - replace if exists)
      if (remoteData['schoolLevels'] != null && (remoteData['schoolLevels'] as List).isNotEmpty) {
        final schoolLevelCompanions = (remoteData['schoolLevels'] as List)
            .map((json) => SchoolLevelsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();
        
        await _database.referenceDataDao.insertSchoolLevels(schoolLevelCompanions);
      }

      // Store legal statuses (UPSERT by ID - replace if exists)
      if (remoteData['legalStatuses'] != null && (remoteData['legalStatuses'] as List).isNotEmpty) {
        final legalStatusCompanions = (remoteData['legalStatuses'] as List)
            .map((json) => LegalStatusesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();
        
        await _database.referenceDataDao.insertLegalStatuses(legalStatusCompanions);
      }

      if (remoteData['vaccineTypes'] != null && (remoteData['vaccineTypes'] as List).isNotEmpty) {
        final vaccineTypeCompanions = (remoteData['vaccineTypes'] as List)
            .map((json) => VaccineTypesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        log('💉 Upserting ${vaccineTypeCompanions.length} vaccine types from sync payload');
        await _database.referenceDataDao.insertVaccineTypes(vaccineTypeCompanions);
      }

      if (remoteData['disposalTypes'] != null && (remoteData['disposalTypes'] as List).isNotEmpty) {
        final disposalTypeCompanions = (remoteData['disposalTypes'] as List)
            .map((json) => DisposalTypesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.logReferenceDao.upsertDisposalTypes(disposalTypeCompanions);
      }

      if (remoteData['diseases'] != null && (remoteData['diseases'] as List).isNotEmpty) {
        final diseaseCompanions = (remoteData['diseases'] as List)
            .map((json) => DiseasesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  status: Value(json['status'] as String?),
                ))
            .toList();

        await _database.logReferenceDao.upsertDiseases(diseaseCompanions);
      }

      if (remoteData['heatTypes'] != null && (remoteData['heatTypes'] as List).isNotEmpty) {
        final heatTypeCompanions = (remoteData['heatTypes'] as List)
            .map((json) => HeatTypesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.logReferenceDao.upsertHeatTypes(heatTypeCompanions);
      }

      if (remoteData['semenStrawTypes'] != null && (remoteData['semenStrawTypes'] as List).isNotEmpty) {
        final semenStrawTypeCompanions = (remoteData['semenStrawTypes'] as List)
            .map((json) => SemenStrawTypesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  category: Value(json['category'] ?? ''),
                ))
            .toList();

        await _database.logReferenceDao.upsertSemenStrawTypes(semenStrawTypeCompanions);
      }

      if (remoteData['inseminationServices'] != null && (remoteData['inseminationServices'] as List).isNotEmpty) {
        final inseminationServiceCompanions = (remoteData['inseminationServices'] as List)
            .map((json) => InseminationServicesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.logReferenceDao.upsertInseminationServices(inseminationServiceCompanions);
      }

      if (remoteData['milkingMethods'] != null && (remoteData['milkingMethods'] as List).isNotEmpty) {
        final milkingMethodCompanions = (remoteData['milkingMethods'] as List)
            .map((json) => MilkingMethodsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.logReferenceDao.upsertMilkingMethods(milkingMethodCompanions);
      }

      if (remoteData['calvingTypes'] != null && (remoteData['calvingTypes'] as List).isNotEmpty) {
        final calvingTypeCompanions = (remoteData['calvingTypes'] as List)
            .map((json) => CalvingTypesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.logReferenceDao.upsertCalvingTypes(calvingTypeCompanions);
      }

      if (remoteData['calvingProblems'] != null && (remoteData['calvingProblems'] as List).isNotEmpty) {
        final calvingProblemCompanions = (remoteData['calvingProblems'] as List)
            .map((json) => CalvingProblemsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.logReferenceDao.upsertCalvingProblems(calvingProblemCompanions);
      }

      if (remoteData['reproductiveProblems'] != null && (remoteData['reproductiveProblems'] as List).isNotEmpty) {
        final reproductiveProblemCompanions = (remoteData['reproductiveProblems'] as List)
            .map((json) => ReproductiveProblemsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.logReferenceDao.upsertReproductiveProblems(reproductiveProblemCompanions);
      }

      if (remoteData['testResults'] != null && (remoteData['testResults'] as List).isNotEmpty) {
        final testResultCompanions = (remoteData['testResults'] as List)
            .map((json) => TestResultsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.logReferenceDao.upsertTestResults(testResultCompanions);
      }

      // Store species (UPSERT by ID - replace if exists)
      if (remoteData['species'] != null && (remoteData['species'] as List).isNotEmpty) {
        final specieCompanions = (remoteData['species'] as List)
            .map((json) => SpeciesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.specieDao.insertSpecies(specieCompanions);
      }

      // Store livestock types (UPSERT by ID - replace if exists)
      if (remoteData['livestockTypes'] != null && (remoteData['livestockTypes'] as List).isNotEmpty) {
        final livestockTypeCompanions = (remoteData['livestockTypes'] as List)
            .map((json) => LivestockTypesCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.livestockTypeDao.insertLivestockTypes(livestockTypeCompanions);
      }

      // Store livestock obtained methods (UPSERT by ID - replace if exists)
      if (remoteData['livestockObtainedMethods'] != null && (remoteData['livestockObtainedMethods'] as List).isNotEmpty) {
        final obtainedMethodCompanions = (remoteData['livestockObtainedMethods'] as List)
            .map((json) => LivestockObtainedMethodsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                ))
            .toList();

        await _database.livestockObtainedMethodDao.insertLivestockObtainedMethods(obtainedMethodCompanions);
      }

      // Store breeds (UPSERT by ID - replace if exists)
      if (remoteData['breeds'] != null && (remoteData['breeds'] as List).isNotEmpty) {
        final breedCompanions = (remoteData['breeds'] as List)
            .map((json) => BreedsCompanion.insert(
                  id: Value(json['id'] ?? 0),
                  name: json['name'] ?? '',
                  group: json['group'] ?? '',
                  livestockTypeId: json['livestockTypeId'] ?? 0,
                ))
            .toList();

        await _database.breedDao.insertBreeds(breedCompanions);
      }

    } catch (e) {
      throw Exception('Repository: Failed to store data to database - $e');
    }
  }

  /// Get filtered location data
  /// 
  /// Returns filtered location data based on parent IDs.
  /// Note: If cache is empty, it will fetch all data first.
  Future<Map<String, dynamic>> getFilteredLocations({
    int? countryId,
    int? regionId,
    int? districtId,
    int? wardId,
  }) async {
    try {
      // If cache is empty, fetch all data first
      if (_cachedAllAdditionalData == null) {
        await getAllAdditionalData();
      }

      final data = _cachedAllAdditionalData!;

      // Get all data
      final countries = data['countries'] as List<CountryModel>;
      final regions = data['regions'] as List<RegionModel>;
      final districts = data['districts'] as List<DistrictModel>;
      final wards = data['wards'] as List<WardModel>;
      final villages = data['villages'] as List<VillageModel>;
      final streets = data['streets'] as List<StreetModel>;
      final divisions = data['divisions'] as List<DivisionModel>;

      // Apply filters
      final filteredRegions = countryId != null
          ? regions.where((r) => r.countryId == countryId).toList()
          : regions;

      final filteredDistricts = regionId != null
          ? districts.where((d) => d.regionId == regionId).toList()
          : districts;

      final filteredWards = districtId != null
          ? wards.where((w) => w.districtId == districtId).toList()
          : wards;

      final filteredVillages = wardId != null
          ? villages.where((v) => v.wardId == wardId).toList()
          : villages;

      final filteredStreets = wardId != null
          ? streets.where((s) => s.wardId == wardId).toList()
          : streets;

      final filteredDivisions = districtId != null
          ? divisions.where((d) => d.districtId == districtId).toList()
          : divisions;

      return {
        'countries': countries,
        'regions': filteredRegions,
        'districts': filteredDistricts,
        'wards': filteredWards,
        'villages': filteredVillages,
        'streets': filteredStreets,
        'divisions': filteredDivisions,
      };
    } catch (e) {
      throw Exception('Repository: Failed to get filtered locations - $e');
    }
  }

  /// Clear cached data
  /// 
  /// This method clears all cached additional data.
  /// Useful for forcing a fresh fetch from the API.
  void clearCache() {
    _cachedAllAdditionalData = null;
  }

  // ============================================================================
  // Livestock Reference Data Methods (Database Access)
  // ============================================================================

  /// Get species by ID from database
  /// 
  /// [speciesId] - The species ID to find
  /// Returns the species name or null if not found
  Future<String?> getSpeciesNameById(int speciesId) async {
    try {
      final species = await _database.specieDao.getSpecieById(speciesId);
      return species?.name;
    } catch (e) {
      return null;
    }
  }

  /// Get breed by ID from database
  /// 
  /// [breedId] - The breed ID to find
  /// Returns the breed name or null if not found
  Future<String?> getBreedNameById(int breedId) async {
    try {
      final breed = await _database.breedDao.getBreedById(breedId);
      return breed?.name;
    } catch (e) {
      return null;
    }
  }

  /// Get livestock type by ID from database
  /// 
  /// [livestockTypeId] - The livestock type ID to find
  /// Returns the livestock type name or null if not found
  Future<String?> getLivestockTypeNameById(int livestockTypeId) async {
    try {
      final livestockType = await _database.livestockTypeDao.getLivestockTypeById(livestockTypeId);
      return livestockType?.name;
    } catch (e) {
      return null;
    }
  }

  /// Get livestock obtained method by ID from database
  /// 
  /// [methodId] - The method ID to find
  /// Returns the method name or null if not found
  Future<String?> getLivestockObtainedMethodNameById(int methodId) async {
    try {
      final method = await _database.livestockObtainedMethodDao.getLivestockObtainedMethodById(methodId);
      return method?.name;
    } catch (e) {
      return null;
    }
  }

  /// Get all species from database
  /// 
  /// Returns list of all species stored locally
  Future<List<Specie>> getAllSpecies() async {
    try {
      return await _database.specieDao.getAllSpecies();
    } catch (e) {
      return [];
    }
  }

  /// Get all breeds from database
  /// 
  /// Returns list of all breeds stored locally
  Future<List<Breed>> getAllBreeds() async {
    try {
      return await _database.breedDao.getAllBreeds();
    } catch (e) {
      return [];
    }
  }

  /// Get breeds by livestock type ID from database
  /// 
  /// [livestockTypeId] - The livestock type ID to filter by
  /// Returns list of breeds for the specified livestock type
  Future<List<Breed>> getBreedsByLivestockTypeId(int livestockTypeId) async {
    try {
      return await _database.breedDao.getBreedsByLivestockTypeId(livestockTypeId);
    } catch (e) {
      return [];
    }
  }

  /// Get all livestock types from database
  /// 
  /// Returns list of all livestock types stored locally
  Future<List<LivestockType>> getAllLivestockTypes() async {
    try {
      return await _database.livestockTypeDao.getAllLivestockTypes();
    } catch (e) {
      return [];
    }
  }

  /// Get all livestock obtained methods from database
  /// 
  /// Returns list of all livestock obtained methods stored locally
  Future<List<LivestockObtainedMethod>> getAllLivestockObtainedMethods() async {
    try {
      return await _database.livestockObtainedMethodDao.getAllLivestockObtainedMethods();
    } catch (e) {
      return [];
    }
  }

  /// Clear all reference data from local database
  /// 
  /// **USE WITH CAUTION!**
  /// This method deletes ALL location and reference data from local database.
  /// 
  /// **When to use:**
  /// - When you need exact server sync (including deletions)
  /// - Before a full reload of reference data
  /// - During app reset/reinstall
  /// 
  /// **Note:** Not needed for normal sync operations. The UPSERT strategy
  /// handles most cases efficiently without clearing data.
  Future<void> clearAllReferenceData() async {
    try {
      // IMPORTANT: Temporarily disable foreign key constraints
      // This allows us to delete reference data even if Farms reference them
      // (We don't want to delete user's Farms during reference data sync!)
      await _database.customStatement('PRAGMA foreign_keys = OFF');
      
      // Delete location data (order doesn't matter with FK disabled)
      await _database.locationDao.deleteAllVillages();
      await _database.locationDao.deleteAllStreets();
      await _database.locationDao.deleteAllWards();
      await _database.locationDao.deleteAllDivisions();
      await _database.locationDao.deleteAllDistricts();
      await _database.locationDao.deleteAllRegions();
      await _database.locationDao.deleteAllCountries();
      
      // Delete all reference data
      await _database.referenceDataDao.deleteAllIdentityCardTypes();
      await _database.referenceDataDao.deleteAllSchoolLevels();
      await _database.referenceDataDao.deleteAllLegalStatuses();
      
      // Re-enable foreign key constraints
      await _database.customStatement('PRAGMA foreign_keys = ON');
      
    } catch (e) {
      // ALWAYS re-enable foreign keys, even on error
      try {
        await _database.customStatement('PRAGMA foreign_keys = ON');
      } catch (_) {}
      
      throw Exception('Repository: Failed to clear reference data - $e');
    }
  }

  /// Full sync with exact server state (includes deletions)
  /// 
  /// This method performs a complete sync that matches server state exactly:
  /// 1. Clears all existing reference data
  /// 2. Fetches fresh data from server
  /// 3. Stores new data locally
  /// 
  /// **When to use:**
  /// - When server may have deleted items
  /// - During major app updates
  /// - For complete data refresh
  /// 
  /// **Note:** More expensive than regular UPSERT sync. Use only when needed.
  Future<void> fullSyncWithDeletions(Map<String, dynamic> data) async {
    try {
      // Step 1: Clear all existing data
      await clearAllReferenceData();
      
      // Step 2: Store fresh data from server
      await storeDataLocally(data);
      
    } catch (e) {
      throw Exception('Repository: Failed to perform full sync with deletions - $e');
    }
  }
}