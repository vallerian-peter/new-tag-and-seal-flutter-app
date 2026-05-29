import 'dart:io';
import 'dart:developer';
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
import '../features/all.additional.data/data/local/tables/stage_table.dart';
import '../features/events/data/tables/feeding_table.dart';
import '../features/events/data/tables/weight_change_table.dart';
import '../features/events/data/tables/deworming_table.dart';
import '../features/events/data/tables/treatment_table.dart';
import '../features/events/data/tables/vaccination_table.dart';
import '../features/events/data/tables/disposal_table.dart';
import '../features/events/data/tables/teeth_clipping_table.dart';
import '../features/events/data/tables/tail_docking_table.dart';
import '../features/events/data/tables/iron_injection_table.dart';
import '../features/events/data/tables/livestock_marking_table.dart';
import '../features/events/data/tables/stage_change_table.dart';
import '../features/events/data/tables/prepuce_condition_table.dart';
import '../features/events/data/tables/milking_table.dart';
import '../features/events/data/tables/pregnancy_table.dart';
import '../features/events/data/tables/insemination_table.dart';
import '../features/events/data/tables/dryoff_table.dart';
import '../features/events/data/tables/transfer_table.dart';
import '../features/vaccines/data/tables/vaccine_table.dart';
import '../features/bills/data/tables/bill_table.dart';
import '../features/reports/data/tables/finance_expense_table.dart';
import '../features/reports/data/tables/finance_income_table.dart';
import '../features/all.logs.additional.data/data/local/tables/feeding_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/administration_route_table.dart';
import '../features/all.logs.additional.data/data/local/tables/medicine_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/medicine_table.dart';
import '../features/all.logs.additional.data/data/local/tables/disease_table.dart';
import '../features/all.logs.additional.data/data/local/tables/disposal_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/milking_method_table.dart';
import '../features/all.logs.additional.data/data/local/tables/teeth_clipping_method_table.dart';
import '../features/all.logs.additional.data/data/local/tables/prepuce_condition_type_table.dart';
import '../features/all.logs.additional.data/data/local/tables/prepuce_severity_table.dart';
import '../features/all.logs.additional.data/data/local/tables/prepuce_clinical_sign_table.dart';
import '../features/all.logs.additional.data/data/local/tables/prepuce_cause_risk_table.dart';
import '../features/all.logs.additional.data/data/local/tables/prepuce_treatment_given_table.dart';
import '../features/all.logs.additional.data/data/local/tables/prepuce_breeding_status_table.dart';
import '../features/all.logs.additional.data/data/local/tables/prepuce_healing_status_table.dart';
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
import '../features/extensionOfficer/data/tables/invited_extension_officer_table.dart';

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
import 'daos/bill_dao.dart';
import 'daos/finance_expense_dao.dart';
import 'daos/finance_income_dao.dart';
import 'daos/stage_dao.dart';
import '../features/notifications/data/dao/notification_dao.dart';
import 'daos/farm_user_dao.dart';
import '../features/extensionOfficer/data/dao/extension_officer_dao.dart';

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
    Stages,
    FeedingTypes,
    AdministrationRoutes,
    MedicineTypes,
    Medicines,
    Diseases,
    DisposalTypes,
    MilkingMethods,
    TeethClippingMethods,
    PrepuceConditionTypes,
    PrepuceSeverities,
    PrepuceClinicalSigns,
    PrepuceCauseRisks,
    PrepuceTreatmentsGiven,
    PrepuceBreedingStatuses,
    PrepuceHealingStatuses,
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
    Treatments,
    Vaccinations,
    Disposals,
    Milkings,
    Pregnancies,
    Inseminations,
    Dryoffs,
    Transfers,
    TeethClippings,
    TailDockings,
    IronInjections,
    LivestockMarkings,
    StageChanges,
    PrepuceConditions,
    // Other feature tables
    Vaccines,
    Bills,
    FinanceExpenses,
    FinanceIncomes,
    FarmUsers,
    NotificationEntries,
    InvitedExtensionOfficers,
  ],
  daos: [
    LocationDao,
    ReferenceDataDao,
    LivestockManagementDao,
    EventDao,
    LogReferenceDao,
    VaccineDao,
    VaccineTypeDao,
    BillDao,
    FinanceExpenseDao,
    FinanceIncomeDao,
    NotificationDao,
    FarmUserDao,
    ExtensionOfficerDao,
    StageDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 39; // v39: make finance_income source fields nullable

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
        await _createTableIfMissing(m, treatments);
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
        final speciesInfo = await customSelect(
          'PRAGMA table_info(species)',
        ).get();
        final hasLivestockTypeId = speciesInfo.any(
          (row) => row.data['name'] == 'livestockTypeId',
        );
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
      if (from < 20) {
        // Version 20: Add primaryColor and secondaryColor columns to livestocks table
        await _addLivestockColorColumns(m);
      }
      if (from < 21) {
        // Version 21: Remove UNIQUE constraints from nullable tag columns
        // This allows multiple NULL values and handles uniqueness at application level
        await _removeTagUniqueConstraints(m);
      }
      if (from < 22) {
        // Version 22: Added InvitedExtensionOfficers table
        await _createTableIfMissing(m, invitedExtensionOfficers);
      }
      if (from < 23) {
        // Version 23: Add sync/audit columns to InvitedExtensionOfficers
        await _migrateInvitedExtensionOfficersColumns(m);
      }
      if (from < 24) {
        // Version 24: Make milking measurement columns nullable and migrate existing data
        await _migrateMilkingMeasurementColumns(m);
      }
      if (from < 25) {
        // Version 25: Add organization and location fields to invited_extension_officers
        await _migrateInvitedExtensionOfficersAddMetadata(m);
      }
      if (from < 26) {
        // Version 26: Add Bills table
        await _createTableIfMissing(m, bills);
      }
      if (from < 27) {
        // Version 27: Rename medications table to treatments and add nextMedicationDate column
        await _migrateMedicationsToTreatments(m);
      }
      if (from < 28) {
        // Version 28: Add eventDate column to all log tables
        await _migrateAddEventDateToLogTables(m);
      }
      if (from < 29) {
        await m.addColumn(livestocks, livestocks.birthEventUuid);
        await m.addColumn(livestocks, livestocks.stageId);
        await m.addColumn(livestocks, livestocks.isIdentified);
        await m.addColumn(birthEvents, birthEvents.totalBorn);
        await m.addColumn(birthEvents, birthEvents.aliveCount);
        await m.addColumn(birthEvents, birthEvents.deadCount);
        await _createTableIfMissing(m, stages);
      }
      if (from < 30) {
        await _createTableIfMissing(m, teethClippings);
        await _createTableIfMissing(m, tailDockings);
        await _createTableIfMissing(m, ironInjections);
        await _createTableIfMissing(m, livestockMarkings);
        await _createTableIfMissing(m, stageChanges);
        await _migrateDisposalSaleColumns();
      }
      if (from < 31) {
        await _createTableIfMissing(m, teethClippingMethods);
      }
      if (from < 32) {
        await _createTableIfMissing(m, prepuceConditionTypes);
        await _createTableIfMissing(m, prepuceSeverities);
        await _createTableIfMissing(m, prepuceClinicalSigns);
        await _createTableIfMissing(m, prepuceCauseRisks);
        await _createTableIfMissing(m, prepuceTreatmentsGiven);
        await _createTableIfMissing(m, prepuceBreedingStatuses);
        await _createTableIfMissing(m, prepuceHealingStatuses);
        await _createTableIfMissing(m, prepuceConditions);
      }
      if (from < 33) {
        await _migratePrepuceConditionsMedicineVetColumns();
      }
      if (from < 34) {
        await _migratePrepuceConditionsTreatmentProviderColumns();
      }
      if (from < 35) {
        await _migratePrepuceV35IdBasedSchema(m);
      }
      if (from < 36) {
        await _migratePrepuceV36SplitReferenceTables(m);
      }
      if (from < 37) {
        await _createTableIfMissing(m, financeExpenses);
      }
      if (from < 38) {
        await _createTableIfMissing(m, financeIncomes);
      }
      if (from < 39) {
        await _migrateFinanceIncomesNullableSourceFields(m);
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
          final tableInfo = await customSelect(
            'PRAGMA table_info(vaccinations)',
          ).get();
          final hasVaccineUuid = tableInfo.any(
            (row) => row.data['name'] == 'vaccine_uuid',
          );

          if (!hasVaccineUuid) {
            // Column missing - add it
            await customStatement(
              'ALTER TABLE vaccinations ADD COLUMN vaccine_uuid TEXT',
            );
          }
        }
      } catch (e) {
        // Ignore errors - migration will handle it
      }

      // Safety check: Ensure color columns exist in livestocks table
      // This handles cases where migration might not have run or failed
      try {
        final livestocksExists = await customSelect(
          'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
          variables: [
            const Variable<String>('table'),
            const Variable<String>('livestocks'),
          ],
        ).get();

        if (livestocksExists.isNotEmpty) {
          final tableInfo = await customSelect(
            'PRAGMA table_info(livestocks)',
          ).get();
          final hasPrimaryColor = tableInfo.any(
            (row) => row.data['name'] == 'primary_color',
          );
          final hasSecondaryColor = tableInfo.any(
            (row) => row.data['name'] == 'secondary_color',
          );

          if (!hasPrimaryColor) {
            // Column missing - add it
            await customStatement(
              'ALTER TABLE livestocks ADD COLUMN primary_color TEXT',
            );
          }
          if (!hasSecondaryColor) {
            // Column missing - add it
            await customStatement(
              'ALTER TABLE livestocks ADD COLUMN secondary_color TEXT',
            );
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
  late final LivestockManagementDao livestockManagementDao =
      LivestockManagementDao(this);

  // Individual DAOs for direct access
  late final SpecieDao specieDao = SpecieDao(this);
  late final LivestockTypeDao livestockTypeDao = LivestockTypeDao(this);
  late final BreedDao breedDao = BreedDao(this);
  late final LivestockObtainedMethodDao livestockObtainedMethodDao =
      LivestockObtainedMethodDao(this);
  late final FarmDao farmDao = FarmDao(this);
  late final LivestockDao livestockDao = LivestockDao(this);
  late final EventDao eventDao = EventDao(this);
  late final LogReferenceDao logReferenceDao = LogReferenceDao(this);
  late final VaccineDao vaccineDao = VaccineDao(this);
  late final VaccineTypeDao vaccineTypeDao = VaccineTypeDao(this);
  late final BillDao billDao = BillDao(this);
  late final FinanceExpenseDao financeExpenseDao = FinanceExpenseDao(this);
  late final FinanceIncomeDao financeIncomeDao = FinanceIncomeDao(this);
  late final NotificationDao notificationDao = NotificationDao(this);
  late final ExtensionOfficerDao extensionOfficerDao = ExtensionOfficerDao(
    this,
  );

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

  Future<void> _createTableIfMissing(
    Migrator migrator,
    TableInfo<Table, Object?> table,
  ) async {
    final tableName = table.actualTableName;
    final result = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [const Variable<String>('table'), Variable<String>(tableName)],
    ).get();

    if (result.isEmpty) {
      await migrator.createTable(table);
    }
  }

  Future<void> _migrateFinanceIncomesNullableSourceFields(
    Migrator migrator,
  ) async {
    final exists = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [
        const Variable<String>('table'),
        const Variable<String>('finance_incomes'),
      ],
    ).get();

    if (exists.isEmpty) return;

    final oldExists = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [
        const Variable<String>('table'),
        const Variable<String>('finance_incomes_old'),
      ],
    ).get();

    if (oldExists.isNotEmpty) {
      await customStatement('DROP TABLE finance_incomes_old');
    }

    await customStatement(
      'ALTER TABLE finance_incomes RENAME TO finance_incomes_old',
    );
    await migrator.createTable(financeIncomes);
    await customStatement('''
      INSERT INTO finance_incomes (
        id,
        uuid,
        source_type,
        source_uuid,
        farm_uuid,
        farmer_id,
        reference_no,
        subject_type,
        quantity,
        unit_amount,
        total_amount,
        status,
        notes,
        income_date,
        created_at,
        updated_at,
        synced,
        sync_action
      )
      SELECT
        id,
        uuid,
        source_type,
        source_uuid,
        farm_uuid,
        farmer_id,
        reference_no,
        subject_type,
        quantity,
        unit_amount,
        total_amount,
        status,
        notes,
        income_date,
        created_at,
        updated_at,
        synced,
        sync_action
      FROM finance_incomes_old
    ''');
    await customStatement('DROP TABLE finance_incomes_old');
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
      final birthTypesInfo = await customSelect(
        'PRAGMA table_info(birth_types)',
      ).get();
      final hasLivestockTypeId = birthTypesInfo.any(
        (row) => row.data['name'] == 'livestockTypeId',
      );

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
      await customStatement(
        'ALTER TABLE calving_problems RENAME TO birth_problems',
      );

      // Add livestockTypeId column if it doesn't exist
      final birthProblemsInfo = await customSelect(
        'PRAGMA table_info(birth_problems)',
      ).get();
      final hasLivestockTypeId = birthProblemsInfo.any(
        (row) => row.data['name'] == 'livestockTypeId',
      );

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
      final tableInfo = await customSelect(
        'PRAGMA table_info(vaccinations)',
      ).get();
      final hasVaccineUuid = tableInfo.any(
        (row) => row.data['name'] == 'vaccine_uuid',
      );

      if (hasVaccineUuid) {
        // Migration already done
        return;
      }

      // Add vaccine_uuid column (Drift converts camelCase to snake_case)
      await customStatement(
        'ALTER TABLE vaccinations ADD COLUMN vaccine_uuid TEXT',
      );

      // If vaccine_id exists, copy its values to vaccine_uuid by looking up UUIDs
      final hasVaccineId = tableInfo.any(
        (row) => row.data['name'] == 'vaccine_id',
      );
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

  /// Migration helper: recreate milkings table with nullable measurement columns
  /// and copy data from the old table while converting empty strings to NULL
  Future<void> _migrateMilkingMeasurementColumns(Migrator m) async {
    try {
      final exists = await customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          const Variable<String>('table'),
          Variable<String>('milkings'),
        ],
      ).get();

      if (exists.isEmpty) return;

      // Rename existing table
      await customStatement('ALTER TABLE milkings RENAME TO milkings_old');

      // Create new table with current schema (migrator.createTable uses the table definition)
      await m.createTable(milkings);

      // Copy data from old to new, converting empty strings ('') in measurement columns to NULL
      await customStatement('''
        INSERT INTO milkings (
          id, uuid, farm_uuid, livestock_uuid, milking_method_id, amount,
          lactometer_reading, solid, solid_non_fat, protein,
          corrected_lactometer_reading, total_solids, colony_forming_units,
          acidity, session, status, synced, sync_action, created_at, updated_at
        )
        SELECT
          id, uuid, farm_uuid, livestock_uuid, milking_method_id, amount,
          CASE WHEN lactometer_reading = '' THEN NULL ELSE lactometer_reading END,
          CASE WHEN solid = '' THEN NULL ELSE solid END,
          CASE WHEN solid_non_fat = '' THEN NULL ELSE solid_non_fat END,
          CASE WHEN protein = '' THEN NULL ELSE protein END,
          CASE WHEN corrected_lactometer_reading = '' THEN NULL ELSE corrected_lactometer_reading END,
          CASE WHEN total_solids = '' THEN NULL ELSE total_solids END,
          CASE WHEN colony_forming_units = '' THEN NULL ELSE colony_forming_units END,
          CASE WHEN acidity = '' THEN NULL ELSE acidity END,
          session, status, synced, sync_action, created_at, updated_at
        FROM milkings_old;
      ''');

      // Drop old table
      await customStatement('DROP TABLE milkings_old');
    } catch (e) {
      // If something fails, ignore - migration can be retried or handled manually
    }
  }

  /// Migration to version 20: Add primaryColor and secondaryColor columns to livestocks table
  Future<void> _addLivestockColorColumns(Migrator m) async {
    try {
      // Check if livestocks table exists
      final livestocksExists = await customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          const Variable<String>('table'),
          const Variable<String>('livestocks'),
        ],
      ).get();

      if (livestocksExists.isEmpty) {
        // Table doesn't exist yet, just create it with new schema
        await m.createTable(livestocks);
        return;
      }

      // Check if columns already exist (Drift uses snake_case in SQLite)
      final tableInfo = await customSelect(
        'PRAGMA table_info(livestocks)',
      ).get();
      final hasPrimaryColor = tableInfo.any(
        (row) => row.data['name'] == 'primary_color',
      );
      final hasSecondaryColor = tableInfo.any(
        (row) => row.data['name'] == 'secondary_color',
      );

      // Add primary_color column if it doesn't exist
      if (!hasPrimaryColor) {
        await m.addColumn(livestocks, livestocks.primaryColor);
      }

      // Add secondary_color column if it doesn't exist
      if (!hasSecondaryColor) {
        await m.addColumn(livestocks, livestocks.secondaryColor);
      }
    } catch (e) {
      // Re-throw with context
      throw Exception('Failed to add color columns to livestocks table: $e');
    }
  }

  /// Migration to version 21: Remove UNIQUE constraints from nullable tag columns
  /// This migration recreates the livestocks table without UNIQUE constraints on
  /// rfidTagId, barcodeTagId, and dummyTagId to allow multiple NULL values.
  /// Uniqueness validation is now handled at the application level.
  Future<void> _removeTagUniqueConstraints(Migrator m) async {
    try {
      // Check if livestocks table exists
      final livestocksExists = await customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          const Variable<String>('table'),
          const Variable<String>('livestocks'),
        ],
      ).get();

      if (livestocksExists.isEmpty) {
        // Table doesn't exist yet, just create it with new schema (no UNIQUE constraints)
        await m.createTable(livestocks);
        return;
      }

      // SQLite doesn't support DROP CONSTRAINT directly, so we need to recreate the table
      // Step 1: Create backup table with all data
      await customStatement('''
        CREATE TABLE livestocks_backup AS 
        SELECT * FROM livestocks
      ''');

      // Step 2: Drop old table
      await m.deleteTable('livestocks');

      // Step 3: Create new table without UNIQUE constraints on tag columns
      await m.createTable(livestocks);

      // Step 4: Copy data back from backup
      await customStatement('''
        INSERT INTO livestocks (
          id, farm_uuid, uuid, identification_number, dummy_tag_id, barcode_tag_id, 
          rfid_tag_id, livestock_type_id, name, date_of_birth, mother_uuid, father_uuid,
          gender, breed_id, species_id, status, livestock_obtained_method_id,
          date_first_entered_to_farm, weight_as_on_registration, primary_color,
          secondary_color, synced, sync_action, created_at, updated_at
        )
        SELECT 
          id, farm_uuid, uuid, identification_number, dummy_tag_id, barcode_tag_id,
          rfid_tag_id, livestock_type_id, name, date_of_birth, mother_uuid, father_uuid,
          gender, breed_id, species_id, status, livestock_obtained_method_id,
          date_first_entered_to_farm, weight_as_on_registration, primary_color,
          secondary_color, synced, sync_action, created_at, updated_at
        FROM livestocks_backup
      ''');

      // Step 5: Drop backup table
      await customStatement('DROP TABLE livestocks_backup');

      log('✅ Successfully removed UNIQUE constraints from tag columns');
    } catch (e) {
      // Re-throw with context
      throw Exception(
        'Failed to remove UNIQUE constraints from tag columns: $e',
      );
    }
  }

  /// Migration to version 23: Add sync and audit columns to InvitedExtensionOfficers
  Future<void> _migrateInvitedExtensionOfficersColumns(Migrator m) async {
    // Check if table exists
    final tableExists = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [
        const Variable<String>('table'),
        const Variable<String>('invited_extension_officers'),
      ],
    ).get();

    if (tableExists.isEmpty) {
      // Logic in v22 block creates it with current columns, so we don't need to do anything if it's new
      return;
    }

    // Check existing columns to avoid errors
    final tableInfo = await customSelect(
      'PRAGMA table_info(invited_extension_officers)',
    ).get();

    bool hasColumn(String name) =>
        tableInfo.any((row) => row.data['name'] == name);

    if (!hasColumn('synced')) {
      await m.addColumn(
        invitedExtensionOfficers,
        invitedExtensionOfficers.synced,
      );
    }
    if (!hasColumn('sync_action')) {
      await m.addColumn(
        invitedExtensionOfficers,
        invitedExtensionOfficers.syncAction,
      );
    }
    if (!hasColumn('created_at')) {
      await m.addColumn(
        invitedExtensionOfficers,
        invitedExtensionOfficers.createdAt,
      );
    }
    if (!hasColumn('updated_at')) {
      await m.addColumn(
        invitedExtensionOfficers,
        invitedExtensionOfficers.updatedAt,
      );
    }
  }

  /// Migration helper: add organization and location metadata columns to invited_extension_officers
  Future<void> _migrateInvitedExtensionOfficersAddMetadata(Migrator m) async {
    try {
      final tableExists = await customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          const Variable<String>('table'),
          Variable<String>('invited_extension_officers'),
        ],
      ).get();

      if (tableExists.isEmpty) return;

      final tableInfo = await customSelect(
        'PRAGMA table_info(invited_extension_officers)',
      ).get();

      bool hasColumn(String name) =>
          tableInfo.any((row) => row.data['name'] == name);

      if (!hasColumn('organization')) {
        await customStatement(
          'ALTER TABLE invited_extension_officers ADD COLUMN organization TEXT',
        );
      }
      if (!hasColumn('country_id')) {
        await customStatement(
          'ALTER TABLE invited_extension_officers ADD COLUMN country_id INTEGER',
        );
      }
      if (!hasColumn('region_id')) {
        await customStatement(
          'ALTER TABLE invited_extension_officers ADD COLUMN region_id INTEGER',
        );
      }
      if (!hasColumn('district_id')) {
        await customStatement(
          'ALTER TABLE invited_extension_officers ADD COLUMN district_id INTEGER',
        );
      }
      if (!hasColumn('ward_id')) {
        await customStatement(
          'ALTER TABLE invited_extension_officers ADD COLUMN ward_id INTEGER',
        );
      }
      if (!hasColumn('is_verified')) {
        await customStatement(
          'ALTER TABLE invited_extension_officers ADD COLUMN is_verified INTEGER',
        );
      }
    } catch (e) {
      // ignore migration errors - can be retried
    }
  }

  /// Migration to version 27: Rename medications table to treatments and add nextMedicationDate column
  Future<void> _migrateMedicationsToTreatments(Migrator m) async {
    try {
      // Check if medications table exists
      final medicationsExists = await customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          const Variable<String>('table'),
          const Variable<String>('medications'),
        ],
      ).get();

      if (medicationsExists.isNotEmpty) {
        // Step 1: Rename medications table to treatments
        await customStatement('ALTER TABLE medications RENAME TO treatments');

        // Step 2: Check if nextMedicationDate column already exists
        final tableInfo = await customSelect(
          'PRAGMA table_info(treatments)',
        ).get();
        final hasNextMedicationDate = tableInfo.any(
          (row) => row.data['name'] == 'nextMedicationDate',
        );

        // Step 3: Add nextMedicationDate column if it doesn't exist
        if (!hasNextMedicationDate) {
          await customStatement(
            'ALTER TABLE treatments ADD COLUMN nextMedicationDate TEXT',
          );
        }
      } else {
        // If medications table doesn't exist, create treatments table
        await m.createTable(treatments);
      }
    } catch (e) {
      // If treatments table already exists, just ensure nextMedicationDate column exists
      try {
        final tableInfo = await customSelect(
          'PRAGMA table_info(treatments)',
        ).get();
        final hasNextMedicationDate = tableInfo.any(
          (row) => row.data['name'] == 'nextMedicationDate',
        );

        if (!hasNextMedicationDate) {
          await customStatement(
            'ALTER TABLE treatments ADD COLUMN nextMedicationDate TEXT',
          );
        }
      } catch (e2) {
        // ignore migration errors - can be retried
      }
    }
  }

  Future<void> _migrateDisposalSaleColumns() async {
    try {
      final exists = await customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          const Variable<String>('table'),
          const Variable<String>('disposals'),
        ],
      ).get();
      if (exists.isEmpty) return;

      final info = await customSelect('PRAGMA table_info(disposals)').get();
      final names = info.map((r) => r.data['name'] as String).toSet();
      if (!names.contains('sale_weight')) {
        await customStatement(
          'ALTER TABLE disposals ADD COLUMN sale_weight REAL',
        );
      }
      if (!names.contains('sale_price')) {
        await customStatement(
          'ALTER TABLE disposals ADD COLUMN sale_price REAL',
        );
      }
      if (!names.contains('buyer_name')) {
        await customStatement(
          'ALTER TABLE disposals ADD COLUMN buyer_name TEXT',
        );
      }
    } catch (e) {
      log('disposals sale columns migration: $e');
    }
  }

  /// Migration to version 28: Add eventDate column to all log tables
  Future<void> _migrateAddEventDateToLogTables(Migrator m) async {
    final logTables = [
      'treatments',
      'feedings',
      'vaccinations',
      'dewormings',
      'weight_changes',
      'disposals',
      'birth_events',
      'aborted_pregnancies',
      'milkings',
      'pregnancies',
      'inseminations',
      'dryoffs',
      'transfers',
      'calvings',
    ];

    for (final tableName in logTables) {
      try {
        // Check if table exists
        final tableExists = await customSelect(
          'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
          variables: [
            const Variable<String>('table'),
            Variable<String>(tableName),
          ],
        ).get();

        if (tableExists.isNotEmpty) {
          // Check if eventDate column already exists
          final tableInfo = await customSelect(
            'PRAGMA table_info($tableName)',
          ).get();
          final hasEventDate = tableInfo.any(
            (row) => row.data['name'] == 'eventDate',
          );

          // Add eventDate column if it doesn't exist
          if (!hasEventDate) {
            await customStatement(
              'ALTER TABLE $tableName ADD COLUMN eventDate TEXT',
            );
            log('✅ Added eventDate column to $tableName table');
          }
        } else {
          log('⚠️ Table $tableName does not exist, skipping...');
        }
      } catch (e) {
        log('❌ Error adding eventDate to $tableName: $e');
        // Continue with other tables even if one fails
      }
    }
  }

  /// v33: Drop duplicated drug/vet/route text columns; align with medicines + administration_routes + vetId.
  Future<void> _migratePrepuceConditionsMedicineVetColumns() async {
    try {
      final exists = await customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          const Variable<String>('table'),
          const Variable<String>('prepuce_conditions'),
        ],
      ).get();
      if (exists.isEmpty) return;

      final info = await customSelect(
        'PRAGMA table_info(prepuce_conditions)',
      ).get();
      final names = info.map((r) => r.data['name'] as String).toSet();
      if (names.contains('medicine_id')) return;
      if (!names.contains('drug_name')) return;

      await transaction(() async {
        await customStatement('''
CREATE TABLE prepuce_conditions__new (
  id INTEGER,
  uuid TEXT NOT NULL,
  event_date TEXT,
  farm_uuid TEXT NOT NULL,
  livestock_uuid TEXT NOT NULL,
  condition_type TEXT NOT NULL,
  severity TEXT NOT NULL,
  clinical_signs_json TEXT NOT NULL DEFAULT '[]',
  cause_risk TEXT,
  treatment_given_json TEXT NOT NULL DEFAULT '[]',
  medicine_id INTEGER,
  administration_route_id INTEGER,
  vet_id TEXT,
  quantity TEXT,
  dose TEXT,
  reported_by TEXT NOT NULL,
  attended_by TEXT,
  breeding_status TEXT NOT NULL,
  healing_status TEXT,
  follow_up_date TEXT,
  notes TEXT,
  synced INTEGER NOT NULL DEFAULT 0,
  sync_action TEXT NOT NULL DEFAULT 'create',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  PRIMARY KEY (uuid)
)''');

        await customStatement(r'''
INSERT INTO prepuce_conditions__new (
  id, uuid, event_date, farm_uuid, livestock_uuid, condition_type, severity,
  clinical_signs_json, cause_risk, treatment_given_json,
  medicine_id, administration_route_id, vet_id, quantity, dose,
  reported_by, attended_by, breeding_status, healing_status, follow_up_date,
  notes, synced, sync_action, created_at, updated_at
)
SELECT
  id, uuid, event_date, farm_uuid, livestock_uuid, condition_type, severity,
  clinical_signs_json, cause_risk, treatment_given_json,
  NULL, NULL, NULL, NULL, dosage,
  reported_by, attended_by, breeding_status, healing_status, follow_up_date,
  NULLIF(TRIM(COALESCE(notes, '') ||
    CASE WHEN drug_name IS NOT NULL AND trim(drug_name) != '' THEN x'0a' || '[Legacy] drug: ' || drug_name ELSE '' END ||
    CASE WHEN duration IS NOT NULL AND trim(duration) != '' THEN x'0a' || '[Legacy] duration: ' || duration ELSE '' END ||
    CASE WHEN route IS NOT NULL AND trim(route) != '' THEN x'0a' || '[Legacy] route code: ' || route ELSE '' END ||
    CASE WHEN vet_name IS NOT NULL AND trim(vet_name) != '' THEN x'0a' || '[Legacy] vet: ' || vet_name ELSE '' END ||
    CASE WHEN vet_contact IS NOT NULL AND trim(vet_contact) != '' THEN x'0a' || '[Legacy] vet contact: ' || vet_contact ELSE '' END
  ), ''),
  synced, sync_action, created_at, updated_at
FROM prepuce_conditions
''');

        await customStatement('DROP TABLE prepuce_conditions');
        await customStatement(
          'ALTER TABLE prepuce_conditions__new RENAME TO prepuce_conditions',
        );
      });
      log(
        '✅ Migrated prepuce_conditions to shared medicine / route / vet columns',
      );
    } catch (e, st) {
      log('❌ prepuce_conditions v33 migration failed: $e', stackTrace: st);
    }
  }

  /// v34: Remove reported_by / attended_by; add extension_officer_id (deworming-style provider).
  Future<void> _migratePrepuceConditionsTreatmentProviderColumns() async {
    try {
      final exists = await customSelect(
        'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
        variables: [
          const Variable<String>('table'),
          const Variable<String>('prepuce_conditions'),
        ],
      ).get();
      if (exists.isEmpty) return;

      final info = await customSelect(
        'PRAGMA table_info(prepuce_conditions)',
      ).get();
      final names = info.map((r) => r.data['name'] as String).toSet();
      if (names.contains('extension_officer_id')) return;
      if (!names.contains('reported_by')) return;

      await transaction(() async {
        await customStatement('''
CREATE TABLE prepuce_conditions__v34 (
  id INTEGER,
  uuid TEXT NOT NULL,
  event_date TEXT,
  farm_uuid TEXT NOT NULL,
  livestock_uuid TEXT NOT NULL,
  condition_type TEXT NOT NULL,
  severity TEXT NOT NULL,
  clinical_signs_json TEXT NOT NULL DEFAULT '[]',
  cause_risk TEXT,
  treatment_given_json TEXT NOT NULL DEFAULT '[]',
  medicine_id INTEGER,
  administration_route_id INTEGER,
  vet_id TEXT,
  extension_officer_id TEXT,
  quantity TEXT,
  dose TEXT,
  breeding_status TEXT NOT NULL,
  healing_status TEXT,
  follow_up_date TEXT,
  notes TEXT,
  synced INTEGER NOT NULL DEFAULT 0,
  sync_action TEXT NOT NULL DEFAULT 'create',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  PRIMARY KEY (uuid)
)''');

        await customStatement(r'''
INSERT INTO prepuce_conditions__v34 (
  id, uuid, event_date, farm_uuid, livestock_uuid, condition_type, severity,
  clinical_signs_json, cause_risk, treatment_given_json,
  medicine_id, administration_route_id, vet_id, extension_officer_id, quantity, dose,
  breeding_status, healing_status, follow_up_date,
  notes, synced, sync_action, created_at, updated_at
)
SELECT
  id, uuid, event_date, farm_uuid, livestock_uuid, condition_type, severity,
  clinical_signs_json, cause_risk, treatment_given_json,
  medicine_id, administration_route_id, vet_id, NULL, quantity, dose,
  breeding_status, healing_status, follow_up_date,
  NULLIF(TRIM(COALESCE(notes, '') ||
    CASE WHEN reported_by IS NOT NULL AND trim(reported_by) != '' THEN x'0a' || '[Legacy] reported_by: ' || reported_by ELSE '' END ||
    CASE WHEN attended_by IS NOT NULL AND trim(attended_by) != '' THEN x'0a' || '[Legacy] attended_by: ' || attended_by ELSE '' END
  ), ''),
  synced, sync_action, created_at, updated_at
FROM prepuce_conditions
''');

        await customStatement('DROP TABLE prepuce_conditions');
        await customStatement(
          'ALTER TABLE prepuce_conditions__v34 RENAME TO prepuce_conditions',
        );
      });
      log(
        '✅ prepuce_conditions v34: extension officer id, dropped reported/attended',
      );
    } catch (e, st) {
      log('❌ prepuce_conditions v34 migration failed: $e', stackTrace: st);
    }
  }

  /// v35: Align with Laravel — integer FKs on logs; medicine-style reference rows.
  Future<void> _migratePrepuceV35IdBasedSchema(Migrator m) async {
    try {
      await customStatement('DROP TABLE IF EXISTS prepuce_condition_lookups');
      await _createTableIfMissing(m, prepuceConditionTypes);
      await _createTableIfMissing(m, prepuceSeverities);
      await _createTableIfMissing(m, prepuceClinicalSigns);
      await _createTableIfMissing(m, prepuceCauseRisks);
      await _createTableIfMissing(m, prepuceTreatmentsGiven);
      await _createTableIfMissing(m, prepuceBreedingStatuses);
      await _createTableIfMissing(m, prepuceHealingStatuses);
      await customStatement('DROP TABLE IF EXISTS prepuce_conditions');
      await m.createTable(prepuceConditions);
      log('✅ v35: prepuce_conditions + split prepuce lookup tables (id-based)');
    } catch (e, st) {
      log('❌ prepuce v35 migration failed: $e', stackTrace: st);
    }
  }

  /// v36: Split local prepuce lookup cache into backend-aligned individual tables.
  Future<void> _migratePrepuceV36SplitReferenceTables(Migrator m) async {
    try {
      await _createTableIfMissing(m, prepuceConditionTypes);
      await _createTableIfMissing(m, prepuceSeverities);
      await _createTableIfMissing(m, prepuceClinicalSigns);
      await _createTableIfMissing(m, prepuceCauseRisks);
      await _createTableIfMissing(m, prepuceTreatmentsGiven);
      await _createTableIfMissing(m, prepuceBreedingStatuses);
      await _createTableIfMissing(m, prepuceHealingStatuses);

      final oldExists = await customSelect(
        "SELECT 1 FROM sqlite_master WHERE type='table' AND name='prepuce_reference_options' LIMIT 1",
      ).get();
      if (oldExists.isNotEmpty) {
        final rows = await customSelect(
          'SELECT kind, reference_id, name, name_sw FROM prepuce_reference_options',
        ).get();
        for (final row in rows) {
          final kind = row.read<String>('kind');
          final id = row.read<int>('reference_id');
          final name = row.read<String>('name');
          final nameSw = row.read<String?>('name_sw');

          String table;
          switch (kind) {
            case 'condition_type':
              table = 'prepuce_condition_types';
              break;
            case 'severity':
              table = 'prepuce_severities';
              break;
            case 'clinical_sign':
              table = 'prepuce_clinical_signs';
              break;
            case 'cause_risk':
              table = 'prepuce_cause_risks';
              break;
            case 'treatment_given':
              table = 'prepuce_treatments_given';
              break;
            case 'breeding_status':
              table = 'prepuce_breeding_statuses';
              break;
            case 'healing_status':
              table = 'prepuce_healing_statuses';
              break;
            default:
              continue;
          }
          await customStatement(
            'INSERT OR REPLACE INTO $table (id, name, name_sw) VALUES (?, ?, ?)',
            [id, name, nameSw],
          );
        }
        await customStatement('DROP TABLE IF EXISTS prepuce_reference_options');
      }
      log('✅ v36: split prepuce lookup tables migrated from local cache');
    } catch (e, st) {
      log('❌ prepuce v36 migration failed: $e', stackTrace: st);
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
