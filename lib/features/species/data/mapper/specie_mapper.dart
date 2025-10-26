import '../../domain/models/specie_model.dart';

/// Mapper for converting between Specie domain models and database entities
class SpecieMapper {
  /// Convert database entity to domain model
  static SpecieModel specieToEntity(Map<String, dynamic> entity) {
    return SpecieModel(
      id: entity['id'] as int?,
      name: entity['name'] as String,
    );
  }

  /// Convert domain model to database entity for insert
  static Map<String, dynamic> specieToSql(SpecieModel model) {
    return {
      'id': model.id,  // Include server-provided ID
      'name': model.name,
    };
  }

  /// Convert domain model to database entity for update
  static Map<String, dynamic> specieToUpdateSql(SpecieModel model) {
    return {
      'name': model.name,
    };
  }

  /// Convert list of database entities to domain models
  static List<SpecieModel> speciesToEntities(List<Map<String, dynamic>> entities) {
    return entities.map((entity) => specieToEntity(entity)).toList();
  }

  /// Convert list of domain models to database entities
  static List<Map<String, dynamic>> speciesToSql(List<SpecieModel> models) {
    return models.map((model) => specieToSql(model)).toList();
  }

  /// Convert list of domain models to update entities
  static List<Map<String, dynamic>> speciesToUpdateSql(List<SpecieModel> models) {
    return models.map((model) => specieToUpdateSql(model)).toList();
  }
}
