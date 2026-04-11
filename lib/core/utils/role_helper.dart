import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/toast_alerts.dart';
import 'package:new_tag_and_seal_flutter_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Role Helper Utility
///
/// Provides helper methods for role-based access control and permission checking.
/// Shows appropriate error messages when access is denied.
class RoleHelper {
  RoleHelper._();

  /// Checks if the current user is a farmer.
  ///
  /// Returns `true` if user is a farmer, `false` otherwise.
  /// Shows a toast error message if user is not a farmer.
  ///
  /// Example:
  /// ```dart
  /// if (RoleHelper.checkFarmerRole(context, l10n)) {
  ///   // Proceed with farmer-only action
  /// }
  /// ```
  static bool checkFarmerRole(BuildContext context, AppLocalizations l10n) {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isFarmer) {
      ToastAlerts.showError(context, message: l10n.notAFarmer);
      return false;
    }
    return true;
  }

  /// Checks if the current user is a farm invited user.
  ///
  /// Returns `true` if user is a farm invited user, `false` otherwise.
  /// Shows a toast error message if user is not a farm invited user.
  static bool checkFarmUserRole(BuildContext context, AppLocalizations l10n) {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isFarmUser) {
      ToastAlerts.showError(context, message: l10n.notAFarmUser);
      return false;
    }
    return true;
  }

  /// Checks if the current user has a specific role.
  ///
  /// Returns `true` if user has the specified role, `false` otherwise.
  /// Shows a toast error message if user doesn't have the required role.
  static bool checkRole(
    BuildContext context,
    AppLocalizations l10n,
    String requiredRole, {
    String? customErrorMessage,
  }) {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.userRole;

    if (userRole?.toLowerCase() != requiredRole.toLowerCase()) {
      ToastAlerts.showError(
        context,
        message:
            customErrorMessage ?? l10n.accessDeniedRequiredRole(requiredRole),
      );
      return false;
    }
    return true;
  }

  /// Checks if the current user can create livestock.
  ///
  /// Returns `true` if user is a farmer OR has roleTitle = 'farm-manager'.
  /// Shows a toast error message if user doesn't have permission.
  static bool checkCanCreateLivestock(
    BuildContext context,
    AppLocalizations l10n,
    AuthProvider authProvider,
  ) {
    // Check if user is a farmer
    if (authProvider.isFarmer) {
      return true;
    }

    
    if (authProvider.isExtensionOfficer) {
      return true;
    }

    // Check if user is a farm user with roleTitle = 'farm-manager'
    if (authProvider.isFarmUser) {
      final profile = authProvider.currentProfile;
      final roleTitle = profile?['roleTitle'] as String?;
      if (roleTitle != null &&
          roleTitle.toLowerCase().trim() == 'farm-manager') {
        return true;
      }
    }

    // User doesn't have permission
    ToastAlerts.showError(context, message: l10n.notAFarmerOrFarmManager);
    return false;
  }

  /// Checks if the current user can add vaccines.
  ///
  /// Returns `true` if user is a farmer OR has roleTitle = 'farm-manager' OR roleTitle = 'vaccination-user'.
  /// Shows a toast error message if user doesn't have permission.
  static bool checkCanAddVaccine(
    BuildContext context,
    AppLocalizations l10n,
    AuthProvider authProvider,
  ) {
    // Check if user is a farmer
    if (authProvider.isFarmer) {
      return true;
    }

    // Check if user is a farm user with allowed roleTitle
    if (authProvider.isFarmUser) {
      final profile = authProvider.currentProfile;
      final roleTitle = profile?['roleTitle'] as String?;
      if (roleTitle != null) {
        final normalizedRoleTitle = roleTitle.toLowerCase().trim();
        if (normalizedRoleTitle == 'farm-manager' ||
            normalizedRoleTitle == 'vaccination-user') {
          return true;
        }
      }
    }

    // User doesn't have permission
    ToastAlerts.showError(
      context,
      message: l10n.notAFarmerFarmManagerOrVaccinationUser,
    );
    return false;
  }

  /// Checks if the current user can manage (edit/delete) livestock.
  ///
  /// Returns `true` if user is a farmer OR has roleTitle = 'farm-manager'.
  /// Shows a toast error message if user doesn't have permission.
  ///
  /// [customErrorMessage] - Optional custom error message to show.
  /// If not provided, uses the default manage livestock message.
  static bool checkCanManageLivestock(
    BuildContext context,
    AppLocalizations l10n,
    AuthProvider authProvider, {
    String? customErrorMessage,
  }) {
    // Check if user is a farmer
    if (authProvider.isFarmer) {
      return true;
    }

    // Check if user is a farm user with roleTitle = 'farm-manager'
    if (authProvider.isFarmUser) {
      final profile = authProvider.currentProfile;
      final roleTitle = profile?['roleTitle'] as String?;
      if (roleTitle != null &&
          roleTitle.toLowerCase().trim() == 'farm-manager') {
        return true;
      }
    }

    // User doesn't have permission
    ToastAlerts.showError(
      context,
      message: customErrorMessage ?? l10n.notAFarmerOrFarmManagerManage,
    );
    return false;
  }

  /// Maps log type to the corresponding role title for that log type.
  ///
  /// Returns the role title string (e.g., 'feeding-user') or null if no mapping exists.
  static String? _getRoleTitleForLogType(String logType) {
    switch (logType.toLowerCase()) {
      case 'feeding':
        return 'feeding-user';
      case 'weightchange':
        return 'weight-change-user';
      case 'deworming':
        return 'deworming-user';
      case 'medication':
        return 'medication-user';
      case 'vaccination':
        return 'vaccination-user';
      case 'disposal':
        return 'disposal-user';
      case 'calving':
      case 'farrowing':
        return 'birth-event-user';
      case 'abortedpregnancy':
        return 'aborted-pregnancy-user';
      case 'dryoff':
        return 'dryoff-user';
      case 'insemination':
        return 'insemination-user';
      case 'pregnancy':
        return 'pregnancy-user';
      case 'milking':
        return 'milking-user';
      case 'transfer':
        return 'transfer-user';
      case 'prepucecondition':
        return 'prepuce-condition-user';
      default:
        return null;
    }
  }

  /// Checks if the current user can access a specific log type.
  ///
  /// Returns `true` if user is:
  /// - A farmer (always allowed)
  /// - A farm-manager (always allowed)
  /// - A farm user with roleTitle matching the log type (e.g., 'feeding-user' for 'feeding' log)
  ///
  /// Shows a toast error message if user doesn't have permission.
  ///
  /// [logType] - The log type to check (e.g., 'feeding', 'medication', 'vaccination')
  /// [customErrorMessage] - Optional custom error message to show.
  static bool checkCanAccessLogType(
    BuildContext context,
    AppLocalizations l10n,
    AuthProvider authProvider,
    String logType, {
    String? customErrorMessage,
  }) {
    // Check if user is a farmer (always allowed)
    if (authProvider.isFarmer) {
      return true;
    }

    // Check if user is a farm-manager (always allowed)
    if (authProvider.isFarmUser) {
      final profile = authProvider.currentProfile;
      final roleTitle = profile?['roleTitle'] as String?;
      if (roleTitle != null) {
        final normalizedRoleTitle = roleTitle.toLowerCase().trim();
        if (normalizedRoleTitle == 'farm-manager') {
          return true;
        }

        // Check if user has the specific log type role
        final requiredRoleTitle = _getRoleTitleForLogType(logType);
        if (requiredRoleTitle != null &&
            normalizedRoleTitle == requiredRoleTitle) {
          return true;
        }
      }
    }

    // If user is an extension officer, allow only technical logs defined in AuthProvider
    if (authProvider.isExtensionOfficer) {
      if (authProvider.hasAccessToLogType(logType)) {
        return true;
      }

      final logTypeName = logType.isNotEmpty
          ? '${logType[0].toUpperCase()}${logType.substring(1)}'
          : logType;
      ToastAlerts.showError(
        context,
        message: customErrorMessage ?? l10n.logTypeAccessDenied(logTypeName),
      );
      return false;
    }

    // User doesn't have permission
    final logTypeName = logType.isNotEmpty
        ? '${logType[0].toUpperCase()}${logType.substring(1)}'
        : logType;
    ToastAlerts.showError(
      context,
      message: customErrorMessage ?? l10n.logTypeAccessDenied(logTypeName),
    );
    return false;
  }
}
