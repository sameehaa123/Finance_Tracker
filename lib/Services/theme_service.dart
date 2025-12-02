// lib/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ValueNotifier<bool> isDark = ValueNotifier<bool>(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getBool('isDarkTheme') ?? false;
  }

  static Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = !isDark.value;
    await prefs.setBool('isDarkTheme', isDark.value);
  }

  static Future<void> setDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = value;
    await prefs.setBool('isDarkTheme', value);
  }
}
