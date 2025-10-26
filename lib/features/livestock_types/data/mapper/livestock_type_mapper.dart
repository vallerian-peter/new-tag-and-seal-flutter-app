import '../../domain/models/livestock_type_model.dart';

/// Mapper for converting between LivestockType domain models and database entities
class LivestockTypeMapper {
  /// Convert database entity to domain model
  static LivestockTypeModel livestockTypeToEntity(Map<String, dynamic> entity) {
    return LivestockTypeModel(
      id: entity['id'] as int?,
      name: entity['name'] as String,
    );
  }

  /// Convert domain model to database entity for insert
  static Map<String, dynamic> livestockTypeToSql(LivestockTypeModel model) {
    return {
      'id': model.id,  // Include server-provided ID
      'name': model.name,
    };
  }

  /// Convert domain model to database entity for update
  static Map<String, dynamic> livestockTypeToUpdateSql(LivestockTypeModel model) {
    return {
      'name': model.name,
    };
  }

  /// Convert list of database entities to domain models
  static List<LivestockTypeModel> livestockTypesToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => livestockTypeToEntity(entity)).toList();
  }

  /// Convert list of domain models to database entities
  static List<Map<String, dynamic>> livestockTypesToSql(List<LivestockTypeModel> models) {
    return models.map((model) => livestockTypeToSql(model)).toList();
  }

  /// Convert list of domain models to update entities
  static List<Map<String, dynamic>> livestockTypesToUpdateSql(List<LivestockTypeModel> models) {
    return models.map((model) => livestockTypeToUpdateSql(model)).toList();
  }
}
