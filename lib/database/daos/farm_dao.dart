import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../features/farms/data/tables/farm-table.dart';
import '../../features/livestocks/data/tables/livestock_table.dart';
import '../../features/farms/domain/models/farm_model.dart';
import '../../features/livestocks/domain/models/livestock_model.dart';
import '../../features/farms/data/mapper/farm_mapper.dart';
import '../../features/livestocks/data/mapper/livestock_mapper.dart';
part 'farm_dao.g.dart';

/// DAO for handling farm-related data with livestock relationships
/// This provides methods for farm operations and their associated livestock
@DriftAccessor(tables: [Farms, Livestocks])
class FarmDao extends DatabaseAccessor<AppDatabase> with _$FarmDaoMixin {
  FarmDao(AppDatabase db) : super(db);

  // ==================== FARM CRUD OPERATIONS ====================

  /// Get all farms
  Future<List<Farm>> getAllFarms() => select(farms).get();

  /// Get all farms excluding deleted ones
  Future<List<Farm>> getAllActiveFarms() =>
      (select(farms)..where((f) => f.syncAction.isNotValue('deleted'))).get();

  /// Get farm by ID
  Future<Farm?> getFarmById(int id) =>
      (select(farms)..where((f) => f.id.equals(id))).getSingleOrNull();

  /// Get farm by UUID
  Future<Farm?> getFarmByUuid(String uuid) =>
      (select(farms)..where((f) => f.uuid.equals(uuid))).getSingleOrNull();

  /// Insert a new farm
  Future<int> insertFarm(FarmsCompanion entry) => into(farms).insert(entry);

  /// Update a farm
  Future<bool> updateFarm(Farm entry) => update(farms).replace(entry);

  /// Delete a farm
  Future<int> deleteFarm(int id) =>
      (delete(farms)..where((f) => f.id.equals(id))).go();

  /// Get farms by farmer ID
  Future<List<Farm>> getFarmsByFarmerId(int farmerId) =>
      (select(farms)..where((f) => f.farmerId.equals(farmerId))).get();

  /// Get unsynced farms
  Future<List<Farm>> getUnsyncedFarms() =>
      (select(farms)..where((f) => f.synced.equals(false))).get();

  // ==================== LIVESTOCK RELATIONSHIPS ====================

  /// Get all livestock for a specific farm by farm UUID
  Future<List<Livestock>> getLivestockByFarmUuid(String farmUuid) =>
      (select(livestocks)..where((l) => l.farmUuid.equals(farmUuid))).get();

  /// Get farm with its livestock (one-to-many relationship)
  Future<FarmWithLivestock?> getFarmWithLivestock(int farmId) async {
    final farm = await getFarmById(farmId);
    if (farm == null) return null;

    final livestockList = await getLivestockByFarmUuid(farm.uuid);
    return FarmWithLivestock(farm: farm, livestock: livestockList);
  }

  /// Get all farms with their livestock
  Future<List<FarmWithLivestock>> getAllFarmsWithLivestock() async {
    final allFarms = await getAllFarms();
    final List<FarmWithLivestock> farmsWithLivestock = [];

    for (final farm in allFarms) {
      final livestockList = await getLivestockByFarmUuid(farm.uuid);
      farmsWithLivestock.add(
        FarmWithLivestock(farm: farm, livestock: livestockList),
      );
    }

    return farmsWithLivestock;
  }

  /// Get farms by farmer with their livestock
  Future<List<FarmWithLivestock>> getFarmsByFarmerWithLivestock(
    int farmerId,
  ) async {
    final farms = await getFarmsByFarmerId(farmerId);
    final List<FarmWithLivestock> farmsWithLivestock = [];

    for (final farm in farms) {
      final livestockList = await getLivestockByFarmUuid(farm.uuid);
      farmsWithLivestock.add(
        FarmWithLivestock(farm: farm, livestock: livestockList),
      );
    }

    return farmsWithLivestock;
  }

  // ==================== BATCH OPERATIONS ====================

  /// Insert multiple farms at once
  Future<void> insertFarms(List<FarmsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(farms, entries, mode: InsertMode.insertOrReplace);
    });
  }

  /// Get unsynced farms with their livestock
  Future<List<FarmWithLivestock>> getUnsyncedFarmsWithLivestock() async {
    final unsyncedFarms = await getUnsyncedFarms();
    final List<FarmWithLivestock> farmsWithLivestock = [];

    for (final farm in unsyncedFarms) {
      final livestockList = await getLivestockByFarmUuid(farm.uuid);
      farmsWithLivestock.add(
        FarmWithLivestock(farm: farm, livestock: livestockList),
      );
    }

    return farmsWithLivestock;
  }

  // ==================== SEARCH OPERATIONS ====================

  /// Search farms by name
  Future<List<Farm>> searchFarmsByName(String name) =>
      (select(farms)..where((f) => f.name.like('%$name%'))).get();

  /// Search farms by location (ward, district, region, country)
  Future<List<Farm>> searchFarmsByLocation({
    int? wardId,
    int? districtId,
    int? regionId,
    int? countryId,
  }) {
    var query = select(farms);

    if (wardId != null) {
      query = query..where((f) => f.wardId.equals(wardId));
    }
    if (districtId != null) {
      query = query..where((f) => f.districtId.equals(districtId));
    }
    if (regionId != null) {
      query = query..where((f) => f.regionId.equals(regionId));
    }
    if (countryId != null) {
      query = query..where((f) => f.countryId.equals(countryId));
    }

    return query.get();
  }
}

/// Data class representing a farm with its associated livestock
class FarmWithLivestock {
  final Farm farm;
  final List<Livestock> livestock;

  const FarmWithLivestock({required this.farm, required this.livestock});

  /// Convert to domain models
  FarmModel get farmModel => FarmMapper.farmToEntity(farm.toJson());
  List<LivestockModel> get livestockModels => livestock
      .map((l) => LivestockMapper.livestockToEntity(l.toJson()))
      .toList();

  /// Get livestock count
  int get livestockCount => livestock.length;

  /// Check if farm has livestock
  bool get hasLivestock => livestock.isNotEmpty;

  @override
  String toString() {
    return 'FarmWithLivestock(farm: $farm, livestockCount: $livestockCount)';
  }
}
