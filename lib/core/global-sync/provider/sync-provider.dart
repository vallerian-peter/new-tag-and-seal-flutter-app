import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/global-sync/sync.dart';
import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:new_tag_and_seal_flutter_app/core/check-network/network_check.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/features/notifications/presentation/provider/notification_provider.dart';
import 'package:new_tag_and_seal_flutter_app/features/all.logs.additional.data/provider/log_additional_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:developer';

class SyncProvider extends ChangeNotifier {
  final AppDatabase _database;
  bool _isSyncing = false;
  String _syncStatus = '';
  int _syncProgress = 0;
  int _totalSteps = 4;

  // Scheduler properties
  Timer? _syncSchedulerTimer;
  BuildContext? _currentContext;
  static const String _lastSyncTimestampKey = 'last_automatic_sync_timestamp';
  static const String _lastUnsyncedCheckKey = 'last_unsynced_check_timestamp';
  static const int _syncIntervalHours = 24;
  static const int _forcedSyncThreshold = 15;
  bool _isChecking = false;

  SyncProvider({required AppDatabase database}) : _database = database;

  // Getters
  bool get isSyncing => _isSyncing;
  String get syncStatus => _syncStatus;
  int get syncProgress => _syncProgress;
  int get totalSteps => _totalSteps;
  double get syncProgressPercentage =>
      _totalSteps > 0 ? _syncProgress / _totalSteps : 0.0;

  /// Initialize sync scheduler with context
  /// Call this from dashboard screen initState
  void initializeScheduler(BuildContext context) {
    _currentContext = context;

    // Start periodic check (every hour to check if 24 hours have passed)
    _syncSchedulerTimer?.cancel();
    _syncSchedulerTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _checkAndSyncIfNeeded(),
    );

    // Also check immediately on initialization
    _checkAndSyncIfNeeded();
  }

  /// Check if 24 hours have passed and sync if needed
  Future<void> _checkAndSyncIfNeeded() async {
    if (_isChecking || _database == null) return;

    _isChecking = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTimestamp = prefs.getInt(_lastSyncTimestampKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceLastSync = (now - lastSyncTimestamp) / (1000 * 60 * 60);

      log('🕐 Last sync: ${hoursSinceLastSync.toStringAsFixed(1)} hours ago');

      // Check if 24 hours have passed
      if (hoursSinceLastSync >= _syncIntervalHours) {
        log('⏰ 24 hours passed - checking for unsynced data...');

        // Get unsynced data summary
        final summary = await Sync.getUnsyncedSummary(_database);
        final unsyncedCount = summary.totalPending;

        log('📊 Found $unsyncedCount unsynced items');

        if (unsyncedCount > 0) {
          // Check if we need to show forced sync dialog
          if (unsyncedCount >= _forcedSyncThreshold &&
              _currentContext != null &&
              _currentContext!.mounted) {
            log(
              '⚠️ Unsynced count ($unsyncedCount) >= threshold ($_forcedSyncThreshold) - showing forced sync dialog',
            );
            await _showForcedSyncDialog();
          } else {
            // Trigger automatic sync in background
            log('🔄 Triggering automatic background sync...');
            await splashSync();

            // Update last sync timestamp
            await prefs.setInt(_lastSyncTimestampKey, now);
            log('✅ Automatic sync completed');
          }
        } else {
          // No unsynced data, just update timestamp
          await prefs.setInt(_lastSyncTimestampKey, now);
          log('✅ No unsynced data - timestamp updated');
        }
      } else {
        // Check unsynced count for forced sync dialog (even if not 24 hours yet)
        await _checkForcedSync();
      }
    } catch (e) {
      log('❌ Error in sync scheduler: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Check if unsynced count requires forced sync dialog
  Future<void> _checkForcedSync() async {
    if (_database == null || _currentContext == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckTimestamp = prefs.getInt(_lastUnsyncedCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check every 6 hours to avoid too frequent checks
      if (now - lastCheckTimestamp < 6 * 60 * 60 * 1000) {
        return;
      }

      final summary = await Sync.getUnsyncedSummary(_database);
      final unsyncedCount = summary.totalPending;

      if (unsyncedCount >= _forcedSyncThreshold && _currentContext!.mounted) {
        log(
          '⚠️ Unsynced count ($unsyncedCount) >= threshold - showing forced sync dialog',
        );
        await _showForcedSyncDialog();
      }

      // Update last check timestamp
      await prefs.setInt(_lastUnsyncedCheckKey, now);
    } catch (e) {
      log('❌ Error checking forced sync: $e');
    }
  }

  /// Show forced sync dialog (no cancel option)
  Future<void> _showForcedSyncDialog() async {
    if (_currentContext == null || !_currentContext!.mounted) return;

    final context = _currentContext!;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    try {
      final summary = await Sync.getUnsyncedSummary(_database);
      final unsyncedCount = summary.totalPending;

      await showDialog(
        context: context,
        barrierDismissible: false, // Cannot dismiss by tapping outside
        builder: (context) => _ForcedSyncDialog(
          unsyncedCount: unsyncedCount,
          onSync: () async {
            Navigator.of(context).pop();
            await splashSyncWithDialog(context);

            // Update last sync timestamp after successful sync
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt(
              _lastSyncTimestampKey,
              DateTime.now().millisecondsSinceEpoch,
            );
          },
        ),
      );
    } catch (e) {
      log('❌ Error showing forced sync dialog: $e');
    }
  }

  /// Manually trigger sync check (for testing or manual triggers)
  Future<void> checkSyncNow() async {
    await _checkAndSyncIfNeeded();
  }

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

      // Update last sync timestamp after successful sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastSyncTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
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
  ///
  /// This sync includes:
  /// - Farms, livestock, events, vaccines, and farm users
  /// - Farm users: When synced, invitation emails are automatically sent by the backend
  Future<void> _performSync(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Step 1: Starting sync
      _updateProgress(l10n.syncStarting, 2);

      // Step 2: Get NotificationProvider from context if available
      NotificationProvider? notificationProvider;
      try {
        notificationProvider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );
      } catch (_) {
        // NotificationProvider not available in context, continue without it
        log(
          '⚠️ NotificationProvider not available in context - notifications will not be created during sync',
        );
      }

      // Step 3: Call the existing Sync.splashSync method
      // Note: This sync will send unsynced farm users to backend, which triggers email sending
      // Also creates notifications for logs with nextDates if NotificationProvider is available
      _updateProgress('Syncing data...', 3);
      await Sync.splashSync(
        _database,
        notificationProvider: notificationProvider,
      );
      await _refreshReferenceDataIfAvailable(context);

      // Step 4: Sync completed
      _updateProgress(l10n.syncCompleted, 4);

      log(
        '✅ Sync completed - farm user invitation emails have been sent if any were synced',
      );
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
        // Dialog already pops itself, just trigger refresh
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
      // Dialog already pops itself, no need for onPressed
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
      // Dialog already pops itself, no need for onPressed
    );
  }

  /// Format error message to be user-friendly
  /// Handles socket errors, network errors, and other common exceptions
  String _formatErrorMessage(String error, AppLocalizations l10n) {
    final lowerError = error.toLowerCase();

    // Handle socket exceptions
    if (lowerError.contains('socket') ||
        lowerError.contains('failed host lookup')) {
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
    if (lowerError.contains('500') ||
        lowerError.contains('internal server error')) {
      return l10n.serverErrorMessage;
    }

    // Handle service unavailable
    if (lowerError.contains('503') ||
        lowerError.contains('service unavailable')) {
      return l10n.serviceUnavailableMessage;
    }

    // Handle invalid response
    if (lowerError.contains('invalid response') ||
        lowerError.contains('format exception')) {
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

    // Try to get NotificationProvider from context if available
    NotificationProvider? notificationProvider;
    if (_currentContext != null && _currentContext!.mounted) {
      try {
        notificationProvider = Provider.of<NotificationProvider>(
          _currentContext!,
          listen: false,
        );
      } catch (_) {
        // NotificationProvider not available, continue without it
      }
    }

    _isSyncing = true;
    notifyListeners();

    try {
      await Sync.splashSync(
        _database,
        notificationProvider: notificationProvider,
      );
      await _refreshReferenceDataIfAvailable(_currentContext);
      log('✅ Background sync completed');
    } catch (e) {
      log('❌ Background sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _syncSchedulerTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshReferenceDataIfAvailable(BuildContext? context) async {
    if (context == null || !context.mounted) return;

    try {
      final referenceProvider = Provider.of<LogAdditionalDataProvider>(
        context,
        listen: false,
      );
      await referenceProvider.loadFromLocal();
    } catch (e) {
      log('⚠️ Failed to refresh reference data after sync: $e');
    }
  }
}

/// Forced Sync Dialog Widget
///
/// Shows a dialog that requires user to sync when unsynced count >= 15
/// No cancel option - user must sync to proceed
class _ForcedSyncDialog extends StatelessWidget {
  final int unsyncedCount;
  final VoidCallback onSync;

  const _ForcedSyncDialog({required this.unsyncedCount, required this.onSync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.scaffoldBackgroundColor
          : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? theme.scaffoldBackgroundColor
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sync_problem,
                size: 40,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              l10n.syncRequired,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              l10n.syncRequiredMessage(unsyncedCount),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Sync button (only option - no cancel)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSync,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.syncNow,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
