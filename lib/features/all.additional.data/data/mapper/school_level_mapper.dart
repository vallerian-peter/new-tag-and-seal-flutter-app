import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/school_level_model.dart';

/// Mapper for SchoolLevel entity following the same pattern as LocationsMapper
/// 
/// This mapper provides conversion methods between SchoolLevel domain models and database entities.
class SchoolLevelMapper {
  
  // ==================== SCHOOL LEVEL MAPPERS ====================
  
  /// Maps SchoolLevel entity to SchoolLevelModel
  /// 
  /// [entity] - The database entity from the SchoolLevel table
  /// Returns a SchoolLevelModel with the mapped data
  static SchoolLevelModel schoolLevelToEntity(Map<String, dynamic> entity) {
    return SchoolLevelModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
    );
  }

  /// Maps SchoolLevelModel to database insert values
  /// 
  /// [model] - The SchoolLevelModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> schoolLevelToSql(SchoolLevelModel model) {
    return {
      'id': model.id,
      'name': model.name,
    };
  }

  /// Maps SchoolLevelModel to database update values
  /// 
  /// [model] - The SchoolLevelModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> schoolLevelToUpdateSql(SchoolLevelModel model) {
    return {
      'name': model.name,
    };
  }

  // ==================== BATCH OPERATIONS ====================
  
  /// Maps a list of SchoolLevel entities to SchoolLevelModel list
  /// 
  /// [entities] - List of database entities from the SchoolLevel table
  /// Returns a list of SchoolLevelModel objects
  static List<SchoolLevelModel> schoolLevelsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => schoolLevelToEntity(entity)).toList();
  }
}
