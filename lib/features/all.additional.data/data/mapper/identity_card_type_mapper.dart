import 'package:new_tag_and_seal_flutter_app/features/all.additional.data/domain/models/identity_card_type_model.dart';

/// Mapper for IdentityCardType entity following the same pattern as LocationsMapper
/// 
/// This mapper provides conversion methods between IdentityCardType domain models and database entities.
class IdentityCardTypeMapper {
  
  // ==================== IDENTITY CARD TYPE MAPPERS ====================
  
  /// Maps IdentityCardType entity to IdentityCardTypeModel
  /// 
  /// [entity] - The database entity from the IdentityCardTypes table
  /// Returns an IdentityCardTypeModel with the mapped data
  static IdentityCardTypeModel identityCardTypeToEntity(Map<String, dynamic> entity) {
    return IdentityCardTypeModel(
      id: entity['id'] as int,
      name: entity['name'] as String,
    );
  }

  /// Maps IdentityCardTypeModel to database insert values
  /// 
  /// [model] - The IdentityCardTypeModel to convert
  /// Returns a Map suitable for database insertion
  static Map<String, dynamic> identityCardTypeToSql(IdentityCardTypeModel model) {
    return {
      'id': model.id,
      'name': model.name,
    };
  }

  /// Maps IdentityCardTypeModel to database update values
  /// 
  /// [model] - The IdentityCardTypeModel to convert
  /// Returns a Map suitable for database updates
  static Map<String, dynamic> identityCardTypeToUpdateSql(IdentityCardTypeModel model) {
    return {
      'name': model.name,
    };
  }

  // ==================== BATCH OPERATIONS ====================
  
  /// Maps a list of IdentityCardType entities to IdentityCardTypeModel list
  /// 
  /// [entities] - List of database entities from the IdentityCardTypes table
  /// Returns a list of IdentityCardTypeModel objects
  static List<IdentityCardTypeModel> identityCardTypesToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => identityCardTypeToEntity(entity)).toList();
  }
}
