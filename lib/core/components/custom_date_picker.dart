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
         // Allow both if autoFillValue is false (callback handles controller update manually)
         !(controller != null && onDateSelected != null && autoFillValue),
         'When using both controller and onDateSelected, set autoFillValue to false',
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

  Future<DateTime?> _showDatePicker(BuildContext context) async {
    if (!enabled) return null;

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
      final formattedDate = '${date.day}/${date.month}/${date.year}';
      
      if (onDateSelected != null) {
        // Call the callback first (may handle controller update itself)
        await onDateSelected!(date);
        // If autoFillValue is true and controller exists and wasn't filled by callback, auto-fill
        if (autoFillValue && controller != null && controller!.text.isEmpty) {
          controller!.text = formattedDate;
        }
      } else if (controller != null && autoFillValue) {
        // Update controller with formatted date
        controller!.text = formattedDate;
      }
      // Note: If both controller and onDateSelected are provided with autoFillValue=false,
      // the callback is responsible for updating the controller
    }
    
    return date;
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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // If using controller, wrap in FormField for proper validation integration
    if (controller != null) {
      return FormField<String>(
        initialValue: controller!.text,
        validator: validator,
        builder: (FormFieldState<String> field) {
          // Use ValueListenableBuilder to listen to controller changes
          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller!,
            builder: (context, value, child) {
              final displayText = value.text;
              final isEmpty = displayText.isEmpty;
              final hasError = field.hasError;

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
                onTap: enabled
                    ? () async {
                        final selectedDate = await _showDatePicker(context);
                        if (selectedDate != null) {
                          // Controller is already updated in _showDatePicker (or by onDateSelected callback)
                          // Update form field value after date selection
                          field.didChange(controller!.text);
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
                        field.errorText ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Constants.dangerColor,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
    }
    
    // For DateTime-based API (without controller)
    // Wrap in FormField for proper validation integration
    if (onDateSelected != null || selectedDate != null) {
      return FormField<DateTime>(
        initialValue: selectedDate,
        validator: dateValidator != null
            ? (value) => dateValidator!(value)
            : validator != null
                ? (value) {
                    if (value == null) {
                      final dateStr = '';
                      return validator!(dateStr.isEmpty ? null : dateStr);
                    }
                    final dateStr = _formatDate(value);
                    return validator!(dateStr.isEmpty ? null : dateStr);
                  }
                : null,
        builder: (FormFieldState<DateTime> field) {
          final currentDate = field.value ?? selectedDate;
          final displayText = currentDate != null ? _formatDate(currentDate) : '';
          final isEmpty = displayText.isEmpty;
          final hasError = field.hasError;

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
                onTap: enabled
                    ? () async {
                        final selectedDate = await _showDatePicker(context);
                        if (selectedDate != null) {
                          // Update form field value
                          field.didChange(selectedDate);
                          // Call the callback
                          if (onDateSelected != null) {
                            await onDateSelected!(selectedDate);
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
                    field.errorText ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Constants.dangerColor,
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    // Fallback: No controller, no DateTime API (shouldn't happen, but handle gracefully)
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
      ],
    );
  }
}
