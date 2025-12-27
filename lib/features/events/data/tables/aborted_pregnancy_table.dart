import 'package:drift/drift.dart';

@DataClassName('AbortedPregnancy')
class AbortedPregnancies extends Table {
  IntColumn get id => integer().nullable()();
  TextColumn get uuid => text()();
  TextColumn get eventDate => text().nullable()();
  TextColumn get farmUuid => text()();
  TextColumn get livestockUuid => text()();
  TextColumn get abortionDate => text()();
  IntColumn get reproductiveProblemId => integer().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {uuid};
}

