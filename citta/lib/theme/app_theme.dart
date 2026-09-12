import 'package:flutter/material.dart';
import '../models/app_theme_mode.dart';
import 'app_palette.dart';

class AppColors {
  // Earthy, calm palette (light mode)
  static const Color primary = Color(0xFF5B7553); // Sage green
  static const Color primaryLight = Color(0xFF8AAF7E);
  static const Color primaryDark = Color(0xFF3D5237);
  static const Color secondary = Color(0xFFC4956A); // Warm terracotta
  static const Color secondaryLight = Color(0xFFDEB896);
  static const Color accent = Color(0xFF9B8E7E); // Muted brown
  static const Color tertiary = Color(0xFFE8834A); // Fire orange (streaks)
  static const Color onTertiary = Colors.white;
  static const Color background = Color(0xFFF7F4F0); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EBE5);
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFA0A0A0);
  static const Color divider = Color(0xFFE5E0DA);
  static const Color error = Color(0xFFB85450);
  static const Color cardShadow = Color(0x0F000000);
}

class DarkAppColors {
  static const Color primary = Color(0xFF8AAF7E); // Lighter sage green
  static const Color primaryLight = Color(0xFFA8C99E);
  static const Color primaryDark = Color(0xFF5B7553);
  static const Color secondary = Color(0xFFDEB896); // Lighter terracotta
  static const Color secondaryLight = Color(0xFFC4956A);
  static const Color accent = Color(0xFFB8A898); // Lighter muted brown
  static const Color tertiary = Color(0xFFEFA880); // Lighter fire orange (streaks)
  static const Color onTertiary = Colors.black;
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color surfaceVariant = Color(0xFF333333);
  static const Color textPrimary = Color(0xFFE8E4E0);
  static const Color textSecondary = Color(0xFFB0ACA8);
  static const Color textHint = Color(0xFF787470);
  static const Color divider = Color(0xFF3D3D3D);
  static const Color error = Color(0xFFCF6B67);
  static const Color cardShadow = Color(0x30000000);
}

/// The subset of [AppColors]/[DarkAppColors] that has no equivalent in
/// [ColorScheme] and would otherwise need manual brightness branching at
/// every call site.
class AdaptiveColors {
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color cardShadow;
  final Color accent;

  const AdaptiveColors({
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.cardShadow,
    required this.accent,
  });

  static const light = AdaptiveColors(
    surfaceVariant: AppColors.surfaceVariant,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textHint: AppColors.textHint,
    cardShadow: AppColors.cardShadow,
    accent: AppColors.accent,
  );

  static const dark = AdaptiveColors(
    surfaceVariant: DarkAppColors.surfaceVariant,
    textPrimary: DarkAppColors.textPrimary,
    textSecondary: DarkAppColors.textSecondary,
    textHint: DarkAppColors.textHint,
    cardShadow: DarkAppColors.cardShadow,
    accent: DarkAppColors.accent,
  );
}

extension AdaptiveColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  AdaptiveColors get adaptiveColors =>
      isDarkMode ? AdaptiveColors.dark : AdaptiveColors.light;
}

class AppTheme {
  static ThemeData lightTheme([AppPalette palette = AppPalette.sage]) {
    return _themeFor(palette.definition.light, Brightness.light);
  }

  static ThemeData darkTheme([AppPalette palette = AppPalette.sage]) {
    return _themeFor(palette.definition.dark, Brightness.dark);
  }

  static ThemeData _themeFor(PaletteColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors.toColorScheme(brightness),
      dividerColor: colors.divider,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 1,
        shadowColor: colors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: colors.textHint),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: colors.primaryLight.withValues(alpha: 0.3),
        labelStyle: TextStyle(fontSize: 13, color: colors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colors.textHint,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static ThemeMode themeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
