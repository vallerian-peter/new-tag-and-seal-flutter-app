import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/custom_text_field.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

/// A reusable date picker component with consistent styling
/// 
/// Usage Examples:
/// 
/// 1. Basic date picker:
/// ```dart
/// CustomDatePicker(
///   controller: dateController,
///   label: 'Date of Birth',
///   hint: 'Select your date of birth',
///   validator: (value) => value == null ? 'Date is required' : null,
/// )
/// ```
/// 
/// 2. Date picker with custom date range:
/// ```dart
/// CustomDatePicker(
///   controller: dateController,
///   label: 'Event Date',
///   hint: 'Select event date',
///   firstDate: DateTime.now(),
///   lastDate: DateTime.now().add(Duration(days: 365)),
/// )
/// ```
class CustomDatePicker extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final ValueChanged<DateTime>? onDateSelected;
  final bool autoFillValue;

  const CustomDatePicker({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.isRequired = true,
    this.onDateSelected,
    this.autoFillValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate ?? now,
          firstDate: firstDate ?? DateTime(1900),
          lastDate: lastDate ?? DateTime(now.year + 5),
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: Constants.primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: theme.colorScheme.onSurface,
                ),
                dialogBackgroundColor: Colors.white,
                cardColor: Colors.white,
                canvasColor: Colors.white,
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.white,
                  headerBackgroundColor: Constants.primaryColor,
                  headerForegroundColor: Colors.white,
                  dayStyle: TextStyle(
                    fontSize: Constants.textSize,
                    color: theme.colorScheme.onSurface,
                  ),
                  yearStyle: TextStyle(
                    fontSize: Constants.textSize,
                    color: theme.colorScheme.onSurface,
                  ),
                  dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return theme.colorScheme.onSurface;
                  }),
                  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Constants.primaryColor;
                    }
                    return Colors.transparent;
                  }),
                  todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Constants.primaryColor;
                  }),
                  todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Constants.primaryColor;
                    }
                    return Colors.transparent;
                  }),
                  todayBorder: const BorderSide(color: Constants.primaryColor, width: 1),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          if (autoFillValue) {
            controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          }
          onDateSelected?.call(date);
        }
      },
      child: AbsorbPointer(
        child: CustomTextField(
          controller: controller,
          label: label,
          hintText: hint,
          prefixIcon: Icons.calendar_today_outlined,
          validator: validator,
          readOnly: true,
        ),
      ),
    );
  }
}
