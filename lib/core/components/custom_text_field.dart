import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

/// A customizable text field with prefix icon support and password visibility toggle
/// 
/// Usage Examples:
/// 
/// 1. Email field with icon:
/// ```dart
/// CustomTextField(
///   label: 'Email',
///   hintText: 'example@email.com',
///   prefixIcon: Icons.email_outlined,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
/// 
/// 2. Password field with eye icon:
/// ```dart
/// CustomTextField(
///   label: 'Password',
///   hintText: 'Enter password',
///   prefixIcon: Icons.lock_outline,
///   isPassword: true,
/// )
/// ```
/// 
/// 3. Field without prefix icon:
/// ```dart
/// CustomTextField(
///   label: 'Name',
///   hintText: 'Enter your name',
/// )
/// ```
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.contentPadding,
    this.onTap,
    this.inputFormatters,
    this.prefixText,
    this.suffixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword ? _obscureText : false,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onSaved: widget.onSaved,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          style: TextStyle(
            fontSize: Constants.textSize,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontSize: Constants.textSize,
            ),
            filled: true,
            fillColor: widget.fillColor ?? Constants.veryLightGreyColor,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused 
                        ? (widget.focusedBorderColor ?? Constants.primaryColor)
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                    size: Constants.iconsSize,
                  )
                : null,
            prefixText: widget.prefixText,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      size: Constants.iconsSize,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              borderSide: BorderSide(
                color: widget.borderColor ?? Constants.primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              borderSide: BorderSide(
                color: widget.borderColor ?? Constants.primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              borderSide: BorderSide(
                color: widget.focusedBorderColor ?? Constants.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              borderSide: const BorderSide(
                color: Constants.dangerColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              borderSide: const BorderSide(
                color: Constants.dangerColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A simple text field without icons for clean, minimal designs
/// 
/// Usage Examples:
/// 
/// 1. Basic text input:
/// ```dart
/// SimpleTextField(
///   hintText: 'Enter text...',
/// )
/// ```
/// 
/// 2. Multiline text area:
/// ```dart
/// SimpleTextField(
///   hintText: 'Enter description...',
///   maxLines: 4,
/// )
/// ```
class SimpleTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const SimpleTextField({
    super.key,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      style: TextStyle(
        fontSize: Constants.textSize,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          fontSize: Constants.textSize,
        ),
        filled: true,
        fillColor: fillColor ?? Constants.veryLightGreyColor,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: borderColor ?? Constants.primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: borderColor ?? Constants.primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: focusedBorderColor ?? Constants.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: const BorderSide(
            color: Constants.dangerColor,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: const BorderSide(
            color: Constants.dangerColor,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

