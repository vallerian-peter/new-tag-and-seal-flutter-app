import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabledBgColor;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.isEnabledBgColor = true,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 10),
        child: InkWell(
          onTap: onPressed ?? () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If no route to pop, try to go to home or close app
              print('No route to pop, navigation stack is empty');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isEnabledBgColor 
                  ? (backgroundColor ?? Colors.black.withOpacity(0.3))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isEnabledBgColor 
                  ? Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    )
                  : null,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: iconColor ?? Colors.white,
              size: iconSize ?? 23,
            ),
          ),
        ),
      ),
    );
  }
}
