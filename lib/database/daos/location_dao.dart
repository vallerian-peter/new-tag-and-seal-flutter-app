import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../features/all.additional.data/data/local/tables/country_table.dart';
import '../../features/all.additional.data/data/local/tables/region_table.dart';
import '../../features/all.additional.data/data/local/tables/district_table.dart';
import '../../features/all.additional.data/data/local/tables/division_table.dart';
import '../../features/all.additional.data/data/local/tables/ward_table.dart';
import '../../features/all.additional.data/data/local/tables/village_table.dart';
import '../../features/all.additional.data/data/local/tables/street_table.dart';
part 'location_dao.g.dart';

/// DAO for handling location-related data (Country, Region, District, Division, Ward, Village, Street)
/// This provides simple, easy-to-understand methods for location queries
@DriftAccessor(tables: [Countries, Regions, Districts, Divisions, Wards, Villages, Streets])
class LocationDao extends DatabaseAccessor<AppDatabase> with _$LocationDaoMixin {
  LocationDao(AppDatabase db) : super(db);

  // ==================== COUNTRY METHODS ====================

  /// Get all countries
  Future<List<Country>> getAllCountries() => select(countries).get();

  /// Get a single country by ID
  Future<Country?> getCountryById(int id) =>
      (select(countries)..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Insert a new country
  Future<int> insertCountry(CountriesCompanion entry) => into(countries).insert(entry);

  /// Update a country
  Future<bool> updateCountry(Country entry) => update(countries).replace(entry);

  /// Delete a country
  Future<int> deleteCountry(int id) =>
      (delete(countries)..where((c) => c.id.equals(id))).go();

  // ==================== REGION METHODS ====================

  /// Get all regions
  Future<List<Region>> getAllRegions() => select(regions).get();

  /// Get regions by country ID
  Future<List<Region>> getRegionsByCountry(int countryId) =>
      (select(regions)..where((r) => r.countryId.equals(countryId))).get();

  /// Get a single region by ID
  Future<Region?> getRegionById(int id) =>
      (select(regions)..where((r) => r.id.equals(id))).getSingleOrNull();

  /// Insert a new region
  Future<int> insertRegion(RegionsCompanion entry) => into(regions).insert(entry);

  /// Update a region
  Future<bool> updateRegion(Region entry) => update(regions).replace(entry);

  /// Delete a region
  Future<int> deleteRegion(int id) =>
      (delete(regions)..where((r) => r.id.equals(id))).go();

  // ==================== DISTRICT METHODS ====================

  /// Get all districts
  Future<List<District>> getAllDistricts() => select(districts).get();

  /// Get districts by region ID
  Future<List<District>> getDistrictsByRegion(int regionId) =>
      (select(districts)..where((d) => d.regionId.equals(regionId))).get();

  /// Get a single district by ID
  Future<District?> getDistrictById(int id) =>
      (select(districts)..where((d) => d.id.equals(id))).getSingleOrNull();

  /// Insert a new district
  Future<int> insertDistrict(DistrictsCompanion entry) => into(districts).insert(entry);

  /// Update a district
  Future<bool> updateDistrict(District entry) => update(districts).replace(entry);

  /// Delete a district
  Future<int> deleteDistrict(int id) =>
      (delete(districts)..where((d) => d.id.equals(id))).go();

  // ==================== DIVISION METHODS ====================

  /// Get all divisions
  Future<List<Division>> getAllDivisions() => select(divisions).get();

  /// Get divisions by district ID
  Future<List<Division>> getDivisionsByDistrict(int districtId) =>
      (select(divisions)..where((d) => d.districtId.equals(districtId))).get();

  /// Get a single division by ID
  Future<Division?> getDivisionById(int id) =>
      (select(divisions)..where((d) => d.id.equals(id))).getSingleOrNull();

  /// Insert a new division
  Future<int> insertDivision(DivisionsCompanion entry) => into(divisions).insert(entry);

  /// Update a division
  Future<bool> updateDivision(Division entry) => update(divisions).replace(entry);

  /// Delete a division
  Future<int> deleteDivision(int id) =>
      (delete(divisions)..where((d) => d.id.equals(id))).go();

  // ==================== WARD METHODS ====================

  /// Get all wards
  Future<List<Ward>> getAllWards() => select(wards).get();

  /// Get wards by district ID
  Future<List<Ward>> getWardsByDistrict(int districtId) =>
      (select(wards)..where((w) => w.districtId.equals(districtId))).get();

  /// Get a single ward by ID
  Future<Ward?> getWardById(int id) =>
      (select(wards)..where((w) => w.id.equals(id))).getSingleOrNull();

  /// Insert a new ward
  Future<int> insertWard(WardsCompanion entry) => into(wards).insert(entry);

  /// Update a ward
  Future<bool> updateWard(Ward entry) => update(wards).replace(entry);

  /// Delete a ward
  Future<int> deleteWard(int id) =>
      (delete(wards)..where((w) => w.id.equals(id))).go();

  // ==================== STREET METHODS ====================

  /// Get all villages
  Future<List<Village>> getAllVillages() => select(villages).get();

  /// Get villages by ward ID
  Future<List<Village>> getVillagesByWard(int wardId) =>
      (select(villages)..where((v) => v.wardId.equals(wardId))).get();

  /// Get a single village by ID
  Future<Village?> getVillageById(int id) =>
      (select(villages)..where((v) => v.id.equals(id))).getSingleOrNull();

  /// Insert a new village
  Future<int> insertVillage(VillagesCompanion entry) => into(villages).insert(entry);

  /// Update a village
  Future<bool> updateVillage(Village entry) => update(villages).replace(entry);

  /// Delete a village
  Future<int> deleteVillage(int id) =>
      (delete(villages)..where((v) => v.id.equals(id))).go();

  /// Get all streets
  Future<List<Street>> getAllStreets() => select(streets).get();

  /// Get streets by ward ID
  Future<List<Street>> getStreetsByWard(int wardId) =>
      (select(streets)..where((s) => s.wardId.equals(wardId))).get();

  /// Get a single street by ID
  Future<Street?> getStreetById(int id) =>
      (select(streets)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Insert a new street
  Future<int> insertStreet(StreetsCompanion entry) => into(streets).insert(entry);

  /// Update a street
  Future<bool> updateStreet(Street entry) => update(streets).replace(entry);

  /// Delete a street
  Future<int> deleteStreet(int id) =>
      (delete(streets)..where((s) => s.id.equals(id))).go();

  // ==================== BATCH OPERATIONS ====================

  /// Insert multiple countries at once
  Future<void> insertCountries(List<CountriesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(countries, entries, mode: InsertMode.insertOrReplace);
    });
  }

  /// Insert multiple regions at once
  Future<void> insertRegions(List<RegionsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(regions, entries, mode: InsertMode.insertOrReplace);
    });
  }

  /// Insert multiple districts at once
  Future<void> insertDistricts(List<DistrictsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(districts, entries, mode: InsertMode.insertOrReplace);
    });
  }

  /// Insert multiple divisions at once
  Future<void> insertDivisions(List<DivisionsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(divisions, entries, mode: InsertMode.insertOrReplace);
    });
  }

  /// Insert multiple wards at once
  Future<void> insertWards(List<WardsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(wards, entries, mode: InsertMode.insertOrReplace);
    });
  }

  /// Insert multiple villages at once
  Future<void> insertVillages(List<VillagesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(villages, entries, mode: InsertMode.insertOrReplace);
    });
  }

  /// Insert multiple streets at once
  Future<void> insertStreets(List<StreetsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(streets, entries, mode: InsertMode.insertOrReplace);
    });
  }

  // ==================== DELETE OPERATIONS ====================

  /// Delete all countries (USE WITH CAUTION!)
  Future<int> deleteAllCountries() => delete(countries).go();

  /// Delete all regions (USE WITH CAUTION!)
  Future<int> deleteAllRegions() => delete(regions).go();

  /// Delete all districts (USE WITH CAUTION!)
  Future<int> deleteAllDistricts() => delete(districts).go();

  /// Delete all wards (USE WITH CAUTION!)
  Future<int> deleteAllWards() => delete(wards).go();

  /// Delete all villages (USE WITH CAUTION!)
  Future<int> deleteAllVillages() => delete(villages).go();

  /// Delete all streets (USE WITH CAUTION!)
  Future<int> deleteAllStreets() => delete(streets).go();

  /// Delete all divisions (USE WITH CAUTION!)
  Future<int> deleteAllDivisions() => delete(divisions).go();

  // ==================== UTILITY METHODS ====================

  /// Search locations by name (useful for autocomplete)
  Future<List<Region>> searchRegions(String query) =>
      (select(regions)..where((r) => r.name.like('%$query%'))).get();

  Future<List<District>> searchDistricts(String query) =>
      (select(districts)..where((d) => d.name.like('%$query%'))).get();

  Future<List<Ward>> searchWards(String query) =>
      (select(wards)..where((w) => w.name.like('%$query%'))).get();

  Future<List<Village>> searchVillages(String query) =>
      (select(villages)..where((v) => v.name.like('%$query%'))).get();

  Future<List<Street>> searchStreets(String query) =>
      (select(streets)..where((s) => s.name.like('%$query%'))).get();
}

