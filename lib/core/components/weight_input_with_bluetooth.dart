import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';
import 'package:new_tag_and_seal_flutter_app/core/components/bluetooth_weight_bottom_sheet.dart';
import 'package:icons_plus/icons_plus.dart';

/// Reusable Weight Input Component with Bluetooth Support
///
/// Allows manual weight entry or Bluetooth connection to weight devices.
/// Can be used anywhere in the app (livestock registration, weight logs, etc.)
///
/// Usage:
/// ```dart
/// WeightInputWithBluetooth(
///   controller: _weightController,
///   label: 'Weight (kg)',
///   hintText: 'Enter weight or use Bluetooth',
///   validator: (value) {
///     if (value == null || value.isEmpty) return 'Weight required';
///     return null;
///   },
///   onWeightChanged: (weight) {
///     print('Weight: $weight kg');
///   },
/// )
/// ```
class WeightInputWithBluetooth extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<double?>? onWeightChanged;

  const WeightInputWithBluetooth({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.onWeightChanged,
  });

  @override
  State<WeightInputWithBluetooth> createState() => _WeightInputWithBluetoothState();
}

class _WeightInputWithBluetoothState extends State<WeightInputWithBluetooth> {
  
  Future<void> _showBluetoothBottomSheet() async {
    final weight = await BluetoothWeightBottomSheet.show(context);
    
    if (weight != null) {
      setState(() {
        widget.controller.text = weight.toStringAsFixed(2);
        widget.onWeightChanged?.call(weight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark
        ? theme.colorScheme.surface
        : Colors.white;

    return TextFormField(
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        filled: true,
        fillColor: fillColor,
        suffixIcon: Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(
              FontAwesome.bluetooth_brand,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            tooltip: 'Connect Bluetooth Scale', // TODO: Add l10n.connectBluetoothScale
            onPressed: _showBluetoothBottomSheet,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(isDark ? 0.5 : 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(isDark ? 0.5 : 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Constants.dangerColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Constants.dangerColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: widget.validator,
    );
  }
}

