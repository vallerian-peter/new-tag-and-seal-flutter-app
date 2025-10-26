import '../../domain/models/breed_model.dart';

/// Mapper for converting between Breed domain models and database entities
class BreedMapper {
  /// Convert database entity to domain model
  static BreedModel breedToEntity(Map<String, dynamic> entity) {
    return BreedModel(
      id: entity['id'] as int?,
      name: entity['name'] as String,
      group: entity['group'] as String,
      livestockTypeId: entity['livestockTypeId'] as int,
    );
  }

  /// Convert domain model to database entity for insert
  static Map<String, dynamic> breedToSql(BreedModel model) {
    return {
      'id': model.id,  // Include server-provided ID
      'name': model.name,
      'group': model.group,
      'livestockTypeId': model.livestockTypeId,
    };
  }

  /// Convert domain model to database entity for update
  static Map<String, dynamic> breedToUpdateSql(BreedModel model) {
    return {
      'name': model.name,
      'group': model.group,
      'livestockTypeId': model.livestockTypeId,
    };
  }

  /// Convert list of database entities to domain models
  static List<BreedModel> breedsToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => breedToEntity(entity)).toList();
  }

  /// Convert list of domain models to database entities
  static List<Map<String, dynamic>> breedsToSql(List<BreedModel> models) {
    return models.map((model) => breedToSql(model)).toList();
  }

  /// Convert list of domain models to update entities
  static List<Map<String, dynamic>> breedsToUpdateSql(List<BreedModel> models) {
    return models.map((model) => breedToUpdateSql(model)).toList();
  }
}
