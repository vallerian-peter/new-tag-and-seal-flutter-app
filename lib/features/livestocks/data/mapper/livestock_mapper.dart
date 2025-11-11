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
    // Handle dateFirstEnteredToFarm which can be:
    // - int (milliseconds timestamp from Drift DateTimeColumn)
    // - DateTime object
    // - String (from API)
    final dateFirstEnteredToFarmRaw = entity['dateFirstEnteredToFarm'];
    final parsedDate = dateFirstEnteredToFarmRaw is DateTime 
        ? dateFirstEnteredToFarmRaw 
        : dateFirstEnteredToFarmRaw is int
            ? DateTime.fromMillisecondsSinceEpoch(dateFirstEnteredToFarmRaw)
            : DateTime.parse(dateFirstEnteredToFarmRaw as String);
    
    // Safely convert synced field (can be int 0/1 from SQLite or bool from Dart)
    final syncedRaw = entity['synced'];
    final synced = syncedRaw is bool ? syncedRaw : (syncedRaw == 1 || syncedRaw == true);
    
    return LivestockModel(
      id: entity['id'] as int,
      farmUuid: entity['farmUuid'].toString(),  // Ensure string
      uuid: entity['uuid'].toString(),  // Ensure string
      identificationNumber: entity['identificationNumber'].toString(),  // Ensure string
      dummyTagId: entity['dummyTagId'].toString(),  // Ensure string
      barcodeTagId: entity['barcodeTagId'].toString(),  // Ensure string
      rfidTagId: entity['rfidTagId'].toString(),  // Ensure string
      livestockTypeId: entity['livestockTypeId'] as int,
      name: entity['name'].toString(),  // Ensure string
      dateOfBirth: entity['dateOfBirth'].toString(),  // Ensure string
      motherUuid: entity['motherUuid']?.toString(),  // Nullable, ensure string
      fatherUuid: entity['fatherUuid']?.toString(),  // Nullable, ensure string
      gender: entity['gender'].toString(),  // Ensure string
      breedId: entity['breedId'] as int,
      speciesId: entity['speciesId'] as int,
      status: entity['status']?.toString() ?? 'active',  // Ensure string
      livestockObtainedMethodId: entity['livestockObtainedMethodId'] as int,
      dateFirstEnteredToFarm: parsedDate,
      weightAsOnRegistration: _parseWeight(entity['weightAsOnRegistration']),
      synced: synced,
      syncAction: entity['syncAction']?.toString() ?? 'create',  // Ensure string
      createdAt: entity['createdAt'].toString(),  // Ensure string
      updatedAt: entity['updatedAt'].toString(),  // Ensure string
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

  /// Helper to parse weight which can be String (from backend) or num (from local DB)
  static double _parseWeight(dynamic weight) {
    if (weight == null) return 0.0;
    if (weight is num) return weight.toDouble();
    if (weight is String) {
      return double.tryParse(weight) ?? 0.0;
    }
    return 0.0;
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
