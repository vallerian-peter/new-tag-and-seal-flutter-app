import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/feeding_model.dart';

/// Mapper for Feeding entity following the same pattern as other mappers
///
/// This mapper provides conversion methods between Feeding domain models and database entities.
/// It handles the mapping between database records and domain models for feeding information.
class FeedingMapper {

  // ==================== FEEDING MAPPERS ====================

  /// Maps Feeding entity to FeedingModel
  ///
  /// [entity] - The database entity from the Feedings table
  /// Returns a FeedingModel with the mapped data
  static FeedingModel feedingToEntity(Map<String, dynamic> entity) {
    return FeedingModel(
      id: entity['id'] as int?,
      uuid: entity['uuid'] as String,
      feedingTypeId: entity['feedingTypeId'] as int,
      farmUuid: entity['farmUuid'] as String,
      livestockUuid: entity['livestockUuid'] as String,
      nextFeedingTime: entity['nextFeedingTime'] as String,
      amount: entity['amount'] as String,
      remarks: entity['remarks'] as String?,
      synced: entity['synced'] as bool? ?? true,
      syncAction: entity['syncAction'] as String? ?? 'server-create',
      createdAt: entity['createdAt'] as String,
      updatedAt: entity['updatedAt'] as String
    );
  }

  /// Maps FeedingModel to database insert values
  ///
  /// [model] - The FeedingModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> feedingToSql(FeedingModel model) {
    return {
      'id': model.id,
      'uuid': model.uuid,
      'feedingTypeId': model.feedingTypeId,
      'farmUuid': model.farmUuid,
      'livestockUuid': model.livestockUuid,
      'nextFeedingTime': model.nextFeedingTime,
      'amount': model.amount,
      'remarks': model.remarks,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  /// Maps FeedingModel to database update values
  ///
  /// [model] - The FeedingModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> feedingToUpdateSql(FeedingModel model) {
    return {
      'uuid': model.uuid,
      'feedingTypeId': model.feedingTypeId,
      'farmUuid': model.farmUuid,
      'livestockUuid': model.livestockUuid,
      'nextFeedingTime': model.nextFeedingTime,
      'amount': model.amount,
      'remarks': model.remarks,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  // ==================== BATCH OPERATIONS ====================

  /// Maps a list of Feeding entities to FeedingModel list
  ///
  /// [entities] - List of database entities from the Feedings table
  /// Returns a list of FeedingModel objects
  static List<FeedingModel> feedingsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => feedingToEntity(entity)).toList();
  }
}
