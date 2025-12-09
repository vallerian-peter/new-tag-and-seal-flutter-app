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
import '../features/all.additional.data/data/local/tables/specie_table.dart';
import '../features/all.additional.data/data/local/tables/livestock_type_table.dart';
import '../features/all.additional.data/data/local/tables/breed_table.dart';
import '../features/all.additional.data/data/local/tables/livestock_obtained_method_table.dart';
import '../features/events/data/tables/feeding_table.dart';
import '../features/events/data/tables/weight_change_table.dart';
import '../features/events/data/tables/deworming_table.dart';
import '../features/events/data/tables/medication_table.dart';
import '../features/events/data/tables/vaccination_table.dart';
import '../features/events/data/tables/disposal_table.dart';
import '../features/events/data/tables/milking_table.dart';
import '../features/events/data/tables/pregnancy_table.dart';
import '../features/events/data/tables/insemination_table.dart';
import '../features/events/data/tables/dryoff_table.dart';
import '../features/events/data/tables/transfer_table.dart';
import '../features/vaccines/data/tables/vaccine_table.dart';
import '../features/all.logs.additional.data/data/local/tables/feeding_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/administration_route_table.dart';
import '../features/all.logs.additional.data/data/local/tables/medicine_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/medicine_table.dart';
import '../features/all.logs.additional.data/data/local/tables/disease_table.dart';
import '../features/all.logs.additional.data/data/local/tables/disposal_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/milking_method_table.dart';
import '../features/all.logs.additional.data/data/local/tables/heat_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/insemination_service_table.dart';
import '../features/all.logs.additional.data/data/local/tables/semen_straw_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/test_result_table.dart';
import '../features/all.logs.additional.data/data/local/tables/calving_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/calving_problem_table.dart';
import '../features/all.logs.additional.data/data/local/tables/birth_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/birth_problem_table.dart';
import '../features/events/data/tables/birth_event_table.dart';
import '../features/events/data/tables/aborted_pregnancy_table.dart';
import '../features/all.logs.additional.data/data/local/tables/reproductive_problem_table.dart';
import '../features/vaccines/data/tables/vaccine_type_table.dart';
import '../features/notifications/data/tables/notification_table.dart';
import '../features/farmUser/data/tables/farm_user_table.dart';

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
import 'daos/event_dao.dart';
import 'daos/log_reference_dao.dart';
import 'daos/vaccine_dao.dart';
import 'daos/vaccine_type_dao.dart';
import '../features/notifications/data/dao/notification_dao.dart';
import 'daos/farm_user_dao.dart';

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
    FeedingTypes,
    AdministrationRoutes,
    MedicineTypes,
    Medicines,
    Diseases,
    DisposalTypes,
    MilkingMethods,
    HeatTypes,
    InseminationServices,
    SemenStrawTypes,
    TestResults,
    CalvingTypes,
    CalvingProblems,
    BirthTypes,
    BirthProblems,
    BirthEvents,
    AbortedPregnancies,
    ReproductiveProblems,
    VaccineTypes,
    // Event log tables
    Feedings,
    WeightChanges,
    Dewormings,
    Medications,
    Vaccinations,
    Disposals,
    Milkings,
    Pregnancies,
    Inseminations,
    Dryoffs,
    Transfers,
    // Other feature tables
    Vaccines,
    FarmUsers,
    NotificationEntries,
  ],
  daos: [
    LocationDao,
    ReferenceDataDao,
    LivestockManagementDao,
    EventDao,
    LogReferenceDao,
    VaccineDao,
    VaccineTypeDao,
    NotificationDao,
    FarmUserDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 19; // v19 changes vaccinations.vaccineId to vaccineUuid

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
      if (from < 4) {
        // Version 4: Introduced log reference data and event tables
        await m.createTable(feedingTypes);
        await m.createTable(administrationRoutes);
        await m.createTable(medicineTypes);
        await m.createTable(medicines);
        await m.createTable(vaccineTypes);
        await m.createTable(feedings);
        await m.createTable(weightChanges);
        await m.createTable(dewormings);
      }
      if (from < 5) {
        // Version 5: Ensure log tables exist if previous migrations were skipped
        await _createTableIfMissing(m, feedingTypes);
        await _createTableIfMissing(m, administrationRoutes);
        await _createTableIfMissing(m, medicineTypes);
        await _createTableIfMissing(m, medicines);
        await _createTableIfMissing(m, vaccineTypes);
        await _createTableIfMissing(m, feedings);
        await _createTableIfMissing(m, weightChanges);
        await _createTableIfMissing(m, dewormings);
      }
      if (from < 6) {
        await _renameColumnIfExists(
          table: 'feedings',
          oldColumn: 'feedingTime',
          newColumn: 'nextFeedingTime',
        );
      }
      if (from < 7) {
        await _renameColumnIfExists(
          table: 'feedings',
          oldColumn: 'feeding_time',
          newColumn: 'nextFeedingTime',
        );
      }
      if (from < 8) {
        await _migrateDewormingProviderColumns(m);
      }
      if (from < 9) {
        await _createTableIfMissing(m, vaccines);
      }
      if (from < 10) {
        await _createTableIfMissing(m, medications);
        await _createTableIfMissing(m, vaccinations);
        await _createTableIfMissing(m, disposals);
      }
      if (from < 11) {
        await _createTableIfMissing(m, notificationEntries);
      }
      if (from < 12) {
        await _createTableIfMissing(m, diseases);
        await _createTableIfMissing(m, disposalTypes);
        await _createTableIfMissing(m, milkingMethods);
        await _createTableIfMissing(m, heatTypes);
        await _createTableIfMissing(m, inseminationServices);
        await _createTableIfMissing(m, semenStrawTypes);
        await _createTableIfMissing(m, testResults);
        await _createTableIfMissing(m, calvingTypes);
        await _createTableIfMissing(m, calvingProblems);
        await _createTableIfMissing(m, reproductiveProblems);
      }
      if (from < 13) {
        await m.addColumn(notificationEntries, notificationEntries.soundPath);
        await m.addColumn(notificationEntries, notificationEntries.soundName);
        await m.addColumn(notificationEntries, notificationEntries.loopAudio);
        await m.addColumn(notificationEntries, notificationEntries.vibrate);
        await m.addColumn(notificationEntries, notificationEntries.volume);
      }
      if (from < 14) {
        await m.addColumn(notificationEntries, notificationEntries.repeatDaily);
      }
      if (from < 15) {
        // Version 15: Multi-livestock support - migrate from calvings to birth events
        await _migrateToBirthEvents(m);
      }
      if (from < 16) {
        // Version 16: Add livestockTypeId to species (if not already present)
        final speciesInfo =
            await customSelect('PRAGMA table_info(species)').get();
        final hasLivestockTypeId =
            speciesInfo.any((row) => row.data['name'] == 'livestockTypeId');
        if (!hasLivestockTypeId) {
          await m.addColumn(species, species.livestockTypeId);
        }
      }
      if (from < 17) {
        await _createTableIfMissing(m, farmUsers);
      }
      if (from < 18) {
        // Version 18: Add the 5 new event log tables (milking, pregnancy, insemination, dryoff, transfer)
        await _createTableIfMissing(m, milkings);
        await _createTableIfMissing(m, pregnancies);
        await _createTableIfMissing(m, inseminations);
        await _createTableIfMissing(m, dryoffs);
        await _createTableIfMissing(m, transfers);
      }
      if (from < 19) {
        // Version 19: Change vaccinations.vaccineId (integer) to vaccineUuid (text)
        await _migrateVaccinationsToVaccineUuid(m);
      }
    },
    beforeOpen: (details) async {
      // Enable foreign key constraints
      await customStatement('PRAGMA foreign_keys = ON');
      
      // Safety check: Ensure vaccine_uuid column exists in vaccinations table
      // This handles cases where migration might not have run or failed
      try {
        final vaccinationsExists = await customSelect(
          'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
          variables: [
            const Variable<String>('table'),
            const Variable<String>('vaccinations'),
          ],
        ).get();
        
        if (vaccinationsExists.isNotEmpty) {
          final tableInfo = await customSelect('PRAGMA table_info(vaccinations)').get();
          final hasVaccineUuid = tableInfo.any((row) => row.data['name'] == 'vaccine_uuid');
          
          if (!hasVaccineUuid) {
            // Column missing - add it
            await customStatement('ALTER TABLE vaccinations ADD COLUMN vaccine_uuid TEXT');
          }
        }
      } catch (e) {
        // Ignore errors - migration will handle it
      }
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
  late final EventDao eventDao = EventDao(this);
  late final LogReferenceDao logReferenceDao = LogReferenceDao(this);
  late final VaccineDao vaccineDao = VaccineDao(this);
  late final VaccineTypeDao vaccineTypeDao = VaccineTypeDao(this);
  late final NotificationDao notificationDao = NotificationDao(this);

  // ==================== UTILITY METHODS ====================

  /// Clear all data from all tables (useful for testing/logout)
  Future<void> clearAllData() async {
    await transaction(() async {
      await customStatement('PRAGMA foreign_keys = OFF');
      try {
        for (final table in allTables.toList().reversed) {
          await delete(table).go();
        }
      } finally {
        await customStatement('PRAGMA foreign_keys = ON');
      }
    });
  }

  /// Check if database is empty (checks if any table has data)
  Future<bool> isDatabaseEmpty() async {
    final countries = await locationDao.getAllCountries();
    return countries.isEmpty;
  }

  Future<void> _createTableIfMissing(Migrator migrator, TableInfo<Table, Object?> table) async {
    final tableName = table.actualTableName;
    final result = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [
        const Variable<String>('table'),
        Variable<String>(tableName),
      ],
    ).get();

    if (result.isEmpty) {
      await migrator.createTable(table);
    }
  }

  Future<void> _migrateDewormingProviderColumns(Migrator migrator) async {
    await customStatement('ALTER TABLE dewormings RENAME TO dewormings_old');
    await migrator.createTable(dewormings);
    await customStatement('''
      INSERT INTO dewormings (
        id,
        uuid,
        farm_uuid,
        livestock_uuid,
        administration_route_id,
        medicine_id,
        vet_id,
        extension_officer_id,
        quantity,
        dose,
        next_administration_date,
        synced,
        sync_action,
        created_at,
        updated_at
      )
      SELECT
        id,
        uuid,
        farm_uuid,
        livestock_uuid,
        administration_route_id,
        medicine_id,
        CASE
          WHEN vet_id IS NULL THEN NULL
          ELSE CAST(vet_id AS TEXT)
        END,
        CASE
          WHEN extension_officer_id IS NULL THEN NULL
          ELSE CAST(extension_officer_id AS TEXT)
        END,
        quantity,
        dose,
        next_administration_date,
        synced,
        sync_action,
        created_at,
        updated_at
      FROM dewormings_old
    ''');
    await customStatement('DROP TABLE dewormings_old');
  }

  Future<void> _renameColumnIfExists({
    required String table,
    required String oldColumn,
    required String newColumn,
  }) async {
    final columnInfo = await customSelect('PRAGMA table_info($table)').get();
    final columnExists = columnInfo.any((row) => row.data['name'] == oldColumn);

    if (columnExists) {
      await customStatement(
        'ALTER TABLE $table RENAME COLUMN $oldColumn TO $newColumn',
      );
    }
  }

  /// Migration to version 15: Multi-livestock support
  /// - Creates birth_events table (replaces calvings)
  /// - Migrates data from calvings to birth_events with eventType
  /// - Renames calving_types to birth_types
  /// - Renames calving_problems to birth_problems
  /// - Adds livestockTypeId to birth_types and birth_problems
  /// - Creates aborted_pregnancies table
  Future<void> _migrateToBirthEvents(Migrator m) async {
    // Step 1: Check if calvings table exists
    final calvingsExists = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [
        const Variable<String>('table'),
        const Variable<String>('calvings'),
      ],
    ).get();

    if (calvingsExists.isNotEmpty) {
      // Step 2: Create new birth_events table
      await m.createTable(birthEvents);

      // Step 3: Migrate data from calvings to birth_events
      // Determine eventType based on livestock species
      await customStatement('''
        INSERT INTO birth_events (
          id, uuid, farmUuid, livestockUuid, eventType, startDate, endDate,
          birthTypeId, birthProblemsId, reproductiveProblemId, remarks, status,
          synced, syncAction, createdAt, updatedAt
        )
        SELECT 
          c.id,
          c.uuid,
          c.farmUuid,
          c.livestockUuid,
          CASE 
            WHEN EXISTS (
              SELECT 1 FROM livestocks l 
              JOIN species s ON l.speciesId = s.id 
              WHERE l.uuid = c.livestockUuid 
              AND LOWER(s.name) = 'pig'
            ) THEN 'farrowing'
            ELSE 'calving'
          END as eventType,
          c.startDate,
          c.endDate,
          c.calvingTypeId as birthTypeId,
          c.calvingProblemsId as birthProblemsId,
          c.reproductiveProblemId,
          c.remarks,
          c.status,
          c.synced,
          c.syncAction,
          c.createdAt,
          c.updatedAt
        FROM calvings c
      ''');

      // Step 4: Drop old calvings table
      await m.deleteTable('calvings');
    } else {
      // If calvings table doesn't exist, just create the new tables
      await m.createTable(birthEvents);
    }

    // Step 5: Check if calving_types table exists and rename to birth_types
    final calvingTypesExists = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [
        const Variable<String>('table'),
        const Variable<String>('calving_types'),
      ],
    ).get();

    if (calvingTypesExists.isNotEmpty) {
      // Rename calving_types to birth_types
      await customStatement('ALTER TABLE calving_types RENAME TO birth_types');
      
      // Add livestockTypeId column if it doesn't exist
      final birthTypesInfo = await customSelect('PRAGMA table_info(birth_types)').get();
      final hasLivestockTypeId = birthTypesInfo.any((row) => row.data['name'] == 'livestockTypeId');
      
      if (!hasLivestockTypeId) {
        await m.addColumn(birthTypes, birthTypes.livestockTypeId);
      }
    } else {
      // If calving_types doesn't exist, create birth_types table
      await m.createTable(birthTypes);
    }

    // Step 6: Check if calving_problems table exists and rename to birth_problems
    final calvingProblemsExists = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [
        const Variable<String>('table'),
        const Variable<String>('calving_problems'),
      ],
    ).get();

    if (calvingProblemsExists.isNotEmpty) {
      // Rename calving_problems to birth_problems
      await customStatement('ALTER TABLE calving_problems RENAME TO birth_problems');
      
      // Add livestockTypeId column if it doesn't exist
      final birthProblemsInfo = await customSelect('PRAGMA table_info(birth_problems)').get();
      final hasLivestockTypeId = birthProblemsInfo.any((row) => row.data['name'] == 'livestockTypeId');
      
      if (!hasLivestockTypeId) {
        await m.addColumn(birthProblems, birthProblems.livestockTypeId);
      }
    } else {
      // If calving_problems doesn't exist, create birth_problems table
      await m.createTable(birthProblems);
    }

    // Step 7: Create aborted_pregnancies table
    await m.createTable(abortedPregnancies);
  }

  /// Migration to version 19: Add vaccineUuid column to vaccinations table
  Future<void> _migrateVaccinationsToVaccineUuid(Migrator m) async {
    try {
      // Check if vaccinations table exists
      final vaccinationsExists = await customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          const Variable<String>('table'),
          const Variable<String>('vaccinations'),
        ],
      ).get();

      if (vaccinationsExists.isEmpty) {
        // Table doesn't exist yet, just create it with new schema
        await m.createTable(vaccinations);
        return;
      }

      // Check if vaccine_uuid column already exists (Drift uses snake_case in SQLite)
      final tableInfo = await customSelect('PRAGMA table_info(vaccinations)').get();
      final hasVaccineUuid = tableInfo.any((row) => row.data['name'] == 'vaccine_uuid');
      
      if (hasVaccineUuid) {
        // Migration already done
        return;
      }

      // Add vaccine_uuid column (Drift converts camelCase to snake_case)
      await customStatement('ALTER TABLE vaccinations ADD COLUMN vaccine_uuid TEXT');

      // If vaccine_id exists, copy its values to vaccine_uuid by looking up UUIDs
      final hasVaccineId = tableInfo.any((row) => row.data['name'] == 'vaccine_id');
      if (hasVaccineId) {
        await customStatement('''
          UPDATE vaccinations 
          SET vaccine_uuid = (
            SELECT vac.uuid 
            FROM vaccines vac 
            WHERE vac.id = vaccinations.vaccine_id 
            LIMIT 1
          )
          WHERE vaccine_id IS NOT NULL
        ''');
      }
    } catch (e) {
      // Re-throw with context
      throw Exception('Failed to migrate vaccinations table: $e');
    }
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
