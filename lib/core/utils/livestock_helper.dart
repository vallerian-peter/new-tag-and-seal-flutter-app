import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

/// Livestock Helper Utility
///
/// Provides helper methods for livestock-related operations and status checks.
class LivestockHelper {
  LivestockHelper._();

  static const Set<String> _inactiveStatuses = {
    'notactive',
    'not-active',
    'not_active',
    'inactive',
  };

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
    return _inactiveStatuses.contains(status);
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

    final hasId = id.trim().isNotEmpty && id.trim().toLowerCase() != 'null';
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

  /// Returns the display name, or a localized fallback label when empty.
  static String getDisplayLabel(
    Livestock livestock, {
    required String fallbackPrefix,
  }) {
    final displayName = getDisplayName(livestock);
    if (displayName.isNotEmpty) return displayName;
    return '$fallbackPrefix #${livestock.id}';
  }

  /// Formats age from a date of birth as a compact label.
  ///
  /// Examples:
  /// - `2y 3m`
  /// - `5m 12d`
  /// - `8d`
  static String getAgeLabelFromDateOfBirth(
    String dateOfBirth, {
    DateTime? referenceDate,
  }) {
    final birthDate = DateTime.tryParse(dateOfBirth);
    if (birthDate == null) return '---';
    return getAgeLabelFromBirthDate(birthDate, referenceDate: referenceDate);
  }

  /// Formats age from a birth date as a compact label.
  static String getAgeLabelFromBirthDate(
    DateTime birthDate, {
    DateTime? referenceDate,
  }) {
    final today = referenceDate ?? DateTime.now();
    if (birthDate.isAfter(today)) {
      return '0d';
    }

    var years = today.year - birthDate.year;
    var months = today.month - birthDate.month;
    var days = today.day - birthDate.day;

    if (days < 0) {
      months--;
      final previousMonth = DateTime(today.year, today.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      if (months > 0) return '${years}y ${months}m';
      return '${years}y';
    }

    if (months > 0) {
      if (days > 0) return '${months}m ${days}d';
      return '${months}m';
    }

    return '${days < 0 ? 0 : days}d';
  }
}
