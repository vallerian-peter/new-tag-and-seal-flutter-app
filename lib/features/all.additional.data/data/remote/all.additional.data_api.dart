import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/endpoints.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/country_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/identity_card_type_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/region_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/district_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/school_level_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/ward_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/village_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/street_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/division_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/feeding_type.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/administration_route.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine_type.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/disease.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/disposal_type.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/milking_method.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/heat_type.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/insemination_service.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/semen_straw_type.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/test_result.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/calving_type.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/calving_problem.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/reproductive_problem.dart'
    as log;
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/specie_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/livestock_type_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/livestock_obtained_method_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/breed_model.dart';

/// Location Service
/// 
/// A clean, focused service for fetching location data from the remote API.
/// This service handles:
/// - Remote data fetching (no local storage/caching)
/// - Secure authentication with Bearer tokens
/// - JSON parsing and model transformation
/// - Error handling and response validation
/// 
/// Design principles:
/// - Single Responsibility: Only handles API communication
/// - No State Management: Stateless service methods
/// - No Caching: Repository layer handles caching
/// - Clean API: Simple, focused methods
/// - Security: Uses Flutter Secure Storage for tokens
class AllAdditionalDataService {
  // Private constructor to prevent instantiation
  AllAdditionalDataService._();

  // ============================================================================
  // Configuration & Headers
  // ============================================================================
  
  /// Secure storage instance for storing sensitive data
  static const _secureStorage = FlutterSecureStorage();
  
  /// Secure storage key for authentication token
  static const String _tokenKey = 'auth_token';
  
  /// Get authentication token from secure storage
  /// 
  /// Returns null if no token is stored.
  /// Uses Flutter Secure Storage for enhanced security.
  static Future<String?> _getAuthToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw Exception('Failed to retrieve auth token from secure storage: $e');
    }
  }
  
  /// Build HTTP headers with authentication
  /// 
  /// Includes:
  /// - Content-Type: application/json
  /// - Accept: application/json
  /// - Authorization: Bearer {token} (if available)
  static Future<Map<String, String>> _buildHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============================================================================
  // Remote Fetch Methods
  // ============================================================================
  
  /// Fetch all location data from remote API
  /// 
  /// This method makes a single API call to retrieve all location data:
  /// - Countries
  /// - Regions
  /// - Districts
  /// - Wards
  /// - Villages
  /// - Streets
  /// 
  /// Returns a Map containing all location data with typed model lists.
  /// 
  /// Throws an exception if:
  /// - Network request fails
  /// - Response status is not 200
  /// - Response format is invalid
  /// - JSON parsing fails
  /// 
  /// Example usage:
  /// ```dart
  /// try {
  ///   final data = await LocationService.fetchAllLocations();
  ///   final countries = data['countries'] as List<CountryModel>;
  ///   print('Fetched ${countries.length} countries');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
  static Future<Map<String, dynamic>> fetchAllAdditionalData() async {
    try {
      // Build headers with auth token
      final headers = await _buildHeaders();
      
      // Make GET request to fetch all locations
      final response = await http.get(
        Uri.parse(ApiEndpoints.initialRegisterSync),
        headers: headers,
      );
      
      // Check response status
      if (response.statusCode == 200) {
        return _parseAllAdditionalDataResponse(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: You do not have permission to access locations');
      } else if (response.statusCode == 404) {
        throw Exception('Location endpoint not found');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error: Please try again later');
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================
  
  /// Parse location data from API response
  /// 
  /// Validates response structure and transforms JSON into typed models.
  /// 
  /// Expected response format:
  /// ```json
  /// {
  ///   "status": true,
  ///   "message": "Success",
  ///   "data": {
  ///     "countries": [...],
  ///     "regions": [...],
  ///     "districts": [...],
  ///     "wards": [...],
  ///     "villages": [...],
  ///     "streets": [...],
  ///     "divisions": [...]
  ///   }
  /// }
  /// ```
  static Map<String, dynamic> _parseAllAdditionalDataResponse(String responseBody) {
    try {
      // Decode JSON
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      
      // Validate response structure
      if (json['status'] != true) {
        final message = json['message'] ?? 'Unknown error';
        throw Exception('API returned error: $message');
      }
      
      final data = json['data'];
      if (data == null) {
        throw Exception('Response data is null');
      }
      
      // Parse and transform each location/reference type
      final locations = data['locations'] ?? {};
      final referenceData = data;
      final livestockRef = data['livestockReferenceData'] ?? {};

      return {
        'countries': _parseCountries(locations['countries']),
        'regions': _parseRegions(locations['regions']),
        'districts': _parseDistricts(locations['districts']),
        'wards': _parseWards(locations['wards']),
        'villages': _parseVillages(locations['villages']),
        'streets': _parseStreets(locations['streets']),
        'divisions': _parseDivisions(locations['divisions']),
        'identityCardTypes': _parseIdentityCardTypes(referenceData['identityCardTypes']),
        'schoolLevels': _parseSchoolLevels(referenceData['schoolLevels']),
        // Livestock reference data (optional on this endpoint)
        'species': _parseSpecies(livestockRef['species'] ?? referenceData['species']),
        'livestockTypes': _parseLivestockTypes(livestockRef['livestockTypes'] ?? referenceData['livestockTypes']),
        'livestockObtainedMethods': _parseLivestockObtainedMethods(livestockRef['livestockObtainedMethods'] ?? referenceData['livestockObtainedMethods']),
        'breeds': _parseBreeds(livestockRef['breeds'] ?? referenceData['breeds']),
        'feedingTypes': _parseFeedingTypes(referenceData['feedingTypes']),
        'administrationRoutes': _parseAdministrationRoutes(referenceData['administrationRoutes']),
        'medicineTypes': _parseMedicineTypes(referenceData['medicineTypes']),
        'medicines': _parseMedicines(referenceData['medicines']),
        'diseases': _parseDiseases(referenceData['diseases']),
        'disposalTypes': _parseDisposalTypes(referenceData['disposalTypes']),
        'milkingMethods': _parseMilkingMethods(referenceData['milkingMethods']),
        'heatTypes': _parseHeatTypes(referenceData['heatTypes']),
        'inseminationServices': _parseInseminationServices(referenceData['inseminationServices']),
        'semenStrawTypes': _parseSemenStrawTypes(referenceData['semenStrawTypes']),
        'testResults': _parseTestResults(referenceData['testResults']),
        'calvingTypes': _parseCalvingTypes(referenceData['calvingTypes']),
        'calvingProblems': _parseCalvingProblems(referenceData['calvingProblems']),
        'reproductiveProblems': _parseReproductiveProblems(referenceData['reproductiveProblems']),
      };
    } catch (e) {
      throw Exception('Failed to parse location response: $e');
    }
  }

  /// Parse identity card types from JSON array
  static List<IdentityCardTypeModel> _parseIdentityCardTypes(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => IdentityCardTypeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parse school levels from JSON array
  static List<SchoolLevelModel> _parseSchoolLevels(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => SchoolLevelModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  
  /// Parse countries from JSON array
  static List<CountryModel> _parseCountries(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  
  /// Parse regions from JSON array
  static List<RegionModel> _parseRegions(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => RegionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  
  /// Parse districts from JSON array
  static List<DistrictModel> _parseDistricts(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => DistrictModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  
  /// Parse wards from JSON array
  static List<WardModel> _parseWards(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => WardModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  
  /// Parse villages from JSON array
  static List<VillageModel> _parseVillages(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => VillageModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  
  /// Parse streets from JSON array
  static List<StreetModel> _parseStreets(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => StreetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  
  /// Parse divisions from JSON array
  static List<DivisionModel> _parseDivisions(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => DivisionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parse species from JSON array
  static List<SpecieModel> _parseSpecies(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => SpecieModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parse livestock types from JSON array
  static List<LivestockTypeModel> _parseLivestockTypes(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => LivestockTypeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parse livestock obtained methods from JSON array
  static List<LivestockObtainedMethodModel> _parseLivestockObtainedMethods(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => LivestockObtainedMethodModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parse breeds from JSON array
  static List<BreedModel> _parseBreeds(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => BreedModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parse feeding types from JSON array (log reference data)
  static List<log.FeedingType> _parseFeedingTypes(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.FeedingType.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parse administration routes from JSON array (log reference data)
  static List<log.AdministrationRoute> _parseAdministrationRoutes(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.AdministrationRoute.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parse medicine types from JSON array (log reference data)
  static List<log.MedicineType> _parseMedicineTypes(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.MedicineType.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Parse medicines from JSON array (log reference data)
  static List<log.Medicine> _parseMedicines(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.Medicine.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<log.Disease> _parseDiseases(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.Disease.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<log.DisposalType> _parseDisposalTypes(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.DisposalType.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<log.MilkingMethod> _parseMilkingMethods(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.MilkingMethod.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<log.HeatType> _parseHeatTypes(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.HeatType.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<log.InseminationService> _parseInseminationServices(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map(
          (item) => log.InseminationService.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  static List<log.SemenStrawType> _parseSemenStrawTypes(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.SemenStrawType.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<log.TestResult> _parseTestResults(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.TestResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<log.CalvingType> _parseCalvingTypes(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.CalvingType.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<log.CalvingProblem> _parseCalvingProblems(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map((item) => log.CalvingProblem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<log.ReproductiveProblem> _parseReproductiveProblems(dynamic json) {
    if (json == null) return [];
    return (json as List<dynamic>)
        .map(
          (item) => log.ReproductiveProblem.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}

