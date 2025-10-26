import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../features/livestocks/data/tables/livestock_table.dart';
import '../../features/farms/data/tables/farm-table.dart';
import '../../features/species/data/tables/specie_table.dart';
import '../../features/livestock_types/data/tables/livestock_type_table.dart';
import '../../features/breeds/data/tables/breed_table.dart';
import '../../features/livestock_obtained_methods/data/tables/livestock_obtained_method_table.dart';

part 'livestock_management_dao.g.dart';

/// Combined DAO for all livestock-related operations
/// This groups related DAOs together for better organization
@DriftAccessor(tables: [
  Livestocks, 
  Farms, 
  Species, 
  LivestockTypes, 
  Breeds, 
  LivestockObtainedMethods
])
class LivestockManagementDao extends DatabaseAccessor<AppDatabase> with _$LivestockManagementDaoMixin {
  LivestockManagementDao(AppDatabase db) : super(db);

  // ==================== LIVESTOCK OPERATIONS ====================
  
  /// Get all livestock with their complete information
  Future<List<LivestockWithDetails>> getAllLivestockWithDetails() async {
    final livestock = await select(livestocks).get();
    final List<LivestockWithDetails> livestockWithDetails = [];

    for (final l in livestock) {
      final farm = await (select(farms)..where((f) => f.uuid.equals(l.farmUuid))).getSingleOrNull();
      final specie = await (select(species)..where((s) => s.id.equals(l.speciesId))).getSingleOrNull();
      final livestockType = await (select(livestockTypes)..where((lt) => lt.id.equals(l.livestockTypeId))).getSingleOrNull();
      final breed = await (select(breeds)..where((b) => b.id.equals(l.breedId))).getSingleOrNull();
      final obtainedMethod = await (select(livestockObtainedMethods)..where((lom) => lom.id.equals(l.livestockObtainedMethodId))).getSingleOrNull();

      livestockWithDetails.add(LivestockWithDetails(
        livestock: l,
        farm: farm,
        specie: specie,
        livestockType: livestockType,
        breed: breed,
        obtainedMethod: obtainedMethod,
      ));
    }

    return livestockWithDetails;
  }

  /// Get livestock by farm UUID with all related data
  Future<List<LivestockWithDetails>> getLivestockByFarmWithDetails(String farmUuid) async {
    final livestock = await (select(livestocks)..where((l) => l.farmUuid.equals(farmUuid))).get();
    final List<LivestockWithDetails> livestockWithDetails = [];

    for (final l in livestock) {
      final farm = await (select(farms)..where((f) => f.uuid.equals(l.farmUuid))).getSingleOrNull();
      final specie = await (select(species)..where((s) => s.id.equals(l.speciesId))).getSingleOrNull();
      final livestockType = await (select(livestockTypes)..where((lt) => lt.id.equals(l.livestockTypeId))).getSingleOrNull();
      final breed = await (select(breeds)..where((b) => b.id.equals(l.breedId))).getSingleOrNull();
      final obtainedMethod = await (select(livestockObtainedMethods)..where((lom) => lom.id.equals(l.livestockObtainedMethodId))).getSingleOrNull();

      livestockWithDetails.add(LivestockWithDetails(
        livestock: l,
        farm: farm,
        specie: specie,
        livestockType: livestockType,
        breed: breed,
        obtainedMethod: obtainedMethod,
      ));
    }

    return livestockWithDetails;
  }

  // ==================== BREED OPERATIONS ====================
  
  /// Get breeds by livestock type with type information
  Future<List<BreedWithType>> getBreedsByTypeWithDetails(int livestockTypeId) async {
    final breedList = await (select(breeds)..where((b) => b.livestockTypeId.equals(livestockTypeId))).get();
    final List<BreedWithType> breedsWithType = [];

    for (final breed in breedList) {
      final livestockType = await (select(livestockTypes)..where((lt) => lt.id.equals(breed.livestockTypeId))).getSingleOrNull();
      breedsWithType.add(BreedWithType(
        breed: breed,
        livestockType: livestockType,
      ));
    }

    return breedsWithType;
  }

  // ==================== SEARCH OPERATIONS ====================
  
  /// Search livestock by multiple criteria
  Future<List<LivestockWithDetails>> searchLivestock({
    String? name,
    String? farmUuid,
    int? specieId,
    int? livestockTypeId,
    int? breedId,
  }) async {
    var query = select(livestocks);
    
    if (name != null) {
      query = query..where((l) => l.name.like('%$name%'));
    }
    if (farmUuid != null) {
      query = query..where((l) => l.farmUuid.equals(farmUuid));
    }
    if (specieId != null) {
      query = query..where((l) => l.speciesId.equals(specieId));
    }
    if (livestockTypeId != null) {
      query = query..where((l) => l.livestockTypeId.equals(livestockTypeId));
    }
    if (breedId != null) {
      query = query..where((l) => l.breedId.equals(breedId));
    }

    final livestock = await query.get();
    final List<LivestockWithDetails> livestockWithDetails = [];

    for (final l in livestock) {
      final farm = await (select(farms)..where((f) => f.uuid.equals(l.farmUuid))).getSingleOrNull();
      final specie = await (select(species)..where((s) => s.id.equals(l.speciesId))).getSingleOrNull();
      final livestockType = await (select(livestockTypes)..where((lt) => lt.id.equals(l.livestockTypeId))).getSingleOrNull();
      final breed = await (select(breeds)..where((b) => b.id.equals(l.breedId))).getSingleOrNull();
      final obtainedMethod = await (select(livestockObtainedMethods)..where((lom) => lom.id.equals(l.livestockObtainedMethodId))).getSingleOrNull();

      livestockWithDetails.add(LivestockWithDetails(
        livestock: l,
        farm: farm,
        specie: specie,
        livestockType: livestockType,
        breed: breed,
        obtainedMethod: obtainedMethod,
      ));
    }

    return livestockWithDetails;
  }
}

/// Data class representing livestock with all related information
class LivestockWithDetails {
  final Livestock livestock;
  final Farm? farm;
  final Specie? specie;
  final LivestockType? livestockType;
  final Breed? breed;
  final LivestockObtainedMethod? obtainedMethod;

  const LivestockWithDetails({
    required this.livestock,
    this.farm,
    this.specie,
    this.livestockType,
    this.breed,
    this.obtainedMethod,
  });

  @override
  String toString() {
    return 'LivestockWithDetails(livestock: ${livestock.name}, farm: ${farm?.name}, specie: ${specie?.name})';
  }
}

/// Data class representing breed with livestock type information
class BreedWithType {
  final Breed breed;
  final LivestockType? livestockType;

  const BreedWithType({
    required this.breed,
    this.livestockType,
  });

  @override
  String toString() {
    return 'BreedWithType(breed: ${breed.name}, type: ${livestockType?.name})';
  }
}
