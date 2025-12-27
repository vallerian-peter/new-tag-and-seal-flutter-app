import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

/// Helper for resolving placeholder images for livestock based on type and gender.
class LivestockImageHelper {
  /// Returns an asset path for a livestock placeholder image.
  ///
  /// - Uses `livestockTypeName` (if provided) to match livestock types by name (case-insensitive).
  /// - Falls back to `livestock.livestockTypeId` if name is not provided (for backward compatibility).
  /// - Uses `livestock.gender` to pick male vs female variants where available.
  ///
  /// Fallbacks:
  /// - If type name is not provided, falls back to ID-based matching.
  /// - If gender is unknown, treats as female for visual neutrality.
  static String getPlaceholderForLivestock(
    Livestock livestock, {
    String? livestockTypeName,
  }) {
    final isMale = livestock.gender.toLowerCase() == 'male';
    
    // Normalize the type name for matching (case-insensitive, trim whitespace)
    final normalizedTypeName = livestockTypeName?.toLowerCase().trim();
    
    // Use name-based matching if provided, otherwise fall back to ID
    if (normalizedTypeName != null && normalizedTypeName.isNotEmpty) {
      return _getImageByTypeName(normalizedTypeName, isMale);
    }
    
    // Fallback to ID-based matching if name is not provided
    return _getImageByTypeId(livestock.livestockTypeId, isMale);
  }

  /// Get image path based on livestock type name (case-insensitive matching).
  static String _getImageByTypeName(String typeName, bool isMale) {
    // Match various name variations for each livestock type
    if (_matchesType(typeName, ['cattle', 'cow'])) {
      return isMale
          ? 'assets/images/placeholders/bull-1.png'
          : 'assets/images/placeholders/cow-1.png';
    }
    
    if (_matchesType(typeName, ['swine', 'pig', 'pigs'])) {
      return isMale
          ? 'assets/images/placeholders/pig-image-MALE.png'
          : 'assets/images/placeholders/pig-image-FEMALE.png';
    }
    
    if (_matchesType(typeName, ['goat'])) {
      return isMale
          ? 'assets/images/placeholders/green-male-goat.png'
          : 'assets/images/placeholders/green-female-goat.png';
    }
    
    if (_matchesType(typeName, ['sheep', 'lamb'])) {
      return isMale
          ? 'assets/images/placeholders/green-male-sheep-lamb.png'
          : 'assets/images/placeholders/green-female-lamb-sheep.png';
    }
    
    if (_matchesType(typeName, ['horse'])) {
      return isMale
          ? 'assets/images/placeholders/green-male-horse.png'
          : 'assets/images/placeholders/green-female-horse.png';
    }
    
    if (_matchesType(typeName, ['chicken', 'chickens'])) {
      return isMale
          ? 'assets/images/placeholders/green-male-roaster.png'
          : 'assets/images/placeholders/green-female-chicken-hen.png';
    }
    
    if (_matchesType(typeName, ['turkey'])) {
      return isMale
          ? 'assets/images/placeholders/green-male-turkey.png'
          : 'assets/images/placeholders/green-female-turkey.png';
    }
    
    if (_matchesType(typeName, ['duck', 'ducks'])) {
      return isMale
          ? 'assets/images/placeholders/green-male-duck.png'
          : 'assets/images/placeholders/green-female-duck.png';
    }
    
    if (_matchesType(typeName, ['donkey', 'donkeys'])) {
      return isMale
          ? 'assets/images/placeholders/green-male-donkey.png'
          : 'assets/images/placeholders/green-female-donkey.png';
    }
    
    if (_matchesType(typeName, ['dog', 'dogs', 'pet', 'pets'])) {
      return isMale
          ? 'assets/images/placeholders/green-male-dog.png'
          : 'assets/images/placeholders/green-female-dog.png';
    }
    
    if (_matchesType(typeName, ['cat', 'cats'])) {
      return isMale
          ? 'assets/images/placeholders/green-male-cat.png'
          : 'assets/images/placeholders/green-female-cat.png';
    }
    
    // Fallback to cattle for unknown types
    return isMale
        ? 'assets/images/placeholders/bull-1.png'
        : 'assets/images/placeholders/cow-1.png';
  }

  /// Get image path based on livestock type ID (for backward compatibility).
  static String _getImageByTypeId(int typeId, bool isMale) {
    switch (typeId) {
      case 1: // Cattle / Cow
        return isMale
            ? 'assets/images/placeholders/bull-1.png'
            : 'assets/images/placeholders/cow-1.png';

      case 2: // Swine / Pig
        return isMale
            ? 'assets/images/placeholders/pig-image-MALE.png'
            : 'assets/images/placeholders/pig-image-FEMALE.png';

      case 3: // Goat
        return isMale
            ? 'assets/images/placeholders/green-male-goat.png'
            : 'assets/images/placeholders/green-female-goat.png';

      case 4: // Sheep or Lamb
        return isMale
            ? 'assets/images/placeholders/green-male-sheep-lamb.png'
            : 'assets/images/placeholders/green-female-lamb-sheep.png';

      case 5: // Horse
        return isMale
            ? 'assets/images/placeholders/green-male-horse.png'
            : 'assets/images/placeholders/green-female-horse.png';

      case 6: // Chicken
        return isMale
            ? 'assets/images/placeholders/green-male-roaster.png'
            : 'assets/images/placeholders/green-female-chicken-hen.png';

      case 7: // Turkey
        return isMale
            ? 'assets/images/placeholders/green-male-turkey.png'
            : 'assets/images/placeholders/green-female-turkey.png';

      case 8: // Duck
        return isMale
            ? 'assets/images/placeholders/green-male-duck.png'
            : 'assets/images/placeholders/green-female-duck.png';

      case 9: // Other (may include Donkey, Dog/Pets, Cat)
      case 10: // Donkey
        return isMale
            ? 'assets/images/placeholders/green-male-donkey.png'
            : 'assets/images/placeholders/green-female-donkey.png';

      case 11: // Dog / Pets
        return isMale
            ? 'assets/images/placeholders/green-male-dog.png'
            : 'assets/images/placeholders/green-female-dog.png';

      case 12: // Cat
        return isMale
            ? 'assets/images/placeholders/green-male-cat.png'
            : 'assets/images/placeholders/green-female-cat.png';

      default:
        // Fallback to cattle for unknown types
        return isMale
            ? 'assets/images/placeholders/bull-1.png'
            : 'assets/images/placeholders/cow-1.png';
    }
  }

  /// Check if the type name matches any of the provided variations.
  /// Uses exact matching or word boundary matching to avoid false positives
  /// (e.g., "cattle" should not match "cat").
  static bool _matchesType(String typeName, List<String> variations) {
    final lowerTypeName = typeName.toLowerCase();
    return variations.any((variation) {
      final lowerVariation = variation.toLowerCase();
      // Exact match
      if (lowerTypeName == lowerVariation) return true;
      // Word boundary match (e.g., "sheep or lamb" contains "sheep")
      // Check if variation appears as a whole word
      final regex = RegExp(r'\b' + RegExp.escape(lowerVariation) + r'\b');
      return regex.hasMatch(lowerTypeName);
    });
  }
}


