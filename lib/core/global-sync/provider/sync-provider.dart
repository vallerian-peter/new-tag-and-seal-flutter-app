import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/sync.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/core/check-network/network_check.dart';
import 'dart:developer';

class SyncProvider extends ChangeNotifier {
  final AppDatabase _database;
  bool _isSyncing = false;
  String _syncStatus = '';
  int _syncProgress = 0;
  int _totalSteps = 4;

  SyncProvider({required AppDatabase database}) : _database = database;

  // Getters
  bool get isSyncing => _isSyncing;
  String get syncStatus => _syncStatus;
  int get syncProgress => _syncProgress;
  int get totalSteps => _totalSteps;
  double get syncProgressPercentage => _totalSteps > 0 ? _syncProgress / _totalSteps : 0.0;

  /// Show splash sync with loading dialog
  Future<void> splashSyncWithDialog(BuildContext context) async {
    if (_isSyncing) return; // Prevent multiple syncs

    final l10n = AppLocalizations.of(context)!;
    
    // Check network connectivity first
    _updateProgress(l10n.checkingNetworkConnection, 1);
    
    final networkCheck = NetworkCheck.instance;
    final isConnected = await networkCheck.isConnected;
    
    if (!isConnected) {
      // Show network error dialog
      await _showNetworkErrorDialog(context);
      return;
    }
    
    _isSyncing = true;
    _syncProgress = 0;
    _syncStatus = l10n.syncStarting;
    notifyListeners();

    // Show loading dialog using existing AlertDialogs component
    AlertDialogs.showLoading(
      context: context,
      title: l10n.syncTitle,
      message: _syncStatus,
      isDismissible: false,
    );

    try {
      await _performSync(context);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success dialog
      if (context.mounted) {
        await _showSuccessDialog(context);
      }

    } catch (e) {
      log('❌ Sync error: $e');
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      if (context.mounted) {
        await _showErrorDialog(context, e.toString());
      }
    } finally {
      _isSyncing = false;
      _syncProgress = 0;
      _syncStatus = '';
      notifyListeners();
    }
  }

  /// Perform the actual sync operation
  Future<void> _performSync(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      // Step 1: Starting sync
      _updateProgress(l10n.syncStarting, 2);
      
      // Step 2: Call the existing Sync.splashSync method
      _updateProgress('Syncing data...', 3);
      await Sync.splashSync(_database);
      
      // Step 3: Sync completed
      _updateProgress(l10n.syncCompleted, 4);
      
    } catch (e) {
      log('❌ Sync failed: $e');
      rethrow;
    }
  }


  /// Update sync progress
  void _updateProgress(String status, int progress) {
    _syncStatus = status;
    _syncProgress = progress;
    notifyListeners();
    log('🔄 Sync Progress: $status ($progress/$totalSteps)');
  }


  /// Show success dialog
  Future<void> _showSuccessDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialogs.showSuccess(
      context: context,
      title: l10n.syncSuccessful,
      message: l10n.syncSuccessfulMessage,
      buttonText: l10n.ok,
      onPressed: () {
        Navigator.of(context).pop();
        // Trigger refresh/rebuild of the app
        _triggerRefresh();
      },
    );
  }

  /// Show network error dialog
  Future<void> _showNetworkErrorDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialogs.showError(
      context: context,
      title: l10n.noInternetConnection,
      message: l10n.checkInternetConnection,
      buttonText: l10n.ok,
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  /// Show error dialog
  Future<void> _showErrorDialog(BuildContext context, String error) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Parse and format error message for better user experience
    String userFriendlyMessage = _formatErrorMessage(error, l10n);
    
    return AlertDialogs.showError(
      context: context,
      title: l10n.syncFailed,
      message: '${l10n.syncFailedMessage}\n\n$userFriendlyMessage',
      buttonText: l10n.ok,
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  /// Format error message to be user-friendly
  /// Handles socket errors, network errors, and other common exceptions
  String _formatErrorMessage(String error, AppLocalizations l10n) {
    final lowerError = error.toLowerCase();
    
    // Handle socket exceptions
    if (lowerError.contains('socket') || lowerError.contains('failed host lookup')) {
      return l10n.connectionErrorMessage;
    }
    
    // Handle timeout errors
    if (lowerError.contains('timeout') || lowerError.contains('timed out')) {
      return l10n.connectionTimeoutMessage;
    }
    
    // Handle network errors
    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return l10n.networkErrorMessage;
    }
    
    // Handle unauthorized errors
    if (lowerError.contains('unauthorized') || lowerError.contains('401')) {
      return l10n.authenticationFailedMessage;
    }
    
    // Handle server errors
    if (lowerError.contains('500') || lowerError.contains('internal server error')) {
      return l10n.serverErrorMessage;
    }
    
    // Handle service unavailable
    if (lowerError.contains('503') || lowerError.contains('service unavailable')) {
      return l10n.serviceUnavailableMessage;
    }
    
    // Handle invalid response
    if (lowerError.contains('invalid response') || lowerError.contains('format exception')) {
      return l10n.invalidServerResponseMessage;
    }
    
    // Handle generic errors - show only first 100 characters to avoid huge messages
    if (error.length > 100) {
      return '${l10n.error}: ${error.substring(0, 100)}...';
    }
    
    return '${l10n.error}: $error';
  }

  /// Trigger app refresh after successful sync
  void _triggerRefresh() {
    // Notify listeners to refresh the app
    notifyListeners();
    log('🔄 App refreshed after successful sync');
  }

  /// Simple sync without UI (for background operations)
  Future<void> splashSync() async {
    if (_isSyncing) return;
    
    // Check network connectivity first
    final networkCheck = NetworkCheck.instance;
    final isConnected = await networkCheck.isConnected;
    
    if (!isConnected) {
      log('❌ No internet connection - skipping background sync');
      return;
    }
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      await Sync.splashSync(_database);
      log('✅ Background sync completed');
    } catch (e) {
      log('❌ Background sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

}