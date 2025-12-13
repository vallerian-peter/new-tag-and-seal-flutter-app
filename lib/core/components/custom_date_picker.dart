import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/constants/colors.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

/// A reusable date picker component with consistent styling
/// 
/// Usage Examples:
/// 
/// 1. With DateTime (new API):
/// ```dart
/// CustomDatePicker(
///   label: 'Date of Birth',
///   hint: 'Select date',
///   icon: Icons.calendar_today_outlined,
///   selectedDate: _selectedDate,
///   onDateSelected: (date) {
///     setState(() => _selectedDate = date);
///   },
///   firstDate: DateTime(1900),
///   lastDate: DateTime.now(),
///   validator: (date) {
///     if (date == null) return 'Date is required';
///     return null;
///   },
/// )
/// ```
/// 
/// 2. With TextEditingController (legacy API):
/// ```dart
/// CustomDatePicker(
///   controller: _dateController,
///   label: 'Date of Birth',
///   hint: 'Select date',
///   validator: (value) {
///     if (value == null || value.isEmpty) {
///       return 'Date is required';
///     }
///     return null;
///   },
/// )
/// ```
class CustomDatePicker extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final DateTime? selectedDate;
  final FutureOr<void> Function(DateTime)? onDateSelected;
  final TextEditingController? controller;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? Function(String?)? validator;
  final String? Function(DateTime?)? dateValidator;
  final bool isRequired;
  final bool enabled;
  final bool autoFillValue;

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.selectedDate,
    this.onDateSelected,
    this.controller,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.validator,
    this.dateValidator,
    this.isRequired = true,
    this.enabled = true,
    this.autoFillValue = true,
  }) : assert(
         (onDateSelected != null && controller == null) ||
         (controller != null && selectedDate == null),
         'Provide either onDateSelected (with optional selectedDate) OR controller, but not both',
       );

  DateTime? _getCurrentDate() {
    if (selectedDate != null) {
      return selectedDate;
    }
    if (controller != null && controller!.text.isNotEmpty) {
      try {
        final parts = controller!.text.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
        // Invalid date format, return null
      }
    }
    return initialDate ?? DateTime.now();
  }

  Future<void> _showDatePicker(BuildContext context) async {
    if (!enabled) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final date = await showDatePicker(
      context: context,
      initialDate: _getCurrentDate() ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        final backgroundColor = isDark 
            ? theme.scaffoldBackgroundColor 
            : whiteColor;
            
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

    if (date != null) {
      if (onDateSelected != null) {
        // Call the callback first (may handle controller update itself)
        await onDateSelected!(date);
        // If autoFillValue is true and controller exists and wasn't filled by callback, auto-fill
        if (autoFillValue && controller != null && controller!.text.isEmpty) {
          controller!.text = '${date.day}/${date.month}/${date.year}';
        }
      } else if (controller != null && autoFillValue) {
        controller!.text = '${date.day}/${date.month}/${date.year}';
      } else if (selectedDate != null) {
        // This case is handled by the caller via onDateSelected callback
        // But if no callback provided, we can't update selectedDate (it's final)
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDisplayText() {
    if (selectedDate != null) {
      return _formatDate(selectedDate);
    }
    if (controller != null) {
      return controller!.text;
    }
    return '';
  }

  bool _hasError() {
    if (dateValidator != null && selectedDate != null) {
      return dateValidator!(selectedDate) != null;
    }
    if (validator != null) {
      if (selectedDate != null) {
        // For DateTime-based API, convert to string for validation
        final dateStr = _formatDate(selectedDate);
        return validator!(dateStr.isEmpty ? null : dateStr) != null;
      }
      if (controller != null) {
        return validator!(controller!.text.isEmpty ? null : controller!.text) != null;
      }
      return validator!(null) != null;
    }
    return false;
  }

  String? _getErrorText() {
    if (dateValidator != null && selectedDate != null) {
      return dateValidator!(selectedDate);
    }
    if (validator != null) {
      if (selectedDate != null) {
        final dateStr = _formatDate(selectedDate);
        return validator!(dateStr.isEmpty ? null : dateStr);
      }
      if (controller != null) {
        return validator!(controller!.text.isEmpty ? null : controller!.text);
      }
      return validator!(null);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _hasError();
    final displayText = _getDisplayText();
    final isEmpty = displayText.isEmpty;

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
          onTap: enabled ? () => _showDatePicker(context) : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark 
                  ? theme.scaffoldBackgroundColor 
                  : null,
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
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
                Icon(
                  Icons.calendar_today,
                  color: Constants.primaryColor,
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _getErrorText() ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Constants.dangerColor,
              ),
            ),
          ),
      ],
    );
  }
}
