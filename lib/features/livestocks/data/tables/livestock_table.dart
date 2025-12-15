import 'package:drift/drift.dart';

@DataClassName('Livestock')
class Livestocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get farmUuid => text()();  // Farm UUID reference
  TextColumn get uuid => text()();
  TextColumn get identificationNumber => text()();
  // Tag fields are optional (backend allows null); uniqueness handled at application level
  TextColumn get dummyTagId => text().nullable()();
  TextColumn get barcodeTagId => text().nullable()();
  TextColumn get rfidTagId => text().nullable()();
  IntColumn get livestockTypeId => integer()();
  TextColumn get name => text()();
  TextColumn get dateOfBirth => text()();
  TextColumn get motherUuid => text().nullable()();  // Mother livestock UUID reference
  TextColumn get fatherUuid => text().nullable()();  // Father livestock UUID reference
  TextColumn get gender => text()();
  IntColumn get breedId => integer()();
  IntColumn get speciesId => integer()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get livestockObtainedMethodId => integer()();
  DateTimeColumn get dateFirstEnteredToFarm => dateTime()();
  RealColumn get weightAsOnRegistration => real()();
  TextColumn get primaryColor => text().nullable()();
  TextColumn get secondaryColor => text().nullable()();
  
  // Syncing fields for offline tracking
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}
