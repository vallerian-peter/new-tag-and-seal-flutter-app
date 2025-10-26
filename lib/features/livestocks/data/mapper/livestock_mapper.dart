import 'package:new_tag_and_seal_flutter_app/features/livestocks/domain/models/livestock_model.dart';

/// Mapper for Livestock entity following the same pattern as other mappers
///
/// This mapper provides conversion methods between Livestock domain models and database entities.
/// It handles the mapping between database records and domain models for livestock information.
class LivestockMapper {

  // ==================== LIVESTOCK MAPPERS ====================

  /// Maps Livestock entity to LivestockModel
  ///
  /// [entity] - The database entity from the Livestocks table
  /// Returns a LivestockModel with the mapped data
  static LivestockModel livestockToEntity(Map<String, dynamic> entity) {
    return LivestockModel(
      id: entity['id'] as int,
      farmUuid: entity['farmUuid'] as String,  // Farm UUID
      uuid: entity['uuid'] as String,
      identificationNumber: entity['identificationNumber'] as String,
      dummyTagId: entity['dummyTagId'] as String,
      barcodeTagId: entity['barcodeTagId'] as String,
      rfidTagId: entity['rfidTagId'] as String,
      livestockTypeId: entity['livestockTypeId'] as int,
      name: entity['name'] as String,
      dateOfBirth: entity['dateOfBirth'] as String,
      motherUuid: entity['motherUuid'] as String?,  // Mother UUID
      fatherUuid: entity['fatherUuid'] as String?,  // Father UUID
      gender: entity['gender'] as String,
      breedId: entity['breedId'] as int,
      speciesId: entity['speciesId'] as int,
      status: entity['status'] as String? ?? 'active',
      livestockObtainedMethodId: entity['livestockObtainedMethodId'] as int,
      dateFirstEnteredToFarm: DateTime.parse(entity['dateFirstEnteredToFarm'] as String),
      weightAsOnRegistration: (entity['weightAsOnRegistration'] as num).toDouble(),
      synced: entity['synced'] as bool? ?? false,
      syncAction: entity['syncAction'] as String? ?? 'create',
      createdAt: entity['createdAt'] as String,
      updatedAt: entity['updatedAt'] as String,
    );
  }

  /// Maps LivestockModel to database insert values
  ///
  /// [model] - The LivestockModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> livestockToSql(LivestockModel model) {
    return {
      'id': model.id,
      'farmUuid': model.farmUuid,
      'uuid': model.uuid,
      'identificationNumber': model.identificationNumber,
      'dummyTagId': model.dummyTagId,
      'barcodeTagId': model.barcodeTagId,
      'rfidTagId': model.rfidTagId,
      'livestockTypeId': model.livestockTypeId,
      'name': model.name,
      'dateOfBirth': model.dateOfBirth,
      'motherUuid': model.motherUuid,
      'fatherUuid': model.fatherUuid,
      'gender': model.gender,
      'breedId': model.breedId,
      'speciesId': model.speciesId,
      'status': model.status,
      'livestockObtainedMethodId': model.livestockObtainedMethodId,
      'dateFirstEnteredToFarm': model.dateFirstEnteredToFarm.toIso8601String(),
      'weightAsOnRegistration': model.weightAsOnRegistration,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  /// Maps LivestockModel to database update values
  ///
  /// [model] - The LivestockModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> livestockToUpdateSql(LivestockModel model) {
    return {
      'farmUuid': model.farmUuid,
      'uuid': model.uuid,
      'identificationNumber': model.identificationNumber,
      'dummyTagId': model.dummyTagId,
      'barcodeTagId': model.barcodeTagId,
      'rfidTagId': model.rfidTagId,
      'livestockTypeId': model.livestockTypeId,
      'name': model.name,
      'dateOfBirth': model.dateOfBirth,
      'motherUuid': model.motherUuid,
      'fatherUuid': model.fatherUuid,
      'gender': model.gender,
      'breedId': model.breedId,
      'speciesId': model.speciesId,
      'status': model.status,
      'livestockObtainedMethodId': model.livestockObtainedMethodId,
      'dateFirstEnteredToFarm': model.dateFirstEnteredToFarm.toIso8601String(),
      'weightAsOnRegistration': model.weightAsOnRegistration,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  // ==================== BATCH OPERATIONS ====================

  /// Maps a list of Livestock entities to LivestockModel list
  ///
  /// [entities] - List of database entities from the Livestocks table
  /// Returns a list of LivestockModel objects
  static List<LivestockModel> livestocksToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => livestockToEntity(entity)).toList();
  }
}
