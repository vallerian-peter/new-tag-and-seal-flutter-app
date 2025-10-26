import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String subtitle;
  final String image;
  final Color bgColor;
  final Color textColor;

  OnboardingModel({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.bgColor,
    this.textColor = Colors.white,
  });
}

