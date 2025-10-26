import 'package:new_tag_and_seal_flutter_app/features/farms/domain/models/farm_model.dart';

/// Mapper for Farm entity following the same pattern as other mappers
///
/// This mapper provides conversion methods between Farm domain models and database entities.
/// It handles the mapping between database records and domain models for farm information.
class FarmMapper {

  // ==================== FARM MAPPERS ====================

  /// Maps Farm entity to FarmModel
  ///
  /// [entity] - The database entity from the Farms table
  /// Returns a FarmModel with the mapped data
  static FarmModel farmToEntity(Map<String, dynamic> entity) {
    return FarmModel(
      id: entity['id'] as int,
      farmerId: entity['farmerId'] as int,
      uuid: entity['uuid'] as String,
      referenceNo: entity['referenceNo'] as String,
      regionalRegNo: entity['regionalRegNo'] as String,
      name: entity['name'] as String,
      size: entity['size']?.toString() ?? '0',  // Handle both num and String
      sizeUnit: entity['sizeUnit'] as String,
      latitudes: entity['latitudes']?.toString() ?? '0',  // Handle both num and String
      longitudes: entity['longitudes']?.toString() ?? '0',  // Handle both num and String
      physicalAddress: entity['physicalAddress'] as String,
      villageId: entity['villageId'] as int?,
      wardId: entity['wardId'] as int,
      districtId: entity['districtId'] as int,
      regionId: entity['regionId'] as int,
      countryId: entity['countryId'] as int,
      legalStatusId: entity['legalStatusId'] as int,
      status: entity['status'] as String? ?? 'active',
      synced: entity['synced'] as bool? ?? false,
      syncAction: entity['syncAction'] as String? ?? 'create',
      createdAt: entity['createdAt'] as String,
      updatedAt: entity['updatedAt'] as String,
    );
  }

  /// Maps FarmModel to database insert values
  ///
  /// [model] - The FarmModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> farmToSql(FarmModel model) {
    return {
      'id': model.id,
      'farmerId': model.farmerId,
      'uuid': model.uuid,
      'referenceNo': model.referenceNo,
      'regionalRegNo': model.regionalRegNo,
      'name': model.name,
      'size': model.size,
      'sizeUnit': model.sizeUnit,
      'latitudes': model.latitudes,
      'longitudes': model.longitudes,
      'physicalAddress': model.physicalAddress,
      'villageId': model.villageId,
      'wardId': model.wardId,
      'districtId': model.districtId,
      'regionId': model.regionId,
      'countryId': model.countryId,
      'legalStatusId': model.legalStatusId,
      'status': model.status,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  /// Maps FarmModel to database update values
  ///
  /// [model] - The FarmModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> farmToUpdateSql(FarmModel model) {
    return {
      'farmerId': model.farmerId,
      'uuid': model.uuid,
      'referenceNo': model.referenceNo,
      'regionalRegNo': model.regionalRegNo,
      'name': model.name,
      'size': model.size,
      'sizeUnit': model.sizeUnit,
      'latitudes': model.latitudes,
      'longitudes': model.longitudes,
      'physicalAddress': model.physicalAddress,
      'villageId': model.villageId,
      'wardId': model.wardId,
      'districtId': model.districtId,
      'regionId': model.regionId,
      'countryId': model.countryId,
      'legalStatusId': model.legalStatusId,
      'status': model.status,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  // ==================== BATCH OPERATIONS ====================

  /// Maps a list of Farm entities to FarmModel list
  ///
  /// [entities] - List of database entities from the Farms table
  /// Returns a list of FarmModel objects
  static List<FarmModel> farmsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => farmToEntity(entity)).toList();
  }
}
