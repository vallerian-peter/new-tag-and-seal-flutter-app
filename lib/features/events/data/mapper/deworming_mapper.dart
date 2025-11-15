import 'package:new_tag_and_seal_flutter_app/features/events/domain/model/deworming_model.dart';

class DewormingMapper {
  static DewormingModel fromEntity(Map<String, dynamic> entity) {
    return DewormingModel(
      id: entity['id'] as int?,
      uuid: entity['uuid'] as String,
      farmUuid: entity['farmUuid'] as String,
      livestockUuid: entity['livestockUuid'] as String,
      administrationRouteId: entity['administrationRouteId'] as int?,
      medicineId: entity['medicineId'] as int?,
      vetId: entity['vetId'] as String?,
      extensionOfficerId: entity['extensionOfficerId'] as String?,
      quantity: entity['quantity'] as String?,
      dose: entity['dose'] as String?,
      nextAdministrationDate: entity['nextAdministrationDate'] as String?,
      synced: entity['synced'] as bool? ?? true,
      syncAction: entity['syncAction'] as String? ?? 'server-create',
      createdAt: entity['createdAt'] as String,
      updatedAt: entity['updatedAt'] as String,
    );
  }

  static Map<String, dynamic> toSql(DewormingModel model) {
    return {
      'id': model.id,
      'uuid': model.uuid,
      'farmUuid': model.farmUuid,
      'livestockUuid': model.livestockUuid,
      'administrationRouteId': model.administrationRouteId,
      'medicineId': model.medicineId,
      'vetId': model.vetId,
      'extensionOfficerId': model.extensionOfficerId,
      'quantity': model.quantity,
      'dose': model.dose,
      'nextAdministrationDate': model.nextAdministrationDate,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  static Map<String, dynamic> toUpdateSql(DewormingModel model) {
    return {
      'uuid': model.uuid,
      'farmUuid': model.farmUuid,
      'livestockUuid': model.livestockUuid,
      'administrationRouteId': model.administrationRouteId,
      'medicineId': model.medicineId,
      'vetId': model.vetId,
      'extensionOfficerId': model.extensionOfficerId,
      'quantity': model.quantity,
      'dose': model.dose,
      'nextAdministrationDate': model.nextAdministrationDate,
      'synced': model.synced,
      'syncAction': model.syncAction,
      'createdAt': model.createdAt,
      'updatedAt': model.updatedAt,
    };
  }

  static List<DewormingModel> fromEntities(List<Map<String, dynamic>> entities) {
    return entities.map(fromEntity).toList();
  }
}


