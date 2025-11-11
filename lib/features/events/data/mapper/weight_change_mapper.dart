import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/weight_change_model.dart';

class WeightChangeMapper {
  // ==================== WEIGHT CHANGE MAPPERS ====================

  static WeightChangeModel weightToEntity(Map<String, dynamic> entity) {
    return WeightChangeModel(
      id: entity['id'] as int?,
      uuid: entity['uuid'] as String,
      farmUuid: entity['farmUuid'] as String,
      livestockUuid: entity['livestockUuid'] as String,
      oldWeight: entity['oldWeight'] as String?,
      newWeight: entity['newWeight'] as String,
      remarks: entity['remarks'] as String?,
      synced: entity['synced'] as bool? ?? true,
      syncAction: entity['syncAction'] as String? ?? 'server-create',
      createdAt: entity['createdAt'] as String,
      updatedAt: entity['updatedAt'] as String,
    );
  }

  static Map<String, dynamic> weightToSql(WeightChangeModel model) {
    return {
      'id': model.id,
      'uuid': model.uuid,
      'farmUuid': model.farmUuid,
      'livestockUuid': model.livestockUuid,
      'oldWeight': model.oldWeight,
      'newWeight': model.newWeight,
      'remarks': model.remarks,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  static Map<String, dynamic> weightToUpdateSql(WeightChangeModel model) {
    return {
      'uuid': model.uuid,
      'farmUuid': model.farmUuid,
      'livestockUuid': model.livestockUuid,
      'oldWeight': model.oldWeight,
      'newWeight': model.newWeight,
      'remarks': model.remarks,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  static List<WeightChangeModel> weightsToEntities(
    List<Map<String, dynamic>> entities,
  ) {
    return entities.map((entity) => weightToEntity(entity)).toList();
  }
}
