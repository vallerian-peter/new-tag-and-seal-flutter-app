import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../features/all.additional.data/data/local/tables/school_level_table.dart';
import '../../features/all.additional.data/data/local/tables/identity_card_type_table.dart';
import '../../features/all.additional.data/data/local/tables/legal_status_table.dart';
part 'reference_data_dao.g.dart';

/// DAO for handling reference/lookup data (SchoolLevel, IdentityCardType, LegalStatus)
/// This provides simple, easy-to-understand methods for reference data queries
@DriftAccessor(tables: [SchoolLevels, IdentityCardTypes, LegalStatuses])
class ReferenceDataDao extends DatabaseAccessor<AppDatabase> with _$ReferenceDataDaoMixin {
  ReferenceDataDao(AppDatabase db) : super(db);

  // ==================== SCHOOL LEVEL METHODS ====================

  /// Get all school levels
  Future<List<SchoolLevel>> getAllSchoolLevels() => select(schoolLevels).get();

  /// Get a single school level by ID
  Future<SchoolLevel?> getSchoolLevelById(int id) =>
      (select(schoolLevels)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Insert a new school level
  Future<int> insertSchoolLevel(SchoolLevelsCompanion entry) =>
      into(schoolLevels).insert(entry);

  /// Update a school level
  Future<bool> updateSchoolLevel(SchoolLevel entry) =>
      update(schoolLevels).replace(entry);

  /// Delete a school level
  Future<int> deleteSchoolLevel(int id) =>
      (delete(schoolLevels)..where((s) => s.id.equals(id))).go();

  /// Insert multiple school levels at once
  Future<void> insertSchoolLevels(List<SchoolLevelsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(schoolLevels, entries, mode: InsertMode.insertOrReplace);
    });
  }

  // ==================== IDENTITY CARD TYPE METHODS ====================

  /// Get all identity card types
  Future<List<IdentityCardType>> getAllIdentityCardTypes() =>
      select(identityCardTypes).get();

  /// Get a single identity card type by ID
  Future<IdentityCardType?> getIdentityCardTypeById(int id) =>
      (select(identityCardTypes)..where((i) => i.id.equals(id))).getSingleOrNull();

  /// Insert a new identity card type
  Future<int> insertIdentityCardType(IdentityCardTypesCompanion entry) =>
      into(identityCardTypes).insert(entry);

  /// Update an identity card type
  Future<bool> updateIdentityCardType(IdentityCardType entry) =>
      update(identityCardTypes).replace(entry);

  /// Delete an identity card type
  Future<int> deleteIdentityCardType(int id) =>
      (delete(identityCardTypes)..where((i) => i.id.equals(id))).go();

  /// Insert multiple identity card types at once
  Future<void> insertIdentityCardTypes(List<IdentityCardTypesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(identityCardTypes, entries, mode: InsertMode.insertOrReplace);
    });
  }

  // ==================== LEGAL STATUS METHODS ====================

  /// Get all legal statuses
  Future<List<LegalStatus>> getAllLegalStatuses() => select(legalStatuses).get();

  /// Get a single legal status by ID
  Future<LegalStatus?> getLegalStatusById(int id) =>
      (select(legalStatuses)..where((l) => l.id.equals(id))).getSingleOrNull();

  /// Insert a new legal status
  Future<int> insertLegalStatus(LegalStatusesCompanion entry) =>
      into(legalStatuses).insert(entry);

  /// Update a legal status
  Future<bool> updateLegalStatus(LegalStatus entry) =>
      update(legalStatuses).replace(entry);

  /// Delete a legal status
  Future<int> deleteLegalStatus(int id) =>
      (delete(legalStatuses)..where((l) => l.id.equals(id))).go();

  /// Insert multiple legal statuses at once
  Future<void> insertLegalStatuses(List<LegalStatusesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(legalStatuses, entries, mode: InsertMode.insertOrReplace);
    });
  }

  // ==================== DELETE ALL OPERATIONS ====================

  /// Delete all school levels (USE WITH CAUTION!)
  Future<int> deleteAllSchoolLevels() => delete(schoolLevels).go();

  /// Delete all identity card types (USE WITH CAUTION!)
  Future<int> deleteAllIdentityCardTypes() => delete(identityCardTypes).go();

  /// Delete all legal statuses (USE WITH CAUTION!)
  Future<int> deleteAllLegalStatuses() => delete(legalStatuses).go();

  // ==================== UTILITY METHODS ====================

  /// Search school levels by name
  Future<List<SchoolLevel>> searchSchoolLevels(String query) =>
      (select(schoolLevels)..where((s) => s.name.like('%$query%'))).get();

  /// Search identity card types by name
  Future<List<IdentityCardType>> searchIdentityCardTypes(String query) =>
      (select(identityCardTypes)..where((i) => i.name.like('%$query%'))).get();

  /// Search legal statuses by name
  Future<List<LegalStatus>> searchLegalStatuses(String query) =>
      (select(legalStatuses)..where((l) => l.name.like('%$query%'))).get();

  /// Load all reference data at once (useful for app initialization)
  Future<Map<String, dynamic>> loadAllReferenceData() async {
    final schoolLevels = await getAllSchoolLevels();
    final identityCardTypes = await getAllIdentityCardTypes();
    final legalStatuses = await getAllLegalStatuses();

    return {
      'schoolLevels': schoolLevels,
      'identityCardTypes': identityCardTypes,
      'legalStatuses': legalStatuses,
    };
  }
}

