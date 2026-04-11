import 'package:drift/drift.dart';

/// Local log rows for prepuce (sheath) condition events.
/// [tableName] matches Laravel `prepuce_conditions` (FK ids + JSON id lists).
@DataClassName('PrepuceCondition')
class PrepuceConditions extends Table {
  @override
  String get tableName => 'prepuce_conditions';

  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get eventDate => text().nullable()();
  TextColumn get farmUuid => text()();
  TextColumn get livestockUuid => text()();
  IntColumn get conditionTypeId => integer()();
  IntColumn get severityId => integer()();
  TextColumn get clinicalSignIdsJson => text().withDefault(const Constant('[]'))();
  IntColumn get causeRiskId => integer().nullable()();
  TextColumn get treatmentGivenIdsJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get medicineId => integer().nullable()();
  IntColumn get administrationRouteId => integer().nullable()();
  TextColumn get vetId => text().nullable()();
  TextColumn get extensionOfficerId => text().nullable()();
  TextColumn get quantity => text().nullable()();
  TextColumn get dose => text().nullable()();
  IntColumn get breedingStatusId => integer()();
  IntColumn get healingStatusId => integer().nullable()();
  TextColumn get followUpDate => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}
