import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/features/farms/domain/repo/farm_repo.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// Farm Provider with Dialogs
/// 
/// Provides farm CRUD operations with automatic loading dialogs,
/// success feedback, and error handling.
/// All operations are fully localized.
class FarmProvider extends ChangeNotifier {
  final FarmRepositoryInterface _farmRepository;

  FarmProvider({required FarmRepositoryInterface farmRepository}) : _farmRepository = farmRepository;

  // ============================================================================
  // CRUD Operations with Dialogs
  // ============================================================================

  /// Get all farms with loading dialog and error handling
  Future<List<Farm>?> getFarmsWithDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.loadingFarms,
      message: '',
      isDismissible: false,
    );
    
    try {
      final farms = await _farmRepository.getAllFarms();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show success if not empty
      if (farms.isNotEmpty && context.mounted) {
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.farmsLoadedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      
      return farms;
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error dialog
      if (context.mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.farmsLoadFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      
      return null;
    }
  }

  /// Get farm by ID with loading dialog and error handling
  Future<Farm?> getFarmByIdWithDialog(BuildContext context, int id) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.loading,
      message: '',
      isDismissible: false,
    );
    
    try {
      final farm = await _farmRepository.getFarmById(id);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show success if found
      if (farm != null && context.mounted) {
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.farmLoadedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      
      return farm;
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error dialog
      if (context.mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.farmLoadFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      
      return null;
    }
  }

  /// Get farm with livestock with loading dialog and error handling
  Future<Map<String, dynamic>?> getFarmWithLivestockWithDialog(BuildContext context, int farmId) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.loadingFarmWithLivestock,
      message: '',
      isDismissible: false,
    );
    
    try {
      final farmData = await _farmRepository.getFarmWithLivestock(farmId);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show success if found
      if (farmData != null && context.mounted) {
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.farmWithLivestockLoadedSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      
      return farmData;
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error dialog
      if (context.mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.farmWithLivestockLoadFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      
      return null;
    }
  }

  // ============================================================================
  // CRUD Operations WITHOUT Dialogs (Silent)
  // ============================================================================

  /// Get all farms with livestock WITHOUT dialogs
  /// 
  /// Returns farms data or null if error occurs.
  /// No loading dialogs or error dialogs shown.
  Future<List<Map<String, dynamic>>?> getAllFarmsWithLivestock() async {
    try {
      final farmsWithLivestock = await _farmRepository.getAllFarmsWithLivestock();
      return farmsWithLivestock;
    } catch (e) {
      return null;
    }
  }

  /// Get all farms WITHOUT dialogs
  /// 
  /// Returns farms list or null if error occurs.
  /// No loading dialogs or error dialogs shown.
  Future<List<Farm>?> getAllFarms() async {
    try {
      return await _farmRepository.getAllFarms();
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // CRUD Operations WITH Dialogs
  // ============================================================================

  /// Create farm with loading dialog and error handling
  Future<Farm?> createFarmWithDialog(BuildContext context, Map<String, dynamic> farmData) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );
    
    try {
      final farm = await _farmRepository.createFarmLocally(farmData);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show success dialog
      if (context.mounted) {
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.farmRegisteredSuccessfully,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      
      // Notify listeners
      notifyListeners();
      
      return farm;
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error dialog
      if (context.mounted) {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.farmRegistrationFailed,
          buttonText: l10n.ok,
          onPressed: () => Navigator.of(context).pop(),
        );
      }
      
      return null;
    }
  }

  /// Mark farm as deleted (soft delete) WITHOUT dialogs
  /// 
  /// Updates farm's syncAction to 'deleted' without removing from database.
  /// Returns true on success, false on failure.
  Future<bool> markFarmAsDeleted(int farmId) async {
    try {
      return await _farmRepository.markFarmAsDeleted(farmId);
    } catch (e) {
      return false;
    }
  }

  /// Update farm WITHOUT dialogs
  /// 
  /// Updates an existing farm in the local database.
  /// Returns the updated Farm on success, null on failure.
  Future<Farm?> updateFarmWithoutDialog(int farmId, Map<String, dynamic> farmData, {String? syncAction, bool? synced}) async {
    try {
      return await _farmRepository.updateFarm(farmId, farmData, syncAction: syncAction, synced: synced);
    } catch (e) {
      return null;
    }
  }
}