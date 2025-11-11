import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

/// Modern Alert Dialogs
/// 
/// A comprehensive set of alert dialogs for different states:
/// - Loading (with progress indicator)
/// - Success (with checkmark icon)
/// - Error (with error icon)
/// - Warning (with warning icon)
/// - Network Issues (with network icon)
/// 
/// Features:
/// - Component-based design
/// - Full localization support
/// - Theme management
/// - Consistent styling
/// - Accessibility support
/// - No wait issues (async/await)
class AlertDialogs {
  // Private constructor to prevent instantiation
  AlertDialogs._();

  // ============================================================================
  // Loading Dialog
  // ============================================================================

  /// Show loading dialog
  /// 
  /// [context] - BuildContext
  /// [title] - Dialog title (localized)
  /// [message] - Dialog message (localized)
  /// [isDismissible] - Whether dialog can be dismissed by tapping outside
  /// 
  /// Returns the dialog result
  static Future<T?> showLoading<T>({
    required BuildContext context,
    required String title,
    required String message,
    bool isDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => _LoadingDialog(
        title: title,
        message: message,
      ),
    );
  }

  // ============================================================================
  // Success Dialog
  // ============================================================================

  /// Show success dialog
  /// 
  /// [context] - BuildContext
  /// [title] - Dialog title (localized)
  /// [message] - Dialog message (localized)
  /// [buttonText] - Button text (localized)
  /// [onPressed] - Button callback
  /// [isDismissible] - Whether dialog can be dismissed by tapping outside
  /// 
  /// Returns the dialog result
  static Future<T?> showSuccess<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => _SuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  // ============================================================================
  // Error Dialog
  // ============================================================================

  /// Show error dialog
  /// 
  /// [context] - BuildContext
  /// [title] - Dialog title (localized)
  /// [message] - Dialog message (localized)
  /// [buttonText] - Button text (localized)
  /// [onPressed] - Button callback
  /// [isDismissible] - Whether dialog can be dismissed by tapping outside
  /// 
  /// Returns the dialog result
  static Future<T?> showError<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => _ErrorDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  // ============================================================================
  // Warning Dialog
  // ============================================================================

  /// Show warning dialog
  /// 
  /// [context] - BuildContext
  /// [title] - Dialog title (localized)
  /// [message] - Dialog message (localized)
  /// [buttonText] - Button text (localized)
  /// [onPressed] - Button callback
  /// [isDismissible] - Whether dialog can be dismissed by tapping outside
  /// 
  /// Returns the dialog result
  static Future<T?> showWarning<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => _WarningDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  // ============================================================================
  // Network Issues Dialog
  // ============================================================================

  /// Show network issues dialog
  /// 
  /// [context] - BuildContext
  /// [title] - Dialog title (localized)
  /// [message] - Dialog message (localized)
  /// [retryText] - Retry button text (localized)
  /// [cancelText] - Cancel button text (localized)
  /// [onRetry] - Retry button callback
  /// [onCancel] - Cancel button callback
  /// [isDismissible] - Whether dialog can be dismissed by tapping outside
  /// 
  /// Returns the dialog result
  static Future<T?> showNetworkIssues<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String retryText,
    required String cancelText,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
    bool isDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => _NetworkIssuesDialog(
        title: title,
        message: message,
        retryText: retryText,
        cancelText: cancelText,
        onRetry: onRetry,
        onCancel: onCancel,
      ),
    );
  }

  // ============================================================================
  // Confirmation Dialog
  // ============================================================================

  /// Show confirmation dialog
  /// 
  /// [context] - BuildContext
  /// [title] - Dialog title (localized)
  /// [message] - Dialog message (localized)
  /// [confirmText] - Confirm button text (localized)
  /// [cancelText] - Cancel button text (localized)
  /// [onConfirm] - Confirm button callback
  /// [onCancel] - Cancel button callback
  /// [isDismissible] - Whether dialog can be dismissed by tapping outside
  /// 
  /// Returns the dialog result
  static Future<T?> showConfirmation<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => _ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}

// ============================================================================
// Loading Dialog Widget
// ============================================================================

class _LoadingDialog extends StatelessWidget {
  final String title;
  final String message;

  const _LoadingDialog({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.brightness != Brightness.dark ? theme.colorScheme.secondary : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
          boxShadow: theme.brightness == Brightness.dark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading indicator 
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor),
                ),
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
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Success Dialog Widget
// ============================================================================

class _SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const _SuccessDialog({
    required this.title,
    required this.message,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Constants.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 40,
                color: Constants.successColor,
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

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: Constants.textSize,
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

// ============================================================================
// Error Dialog Widget
// ============================================================================

class _ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const _ErrorDialog({
    required this.title,
    required this.message,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Constants.dangerColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Constants.dangerColor,
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

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.dangerColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: Constants.textSize,
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

// ============================================================================
// Warning Dialog Widget
// ============================================================================

class _WarningDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const _WarningDialog({
    required this.title,
    required this.message,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
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
                Icons.warning_outlined,
                size: 40,
                color: Colors.orange,
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

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: Constants.textSize,
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

// ============================================================================
// Network Issues Dialog Widget
// ============================================================================

class _NetworkIssuesDialog extends StatelessWidget {
  final String title;
  final String message;
  final String retryText;
  final String cancelText;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const _NetworkIssuesDialog({
    required this.title,
    required this.message,
    required this.retryText,
    required this.cancelText,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Network icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_outlined,
                size: 40,
                color: Colors.blue,
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
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontSize: Constants.textSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Retry button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry ?? () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      retryText,
                      style: const TextStyle(
                        fontSize: Constants.textSize,
                        fontWeight: FontWeight.w600,
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

// ============================================================================
// Confirmation Dialog Widget
// ============================================================================

class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Question icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
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
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontSize: Constants.textSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontSize: Constants.textSize,
                        fontWeight: FontWeight.w600,
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
