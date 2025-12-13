import 'dart:developer';

/// Utility class for converting date formats between Flutter UI and backend API
class DateFormatConverter {
  DateFormatConverter._(); // Private constructor

  /// Converts date from DD/MM/YYYY format (from CustomDatePicker controller) to YYYY-MM-DD format (for backend)
  /// 
  /// Handles various input formats:
  /// - DD/MM/YYYY (e.g., "13/12/2008")
  /// - YYYY-MM-DD (already correct format)
  /// - ISO8601 datetime strings
  /// 
  /// Returns null if date is empty or cannot be parsed
  static String? convertToBackendFormat(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) {
      return null;
    }

    final trimmed = dateString.trim();

    // If already in YYYY-MM-DD format, return as-is
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
      return trimmed;
    }

    try {
      // Try parsing DD/MM/YYYY format
      final parts = trimmed.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0].trim());
        final month = int.parse(parts[1].trim());
        final year = int.parse(parts[2].trim());
        
        // Validate date values
        if (year < 1900 || year > 2100) {
          log('⚠️ Invalid year in date: $dateString');
          return null;
        }
        if (month < 1 || month > 12) {
          log('⚠️ Invalid month in date: $dateString');
          return null;
        }
        if (day < 1 || day > 31) {
          log('⚠️ Invalid day in date: $dateString');
          return null;
        }

        final date = DateTime(year, month, day);
        // Format as YYYY-MM-DD for backend
        return '${date.year.toString().padLeft(4, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.day.toString().padLeft(2, '0')}';
      }

      // Try parsing as ISO8601 datetime (e.g., "2008-12-13T00:00:00.000Z")
      final parsedDate = DateTime.tryParse(trimmed);
      if (parsedDate != null) {
        final year = parsedDate.year;
        if (year >= 1900 && year <= 2100) {
          return '${year.toString().padLeft(4, '0')}-'
              '${parsedDate.month.toString().padLeft(2, '0')}-'
              '${parsedDate.day.toString().padLeft(2, '0')}';
        }
      }

      log('⚠️ Could not parse date format: $dateString');
      return null;
    } catch (e) {
      log('⚠️ Error parsing date: $dateString - $e');
      return null;
    }
  }

  /// Converts DateTime object to YYYY-MM-DD format string for backend
  static String? convertDateTimeToBackendFormat(DateTime? date) {
    if (date == null) return null;
    
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}


