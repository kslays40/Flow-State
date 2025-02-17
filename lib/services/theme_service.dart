import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

// Theme Service (for managing theme mode using Hive)
class ThemeService {
  static late Box _themeBox;

  static Future<void> init() async {
    _themeBox = await Hive.openBox('theme');
  }

  static ThemeMode get currentThemeMode {
    final isDarkMode = _themeBox.get('isDarkMode', defaultValue: false);
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme() async {
    final isDarkMode = _themeBox.get('isDarkMode', defaultValue: false);
    await _themeBox.put('isDarkMode', !isDarkMode);
  }
}