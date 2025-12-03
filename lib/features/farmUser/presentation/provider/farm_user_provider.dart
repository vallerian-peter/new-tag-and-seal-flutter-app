import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/domain/models/farm_user_model.dart';
import 'package:new_tag_and_seal_flutter_app/features/farmUser/domain/repo/farm_user_repo.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

class FarmUserProvider extends ChangeNotifier {
  FarmUserProvider({required FarmUserRepositoryInterface repository})
      : _repository = repository;

  final FarmUserRepositoryInterface _repository;

  bool _isLoading = false;
  String? _error;
  List<FarmUserModel> _users = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FarmUserModel> get users => _users;

  Future<void> loadFarmUsers({String? farmUuid}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _repository.getFarmUsers(farmUuid: farmUuid);
      log(
        '👥 Loaded ${items.length} farm users from local DB'
        '${farmUuid != null ? ' for farm $farmUuid' : ''}',
      );
      _users = items;
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      log('❌ Failed to load farm users: $e', stackTrace: stackTrace);
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<FarmUserModel> addFarmUser(FarmUserModel model) async {
    try {
      final created = await _repository.createFarmUser(model);
      _users = [..._users, created];
      notifyListeners();
      return created;
    } catch (e, stackTrace) {
      log('❌ Failed to create farm user locally: $e', stackTrace: stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<FarmUserModel> updateFarmUser(FarmUserModel model) async {
    try {
      final updated = await _repository.updateFarmUser(model);
      _users = _users
          .map((item) => item.uuid == updated.uuid ? updated : item)
          .toList();
      notifyListeners();
      return updated;
    } catch (e, stackTrace) {
      log('❌ Failed to update farm user locally: $e', stackTrace: stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<FarmUserModel?> addFarmUserWithDialog(
    BuildContext context,
    FarmUserModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final created = await addFarmUser(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.farmUserSavedSuccessfully,
          buttonText: l10n.ok,
        );
      }

      return created;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.farmUserSaveFailed,
          buttonText: l10n.ok,
        );
      }
      return null;
    }
  }

  Future<FarmUserModel?> updateFarmUserWithDialog(
    BuildContext context,
    FarmUserModel model,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    AlertDialogs.showLoading(
      context: context,
      title: l10n.save,
      message: '',
      isDismissible: false,
    );

    try {
      final updated = await updateFarmUser(model);
      _error = null;

      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.farmUserUpdatedSuccessfully,
          buttonText: l10n.ok,
        );
      }

      return updated;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        Navigator.of(context).pop();
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.farmUserSaveFailed,
          buttonText: l10n.ok,
        );
      }
      return null;
    }
  }

  Future<bool> markFarmUserAsDeleted(String uuid) async {
    try {
      final success = await _repository.markFarmUserAsDeleted(uuid);
      if (success) {
        // Remove from local list
        _users = _users.where((user) => user.uuid != uuid).toList();
        notifyListeners();
      }
      return success;
    } catch (e, stackTrace) {
      log('❌ Failed to mark farm user as deleted: $e', stackTrace: stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> markFarmUserAsDeletedWithDialog(
    BuildContext context,
    String uuid,
  ) async {
    // Check if context is still mounted before proceeding
    if (!context.mounted) {
      log('⚠️ Context not mounted, skipping delete dialog');
      return false;
    }

    final l10n = AppLocalizations.of(context)!;

    // Show loading dialog
    AlertDialogs.showLoading(
      context: context,
      title: l10n.delete,
      message: '',
      isDismissible: false,
    );

    try {
      final success = await markFarmUserAsDeleted(uuid);
      _error = null;

      // Check context again after async operation
      if (!context.mounted) {
        log('⚠️ Context not mounted after delete operation');
        // Try to dismiss loading dialog if still open
        try {
          Navigator.of(context).pop();
        } catch (_) {
          // Ignore if already dismissed
        }
        return success;
      }

      // Dismiss loading dialog
      Navigator.of(context).pop();

      // Show success/error dialog
      if (success) {
        await AlertDialogs.showSuccess(
          context: context,
          title: l10n.success,
          message: l10n.deletedSuccessfully,
          buttonText: l10n.ok,
        );
      } else {
        await AlertDialogs.showError(
          context: context,
          title: l10n.error,
          message: l10n.failedToDelete,
          buttonText: l10n.ok,
        );
      }

      return success;
    } catch (e, stackTrace) {
      log('❌ Error deleting farm user: $e', stackTrace: stackTrace);
      _error = e.toString();
      
      // Check context before showing error
      if (!context.mounted) {
        log('⚠️ Context not mounted, cannot show error dialog');
        return false;
      }

      // Dismiss loading dialog if still open
      try {
        Navigator.of(context).pop();
      } catch (_) {
        // Ignore if already dismissed or context invalid
        log('⚠️ Could not dismiss loading dialog');
      }

      // Show error dialog
      await AlertDialogs.showError(
        context: context,
        title: l10n.error,
        message: l10n.failedToDelete,
        buttonText: l10n.ok,
      );
      return false;
    }
  }
}


