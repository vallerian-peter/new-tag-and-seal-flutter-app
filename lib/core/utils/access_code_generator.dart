import 'dart:math';

/// Utility class for generating access codes for extension officer farm invites
/// 
/// Format: ACODE-{5numbers}{3chars}=7-{2numbers}
/// Total numbers (before and after =7-) must equal 7 (5 + 2 = 7)
/// Example: ACODE-12345ABC=7-12
class AccessCodeGenerator {
  static final Random _random = Random();

  /// Generate a unique access code in the format: ACODE-{5numbers}{3chars}=7-{2numbers}
  /// 
  /// The format ensures:
  /// - 5 random numbers at the start
  /// - 3 random uppercase letters
  /// - 2 random numbers at the end
  /// - Total of 7 digits (5 + 2)
  static String generateAccessCode() {
    // Generate random 5 numbers (padded with zeros if needed)
    final firstPartNumbers = _random.nextInt(100000); // 0-99999
    final firstPart = firstPartNumbers.toString().padLeft(5, '0');

    // Generate random 3 uppercase characters
    final chars = List.generate(3, (_) => String.fromCharCode(65 + _random.nextInt(26))); // A-Z
    final randomChars = chars.join();

    // Generate random 2 numbers (padded with zeros if needed)
    final secondPartNumbers = _random.nextInt(100); // 0-99
    final secondPart = secondPartNumbers.toString().padLeft(2, '0');

    return 'ACODE-$firstPart$randomChars=7-$secondPart';
  }

  /// Validate access code format
  /// 
  /// Returns true if the access code matches the expected format:
  /// ACODE-{5numbers}{3uppercase_chars}=7-{2numbers}
  static bool isValidFormat(String accessCode) {
    final regex = RegExp(r'^ACODE-\d{5}[A-Z]{3}=7-\d{2}$');
    return regex.hasMatch(accessCode);
  }
}

