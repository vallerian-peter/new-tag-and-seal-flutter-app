import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/feeding_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/administration_route.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine_type.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/domain/models/medicine.dart';

class LogAdditionalDataMapper {
  // ==================== FeedingType MAPPERS ====================

  /// Maps FeedingType entity to FeedingTypeModel
  ///
  /// [entity] - The database entity from the FeedingType table
  /// Returns a FeedingTypeModel with the mapped data
  static FeedingType feedingTypeToEntity(Map<String, dynamic> entity) {
    return FeedingType(id: entity['id'] as int, name: entity['name'] as String);
  }

  /// Maps FeedingTypeModel to database insert values
  ///
  /// [model] - The FeedingTypeModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> feedingTypeToSql(FeedingType model) {
    return {'id': model.id, 'name': model.name};
  }

  /// Maps FeedingTypeModel to database update values
  ///
  /// [model] - The FeedingTypeModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> feedingTypeToUpdateSql(FeedingType model) {
    return {'name': model.name};
  }
  // ==================== AdministrationRoute MAPPERS ====================

  static AdministrationRoute administrationRouteToEntity(
    Map<String, dynamic> entity,
  ) {
    return AdministrationRoute(
      id: entity['id'] as int,
      name: entity['name'] as String,
    );
  }

  static Map<String, dynamic> administrationRouteToSql(
    AdministrationRoute model,
  ) {
    return {'id': model.id, 'name': model.name};
  }

  static Map<String, dynamic> administrationRouteToUpdateSql(
    AdministrationRoute model,
  ) {
    return {'name': model.name};
  }

  // ==================== MedicineType MAPPERS ====================

  static MedicineType medicineTypeToEntity(Map<String, dynamic> entity) {
    return MedicineType(
      id: entity['id'] as int,
      name: entity['name'] as String,
    );
  }

  static Map<String, dynamic> medicineTypeToSql(MedicineType model) {
    return {'id': model.id, 'name': model.name};
  }

  static Map<String, dynamic> medicineTypeToUpdateSql(MedicineType model) {
    return {'name': model.name};
  }

  // ==================== Medicine MAPPERS ====================

  static Medicine medicineToEntity(Map<String, dynamic> entity) {
    return Medicine(
      id: entity['id'] as int,
      name: entity['name'] as String,
      medicineTypeId: entity['medicineTypeId'] as int?,
    );
  }

  static Map<String, dynamic> medicineToSql(Medicine model) {
    return {
      'id': model.id,
      'name': model.name,
      'medicineTypeId': model.medicineTypeId,
    };
  }

  static Map<String, dynamic> medicineToUpdateSql(Medicine model) {
    return {'name': model.name, 'medicineTypeId': model.medicineTypeId};
  }
}
