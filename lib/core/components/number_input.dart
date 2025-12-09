import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

/// A specialized text field for numeric input with built-in number keyboard and validation.
/// Includes increment/decrement buttons with customizable step interval.
/// 
/// Usage Examples:
/// ```dart
/// // Basic usage with default step of 1
/// NumberInput(
///   label: 'Number of Months',
///   hintText: 'Enter number',
///   prefixIcon: Icons.numbers,
///   controller: _monthsController,
///   allowDecimal: false,
///   min: 1,
///   max: 12,
/// )
/// 
/// // With custom step interval (e.g., increment by 0.5)
/// NumberInput(
///   label: 'Weight',
///   controller: _weightController,
///   allowDecimal: true,
///   step: 0.5,
///   min: 0,
/// )
/// 
/// // Without increment buttons
/// NumberInput(
///   label: 'Amount',
///   controller: _amountController,
///   showIncrementButtons: false,
/// )
/// ```
class NumberInput extends StatefulWidget {
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool readOnly;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final bool allowDecimal;
  final bool allowNegative;
  final int? min;
  final int? max;
  final bool showIncrementButtons;
  final num step;

  const NumberInput({
    super.key,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.controller,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.contentPadding,
    this.onTap,
    this.allowDecimal = false,
    this.allowNegative = false,
    this.min,
    this.max,
    this.showIncrementButtons = true,
    this.step = 1,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  @override
  void initState() {
    super.initState();
    // Initialize with 0 if controller is empty on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller != null && widget.controller!.text.trim().isEmpty) {
        widget.controller!.text = '0';
        if (mounted) setState(() {});
      }
    });
  }

  void _increment() {
    if (widget.controller == null || !widget.enabled || widget.readOnly) return;
    
    final currentValue = widget.controller!.text.trim();
    final currentNum = widget.allowDecimal
        ? double.tryParse(currentValue.isEmpty ? '0' : currentValue)
        : int.tryParse(currentValue.isEmpty ? '0' : currentValue);
    
    final newValue = (currentNum ?? 0) + widget.step;
    
    // Check max constraint
    if (widget.max != null && newValue > widget.max!) {
      return;
    }
    
    final newValueString = widget.allowDecimal
        ? newValue.toString()
        : newValue.toInt().toString();
    
    widget.controller!.text = newValueString;
    widget.onChanged?.call(newValueString);
    // Update button states
    if (mounted) setState(() {});
  }

  void _decrement() {
    if (widget.controller == null || !widget.enabled || widget.readOnly) return;
    
    final currentValue = widget.controller!.text.trim();
    final currentNum = widget.allowDecimal
        ? double.tryParse(currentValue.isEmpty ? '0' : currentValue)
        : int.tryParse(currentValue.isEmpty ? '0' : currentValue);
    
    final newValue = (currentNum ?? 0) - widget.step;
    
    // Check min constraint
    if (widget.min != null && newValue < widget.min!) {
      return;
    }
    
    // Check negative constraint
    if (!widget.allowNegative && newValue < 0) {
      return;
    }
    
    final newValueString = widget.allowDecimal
        ? newValue.toString()
        : newValue.toInt().toString();
    
    widget.controller!.text = newValueString;
    widget.onChanged?.call(newValueString);
    // Update button states
    if (mounted) setState(() {});
  }

  bool get _canIncrement {
    if (!widget.enabled || widget.readOnly || widget.controller == null) return false;
    final currentValue = widget.controller!.text.trim();
    final currentNum = widget.allowDecimal
        ? double.tryParse(currentValue.isEmpty ? '0' : currentValue)
        : int.tryParse(currentValue.isEmpty ? '0' : currentValue);
    final newValue = (currentNum ?? 0) + widget.step;
    return widget.max == null || newValue <= widget.max!;
  }

  bool get _canDecrement {
    if (!widget.enabled || widget.readOnly || widget.controller == null) return false;
    final currentValue = widget.controller!.text.trim();
    final currentNum = widget.allowDecimal
        ? double.tryParse(currentValue.isEmpty ? '0' : currentValue)
        : int.tryParse(currentValue.isEmpty ? '0' : currentValue);
    final newValue = (currentNum ?? 0) - widget.step;
    if (widget.min != null && newValue < widget.min!) return false;
    if (!widget.allowNegative && newValue < 0) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build input formatters based on options
    final List<TextInputFormatter> inputFormatters = [];
    
    if (widget.allowDecimal && !widget.allowNegative) {
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')));
    } else if (!widget.allowDecimal && !widget.allowNegative) {
      inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (widget.allowDecimal && widget.allowNegative) {
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9.]*')));
    } else {
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*')));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: Constants.textSize,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.allowDecimal
              ? TextInputType.numberWithOptions(
                  decimal: true,
                  signed: widget.allowNegative,
                )
              : TextInputType.number,
          inputFormatters: inputFormatters,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: (value) {
            widget.onChanged?.call(value);
            // Update state to enable/disable buttons based on constraints
            if (mounted) setState(() {});
          },
          onEditingComplete: () {
            // When user finishes editing, set to 0 if empty
            if (widget.controller != null && widget.controller!.text.trim().isEmpty) {
              widget.controller!.text = '0';
              widget.onChanged?.call('0');
              if (mounted) setState(() {});
            }
          },
          onSaved: widget.onSaved,
          validator: (value) {
            // First run custom validator if provided
            final customValidation = widget.validator?.call(value);
            if (customValidation != null) return customValidation;

            // Then check if empty
            if (value == null || value.trim().isEmpty) {
              return null; // Allow empty if no value required
            }

            // Parse the number
            num? number;
            if (widget.allowDecimal) {
              number = double.tryParse(value.trim());
            } else {
              number = int.tryParse(value.trim());
            }

            // Check if valid number
            if (number == null) {
              return 'Please enter a valid number';
            }

            // Check min/max constraints
            if (widget.min != null && number < widget.min!) {
              return 'Value must be at least ${widget.min}';
            }
            if (widget.max != null && number > widget.max!) {
              return 'Value must be at most ${widget.max}';
            }

            return null;
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: Constants.textSize,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    size: Constants.iconsSize,
                  )
                : null,
            suffixIcon: widget.showIncrementButtons && !widget.readOnly
                ? Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _canIncrement ? _increment : null,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                          ),
                          child: Container(
                            width: 32,
                            height: 20,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              size: 18,
                              color: _canIncrement
                                  ? Constants.primaryColor
                                  : theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 1,
                          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                        InkWell(
                          onTap: _canDecrement ? _decrement : null,
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(12),
                          ),
                          child: Container(
                            width: 32,
                            height: 20,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: _canDecrement
                                  ? Constants.primaryColor
                                  : theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
            filled: true,
            fillColor: widget.fillColor ??
                (isDark
                    ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
                    : Constants.veryLightGreyColor),
            contentPadding: widget.contentPadding ??
                EdgeInsets.only(
                  left: 16,
                  right: widget.showIncrementButtons && !widget.readOnly ? 48 : 16,
                  top: 16,
                  bottom: 16,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? 12,
              ),
              borderSide: BorderSide(
                color: widget.borderColor ?? Constants.primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? 12,
              ),
              borderSide: BorderSide(
                color: widget.borderColor ?? Constants.primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? 12,
              ),
              borderSide: BorderSide(
                color: widget.focusedBorderColor ?? Constants.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? 12,
              ),
              borderSide: const BorderSide(
                color: Constants.dangerColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? 12,
              ),
              borderSide: const BorderSide(
                color: Constants.dangerColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? 12,
              ),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1.5,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: Constants.textSize,
            color: widget.enabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

