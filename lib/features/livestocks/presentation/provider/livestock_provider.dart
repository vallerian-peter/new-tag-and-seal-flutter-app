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
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Livestock> get allLivestock => _allLivestock;
  List<Livestock> get filteredLivestock => _filteredLivestock;
  Map<String, String> get farmNames => _farmNames;
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

  /// Filter livestock by search query
  void filterLivestock(String query, String genderFilter) {
    List<Livestock> baseList = _allLivestock;

    // Apply gender filter
    if (genderFilter != 'All') {
      baseList = _allLivestock
          .where((livestock) =>
              livestock.gender.toLowerCase() == genderFilter.toLowerCase())
          .toList();
    }

    // Apply search query
    if (query.isEmpty) {
      _filteredLivestock = baseList;
    } else {
      _filteredLivestock = baseList
          .where((livestock) =>
              livestock.name.toLowerCase().contains(query.toLowerCase()) ||
              livestock.identificationNumber
                  .toLowerCase()
                  .contains(query.toLowerCase()))
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
      log('🗑️ LivestockProvider: Marking livestock by farm UUID as deleted...');
      final count =
          await _livestockRepo.markLivestockByFarmUuidAsDeleted(farmUuid);
      
      if (count > 0) {
        // Refresh the list
        await fetchAllLivestock();
        log('✅ LivestockProvider: $count livestock marked as deleted');
      }
      
      return count;
    } catch (e) {
      log('❌ LivestockProvider: Error marking livestock by farm UUID as deleted: $e');
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
}
