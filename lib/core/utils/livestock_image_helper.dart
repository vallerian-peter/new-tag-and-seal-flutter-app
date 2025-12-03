import 'package:new_tag_and_seal_flutter_app/database/app_database.dart';

/// Helper for resolving placeholder images for livestock based on type and gender.
class LivestockImageHelper {
  /// Returns an asset path for a livestock placeholder image.
  ///
  /// - Uses `livestock.livestockTypeId` to distinguish between Cattle, Swine, etc.
  /// - Uses `livestock.gender` to pick male vs female variants where available.
  ///
  /// Fallbacks:
  /// - If type is unknown, falls back to cattle placeholders.
  /// - If gender is unknown, treats as female for visual neutrality.
  static String getPlaceholderForLivestock(Livestock livestock) {
    final isMale = livestock.gender.toLowerCase() == 'male';
    final typeId = livestock.livestockTypeId;

    switch (typeId) {
      case 2: // Swine / Pig
        return isMale
            ? 'assets/images/placeholders/pig-image-MALE.png'
            : 'assets/images/placeholders/pig-image-FEMALE.png';

      // TODO: When goat/sheep/chicken assets are added, map them here using their IDs.

      case 1: // Cattle
      default:
        return isMale
            ? 'assets/images/placeholders/bull-1.png'
            : 'assets/images/placeholders/cow-1.png';
    }
  }
}


