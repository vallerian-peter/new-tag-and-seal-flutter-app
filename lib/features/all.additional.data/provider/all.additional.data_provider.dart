import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/data/repository/all.additional.data_repository.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/country_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/region_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/district_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/ward_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/village_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/street_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/division_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/identity_card_type_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/school_level_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/specie_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/livestock_type_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/livestock_obtained_method_model.dart';
import 'package:new_tag_and_seal_flutter_app/core/check-network/network_check.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// Additional Data Provider
/// 
/// Manages all additional data for registration including:
/// - Locations (countries, regions, districts, wards, villages, streets, divisions)
/// - Identity Card Types
/// - School Levels
class AdditionalDataProvider extends ChangeNotifier {
  final AllAdditionalDataRepository _additionalDataRepository;

  // ============================================================================
  // Constructor
  // ============================================================================

  AdditionalDataProvider({required AllAdditionalDataRepository additionalDataRepository})
      : _additionalDataRepository = additionalDataRepository;

  // ============================================================================
  // Location Data State
  // ============================================================================

  /// Loading state for location data
  bool _isLoadingLocations = false;
  bool get isLoadingLocations => _isLoadingLocations;

  /// Error state for location data
  String? _locationError;
  String? get locationError => _locationError;

  /// Additional data cache
  List<CountryModel> _countries = [];
  List<RegionModel> _regions = [];
  List<DistrictModel> _districts = [];
  List<WardModel> _wards = [];
  List<VillageModel> _villages = [];
  List<StreetModel> _streets = [];
  List<DivisionModel> _divisions = [];
  List<IdentityCardTypeModel> _identityCardTypes = [];
  List<SchoolLevelModel> _schoolLevels = [];
  List<SpecieModel> _species = [];
  List<LivestockTypeModel> _livestockTypes = [];
  List<LivestockObtainedMethodModel> _livestockObtainedMethods = [];

  /// Getters for all data
  List<CountryModel> get countries => _countries;
  List<RegionModel> get regions => _regions;
  List<DistrictModel> get districts => _districts;
  List<WardModel> get wards => _wards;
  List<VillageModel> get villages => _villages;
  List<StreetModel> get streets => _streets;
  List<DivisionModel> get divisions => _divisions;
  List<IdentityCardTypeModel> get identityCardTypes => _identityCardTypes;
  List<SchoolLevelModel> get schoolLevels => _schoolLevels;
  List<SpecieModel> get species => _species;
  List<LivestockTypeModel> get livestockTypes => _livestockTypes;
  List<LivestockObtainedMethodModel> get livestockObtainedMethods => _livestockObtainedMethods;

  /// Check if data is loaded
  bool get hasLocationData => _countries.isNotEmpty && _identityCardTypes.isNotEmpty && _schoolLevels.isNotEmpty;

  /// Fetch all location data from remote API
  Future<void> fetchRemoteLocations() async {
    try {
      // 1. Check network connectivity first
      final networkCheck = NetworkCheck.instance;
      final isConnected = await networkCheck.isConnected;
      
      if (!isConnected) {
        // Set error state for network issue
        _isLoadingLocations = false;
        _locationError = 'No internet connection. Please check your network settings.';
        notifyListeners();
        throw NetworkException('No internet connection');
      }

      // 2. Set loading state
      _isLoadingLocations = true;
      _locationError = null;
      notifyListeners();

      // 3. Fetch all additional data from repository
      final additionalData = await _additionalDataRepository.getAllAdditionalData();

      // 4. Update local state
      _countries = additionalData['countries'] as List<CountryModel>? ?? [];
      _regions = additionalData['regions'] as List<RegionModel>? ?? [];
      _districts = additionalData['districts'] as List<DistrictModel>? ?? [];
      _wards = additionalData['wards'] as List<WardModel>? ?? [];
      _villages = additionalData['villages'] as List<VillageModel>? ?? [];
      _streets = additionalData['streets'] as List<StreetModel>? ?? [];
      _divisions = additionalData['divisions'] as List<DivisionModel>? ?? [];
      _identityCardTypes = additionalData['identityCardTypes'] as List<IdentityCardTypeModel>? ?? [];
      _schoolLevels = additionalData['schoolLevels'] as List<SchoolLevelModel>? ?? [];
      _species = additionalData['species'] as List<SpecieModel>? ?? [];
      _livestockTypes = additionalData['livestockTypes'] as List<LivestockTypeModel>? ?? [];
      _livestockObtainedMethods = additionalData['livestockObtainedMethods'] as List<LivestockObtainedMethodModel>? ?? [];

      // 5. Clear loading state
      _isLoadingLocations = false;
      notifyListeners();

    } on NetworkException catch (e) {
      // Handle network-specific errors
      _isLoadingLocations = false;
      _locationError = e.message;
      notifyListeners();
      rethrow; // Re-throw so UI can handle it
    } catch (e) {
      // Handle other errors (API, parsing, etc.)
      _isLoadingLocations = false;
      
      // Check if connection was lost during fetch
      final networkCheck = NetworkCheck.instance;
      final isStillConnected = await networkCheck.isConnected;
      
      if (!isStillConnected) {
        _locationError = 'Connection lost during fetch. Please try again.';
      } else {
        _locationError = 'Failed to fetch locations: ${e.toString()}';
      }
      
      notifyListeners();
      rethrow; // Re-throw so UI can handle it
    }
  }


  Future<bool> fetchLocationsWithDialogs(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // 1. Show loading
    AlertDialogs.showLoading(
      context: context,
      title: l10n.fetchingData,
      message: l10n.loadingLocations,
      isDismissible: false,
    );
    
    try {
      // 2. Fetch data
      await fetchRemoteLocations();
      
      // 3. Close loading & return success
      if (context.mounted) Navigator.pop(context);
      return true;
      
    } on NetworkException {
      // 4. Close loading
      if (context.mounted) Navigator.pop(context);
      
      // 5. Show network error with retry
      if (context.mounted) {
        await AlertDialogs.showNetworkIssues(
          context: context,
          title: l10n.noInternetConnection,
          message: l10n.noInternetConnectionMessage,
          retryText: l10n.tryAgain,
          cancelText: l10n.cancel,
          onRetry: () {
            Navigator.pop(context);
            fetchLocationsWithDialogs(context); // Retry
          },
          onCancel: () => Navigator.pop(context),
        );
      }
      return false;
      
    } catch (e) {
      // 6. Close loading
      if (context.mounted) Navigator.pop(context);
      
      // 7. Show error with retry
      if (context.mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.networkError,
          message: l10n.failedToLoadLocations,
          buttonText: l10n.tryAgain,
          onPressed: () {
            Navigator.pop(context);
            fetchLocationsWithDialogs(context); // Retry
          },
        );
      }
      return false;
    }
  }

  /// Get filtered regions by country ID
  /// 
  /// [countryId] - The country ID to filter by
  /// Returns filtered regions for the specified country
  List<RegionModel> getRegionsByCountry(int countryId) {
    return _regions.where((region) => region.countryId == countryId).toList();
  }

  /// Get filtered districts by region ID
  /// 
  /// [regionId] - The region ID to filter by
  /// Returns filtered districts for the specified region
  List<DistrictModel> getDistrictsByRegion(int regionId) {
    return _districts.where((district) => district.regionId == regionId).toList();
  }

  /// Get filtered wards by district ID
  /// 
  /// [districtId] - The district ID to filter by
  /// Returns filtered wards for the specified district
  List<WardModel> getWardsByDistrict(int districtId) {
    return _wards.where((ward) => ward.districtId == districtId).toList();
  }

  /// Get filtered villages by ward ID
  /// 
  /// [wardId] - The ward ID to filter by
  /// Returns filtered villages for the specified ward
  List<VillageModel> getVillagesByWard(int wardId) {
    return _villages.where((village) => village.wardId == wardId).toList();
  }

  /// Clear all additional data and reset state
  /// 
  /// Useful for logout or when refreshing data
  void clearLocationData() {
    _countries.clear();
    _regions.clear();
    _districts.clear();
    _wards.clear();
    _villages.clear();
    _streets.clear();
    _divisions.clear();
    _identityCardTypes.clear();
    _schoolLevels.clear();
    _species.clear();
    _livestockTypes.clear();
    _livestockObtainedMethods.clear();
    _locationError = null;
    _isLoadingLocations = false;
    notifyListeners();
  }

  /// Clear location error
  /// 
  /// Call this when user dismisses error or retries
  void clearLocationError() {
    _locationError = null;
    notifyListeners();
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Get filtered streets by ward ID
  /// 
  /// [wardId] - The ward ID to filter by
  /// Returns filtered streets for the specified ward
  List<StreetModel> getStreetsByWard(int wardId) {
    return _streets.where((street) => street.wardId == wardId).toList();
  }

  /// Get filtered divisions by district ID
  /// 
  /// [districtId] - The district ID to filter by
  /// Returns filtered divisions for the specified district
  List<DivisionModel> getDivisionsByDistrict(int districtId) {
    return _divisions.where((division) => division.districtId == districtId).toList();
  }

  // ============================================================================
  // Livestock Reference Data Methods
  // ============================================================================

  /// Get species by ID
  /// 
  /// [speciesId] - The species ID to find
  /// Returns the species model or null if not found
  SpecieModel? getSpeciesById(int speciesId) {
    try {
      return _species.firstWhere((s) => s.id == speciesId);
    } catch (e) {
      return null;
    }
  }

  /// Get livestock type by ID
  /// 
  /// [livestockTypeId] - The livestock type ID to find
  /// Returns the livestock type model or null if not found
  LivestockTypeModel? getLivestockTypeById(int livestockTypeId) {
    try {
      return _livestockTypes.firstWhere((lt) => lt.id == livestockTypeId);
    } catch (e) {
      return null;
    }
  }

  /// Get livestock obtained method by ID
  /// 
  /// [methodId] - The method ID to find
  /// Returns the livestock obtained method model or null if not found
  LivestockObtainedMethodModel? getLivestockObtainedMethodById(int methodId) {
    try {
      return _livestockObtainedMethods.firstWhere((m) => m.id == methodId);
    } catch (e) {
      return null;
    }
  }

  /// Check if location data is available for a specific hierarchy
  /// 
  /// Returns true if all location data is loaded
  bool isLocationDataReady() {
    return _countries.isNotEmpty &&
           _regions.isNotEmpty &&
           _districts.isNotEmpty &&
           _wards.isNotEmpty &&
           _villages.isNotEmpty;
  }

  /// Check if livestock reference data is loaded
  /// 
  /// Returns true if all livestock reference data is loaded
  bool isLivestockDataReady() {
    return _species.isNotEmpty &&
           _livestockTypes.isNotEmpty &&
           _livestockObtainedMethods.isNotEmpty;
  }

  // ============================================================================
  // Database Access Methods (via Repository)
  // ============================================================================

  /// Get species name by ID from database
  /// 
  /// [speciesId] - The species ID to find
  /// Returns the species name or '---' if not found
  Future<String> getSpeciesNameById(int speciesId) async {
    final name = await _additionalDataRepository.getSpeciesNameById(speciesId);
    return name ?? '---';
  }

  /// Get breed name by ID from database
  /// 
  /// [breedId] - The breed ID to find
  /// Returns the breed name or '---' if not found
  Future<String> getBreedNameById(int breedId) async {
    final name = await _additionalDataRepository.getBreedNameById(breedId);
    return name ?? '---';
  }

  /// Get livestock type name by ID from database
  /// 
  /// [livestockTypeId] - The livestock type ID to find
  /// Returns the livestock type name or '---' if not found
  Future<String> getLivestockTypeNameById(int livestockTypeId) async {
    final name = await _additionalDataRepository.getLivestockTypeNameById(livestockTypeId);
    return name ?? '---';
  }

  /// Get livestock obtained method name by ID from database
  /// 
  /// [methodId] - The method ID to find
  /// Returns the method name or '---' if not found
  Future<String> getLivestockObtainedMethodNameById(int methodId) async {
    final name = await _additionalDataRepository.getLivestockObtainedMethodNameById(methodId);
    return name ?? '---';
  }

  /// Get breeds by livestock type ID from database
  /// 
  /// [livestockTypeId] - The livestock type ID to filter by
  /// Returns list of breeds for the specified livestock type
  Future<List<dynamic>> getBreedsByLivestockTypeId(int livestockTypeId) async {
    return await _additionalDataRepository.getBreedsByLivestockTypeId(livestockTypeId);
  }

  /// Get all data statistics
  /// 
  /// Returns a map with counts of each data type
  Map<String, int> getLocationStats() {
    return {
      'countries': _countries.length,
      'regions': _regions.length,
      'districts': _districts.length,
      'wards': _wards.length,
      'villages': _villages.length,
      'streets': _streets.length,
      'divisions': _divisions.length,
      'identityCardTypes': _identityCardTypes.length,
      'schoolLevels': _schoolLevels.length,
    };
  }

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  @override
  void dispose() {
    // Clear data when provider is disposed
    clearLocationData();
    super.dispose();
  }
}

// ============================================================================
// Custom Exceptions
// ============================================================================

/// Exception thrown when there is no network connection
class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}