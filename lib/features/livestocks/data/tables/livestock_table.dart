import 'package:drift/drift.dart';

@DataClassName('Livestock')
class Livestocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get farmUuid => text()();  // Farm UUID reference
  TextColumn get uuid => text()();
  TextColumn get identificationNumber => text()();
  TextColumn get dummyTagId => text()();
  TextColumn get barcodeTagId => text().unique()();
  TextColumn get rfidTagId => text().unique()();
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
  
  // Syncing fields for offline tracking
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}
