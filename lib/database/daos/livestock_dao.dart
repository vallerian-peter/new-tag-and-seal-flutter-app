import 'package:drift/drift.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/data/mapper/farm_mapper.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/domain/models/farm_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/data/mapper/livestock_mapper.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/domain/models/livestock_model.dart';
import '../../features/farms/data/tables/farm-table.dart';
import '../../features/livestocks/data/tables/livestock_table.dart';
import '../app_database.dart';
part 'livestock_dao.g.dart';

/// DAO for handling livestock-related data with farm relationships
/// This provides methods for livestock operations and their associated farm
@DriftAccessor(tables: [Livestocks, Farms])
class LivestockDao extends DatabaseAccessor<AppDatabase>
    with _$LivestockDaoMixin {
  LivestockDao(AppDatabase db) : super(db);

  // ==================== LIVESTOCK CRUD OPERATIONS ====================

  /// Get all livestock
  Future<List<Livestock>> getAllLivestock() => select(livestocks).get();

  /// Get all livestock excluding deleted ones
  Future<List<Livestock>> getAllActiveLivestock() => (select(
    livestocks,
  )..where((l) => l.syncAction.isNotValue('deleted'))).get();

  /// Get livestock by ID
  Future<Livestock?> getLivestockById(int id) =>
      (select(livestocks)..where((l) => l.id.equals(id))).getSingleOrNull();

  /// Get livestock by UUID
  Future<Livestock?> getLivestockByUuid(String uuid) =>
      (select(livestocks)..where((l) => l.uuid.equals(uuid))).getSingleOrNull();

  /// Insert a new livestock
  Future<int> insertLivestock(LivestocksCompanion entry) =>
      into(livestocks).insert(entry);

  /// Update a livestock
  Future<bool> updateLivestock(Livestock entry) =>
      update(livestocks).replace(entry);

  /// Delete a livestock
  Future<int> deleteLivestock(int id) =>
      (delete(livestocks)..where((l) => l.id.equals(id))).go();

  Future<void> deleteServerLivestockNotIn(List<String> serverUuids) async {
    if (serverUuids.isEmpty) {
      await (delete(livestocks)..where((l) => l.synced.equals(true))).go();
      return;
    }

    await (delete(
          livestocks,
        )..where((l) => l.synced.equals(true) & l.uuid.isIn(serverUuids).not()))
        .go();
  }

  /// Get livestock by farm UUID
  Future<List<Livestock>> getLivestockByFarmUuid(String farmUuid) =>
      (select(livestocks)..where((l) => l.farmUuid.equals(farmUuid))).get();

  /// Find a livestock record by either barcode or RFID tag
  Future<Livestock?> getLivestockByTagValue(String tagValue) {
    final query = select(livestocks)
      ..where((tbl) {
        final barcodeMatch = tbl.barcodeTagId.equals(tagValue);
        final rfidMatch = tbl.rfidTagId.equals(tagValue);
        return tbl.syncAction.isNotValue('deleted') & (barcodeMatch | rfidMatch);
      });

    return query.getSingleOrNull();
  }

  /// Get active livestock by farm UUID (excluding deleted ones)
  Future<List<Livestock>> getActiveLivestockByFarmUuid(String farmUuid) =>
      (select(livestocks)
            ..where((l) => l.farmUuid.equals(farmUuid))
            ..where((l) => l.syncAction.isNotValue('deleted')))
          .get();

  /// Get unsynced livestock
  Future<List<Livestock>> getUnsyncedLivestock() =>
      (select(livestocks)..where((l) => l.synced.equals(false))).get();

  Future<void> moveLivestockToFarm({
    required String livestockUuid,
    required String newFarmUuid,
    required String updatedAt,
  }) async {
    await (update(livestocks)..where((tbl) => tbl.uuid.equals(livestockUuid)))
        .write(
      LivestocksCompanion(
        farmUuid: Value(newFarmUuid),
        synced: const Value(false),
        syncAction: const Value('update'),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  // ==================== FARM RELATIONSHIPS ====================

  /// Get livestock with its farm (many-to-one relationship)
  Future<LivestockWithFarm?> getLivestockWithFarm(int livestockId) async {
    final livestock = await getLivestockById(livestockId);
    if (livestock == null) return null;

    final farm = await (select(
      farms,
    )..where((f) => f.uuid.equals(livestock.farmUuid))).getSingleOrNull();
    if (farm == null) return null;

    return LivestockWithFarm(livestock: livestock, farm: farm);
  }

  /// Get all livestock with their farms
  Future<List<LivestockWithFarm>> getAllLivestockWithFarms() async {
    final allLivestock = await getAllLivestock();
    final List<LivestockWithFarm> livestockWithFarms = [];

    for (final livestock in allLivestock) {
      final farm = await (select(
        farms,
      )..where((f) => f.uuid.equals(livestock.farmUuid))).getSingleOrNull();
      if (farm != null) {
        livestockWithFarms.add(
          LivestockWithFarm(livestock: livestock, farm: farm),
        );
      }
    }

    return livestockWithFarms;
  }

  /// Get livestock by farm UUID with farm details
  Future<List<LivestockWithFarm>> getLivestockByFarmWithFarm(
    String farmUuid,
  ) async {
    final livestockList = await getLivestockByFarmUuid(farmUuid);
    final List<LivestockWithFarm> livestockWithFarms = [];

    for (final livestock in livestockList) {
      final farm = await (select(
        farms,
      )..where((f) => f.uuid.equals(livestock.farmUuid))).getSingleOrNull();
      if (farm != null) {
        livestockWithFarms.add(
          LivestockWithFarm(livestock: livestock, farm: farm),
        );
      }
    }

    return livestockWithFarms;
  }

  /// Get unsynced livestock with their farms
  Future<List<LivestockWithFarm>> getUnsyncedLivestockWithFarms() async {
    final unsyncedLivestock = await getUnsyncedLivestock();
    final List<LivestockWithFarm> livestockWithFarms = [];

    for (final livestock in unsyncedLivestock) {
      final farm = await (select(
        farms,
      )..where((f) => f.uuid.equals(livestock.farmUuid))).getSingleOrNull();
      if (farm != null) {
        livestockWithFarms.add(
          LivestockWithFarm(livestock: livestock, farm: farm),
        );
      }
    }

    return livestockWithFarms;
  }

  // ==================== BATCH OPERATIONS ====================

  /// Insert multiple livestock at once
  Future<void> insertMultipleLivestock(
    List<LivestocksCompanion> entries,
  ) async {
    await batch((batch) {
      batch.insertAll(livestocks, entries, mode: InsertMode.insertOrReplace);
    });
  }

  // ==================== SEARCH OPERATIONS ====================

  /// Search livestock by name
  Future<List<Livestock>> searchLivestockByName(String name) =>
      (select(livestocks)..where((l) => l.name.like('%$name%'))).get();

  /// Search livestock by identification number
  Future<List<Livestock>> searchLivestockByIdentificationNumber(
    String identificationNumber,
  ) =>
      (select(livestocks)..where(
            (l) => l.identificationNumber.like('%$identificationNumber%'),
          ))
          .get();

  /// Search livestock by gender
  Future<List<Livestock>> searchLivestockByGender(String gender) =>
      (select(livestocks)..where((l) => l.gender.equals(gender))).get();

  /// Search livestock by breed
  Future<List<Livestock>> searchLivestockByBreed(int breedId) =>
      (select(livestocks)..where((l) => l.breedId.equals(breedId))).get();

  /// Search livestock by species
  Future<List<Livestock>> searchLivestockBySpecies(int speciesId) =>
      (select(livestocks)..where((l) => l.speciesId.equals(speciesId))).get();

  /// Search livestock by livestock type
  Future<List<Livestock>> searchLivestockByType(int livestockTypeId) => (select(
    livestocks,
  )..where((l) => l.livestockTypeId.equals(livestockTypeId))).get();

  /// Search livestock by status
  Future<List<Livestock>> searchLivestockByStatus(String status) =>
      (select(livestocks)..where((l) => l.status.equals(status))).get();

  // ==================== PARENT-CHILD RELATIONSHIPS ====================

  /// Get livestock by mother UUID
  Future<List<Livestock>> getLivestockByMotherUuid(String motherUuid) =>
      (select(livestocks)..where((l) => l.motherUuid.equals(motherUuid))).get();

  /// Get livestock by father UUID
  Future<List<Livestock>> getLivestockByFatherUuid(String fatherUuid) =>
      (select(livestocks)..where((l) => l.fatherUuid.equals(fatherUuid))).get();

  /// Get livestock with their parents
  Future<LivestockWithParents?> getLivestockWithParents(int livestockId) async {
    final livestock = await getLivestockById(livestockId);
    if (livestock == null) return null;

    Livestock? mother;
    Livestock? father;

    if (livestock.motherUuid != null) {
      mother = await getLivestockByUuid(livestock.motherUuid!);
    }
    if (livestock.fatherUuid != null) {
      father = await getLivestockByUuid(livestock.fatherUuid!);
    }

    return LivestockWithParents(
      livestock: livestock,
      mother: mother,
      father: father,
    );
  }
}

/// Data class representing livestock with its associated farm
class LivestockWithFarm {
  final Livestock livestock;
  final Farm farm;

  const LivestockWithFarm({required this.livestock, required this.farm});

  /// Convert to domain models
  LivestockModel get livestockModel =>
      LivestockMapper.livestockToEntity(livestock.toJson());
  FarmModel get farmModel => FarmMapper.farmToEntity(farm.toJson());

  @override
  String toString() {
    return 'LivestockWithFarm(livestock: ${livestock.name}, farm: ${farm.name})';
  }
}

/// Data class representing livestock with its parents
class LivestockWithParents {
  final Livestock livestock;
  final Livestock? mother;
  final Livestock? father;

  const LivestockWithParents({
    required this.livestock,
    this.mother,
    this.father,
  });

  /// Convert to domain models
  LivestockModel get livestockModel =>
      LivestockMapper.livestockToEntity(livestock.toJson());
  LivestockModel? get motherModel => mother != null
      ? LivestockMapper.livestockToEntity(mother!.toJson())
      : null;
  LivestockModel? get fatherModel => father != null
      ? LivestockMapper.livestockToEntity(father!.toJson())
      : null;

  /// Check if has mother
  bool get hasMother => mother != null;

  /// Check if has father
  bool get hasFather => father != null;

  @override
  String toString() {
    return 'LivestockWithParents(livestock: ${livestock.name}, hasMother: $hasMother, hasFather: $hasFather)';
  }
}
