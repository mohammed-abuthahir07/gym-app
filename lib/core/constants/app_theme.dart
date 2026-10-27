import 'package:flutter/material.dart';

class CustomThemeData {
  final ThemeMode themeMode;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color navBarColor;
  final Color cardBorder;

  const CustomThemeData({
    this.themeMode = ThemeMode.dark,
    this.primary = const Color(0xFFE50914), // Gym Red
    this.secondary = const Color(0xFF1E1E2C),
    this.accent = const Color(0xFFFF5722),
    this.background = const Color(0xFF121212),
    this.surface = const Color(0xFF1E1E1E),
    this.textPrimary = const Color(0xFFFFFFFF),
    this.textSecondary = const Color(0xFFAAAAAA),
    this.buttonColor = const Color(0xFFE50914),
    this.buttonTextColor = Colors.white,
    this.navBarColor = const Color(0xFF1E1E1E),
    this.cardBorder = const Color(0xFF333333),
  });

  static const CustomThemeData darkDefault = CustomThemeData();

  static const CustomThemeData lightDefault = CustomThemeData(
    themeMode: ThemeMode.light,
    primary: Color(0xFFE50914),
    secondary: Color(0xFFF1F5F9),
    accent: Color(0xFFFF5722),
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF64748B),
    buttonColor: Color(0xFFE50914),
    buttonTextColor: Colors.white,
    navBarColor: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE2E8F0),
  );

  CustomThemeData copyWith({
    ThemeMode? themeMode,
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
    return CustomThemeData(
      themeMode: themeMode ?? this.themeMode,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      navBarColor: navBarColor ?? this.navBarColor,
      cardBorder: cardBorder ?? this.cardBorder,
    );
  }

  Map<String, int> toMap() {
    return {
      'mode': themeMode.index,
      'primary': primary.toARGB32(),
      'secondary': secondary.toARGB32(),
      'accent': accent.toARGB32(),
      'background': background.toARGB32(),
      'surface': surface.toARGB32(),
      'textPrimary': textPrimary.toARGB32(),
      'textSecondary': textSecondary.toARGB32(),
      'buttonColor': buttonColor.toARGB32(),
      'buttonTextColor': buttonTextColor.toARGB32(),
      'navBarColor': navBarColor.toARGB32(),
      'cardBorder': cardBorder.toARGB32(),
    };
  }

  factory CustomThemeData.fromMap(Map<String, dynamic> map) {
    return CustomThemeData(
      themeMode: ThemeMode.values[(map['mode'] as int?) ?? 2],
      primary: Color(map['primary'] as int? ?? 0xFFE50914),
      secondary: Color(map['secondary'] as int? ?? 0xFF1E1E2C),
      accent: Color(map['accent'] as int? ?? 0xFFFF5722),
      background: Color(map['background'] as int? ?? 0xFF121212),
      surface: Color(map['surface'] as int? ?? 0xFF1E1E1E),
      textPrimary: Color(map['textPrimary'] as int? ?? 0xFFFFFFFF),
      textSecondary: Color(map['textSecondary'] as int? ?? 0xFFAAAAAA),
      buttonColor: Color(map['buttonColor'] as int? ?? 0xFFE50914),
      buttonTextColor: Color(map['buttonTextColor'] as int? ?? 0xFFFFFFFF),
      navBarColor: Color(map['navBarColor'] as int? ?? 0xFF1E1E1E),
      cardBorder: Color(map['cardBorder'] as int? ?? 0xFF333333),
    );
  }
}

class AppTheme {
  static ThemeData buildTheme(CustomThemeData custom) {
    final isDark = custom.themeMode == ThemeMode.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: custom.primary,
      scaffoldBackgroundColor: custom.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: custom.primary,
        onPrimary: custom.buttonTextColor,
        secondary: custom.secondary,
        onSecondary: custom.textPrimary,
        error: const Color(0xFFF44336),
        onError: Colors.white,
        surface: custom.surface,
        onSurface: custom.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: custom.surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: custom.textPrimary),
        titleTextStyle: TextStyle(
          color: custom.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: custom.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: custom.cardBorder, width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: custom.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: custom.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: custom.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: custom.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF44336)),
        ),
        labelStyle: TextStyle(color: custom.textSecondary),
        hintStyle: TextStyle(
          color: custom.textSecondary.withValues(alpha: 0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: custom.buttonColor,
          foregroundColor: custom.buttonTextColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: custom.primary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: custom.navBarColor,
        indicatorColor: custom.primary.withValues(alpha: 0.2),
      ),
      dividerTheme: DividerThemeData(color: custom.cardBorder, thickness: 1),
    );
  }
}
