import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

/// Camera Permission Alert Component
/// 
/// A specialized alert dialog for camera permission requests.
/// Designed specifically for camera permission flows to avoid affecting
/// other screens that use the general AlertDialogs component.
/// 
/// Features:
/// - Similar theme and UI layout to AlertDialogs for consistency
/// - Returns boolean value (true for allow, false for cancel)
/// - Properly handles dialog dismissal and permission flow
class CameraPermissionAlert {
  // Private constructor to prevent instantiation
  CameraPermissionAlert._();

  /// Show camera permission rationale dialog
  /// 
  /// [context] - BuildContext
  /// [title] - Dialog title (localized)
  /// [message] - Dialog message (localized)
  /// [allowText] - Text for the allow button (localized)
  /// [notNowText] - Text for the cancel button (localized)
  /// 
  /// Returns `true` if user clicked allow, `false` if cancelled, `null` if dismissed
  static Future<bool?> showRationaleDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String allowText,
    required String notNowText,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _CameraPermissionDialog(
        title: title,
        message: message,
        allowText: allowText,
        cancelText: notNowText,
      ),
    );
  }

  /// Show camera permission settings dialog
  /// 
  /// [context] - BuildContext
  /// [title] - Dialog title (localized)
  /// [message] - Dialog message (localized)
  /// [goToSettingsText] - Text for the go to settings button (localized)
  /// [notNowText] - Text for the cancel button (localized)
  /// 
  /// Returns `true` if user clicked go to settings, `false` if cancelled, `null` if dismissed
  static Future<bool?> showSettingsDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String goToSettingsText,
    required String notNowText,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _CameraPermissionDialog(
        title: title,
        message: message,
        allowText: goToSettingsText,
        cancelText: notNowText,
      ),
    );
  }
}

// ============================================================================
// Camera Permission Dialog Widget
// ============================================================================

class _CameraPermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String allowText;
  final String cancelText;

  const _CameraPermissionDialog({
    required this.title,
    required this.message,
    required this.allowText,
    required this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.brightness == Brightness.dark 
          ? theme.scaffoldBackgroundColor 
          : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Camera icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 40,
                color: Constants.primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: Constants.largeTextSize,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: Constants.textSize,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        fontSize: Constants.textSize,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Allow button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      allowText,
                      style: TextStyle(
                        fontSize: Constants.textSize,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


