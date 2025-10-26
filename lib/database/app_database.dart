import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; 
// Import all table definitions
import '../features/all.additional.data/data/local/tables/country_table.dart';
import '../features/all.additional.data/data/local/tables/region_table.dart';
import '../features/all.additional.data/data/local/tables/district_table.dart';
import '../features/all.additional.data/data/local/tables/division_table.dart';
import '../features/all.additional.data/data/local/tables/ward_table.dart';
import '../features/all.additional.data/data/local/tables/village_table.dart';
import '../features/all.additional.data/data/local/tables/street_table.dart';
import '../features/all.additional.data/data/local/tables/school_level_table.dart';
import '../features/all.additional.data/data/local/tables/identity_card_type_table.dart';
import '../features/all.additional.data/data/local/tables/legal_status_table.dart';
import '../features/farms/data/tables/farm-table.dart';
import '../features/livestocks/data/tables/livestock_table.dart';
import '../features/species/data/tables/specie_table.dart';
import '../features/livestock_types/data/tables/livestock_type_table.dart';
import '../features/breeds/data/tables/breed_table.dart';
import '../features/livestock_obtained_methods/data/tables/livestock_obtained_method_table.dart';

// Import DAOs
import 'daos/location_dao.dart';
import 'daos/reference_data_dao.dart';
import 'daos/livestock_management_dao.dart';
import 'daos/specie_dao.dart';
import 'daos/livestock_type_dao.dart';
import 'daos/breed_dao.dart';
import 'daos/livestock_obtained_method_dao.dart';
import 'daos/farm_dao.dart';
import 'daos/livestock_dao.dart';

part 'app_database.g.dart';

/// Main database class with clean structure and proper migration handling
@DriftDatabase(
  tables: [
    Countries,
    Regions,
    Districts,
    Divisions,
    Wards,
    Villages,
    Streets,
    SchoolLevels,
    IdentityCardTypes,
    LegalStatuses,
    Farms,
    Livestocks,
    Species,
    LivestockTypes,
    Breeds,
    LivestockObtainedMethods,
  ],
  daos: [
    LocationDao,
    ReferenceDataDao,
    LivestockManagementDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Increased to force database recreation with new UUID schema

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // Create all tables
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Add future migrations here as schema evolves
      if (from < 2) {
        // Version 2: Added Villages table
        await m.createTable(villages);
      }
      if (from < 3) {
        // Version 3: Changed farmId/motherId/fatherId to UUID references
        // Drop and recreate livestocks table with new schema
        await m.deleteTable(livestocks.actualTableName);
        await m.createTable(livestocks);
      }
    },
    beforeOpen: (details) async {
      // Enable foreign key constraints
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // ==================== DAO GETTERS ====================
  
  /// Access location-related data (Country, Region, District, etc.)
  @override
  late final LocationDao locationDao = LocationDao(this);
  
  /// Access reference/lookup data (SchoolLevel, IdentityCardType, LegalStatus)
  @override
  late final ReferenceDataDao referenceDataDao = ReferenceDataDao(this);

  /// Access livestock management operations (livestock, farms, species, breeds, etc.)
  @override
  late final LivestockManagementDao livestockManagementDao = LivestockManagementDao(this);

  // Individual DAOs for direct access
  late final SpecieDao specieDao = SpecieDao(this);
  late final LivestockTypeDao livestockTypeDao = LivestockTypeDao(this);
  late final BreedDao breedDao = BreedDao(this);
  late final LivestockObtainedMethodDao livestockObtainedMethodDao = LivestockObtainedMethodDao(this);
  late final FarmDao farmDao = FarmDao(this);
  late final LivestockDao livestockDao = LivestockDao(this);

  // ==================== UTILITY METHODS ====================

  /// Clear all data from all tables (useful for testing/logout)
  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  /// Check if database is empty (checks if any table has data)
  Future<bool> isDatabaseEmpty() async {
    final countries = await locationDao.getAllCountries();
    return countries.isEmpty;
  }
}

/// Opens the database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.db'));
    return NativeDatabase.createInBackground(file);
  });
}
