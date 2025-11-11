import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.width,
});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: AbsorbPointer(
      absorbing: isLoading,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color ?? Constants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
          child: Text(
          text, 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool isLoading;
  final double? width;
  final Color? textColor;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.isLoading = false,
    this.width,
    this.textColor,
});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: AbsorbPointer(
      absorbing: isLoading,
      child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(  
        elevation: 0,
        side: BorderSide(color: color ?? Constants.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
          child: Text(
        text, 
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor ?? color ??  Constants.primaryColor,
            ),
          ),
      ),
      ),
    );
  }
}