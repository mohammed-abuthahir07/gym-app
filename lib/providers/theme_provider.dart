import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'custom_theme_settings_v1';
  CustomThemeData _themeData = CustomThemeData.darkDefault;

  CustomThemeData get customTheme => _themeData;
  ThemeData get currentTheme => AppTheme.buildTheme(_themeData);
  ThemeMode get themeMode => _themeData.themeMode;
  bool get isDarkMode => _themeData.themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefKey);
      if (jsonString != null) {
        final Map<String, dynamic> map = json.decode(jsonString);
        _themeData = CustomThemeData.fromMap(map);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _themeData.toMap();
      await prefs.setString(_prefKey, json.encode(map));
    } catch (_) {}
  }

  void toggleThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.light) {
      _themeData = CustomThemeData.lightDefault.copyWith(
        primary: _themeData.primary,
        accent: _themeData.accent,
      );
    } else {
      _themeData = CustomThemeData.darkDefault.copyWith(
        primary: _themeData.primary,
        accent: _themeData.accent,
      );
    }
    notifyListeners();
    _saveToPreferences();
  }

  void updateColor({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? buttonColor,
    Color? buttonTextColor,
    Color? navBarColor,
    Color? cardBorder,
  }) {
    _themeData = _themeData.copyWith(
      primary: primary,
      secondary: secondary,
      accent: accent,
      background: background,
      surface: surface,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      buttonColor: buttonColor,
      buttonTextColor: buttonTextColor,
      navBarColor: navBarColor,
      cardBorder: cardBorder,
    );
    notifyListeners();
    _saveToPreferences();
  }

  void applyPreset(String presetName) {
    switch (presetName) {
      case 'Gym Red (Default)':
        _themeData = CustomThemeData.darkDefault;
        break;
      case 'Electric Blue':
        _themeData = const CustomThemeData(
          primary: Color(0xFF0070F3),
          secondary: Color(0xFF1E2638),
          accent: Color(0xFF00DFD8),
          background: Color(0xFF0B0E14),
          surface: Color(0xFF151B26),
          buttonColor: Color(0xFF0070F3),
          buttonTextColor: Colors.white,
          cardBorder: Color(0xFF263348),
        );
        break;
      case 'Emerald Power':
        _themeData = const CustomThemeData(
          primary: Color(0xFF00C853),
          secondary: Color(0xFF1B2E23),
          accent: Color(0xFF69F0AE),
          background: Color(0xFF0C140F),
          surface: Color(0xFF152219),
          buttonColor: Color(0xFF00C853),
          buttonTextColor: Colors.black,
          cardBorder: Color(0xFF243B2C),
        );
        break;
      case 'Gold Championship':
        _themeData = const CustomThemeData(
          primary: Color(0xFFFFB300),
          secondary: Color(0xFF2B2516),
          accent: Color(0xFFFFD54F),
          background: Color(0xFF12100C),
          surface: Color(0xFF1E1A14),
          buttonColor: Color(0xFFFFB300),
          buttonTextColor: Colors.black,
          cardBorder: Color(0xFF383020),
        );
        break;
      case 'Clean Light':
        _themeData = CustomThemeData.lightDefault;
        break;
    }
    notifyListeners();
    _saveToPreferences();
  }

  Future<void> resetToDefault() async {
    _themeData = CustomThemeData.darkDefault;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
