import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/dropdown_item.dart';
import 'package:new_tag_and_seal_flutter_app/l10n/app_localizations.dart';

/// A searchable dropdown component with search bar at the top and auto-filter
/// 
/// Usage Example:
/// ```dart
/// SearchableDropdown<String>(
///   label: 'Country',
///   hint: 'Select or search country',
///   icon: Icons.public_outlined,
///   dropdownItems: [
///     DropdownItem(value: 'Tanzania', label: 'Tanzania'),
///     DropdownItem(value: 'Kenya', label: 'Kenya'),
///     DropdownItem(value: 'Other', label: 'Other'),
///   ],
///   value: selectedCountry,
///   onChanged: (value) => setState(() => selectedCountry = value),
/// )
/// ```
class SearchableDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<DropdownItem<T>> dropdownItems;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final bool enabled;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.dropdownItems,
    required this.onChanged,
    this.value,
    this.validator,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get display label for selected value
    String? displayLabel;
    if (value != null) {
      try {
        final selectedItem = dropdownItems.firstWhere(
          (item) => item.value == value,
        );
        displayLabel = selectedItem.label;
      } catch (e) {
        // If value not found in dropdown items, use value.toString()
        displayLabel = value.toString();
      }
    }

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
        InkWell(
          onTap: enabled ? () => _showSearchableBottomSheet(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: enabled
                  ? Constants.veryLightGreyColor
                  : Constants.veryLightGreyColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Constants.primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: Constants.iconsSize,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayLabel ?? hint,
                    style: TextStyle(
                      fontSize: Constants.textSize,
                      color: displayLabel != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        if (validator != null && validator!(value) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              validator!(value)!,
              style: TextStyle(
                color: Constants.dangerColor,
                fontSize: Constants.textSize - 2,
              ),
            ),
          ),
      ],
    );
  }

  void _showSearchableBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchableBottomSheetContent<T>(
        label: label,
        dropdownItems: dropdownItems,
        value: value,
        onChanged: onChanged,
        theme: theme,
        l10n: l10n,
      ),
    );
  }
}

class _SearchableBottomSheetContent<T> extends StatefulWidget {
  final String label;
  final List<DropdownItem<T>> dropdownItems;
  final T? value;
  final void Function(T?) onChanged;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _SearchableBottomSheetContent({
    required this.label,
    required this.dropdownItems,
    required this.value,
    required this.onChanged,
    required this.theme,
    required this.l10n,
  });

  @override
  State<_SearchableBottomSheetContent<T>> createState() =>
      _SearchableBottomSheetContentState<T>();
}

class _SearchableBottomSheetContentState<T>
    extends State<_SearchableBottomSheetContent<T>> {
  late final TextEditingController _searchController;
  late final ValueNotifier<List<DropdownItem<T>>> _filteredItems;
  late final ValueNotifier<bool> _hasSearchText;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = ValueNotifier<List<DropdownItem<T>>>(widget.dropdownItems);
    _hasSearchText = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredItems.dispose();
    _hasSearchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Constants.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: Constants.largeTextSize,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<bool>(
              valueListenable: _hasSearchText,
              builder: (context, hasText, _) {
                return TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: Constants.textSize,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.l10n.searchText,
                    hintStyle: TextStyle(
                      color: widget.theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: Constants.textSize,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: widget.theme.colorScheme.onSurface.withOpacity(0.5),
                      size: Constants.iconsSize,
                    ),
                    suffixIcon: hasText
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: widget.theme.colorScheme.onSurface.withOpacity(0.5),
                              size: Constants.iconsSize,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filteredItems.value = widget.dropdownItems;
                              _hasSearchText.value = false;
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Constants.veryLightGreyColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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
                        color: Constants.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (query) {
                    _hasSearchText.value = query.isNotEmpty;
                    if (query.isEmpty) {
                      _filteredItems.value = widget.dropdownItems;
                    } else {
                      _filteredItems.value = widget.dropdownItems
                          .where((item) => item.label
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                          .toList();
                    }
                  },
                );
              },
            ),
          ),
          // List of items
          Expanded(
            child: ValueListenableBuilder<List<DropdownItem<T>>>(
              valueListenable: _filteredItems,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.l10n.noResultsFound,
                        style: TextStyle(
                          fontSize: Constants.textSize,
                          color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item.value == widget.value;

                      return InkWell(
                        onTap: () {
                          widget.onChanged(item.value);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Constants.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: Constants.primaryColor.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: Constants.textSize,
                                    color: widget.theme.colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Constants.primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

