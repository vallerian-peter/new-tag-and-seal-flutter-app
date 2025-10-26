import 'package:drift/drift.dart';
import '../../../all.additional.data/data/local/tables/ward_table.dart';
import '../../../all.additional.data/data/local/tables/district_table.dart';
import '../../../all.additional.data/data/local/tables/region_table.dart';
import '../../../all.additional.data/data/local/tables/country_table.dart';
import '../../../all.additional.data/data/local/tables/legal_status_table.dart';

@DataClassName('Farm')
class Farms extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get farmerId => integer()();
  TextColumn get uuid => text()();
  TextColumn get referenceNo => text()();
  TextColumn get regionalRegNo => text()();
  TextColumn get name => text()();
  TextColumn get size => text()();  // Changed to text to match backend varchar(50)
  TextColumn get sizeUnit => text()();
  TextColumn get latitudes => text()();  // Changed to text to match backend varchar(255)
  TextColumn get longitudes => text()();  // Changed to text to match backend varchar(255)
  TextColumn get physicalAddress => text()();
  IntColumn get villageId => integer().nullable()();
  IntColumn get wardId => integer().references(Wards, #id)();
  IntColumn get districtId => integer().references(Districts, #id)();
  IntColumn get regionId => integer().references(Regions, #id)();
  IntColumn get countryId => integer().references(Countries, #id)();
  IntColumn get legalStatusId => integer().references(LegalStatuses, #id)();
  TextColumn get status => text().withDefault(const Constant('active'))();
  
  // Syncing fields for offline tracking
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncAction => text().withDefault(const Constant('create'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}