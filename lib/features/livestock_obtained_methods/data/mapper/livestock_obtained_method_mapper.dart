import '../../domain/models/livestock_obtained_method_model.dart';

/// Mapper for converting between LivestockObtainedMethod domain models and database entities
class LivestockObtainedMethodMapper {
  /// Convert database entity to domain model
  static LivestockObtainedMethodModel livestockObtainedMethodToEntity(Map<String, dynamic> entity) {
    return LivestockObtainedMethodModel(
      id: entity['id'] as int?,
      name: entity['name'] as String,
    );
  }

  /// Convert domain model to database entity for insert
  static Map<String, dynamic> livestockObtainedMethodToSql(LivestockObtainedMethodModel model) {
    return {
      'id': model.id,  // Include server-provided ID
      'name': model.name,
    };
  }

  /// Convert domain model to database entity for update
  static Map<String, dynamic> livestockObtainedMethodToUpdateSql(LivestockObtainedMethodModel model) {
    return {
      'name': model.name,
    };
  }

  /// Convert list of database entities to domain models
  static List<LivestockObtainedMethodModel> livestockObtainedMethodsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => livestockObtainedMethodToEntity(entity)).toList();
  }

  /// Convert list of domain models to database entities
  static List<Map<String, dynamic>> livestockObtainedMethodsToSql(List<LivestockObtainedMethodModel> models) {
    return models.map((model) => livestockObtainedMethodToSql(model)).toList();
  }

  /// Convert list of domain models to update entities
  static List<Map<String, dynamic>> livestockObtainedMethodsToUpdateSql(List<LivestockObtainedMethodModel> models) {
    return models.map((model) => livestockObtainedMethodToUpdateSql(model)).toList();
  }
}
