import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  ThemeData _themeData = lightTheme;
  bool _isInitialized = false;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkTheme;
  bool get isInitialized => _isInitialized;

  /// Initialize theme from SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeData = isDark ? darkTheme : lightTheme;
    _isInitialized = true;
    notifyListeners();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    _themeData = _themeData == lightTheme ? darkTheme : lightTheme;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeData == darkTheme);
    
    notifyListeners();
  }

  /// Set specific theme
  Future<void> setTheme(bool isDark) async {
    _themeData = isDark ? darkTheme : lightTheme;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
    
    notifyListeners();
  }

  /// Reset to default theme (light)
  Future<void> resetTheme() async {
    _themeData = lightTheme;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, false);
    
    notifyListeners();
  }
}
