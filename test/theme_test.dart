import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymmanagement/core/constants/app_theme.dart';
import 'package:gymmanagement/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CustomThemeData Unit Tests', () {
    test('default CustomThemeData has gym red colors and dark mode', () {
      const custom = CustomThemeData.darkDefault;
      expect(custom.themeMode, ThemeMode.dark);
      expect(custom.primary, const Color(0xFFE50914));
      expect(custom.surface, const Color(0xFF1E1E1E));
      expect(custom.background, const Color(0xFF121212));
    });

    test('lightDefault CustomThemeData has light mode and clean colors', () {
      const light = CustomThemeData.lightDefault;
      expect(light.themeMode, ThemeMode.light);
      expect(light.background, const Color(0xFFF8F9FA));
      expect(light.surface, const Color(0xFFFFFFFF));
    });

    test('CustomThemeData copyWith updates specified fields correctly', () {
      const custom = CustomThemeData.darkDefault;
      final modified = custom.copyWith(
        themeMode: ThemeMode.light,
        primary: const Color(0xFF0070F3),
      );
      expect(modified.themeMode, ThemeMode.light);
      expect(modified.primary, const Color(0xFF0070F3));
      expect(modified.secondary, custom.secondary);
      expect(modified.background, custom.background);
    });

    test('CustomThemeData toMap and fromMap serialization roundtrip', () {
      const original = CustomThemeData(
        themeMode: ThemeMode.light,
        primary: Color(0xFF112233),
        secondary: Color(0xFF445566),
        accent: Color(0xFF778899),
        background: Color(0xFFAABBCC),
        surface: Color(0xFFDDEEFF),
        textPrimary: Color(0xFF000000),
        textSecondary: Color(0xFF333333),
        buttonColor: Color(0xFF112233),
        buttonTextColor: Color(0xFFFFFFFF),
        navBarColor: Color(0xFFEEEEEE),
        cardBorder: Color(0xFFCCCCCC),
      );

      final map = original.toMap();
      final reconstructed = CustomThemeData.fromMap(map);

      expect(reconstructed.themeMode, ThemeMode.light);
      expect(reconstructed.primary.toARGB32(), original.primary.toARGB32());
      expect(reconstructed.secondary.toARGB32(), original.secondary.toARGB32());
      expect(reconstructed.accent.toARGB32(), original.accent.toARGB32());
      expect(
        reconstructed.background.toARGB32(),
        original.background.toARGB32(),
      );
      expect(reconstructed.surface.toARGB32(), original.surface.toARGB32());
      expect(
        reconstructed.textPrimary.toARGB32(),
        original.textPrimary.toARGB32(),
      );
    });
  });

  group('AppTheme Builder Tests', () {
    test('buildTheme returns valid ThemeData with dark brightness', () {
      const custom = CustomThemeData.darkDefault;
      final themeData = AppTheme.buildTheme(custom);

      expect(themeData.brightness, Brightness.dark);
      expect(themeData.primaryColor, custom.primary);
      expect(themeData.scaffoldBackgroundColor, custom.background);
      expect(themeData.appBarTheme.backgroundColor, custom.surface);
    });

    test('buildTheme returns valid light brightness for lightDefault', () {
      const lightTheme = CustomThemeData.lightDefault;
      final themeData = AppTheme.buildTheme(lightTheme);

      expect(themeData.brightness, Brightness.light);
      expect(themeData.scaffoldBackgroundColor, lightTheme.background);
      expect(themeData.appBarTheme.backgroundColor, lightTheme.surface);
    });
  });

  group('ThemeProvider State & Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'ThemeProvider initializes with darkDefault when no preferences saved',
      () {
        final provider = ThemeProvider();
        expect(provider.isDarkMode, isTrue);
        expect(provider.customTheme.primary, const Color(0xFFE50914));
      },
    );

    test('ThemeProvider toggleThemeMode switches between light and dark', () {
      final provider = ThemeProvider();
      expect(provider.isDarkMode, isTrue);

      provider.toggleThemeMode(ThemeMode.light);
      expect(provider.isDarkMode, isFalse);
      expect(provider.themeMode, ThemeMode.light);

      provider.toggleThemeMode(ThemeMode.dark);
      expect(provider.isDarkMode, isTrue);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('ThemeProvider applyPreset changes theme colors correctly', () {
      final provider = ThemeProvider();

      provider.applyPreset('Electric Blue');
      expect(provider.customTheme.primary, const Color(0xFF0070F3));

      provider.applyPreset('Emerald Power');
      expect(provider.customTheme.primary, const Color(0xFF00C853));

      provider.applyPreset('Gold Championship');
      expect(provider.customTheme.primary, const Color(0xFFFFB300));

      provider.applyPreset('Clean Light');
      expect(provider.isDarkMode, isFalse);
    });

    test('ThemeProvider updateColor updates custom colors', () {
      final provider = ThemeProvider();
      const customColor = Color(0xFF9C27B0); // Purple

      provider.updateColor(primary: customColor);
      expect(provider.customTheme.primary, customColor);
    });

    test(
      'ThemeProvider resetToDefault restores default gym red theme',
      () async {
        final provider = ThemeProvider();

        provider.applyPreset('Emerald Power');
        expect(provider.customTheme.primary, const Color(0xFF00C853));

        await provider.resetToDefault();
        expect(provider.customTheme.primary, const Color(0xFFE50914));
        expect(provider.isDarkMode, isTrue);
      },
    );
  });
}
