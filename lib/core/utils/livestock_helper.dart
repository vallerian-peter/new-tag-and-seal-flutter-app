import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

/// Livestock Helper Utility
/// 
/// Provides helper methods for livestock-related operations and status checks.
class LivestockHelper {
  LivestockHelper._();

  /// Checks if the livestock status is "notActive" (handles various formats).
  /// 
  /// Returns `true` if livestock status is any variation of "notActive":
  /// - "notActive"
  /// - "not-active"
  /// - "not_active"
  /// 
  /// Returns `false` otherwise.
  /// 
  /// Example:
  /// ```dart
  /// if (LivestockHelper.isNotActive(livestock)) {
  ///   // Livestock is not active, disable operations
  /// }
  /// ```
  static bool isNotActive(Livestock livestock) {
    final status = livestock.status.toLowerCase().trim();
    return status == 'notactive' || 
           status == 'not-active' || 
           status == 'not_active' ||
           status == 'inactive';
  }

  /// Checks if the livestock status is active (not notActive).
  /// 
  /// Returns `true` if livestock is active, `false` if notActive.
  /// 
  /// Example:
  /// ```dart
  /// if (LivestockHelper.isActive(livestock)) {
  ///   // Livestock is active, allow operations
  /// }
  /// ```
  static bool isActive(Livestock livestock) {
    return !isNotActive(livestock);
  }
}



