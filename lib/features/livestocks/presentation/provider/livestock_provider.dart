import 'package:flutter/foundation.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/livestocks/domain/repo/livestock_repo.dart';
import 'dart:developer';

/// Provider for livestock state management
/// Follows the architecture: Screen → Provider → Domain Repo → Data Repository → DAO
class LivestockProvider extends ChangeNotifier {
  final LivestockRepo _livestockRepo;

  LivestockProvider({required LivestockRepo livestockRepo})
    : _livestockRepo = livestockRepo;

  // State
  List<Livestock> _allLivestock = [];
  List<Livestock> _filteredLivestock = [];
  Map<String, String> _farmNames = {};
  Map<int, String> _livestockTypeNames = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Livestock> get allLivestock => _allLivestock;
  List<Livestock> get filteredLivestock => _filteredLivestock;
  Map<String, String> get farmNames => _farmNames;
  Map<int, String> get livestockTypeNames => _livestockTypeNames;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalCount => _allLivestock.length;
  int get maleCount =>
      _allLivestock.where((l) => l.gender.toLowerCase() == 'male').length;
  int get femaleCount =>
      _allLivestock.where((l) => l.gender.toLowerCase() == 'female').length;

  /// Fetch all active livestock
  Future<void> fetchAllLivestock() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('📦 LivestockProvider: Fetching all active livestock...');
      final livestock = await _livestockRepo.getAllActiveLivestock();

      _allLivestock = livestock;
      _filteredLivestock = livestock;

      log('✅ LivestockProvider: Loaded ${livestock.length} livestock');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('❌ LivestockProvider: Error fetching livestock: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set farm names map
  void setFarmNames(Map<String, String> farmNames) {
    _farmNames = farmNames;
    notifyListeners();
  }

  /// Set livestock type names map
  void setLivestockTypeNames(Map<int, String> livestockTypeNames) {
    _livestockTypeNames = livestockTypeNames;
    notifyListeners();
  }

  /// Filter livestock by search query and multiple filters
  void filterLivestock(
    String query, {
    String genderFilter = 'All',
    String statusFilter = 'All',
    int? livestockTypeId,
  }) {
    // Start with all livestock
    List<Livestock> baseList = List<Livestock>.from(_allLivestock);

    // Apply gender filter
    if (genderFilter != 'All') {
      baseList = baseList
          .where(
            (livestock) =>
                livestock.gender.toLowerCase() == genderFilter.toLowerCase(),
          )
          .toList();
    }

    // Apply status filter
    if (statusFilter != 'All') {
      baseList = baseList
          .where(
            (livestock) =>
                livestock.status.toLowerCase() == statusFilter.toLowerCase(),
          )
          .toList();
    }

    // Apply livestock type filter - only if livestockTypeId is NOT null
    if (livestockTypeId != null) {
      baseList = baseList
          .where((livestock) => livestock.livestockTypeId == livestockTypeId)
          .toList();
    }

    // Apply search query
    if (query.isEmpty) {
      _filteredLivestock = baseList;
    } else {
      _filteredLivestock = baseList
          .where(
            (livestock) =>
                livestock.name.toLowerCase().contains(query.toLowerCase()) ||
                livestock.identificationNumber.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    }

    notifyListeners();
  }

  /// Sort livestock
  void sortLivestock(String sortOption) {
    if (sortOption == 'A to Z') {
      _filteredLivestock.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortOption == 'Z to A') {
      _filteredLivestock.sort((a, b) => b.name.compareTo(a.name));
    } else if (sortOption == 'Newest First') {
      _filteredLivestock.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortOption == 'Oldest First') {
      _filteredLivestock.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    notifyListeners();
  }

  /// Get livestock by ID
  Future<Livestock?> getLivestockById(int id) async {
    try {
      return await _livestockRepo.getLivestockById(id);
    } catch (e) {
      log('❌ LivestockProvider: Error getting livestock by ID: $e');
      return null;
    }
  }

  /// Get livestock by UUID
  Future<Livestock?> getLivestockByUuid(String uuid) async {
    try {
      return await _livestockRepo.getLivestockByUuid(uuid);
    } catch (e) {
      log('❌ LivestockProvider: Error getting livestock by UUID: $e');
      return null;
    }
  }

  /// Get active livestock by farm UUID
  Future<List<Livestock>> getActiveLivestockByFarmUuid(String farmUuid) async {
    try {
      return await _livestockRepo.getActiveLivestockByFarmUuid(farmUuid);
    } catch (e) {
      log('❌ LivestockProvider: Error getting livestock by farm UUID: $e');
      return [];
    }
  }

  /// Mark livestock as deleted
  Future<bool> markLivestockAsDeleted(int livestockId) async {
    try {
      log('🗑️ LivestockProvider: Marking livestock as deleted...');
      final success = await _livestockRepo.markLivestockAsDeleted(livestockId);

      if (success) {
        // Refresh the list
        await fetchAllLivestock();
        log('✅ LivestockProvider: Livestock marked as deleted');
      }

      return success;
    } catch (e) {
      log('❌ LivestockProvider: Error marking livestock as deleted: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Mark livestock by farm UUID as deleted
  Future<int> markLivestockByFarmUuidAsDeleted(String farmUuid) async {
    try {
      log(
        '🗑️ LivestockProvider: Marking livestock by farm UUID as deleted...',
      );
      final count = await _livestockRepo.markLivestockByFarmUuidAsDeleted(
        farmUuid,
      );

      if (count > 0) {
        // Refresh the list
        await fetchAllLivestock();
        log('✅ LivestockProvider: $count livestock marked as deleted');
      }

      return count;
    } catch (e) {
      log(
        '❌ LivestockProvider: Error marking livestock by farm UUID as deleted: $e',
      );
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset filters
  void resetFilters() {
    _filteredLivestock = _allLivestock;
    notifyListeners();
  }

  /// Check if identification number is unique (optionally excluding a livestock by UUID)
  /// Checks uniqueness globally across all farms.
  Future<bool> isIdentificationNumberUnique(
    String identificationNumber, {
    String? excludeUuid,
  }) async {
    final normalized = identificationNumber.trim();
    if (normalized.isEmpty) return true;

    // Global check
    final existing = await _livestockRepo.getLivestockByIdentificationNumber(
      normalized,
    );
    if (existing == null) return true;
    if (excludeUuid != null && existing.uuid == excludeUuid) return true;
    return false;
  }

  /// Check if RFID tag ID is unique globally
  Future<bool> isRfidTagIdUnique(
    String rfidTagId, {
    String? excludeUuid,
  }) async {
    final normalized = rfidTagId.trim();
    if (normalized.isEmpty) return true;
    return await _livestockRepo.isRfidTagIdUnique(
      normalized,
      excludeUuid: excludeUuid,
    );
  }

  /// Check if Barcode tag ID is unique globally
  Future<bool> isBarcodeTagIdUnique(
    String barcodeTagId, {
    String? excludeUuid,
  }) async {
    final normalized = barcodeTagId.trim();
    if (normalized.isEmpty) return true;
    return await _livestockRepo.isBarcodeTagIdUnique(
      normalized,
      excludeUuid: excludeUuid,
    );
  }

  /// Create livestock
  Future<Livestock?> createLivestock(Map<String, dynamic> livestockData) async {
    _isLoading = true;
    notifyListeners();

    try {
      log('📦 LivestockProvider: Creating livestock...');
      final livestock = await _livestockRepo.createLivestock(livestockData);

      // Refresh list
      await fetchAllLivestock();

      _isLoading = false;
      notifyListeners();
      return livestock;
    } catch (e) {
      log('❌ LivestockProvider: Error creating livestock: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update livestock
  Future<bool> updateLivestock(
    int id,
    Map<String, dynamic> livestockData,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      log('📦 LivestockProvider: Updating livestock...');
      final success = await _livestockRepo.updateLivestock(id, livestockData);

      if (success) {
        // Refresh list
        await fetchAllLivestock();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      log('❌ LivestockProvider: Error updating livestock: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
