import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// Shared color utility for livestock primary and secondary colors
class ColorHelper {
  /// Get list of colors with localization for dropdowns
  /// 
  /// [excludeColor] - Optional color value to exclude from the list
  /// Returns a list of DropdownItem with localized color names
  static List<DropdownItem<String>> getColorDropdownItems(
    AppLocalizations l10n, {
    String? excludeColor,
  }) {
    final colors = [
      DropdownItem(value: 'black', label: l10n.colorBlack),
      DropdownItem(value: 'white', label: l10n.colorWhite),
      DropdownItem(value: 'brown', label: l10n.colorBrown),
      DropdownItem(value: 'red', label: l10n.colorRed),
      DropdownItem(value: 'gray', label: l10n.colorGray),
    ];

    // Filter out excluded color if provided
    if (excludeColor != null && excludeColor.isNotEmpty) {
      return colors.where((item) => item.value != excludeColor).toList();
    }

    return colors;
  }
}

