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

  /// Returns the display name of the livestock with ID prefix.
  ///
  /// Format: "[Name]-[ID]"
  /// Priority of ID: dummyTagId -> rfidTagId -> barcodeTagId
  static String getDisplayName(Livestock livestock) {
    String? id = livestock.dummyTagId;
    if (id == null || id.trim().isEmpty || id.trim().toLowerCase() == 'null') {
      id = livestock.rfidTagId;
    }
    if (id == null || id.trim().isEmpty || id.trim().toLowerCase() == 'null') {
      id = livestock.barcodeTagId;
    }
    if (id == null || id.trim().isEmpty || id.trim().toLowerCase() == 'null') {
      id = livestock.identificationNumber;
    }

    final hasId =
        id != null && id.trim().isNotEmpty && id.trim().toLowerCase() != 'null';
    final hasName =
        livestock.name.trim().isNotEmpty &&
        livestock.name.trim().toLowerCase() != 'null';

    if (hasId && hasName) {
      return '${livestock.name}-${id.trim()}';
    } else if (hasId) {
      return id.trim();
    } else if (hasName) {
      return livestock.name;
    }

    return '';
  }
}
