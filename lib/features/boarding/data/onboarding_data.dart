import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/features/boarding/models/onboarding_model.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

class OnboardingData {
  static List<OnboardingModel> getPages() {
    return [
      OnboardingModel(
        title: 'Track Your Livestock',
        subtitle: 'Efficiently manage and track all your livestock with digital tags and real-time monitoring',
        image: 'assets/images/welcome/onboarding1.png',
        bgColor: Constants.primaryColor,
        textColor: Constants.whiteColor,
      ),
      OnboardingModel(
        title: 'Farm Management',
        subtitle: 'Comprehensive farm management system to organize your farms, animals, and operations in one place',
        image: 'assets/images/welcome/onboarding2.png',
        bgColor: const Color(0xFF2196F3),
        textColor: Constants.whiteColor,
      ),
      OnboardingModel(
        title: 'Health & Records',
        subtitle: 'Keep detailed health records, vaccinations, and breeding information for better livestock care',
        image: 'assets/images/welcome/onboarding3.png',
        bgColor: const Color(0xFFFF9800),
        textColor: Constants.whiteColor,
      ),
    ];
  }
}

