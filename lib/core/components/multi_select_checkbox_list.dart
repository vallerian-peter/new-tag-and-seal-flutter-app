import 'package:flutter/material.dart';

/// A reusable multi-select checkbox list component
/// 
/// Usage Example:
/// ```dart
/// MultiSelectCheckboxList<String>(
///   label: l10n.farm,
///   items: farms,
///   selectedItems: selectedFarmUuids,
///   itemLabel: (farm) => farm.name,
///   itemSubtitle: (farm) => farm.referenceNo,
///   onSelectionChanged: (selected) => setState(() => selectedFarmUuids = selected),
///   emptyMessage: l10n.noFarmsAvailable,
///   errorMessage: _autovalidateMode == AutovalidateMode.always && selectedFarmUuids.isEmpty
///       ? l10n.farmRequired
///       : null,
///   successMessage: selectedFarmUuids.isNotEmpty
///       ? '${selectedFarmUuids.length} ${selectedFarmUuids.length == 1 ? l10n.farm : l10n.farms} ${l10n.selected}'
///       : null,
/// )
/// ```
class MultiSelectCheckboxList<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final Set<T> selectedItems;
  final String Function(T) itemLabel;
  final String? Function(T)? itemSubtitle;
  final void Function(Set<T>) onSelectionChanged;
  final String? emptyMessage;
  final String? errorMessage;
  final String? successMessage;
  final double? maxHeight;
  final bool showSelectAll;
  final String? selectAllLabel;
  final String? Function(T)? itemValue;

  const MultiSelectCheckboxList({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    this.itemSubtitle,
    required this.onSelectionChanged,
    this.emptyMessage,
    this.errorMessage,
    this.successMessage,
    this.maxHeight = 200,
    this.showSelectAll = false,
    this.selectAllLabel,
    this.itemValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          _buildEmptyState(context, theme)
        else
          _buildCheckboxList(context, theme),
        if (errorMessage != null) _buildErrorMessage(context, theme),
        if (successMessage != null && errorMessage == null)
          _buildSuccessMessage(context, theme),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        emptyMessage ?? 'No items available',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildCheckboxList(BuildContext context, ThemeData theme) {
    final allSelected = items.isNotEmpty && selectedItems.length == items.length;

    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length + (showSelectAll ? 1 : 0),
        itemBuilder: (context, index) {
          if (showSelectAll && index == 0) {
            return Column(
              children: [
                CheckboxListTile(
                  title: Text(
                    selectAllLabel ?? 'Select All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: allSelected,
                  onChanged: (bool? value) {
                    final newSelection = value == true
                        ? items.toSet()
                        : <T>{};
                    onSelectionChanged(newSelection);
                  },
                  activeColor: theme.colorScheme.primary,
                  checkColor: theme.colorScheme.onPrimary,
                ),
                if (items.isNotEmpty)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
              ],
            );
          }

          final itemIndex = showSelectAll ? index - 1 : index;
          final item = items[itemIndex];
          final isSelected = selectedItems.contains(item);
          final labelText = itemLabel(item);
          final subtitleText = itemSubtitle != null ? itemSubtitle!(item) : null;

          return CheckboxListTile(
            title: Text(
              labelText,
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: subtitleText != null && subtitleText.isNotEmpty
                ? Text(
                    subtitleText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  )
                : null,
            value: isSelected,
            onChanged: (bool? value) {
              final newSelection = Set<T>.from(selectedItems);
              if (value == true) {
                newSelection.add(item);
              } else {
                newSelection.remove(item);
              }
              onSelectionChanged(newSelection);
            },
            activeColor: theme.colorScheme.primary,
            checkColor: theme.colorScheme.onPrimary,
          );
        },
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Text(
        errorMessage!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Text(
        successMessage!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
