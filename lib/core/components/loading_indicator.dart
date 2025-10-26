import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;
  final double? strokeWidth;
  const LoadingIndicator({super.key, this.color, this.size = 35, this.strokeWidth});

  @override 
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? Constants.primaryColor,
        strokeWidth: strokeWidth ?? 1.2,
      ),
    );
  }
}