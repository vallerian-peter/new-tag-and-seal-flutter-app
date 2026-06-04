import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/app_date_picker.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

/// Custom date picker specifically for "Date Entered Farm" field
/// that properly handles auto-fill scenarios when "Born on Farm" is selected
class LivestockDateEnteredFarmPicker extends StatelessWidget {
  final String label;
  final String hint;
  final DateTime? selectedDate;
  final FutureOr<void> Function(DateTime)? onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(DateTime?)? dateValidator;
  final bool enabled;
  final bool isBornOnFarm;

  const LivestockDateEnteredFarmPicker({
    super.key,
    required this.label,
    required this.hint,
    this.selectedDate,
    this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.dateValidator,
    this.enabled = true,
    this.isBornOnFarm = false,
  });

  DateTime? _getCurrentDate() {
    return selectedDate ?? DateTime.now();
  }

  Future<DateTime?> _showDatePicker(BuildContext context) async {
    if (!enabled) return null;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final date = await showAppDatePicker(
      context: context,
      initialDate: _getCurrentDate() ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        final backgroundColor = isDark
            ? theme.scaffoldBackgroundColor
            : Colors.white;

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: Constants.primaryColor,
              onPrimary: theme.colorScheme.onPrimary,
              onSurface: theme.colorScheme.onSurface,
              surface: backgroundColor,
              surfaceContainerHighest: backgroundColor,
            ),
            dialogBackgroundColor: backgroundColor,
            canvasColor: backgroundColor,
            cardColor: backgroundColor,
            scaffoldBackgroundColor: backgroundColor,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: backgroundColor,
              surfaceTintColor: Colors.transparent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Constants.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && onDateSelected != null) {
      await onDateSelected!(date);
    }

    return date;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<DateTime>(
      // Use a key based on selectedDate to force rebuild when date changes
      key: ValueKey(
        'date_entered_farm_${selectedDate?.toIso8601String()}_$isBornOnFarm',
      ),
      initialValue: selectedDate,
      validator: dateValidator,
      builder: (FormFieldState<DateTime> field) {
        // Always use the current selectedDate prop, not just the field.value
        // This ensures auto-filled dates are properly recognized
        final currentDate = selectedDate ?? field.value;
        final displayText = currentDate != null ? _formatDate(currentDate) : '';
        final isEmpty = displayText.isEmpty;
        final hasError = field.hasError;

        // Update field value when selectedDate prop changes (from auto-fill)
        if (selectedDate != null && field.value != selectedDate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (field.mounted) {
              field.didChange(selectedDate);
              // Re-validate after updating
              field.validate();
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Constants.textSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: enabled
                  ? () async {
                      final selected = await _showDatePicker(context);
                      if (selected != null) {
                        // Update form field value
                        field.didChange(selected);
                        // Call the callback
                        if (onDateSelected != null) {
                          await onDateSelected!(selected);
                        }
                        // Validate the field
                        field.validate();
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? theme.scaffoldBackgroundColor
                      : null,
                  border: Border.all(
                    color: hasError
                        ? Constants.dangerColor
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEmpty ? hint : displayText,
                      style: TextStyle(
                        color: isEmpty
                            ? theme.colorScheme.onSurface.withOpacity(0.6)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: Constants.primaryColor),
                  ],
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  field.errorText ?? '',
                  style: TextStyle(fontSize: 12, color: Constants.dangerColor),
                ),
              ),
          ],
        );
      },
    );
  }
}
