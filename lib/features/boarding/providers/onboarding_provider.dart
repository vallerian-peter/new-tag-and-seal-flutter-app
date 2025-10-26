import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class OnboardingProvider extends ChangeNotifier {
  final LiquidController _liquidController = LiquidController();
  int _currentPage = 0;

  LiquidController get liquidController => _liquidController;
  int get currentPage => _currentPage;

  /// Update current page index
  void onPageChanged(int activePageIndex) {
    _currentPage = activePageIndex;
    notifyListeners();
  }

  /// Animate to next slide
  void animateToNextSlide() {
    int nextPage = _currentPage + 1;
    _liquidController.animateToPage(page: nextPage);
  }

  /// Skip to last page
  void skipToLast(int totalPages) {
    _liquidController.jumpToPage(page: totalPages - 1);
  }

  /// Dispose controller
  @override
  void dispose() {
    // LiquidController doesn't have dispose method
    super.dispose();
  }
}

