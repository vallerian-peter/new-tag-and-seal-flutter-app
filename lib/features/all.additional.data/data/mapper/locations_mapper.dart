import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/country_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/region_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/district_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/division_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/ward_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/village_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/street_model.dart';

/// Comprehensive mapper for all location entities following hierarchical order:
/// Country -> Region -> District -> Division/Ward -> Street
/// 
/// This mapper provides conversion methods between domain models and database entities.
/// It follows the hierarchical structure of locations in the system.
class LocationsMapper {
  
  // ==================== COUNTRY MAPPERS ====================
  
  /// Maps Country entity to CountryModel
  /// 
  /// [entity] - The database entity from the Country table
  /// Returns a CountryModel with the mapped data
  static CountryModel countryToEntity(Map<String, dynamic> entity) {
    return CountryModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
      shortName: entity['shortName'] as String,
    );
  }

  /// Maps CountryModel to database insert values
  /// 
  /// [model] - The CountryModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> countryToSql(CountryModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'shortName': model.shortName,
    };
  }

  /// Maps CountryModel to database update values
  /// 
  /// [model] - The CountryModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> countryToUpdateSql(CountryModel model) {
    return {
      'name': model.name,
      'shortName': model.shortName,
    };
  }

  // ==================== REGION MAPPERS ====================
  
  /// Maps Region entity to RegionModel
  /// 
  /// [entity] - The database entity from the Region table
  /// Returns a RegionModel with the mapped data
  static RegionModel regionToEntity(Map<String, dynamic> entity) {
    return RegionModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
      shortName: entity['shortName'] as String,
      countryId: entity['countryId'] as int,
    );
  }

  /// Maps RegionModel to database insert values
  /// 
  /// [model] - The RegionModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> regionToSql(RegionModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'shortName': model.shortName,
      'countryId': model.countryId,
    };
  }

  /// Maps RegionModel to database update values
  /// 
  /// [model] - The RegionModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> regionToUpdateSql(RegionModel model) {
    return {
      'name': model.name,
      'shortName': model.shortName,
      'countryId': model.countryId,
    };
  }

  // ==================== DISTRICT MAPPERS ====================
  
  /// Maps District entity to DistrictModel
  /// 
  /// [entity] - The database entity from the District table
  /// Returns a DistrictModel with the mapped data
  static DistrictModel districtToEntity(Map<String, dynamic> entity) {
    return DistrictModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
      regionId: entity['regionId'] as int,
    );
  }

  /// Maps DistrictModel to database insert values
  /// 
  /// [model] - The DistrictModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> districtToSql(DistrictModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'regionId': model.regionId,
    };
  }

  /// Maps DistrictModel to database update values
  /// 
  /// [model] - The DistrictModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> districtToUpdateSql(DistrictModel model) {
    return {
      'name': model.name,
      'regionId': model.regionId,
    };
  }

  // ==================== DIVISION MAPPERS ====================
  
  /// Maps Division entity to DivisionModel
  /// 
  /// [entity] - The database entity from the Division table
  /// Returns a DivisionModel with the mapped data
  static DivisionModel divisionToEntity(Map<String, dynamic> entity) {
    return DivisionModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
      districtId: entity['districtId'] as int,
    );
  }

  /// Maps DivisionModel to database insert values
  /// 
  /// [model] - The DivisionModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> divisionToSql(DivisionModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'districtId': model.districtId,
    };
  }

  /// Maps DivisionModel to database update values
  /// 
  /// [model] - The DivisionModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> divisionToUpdateSql(DivisionModel model) {
    return {
      'name': model.name,
      'districtId': model.districtId,
    };
  }

  // ==================== WARD MAPPERS ====================
  
  /// Maps Ward entity to WardModel
  /// 
  /// [entity] - The database entity from the Ward table
  /// Returns a WardModel with the mapped data
  static WardModel wardToEntity(Map<String, dynamic> entity) {
    return WardModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
      districtId: entity['districtId'] as int,
    );
  }

  /// Maps WardModel to database insert values
  /// 
  /// [model] - The WardModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> wardToSql(WardModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'districtId': model.districtId,
    };
  }

  /// Maps WardModel to database update values
  /// 
  /// [model] - The WardModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> wardToUpdateSql(WardModel model) {
    return {
      'name': model.name,
      'districtId': model.districtId,
    };
  }

  // ==================== VILLAGE MAPPERS ====================
  
  /// Maps Village entity to VillageModel
  /// 
  /// [entity] - The database entity from the Village table
  /// Returns a VillageModel with the mapped data
  static VillageModel villageToEntity(Map<String, dynamic> entity) {
    return VillageModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
      wardId: entity['wardId'] as int,
    );
  }

  /// Maps VillageModel to database insert values
  /// 
  /// [model] - The VillageModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> villageToSql(VillageModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'wardId': model.wardId,
    };
  }

  /// Maps VillageModel to database update values
  /// 
  /// [model] - The VillageModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> villageToUpdateSql(VillageModel model) {
    return {
      'name': model.name,
      'wardId': model.wardId,
    };
  }

  // ==================== STREET MAPPERS ====================
  
  /// Maps Street entity to StreetModel
  /// 
  /// [entity] - The database entity from the Street table
  /// Returns a StreetModel with the mapped data
  static StreetModel streetToEntity(Map<String, dynamic> entity) {
    return StreetModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
      wardId: entity['wardId'] as int,
    );
  }

  /// Maps StreetModel to database insert values
  /// 
  /// [model] - The StreetModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> streetToSql(StreetModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'wardId': model.wardId,
    };
  }

  /// Maps StreetModel to database update values
  /// 
  /// [model] - The StreetModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> streetToUpdateSql(StreetModel model) {
    return {
      'name': model.name,
      'wardId': model.wardId,
    };
  }

  // ==================== BATCH OPERATIONS ====================
  
  /// Maps a list of Country entities to CountryModel list
  /// 
  /// [entities] - List of database entities from the Country table
  /// Returns a list of CountryModel objects
  static List<CountryModel> countriesToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => countryToEntity(entity)).toList();
  }

  /// Maps a list of Region entities to RegionModel list
  /// 
  /// [entities] - List of database entities from the Region table
  /// Returns a list of RegionModel objects
  static List<RegionModel> regionsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => regionToEntity(entity)).toList();
  }

  /// Maps a list of District entities to DistrictModel list
  /// 
  /// [entities] - List of database entities from the District table
  /// Returns a list of DistrictModel objects
  static List<DistrictModel> districtsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => districtToEntity(entity)).toList();
  }

  /// Maps a list of Division entities to DivisionModel list
  /// 
  /// [entities] - List of database entities from the Division table
  /// Returns a list of DivisionModel objects
  static List<DivisionModel> divisionsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => divisionToEntity(entity)).toList();
  }

  /// Maps a list of Ward entities to WardModel list
  /// 
  /// [entities] - List of database entities from the Ward table
  /// Returns a list of WardModel objects
  static List<WardModel> wardsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => wardToEntity(entity)).toList();
  }

  /// Maps a list of Village entities to VillageModel list
  /// 
  /// [entities] - List of database entities from the Village table
  /// Returns a list of VillageModel objects
  static List<VillageModel> villagesToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => villageToEntity(entity)).toList();
  }

  /// Maps a list of Street entities to StreetModel list
  /// 
  /// [entities] - List of database entities from the Street table
  /// Returns a list of StreetModel objects
  static List<StreetModel> streetsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => streetToEntity(entity)).toList();
  }
}
