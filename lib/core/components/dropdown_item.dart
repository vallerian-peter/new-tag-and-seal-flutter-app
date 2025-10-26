/// Dropdown item model with separate value (for API/DB) and label (for display)
/// 
/// This class ensures that the displayed text can be localized while the stored
/// value remains consistent (e.g., API enums in English).
/// 
/// **Example Usage:**
/// ```dart
/// final sizeUnits = [
///   DropdownItem(value: 'acre', label: l10n.acres),
///   DropdownItem(value: 'hectare', label: l10n.hectares),
/// ];
/// 
/// CustomDropdown<String>(
///   dropdownItems: sizeUnits,
///   onChanged: (value) => print(value), // Prints 'acre' or 'hectare'
/// )
/// ```
/// 
/// **Benefits:**
/// - User sees localized text (e.g., "Acres" or "Ekari")
/// - Database stores consistent value (e.g., "acre")
/// - No language-dependent data in database
class DropdownItem<T> {
  /// The value to be stored in the database or sent to API
  /// This should be a consistent value (e.g., enum, ID, code)
  final T value;
  
  /// The label to be displayed to the user
  /// This can be localized text from l10n
  final String label;
  
  const DropdownItem({
    required this.value,
    required this.label,
  });
}


