import 'package:drift/drift.dart';

class Treatments extends Table {
  IntColumn get id => integer().nullable()();

  // Primary key (see primaryKey override below) - no extra UNIQUE needed
  TextColumn get uuid => text()();

  TextColumn get eventDate => text().nullable()();

  TextColumn get farmUuid => text()();

  TextColumn get livestockUuid => text()();

  IntColumn get diseaseId => integer().nullable()();

  IntColumn get medicineId => integer().nullable()();

  TextColumn get quantity => text().nullable()();

  TextColumn get withdrawalPeriod => text().nullable()();

  TextColumn get medicationDate => text().nullable()();

  TextColumn get nextMedicationDate => text().nullable()();

  TextColumn get remarks => text().nullable()();

  BoolColumn get synced =>
      boolean().withDefault(const Constant<bool>(true))();

  TextColumn get syncAction =>
      text().withDefault(const Constant<String>('server-create'))();

  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}

