import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

class LivestockFilterPills extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;
  final List<FilterOption> filters;

  const LivestockFilterPills({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterPill(
              label: filter.label,
              value: filter.value,
              isSelected: selectedFilter == filter.value,
              onTap: () => onFilterSelected(filter.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterOption {
  final String label;
  final String value;

  const FilterOption({
    required this.label,
    required this.value,
  });
}

class _FilterPill extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Constants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Constants.primaryColor
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Constants.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
