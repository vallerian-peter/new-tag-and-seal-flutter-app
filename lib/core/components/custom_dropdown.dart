import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';

/// A reusable dropdown component with consistent styling
/// 
/// Usage Examples:
/// 
/// 1. String dropdown (simple):
/// ```dart
/// CustomDropdown<String>(
///   label: 'Gender',
///   hint: 'Select gender',
///   icon: Icons.wc_outlined,
///   items: ['Male', 'Female'],
///   onChanged: (value) => setState(() => selectedGender = value),
/// )
/// ```
/// 
/// 2. Dropdown with custom labels (legacy):
/// ```dart
/// CustomDropdown<int>(
///   label: 'Country',
///   hint: 'Select country',
///   icon: Icons.public_outlined,
///   items: [1, 2, 3],
///   itemLabels: ['USA', 'Canada', 'Mexico'],
///   onChanged: (value) => setState(() => selectedCountry = value),
/// )
/// ```
/// 
/// 3. Dropdown with DropdownItem list (recommended):
/// ```dart
/// CustomDropdown<String>(
///   label: 'Unit',
///   hint: 'Select unit',
///   icon: Icons.straighten_outlined,
///   dropdownItems: [
///     DropdownItem(value: 'acre', label: l10n.acres),
///     DropdownItem(value: 'hectare', label: l10n.hectares),
///   ],
///   onChanged: (value) => setState(() => selectedUnit = value),
/// )
/// ```
class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<T>? items;
  final List<String>? itemLabels;
  final List<DropdownItem<T>>? dropdownItems;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.items,
    this.itemLabels,
    this.dropdownItems,
    required this.onChanged,
    this.validator,
    this.isRequired = true,
    this.value,
    this.enabled = true,
  }) : assert(
         (items != null && dropdownItems == null) || 
         (items == null && dropdownItems != null),
         'Either items or dropdownItems must be provided, but not both',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Extract items and labels from dropdownItems if provided
    final actualItems = dropdownItems != null 
        ? dropdownItems!.map((item) => item.value).toList()
        : items!;
    final actualLabels = dropdownItems != null
        ? dropdownItems!.map((item) => item.label).toList()
        : itemLabels;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: TextStyle(
            fontSize: Constants.textSize,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
            cardColor: Colors.white,
            dialogBackgroundColor: Colors.white,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 0,
              maxWidth: double.infinity,
            ),
            child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            dropdownColor: Colors.white,
            onChanged: enabled ? onChanged : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: Constants.textSize,
              ),
              prefixIcon: Icon(
                icon,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                size: Constants.iconsSize,
              ),
              filled: true,
              fillColor: enabled
                  ? Constants.veryLightGreyColor
                  : Constants.veryLightGreyColor.withOpacity(0.6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Constants.primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Constants.primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: enabled ? Constants.primaryColor : Constants.primaryColor.withOpacity(0.2),
                  width: enabled ? 2 : 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Constants.dangerColor,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Constants.dangerColor,
                  width: 2,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: Constants.textSize,
              color: enabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            selectedItemBuilder: (BuildContext context) {
              final labels = actualLabels;
              return actualItems.map<Widget>((T item) {
                final index = actualItems.indexOf(item);
                final label = labels != null && index < labels.length
                    ? labels[index]
                    : item.toString();
                return Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: Constants.textSize,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList();
            },
            items: actualItems.asMap().entries.map((entry) {
              final labels = actualLabels;
              final index = entry.key;
              final item = entry.value;
              final label = labels != null && index < labels.length
                  ? labels[index]
                  : item.toString();
                return DropdownMenuItem<T>(
                value: item,
                child: Tooltip(
                  message: label,
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: Constants.textSize,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              );
            }).toList(),
            validator: validator,
            ),
          ),
        ),
      ],
    );
  }
}