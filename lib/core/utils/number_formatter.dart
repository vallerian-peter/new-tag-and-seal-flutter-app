import 'package:intl/intl.dart';

/// Number formatting utilities for display purposes
class NumberFormatter {
  // Private constructor to prevent instantiation
  NumberFormatter._();

  /// Format number with thousands separator for display
  /// 
  /// Examples:
  /// - 1000 → "1,000"
  /// - 1000.50 → "1,000.50"
  /// - 1234567.89 → "1,234,567.89"
  static String formatWithThousands(double number, {int decimalPlaces = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}', 'en_US');
    return formatter.format(number);
  }

  /// Format currency with thousands separator
  /// 
  /// Examples:
  /// - 1000 → "1,000.00"
  /// - 1234567.89 → "1,234,567.89"
  static String formatCurrency(double number) {
    return formatWithThousands(number, decimalPlaces: 2);
  }

  /// Format number with thousands separator (no decimals)
  /// 
  /// Examples:
  /// - 1000.50 → "1,001"
  /// - 1234567.89 → "1,234,568"
  static String formatInteger(double number) {
    return NumberFormat('#,##0', 'en_US').format(number.round());
  }
}
