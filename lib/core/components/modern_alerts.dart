import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/alert_dialogs.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/toast_alerts.dart';

/// Unified alerts surface for forms/pages.
///
/// - Dialog-based methods delegate to `AlertDialogs`
/// - Lightweight inline alerts delegate to `ToastAlerts`
class ModernAlerts {
  ModernAlerts._();

  static Future<T?> showLoading<T>({
    required BuildContext context,
    required String title,
    required String message,
    bool isDismissible = false,
  }) {
    return AlertDialogs.showLoading(
      context: context,
      title: title,
      message: message,
      isDismissible: isDismissible,
    );
  }

  static Future<T?> showSuccess<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    return AlertDialogs.showSuccess(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
      isDismissible: isDismissible,
    );
  }

  static Future<T?> showError<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    return AlertDialogs.showError(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
      isDismissible: isDismissible,
    );
  }

  static Future<T?> showWarningDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    VoidCallback? onPressed,
    bool isDismissible = true,
  }) {
    return AlertDialogs.showWarning(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
      isDismissible: isDismissible,
    );
  }

  static Future<T?> showConfirmation<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? messageWidget,
    required String confirmText,
    required String cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    Color? secondaryActionColor,
    Color? confirmButtonColor,
    bool showCancelButton = true,
    bool isDismissible = true,
  }) {
    return AlertDialogs.showConfirmation(
      context: context,
      title: title,
      message: message,
      messageWidget: messageWidget,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      secondaryActionColor: secondaryActionColor,
      confirmButtonColor: confirmButtonColor,
      showCancelButton: showCancelButton,
      isDismissible: isDismissible,
    );
  }

  static void showErrorToast(BuildContext context, {required String message}) {
    ToastAlerts.showError(context, message: message);
  }

  static void showWarning(BuildContext context, {required String message}) {
    ToastAlerts.showWarning(context, message: message);
  }

  static void showSuccessToast(
    BuildContext context, {
    required String message,
  }) {
    ToastAlerts.showSuccess(context, message: message);
  }
}
