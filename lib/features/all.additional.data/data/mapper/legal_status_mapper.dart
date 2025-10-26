import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/legal_status_model.dart';

/// Mapper for LegalStatus entity following the same pattern as other mappers
/// 
/// This mapper provides conversion methods between LegalStatus domain models and database entities.
/// It handles the mapping between database records and domain models for legal status information.
class LegalStatusMapper {
  
  // ==================== LEGAL STATUS MAPPERS ====================
  
  /// Maps LegalStatus entity to LegalStatusModel
  /// 
  /// [entity] - The database entity from the LegalStatus table
  /// Returns a LegalStatusModel with the mapped data
  static LegalStatusModel legalStatusToEntity(Map<String, dynamic> entity) {
    return LegalStatusModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
    );
  }

  /// Maps LegalStatusModel to database insert values
  /// 
  /// [model] - The LegalStatusModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> legalStatusToSql(LegalStatusModel model) {
    return {
      'id': model.id,
      'name': model.name,
    };
  }

  /// Maps LegalStatusModel to database update values
  /// 
  /// [model] - The LegalStatusModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> legalStatusToUpdateSql(LegalStatusModel model) {
    return {
      'name': model.name,
    };
  }

  // ==================== BATCH OPERATIONS ====================
  
  /// Maps a list of LegalStatus entities to LegalStatusModel list
  /// 
  /// [entities] - List of database entities from the LegalStatus table
  /// Returns a list of LegalStatusModel objects
  static List<LegalStatusModel> legalStatusesToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => legalStatusToEntity(entity)).toList();
  }
}