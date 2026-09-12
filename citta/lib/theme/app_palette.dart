import 'package:flutter/material.dart';

import 'app_theme.dart';

/// The full set of raw colors needed to build one brightness variant
/// (light or dark) of a [AppPaletteDefinition].
class PaletteColors {
  final Color primary;
  final Color onPrimary;
  final Color primaryLight;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;
  final Color onTertiary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color error;
  final Color onError;
  final Color cardShadow;

  const PaletteColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryLight,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.error,
    required this.onError,
    required this.cardShadow,
  });

  ColorScheme toColorScheme(Brightness brightness) {
    return brightness == Brightness.light
        ? ColorScheme.light(
            primary: primary,
            onPrimary: onPrimary,
            secondary: secondary,
            onSecondary: onSecondary,
            tertiary: tertiary,
            onTertiary: onTertiary,
            surface: surface,
            onSurface: textPrimary,
            error: error,
            onError: onError,
          )
        : ColorScheme.dark(
            primary: primary,
            onPrimary: onPrimary,
            secondary: secondary,
            onSecondary: onSecondary,
            tertiary: tertiary,
            onTertiary: onTertiary,
            surface: surface,
            onSurface: textPrimary,
            error: error,
            onError: onError,
          );
  }
}

/// A named, curated color palette: a light and a dark [PaletteColors] pair
/// that together theme the whole app.
class AppPaletteDefinition {
  final String displayName;
  final PaletteColors light;
  final PaletteColors dark;

  const AppPaletteDefinition({
    required this.displayName,
    required this.light,
    required this.dark,
  });
}

const _sageLight = PaletteColors(
  primary: AppColors.primary,
  onPrimary: Colors.white,
  primaryLight: AppColors.primaryLight,
  secondary: AppColors.secondary,
  onSecondary: Colors.white,
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.onTertiary,
  background: AppColors.background,
  surface: AppColors.surface,
  surfaceVariant: AppColors.surfaceVariant,
  textPrimary: AppColors.textPrimary,
  textSecondary: AppColors.textSecondary,
  textHint: AppColors.textHint,
  divider: AppColors.divider,
  error: AppColors.error,
  onError: Colors.white,
  cardShadow: AppColors.cardShadow,
);

const _sageDark = PaletteColors(
  primary: DarkAppColors.primary,
  onPrimary: Colors.black,
  primaryLight: DarkAppColors.primaryLight,
  secondary: DarkAppColors.secondary,
  onSecondary: Colors.black,
  tertiary: DarkAppColors.tertiary,
  onTertiary: DarkAppColors.onTertiary,
  background: DarkAppColors.background,
  surface: DarkAppColors.surface,
  surfaceVariant: DarkAppColors.surfaceVariant,
  textPrimary: DarkAppColors.textPrimary,
  textSecondary: DarkAppColors.textSecondary,
  textHint: DarkAppColors.textHint,
  divider: DarkAppColors.divider,
  error: DarkAppColors.error,
  onError: Colors.black,
  cardShadow: DarkAppColors.cardShadow,
);

const _oceanLight = PaletteColors(
  primary: Color(0xFF2E6E7E), // Deep teal
  onPrimary: Colors.white,
  primaryLight: Color(0xFF5FA0AF),
  secondary: Color(0xFFB37D33), // Warm amber
  onSecondary: Colors.white,
  tertiary: Color(0xFFE8834A),
  onTertiary: Colors.white,
  background: Color(0xFFF2F7F8),
  surface: Color(0xFFFFFFFF),
  surfaceVariant: Color(0xFFE7EFF1),
  textPrimary: Color(0xFF20302F),
  textSecondary: Color(0xFF5A6E6D),
  textHint: Color(0xFF95A4A3),
  divider: Color(0xFFDCE6E8),
  error: Color(0xFFB3423F),
  onError: Colors.white,
  cardShadow: Color(0x0F000000),
);

const _oceanDark = PaletteColors(
  primary: Color(0xFF6FB4C2),
  onPrimary: Colors.black,
  primaryLight: Color(0xFF98CBD5),
  secondary: Color(0xFFE0AD6E),
  onSecondary: Colors.black,
  tertiary: Color(0xFFEFA880),
  onTertiary: Colors.black,
  background: Color(0xFF141E1F),
  surface: Color(0xFF203031),
  surfaceVariant: Color(0xFF2A3D3E),
  textPrimary: Color(0xFFE3EDEE),
  textSecondary: Color(0xFFAEC0C1),
  textHint: Color(0xFF75898A),
  divider: Color(0xFF3A4F50),
  error: Color(0xFFD98784),
  onError: Colors.black,
  cardShadow: Color(0x30000000),
);

const _lavenderLight = PaletteColors(
  primary: Color(0xFF6E5B9E), // Muted violet
  onPrimary: Colors.white,
  primaryLight: Color(0xFF9C8CC4),
  secondary: Color(0xFFC46E9C), // Soft rose
  onSecondary: Colors.white,
  tertiary: Color(0xFFE8834A),
  onTertiary: Colors.white,
  background: Color(0xFFF7F4FA),
  surface: Color(0xFFFFFFFF),
  surfaceVariant: Color(0xFFEEE8F5),
  textPrimary: Color(0xFF2A2530),
  textSecondary: Color(0xFF6C6472),
  textHint: Color(0xFFA39CAB),
  divider: Color(0xFFE2DAEB),
  error: Color(0xFFB85470),
  onError: Colors.white,
  cardShadow: Color(0x0F000000),
);

const _lavenderDark = PaletteColors(
  primary: Color(0xFFA391CB),
  onPrimary: Colors.black,
  primaryLight: Color(0xFFBFB1DB),
  secondary: Color(0xFFDD9DBC),
  onSecondary: Colors.black,
  tertiary: Color(0xFFEFA880),
  onTertiary: Colors.black,
  background: Color(0xFF1C1922),
  surface: Color(0xFF2A2632),
  surfaceVariant: Color(0xFF34303E),
  textPrimary: Color(0xFFEAE5F0),
  textSecondary: Color(0xFFB6ADBF),
  textHint: Color(0xFF7E7688),
  divider: Color(0xFF3F3A4A),
  error: Color(0xFFD9899E),
  onError: Colors.black,
  cardShadow: Color(0x30000000),
);

const _clayLight = PaletteColors(
  primary: Color(0xFFA6533A), // Burnt clay
  onPrimary: Colors.white,
  primaryLight: Color(0xFFCB8468),
  secondary: Color(0xFF7C8A4E), // Olive
  onSecondary: Colors.white,
  tertiary: Color(0xFFE8834A),
  onTertiary: Colors.white,
  background: Color(0xFFFAF4F0),
  surface: Color(0xFFFFFFFF),
  surfaceVariant: Color(0xFFF1E7DF),
  textPrimary: Color(0xFF302420),
  textSecondary: Color(0xFF725F56),
  textHint: Color(0xFFAB9A90),
  divider: Color(0xFFEADDD3),
  error: Color(0xFFB03B32),
  onError: Colors.white,
  cardShadow: Color(0x0F000000),
);

const _clayDark = PaletteColors(
  primary: Color(0xFFD68F73),
  onPrimary: Colors.black,
  primaryLight: Color(0xFFE3AF99),
  secondary: Color(0xFFA6B378),
  onSecondary: Colors.black,
  tertiary: Color(0xFFEFA880),
  onTertiary: Colors.black,
  background: Color(0xFF211815),
  surface: Color(0xFF302422),
  surfaceVariant: Color(0xFF3D2F2A),
  textPrimary: Color(0xFFF1E5DE),
  textSecondary: Color(0xFFC5B2A8),
  textHint: Color(0xFF8C776C),
  divider: Color(0xFF4A3A34),
  error: Color(0xFFDF9088),
  onError: Colors.black,
  cardShadow: Color(0x30000000),
);

const _slateLight = PaletteColors(
  primary: Color(0xFF4B5D75), // Blue-gray slate
  onPrimary: Colors.white,
  primaryLight: Color(0xFF7C8FA8),
  secondary: Color(0xFFC26955), // Coral
  onSecondary: Colors.white,
  tertiary: Color(0xFFE8834A),
  onTertiary: Colors.white,
  background: Color(0xFFF4F6F8),
  surface: Color(0xFFFFFFFF),
  surfaceVariant: Color(0xFFE7ECF1),
  textPrimary: Color(0xFF23282F),
  textSecondary: Color(0xFF5E6874),
  textHint: Color(0xFF98A1AB),
  divider: Color(0xFFDDE3E9),
  error: Color(0xFFB2453F),
  onError: Colors.white,
  cardShadow: Color(0x0F000000),
);

const _slateDark = PaletteColors(
  primary: Color(0xFF8FA0B6),
  onPrimary: Colors.black,
  primaryLight: Color(0xFFAEBBCB),
  secondary: Color(0xFFDB9585),
  onSecondary: Colors.black,
  tertiary: Color(0xFFEFA880),
  onTertiary: Colors.black,
  background: Color(0xFF181C21),
  surface: Color(0xFF262B32),
  surfaceVariant: Color(0xFF30363E),
  textPrimary: Color(0xFFE7EBEF),
  textSecondary: Color(0xFFAFB8C2),
  textHint: Color(0xFF78828D),
  divider: Color(0xFF3A414A),
  error: Color(0xFFD98884),
  onError: Colors.black,
  cardShadow: Color(0x30000000),
);

const _amberLight = PaletteColors(
  primary: Color(0xFF8F620F), // Golden amber
  onPrimary: Colors.white,
  primaryLight: Color(0xFFCFA24E),
  secondary: Color(0xFF3F7D74), // Deep teal
  onSecondary: Colors.white,
  tertiary: Color(0xFFE8834A),
  onTertiary: Colors.white,
  background: Color(0xFFFBF6EC),
  surface: Color(0xFFFFFFFF),
  surfaceVariant: Color(0xFFF2E9D4),
  textPrimary: Color(0xFF2E2712),
  textSecondary: Color(0xFF6E6247),
  textHint: Color(0xFFA89A78),
  divider: Color(0xFFEBDFBF),
  error: Color(0xFFB2483A),
  onError: Colors.white,
  cardShadow: Color(0x0F000000),
);

const _amberDark = PaletteColors(
  primary: Color(0xFFDBAE55),
  onPrimary: Colors.black,
  primaryLight: Color(0xFFE7C583),
  secondary: Color(0xFF74A79E),
  onSecondary: Colors.black,
  tertiary: Color(0xFFEFA880),
  onTertiary: Colors.black,
  background: Color(0xFF201A0E),
  surface: Color(0xFF2E2818),
  surfaceVariant: Color(0xFF3B331E),
  textPrimary: Color(0xFFF0E7D3),
  textSecondary: Color(0xFFC4B896),
  textHint: Color(0xFF8C7F5D),
  divider: Color(0xFF4A3F27),
  error: Color(0xFFDC9084),
  onError: Colors.black,
  cardShadow: Color(0x30000000),
);

const _forestLight = PaletteColors(
  primary: Color(0xFF2F6B45), // Deep forest green
  onPrimary: Colors.white,
  primaryLight: Color(0xFF64A177),
  secondary: Color(0xFFA88A2E), // Mustard
  onSecondary: Colors.white,
  tertiary: Color(0xFFE8834A),
  onTertiary: Colors.white,
  background: Color(0xFFF3F7F2),
  surface: Color(0xFFFFFFFF),
  surfaceVariant: Color(0xFFE6EFE5),
  textPrimary: Color(0xFF20291F),
  textSecondary: Color(0xFF57685A),
  textHint: Color(0xFF93A594),
  divider: Color(0xFFDCE7DA),
  error: Color(0xFFB04A3F),
  onError: Colors.white,
  cardShadow: Color(0x0F000000),
);

const _forestDark = PaletteColors(
  primary: Color(0xFF74B489),
  onPrimary: Colors.black,
  primaryLight: Color(0xFF9CCBAA),
  secondary: Color(0xFFCBB264),
  onSecondary: Colors.black,
  tertiary: Color(0xFFEFA880),
  onTertiary: Colors.black,
  background: Color(0xFF161C16),
  surface: Color(0xFF232B22),
  surfaceVariant: Color(0xFF2D372B),
  textPrimary: Color(0xFFE5EDE3),
  textSecondary: Color(0xFFAFBFAE),
  textHint: Color(0xFF77897A),
  divider: Color(0xFF3A463A),
  error: Color(0xFFDA8F85),
  onError: Colors.black,
  cardShadow: Color(0x30000000),
);

/// The set of curated, named color palettes the app can be themed with.
///
/// [sage] is today's original (and current default) palette; the other six
/// lay the groundwork for user-selectable theming (see issues #18-#20).
enum AppPalette {
  sage,
  ocean,
  lavender,
  clay,
  slate,
  amber,
  forest;

  AppPaletteDefinition get definition => switch (this) {
        AppPalette.sage => const AppPaletteDefinition(
            displayName: 'Sage',
            light: _sageLight,
            dark: _sageDark,
          ),
        AppPalette.ocean => const AppPaletteDefinition(
            displayName: 'Ocean',
            light: _oceanLight,
            dark: _oceanDark,
          ),
        AppPalette.lavender => const AppPaletteDefinition(
            displayName: 'Lavender',
            light: _lavenderLight,
            dark: _lavenderDark,
          ),
        AppPalette.clay => const AppPaletteDefinition(
            displayName: 'Clay',
            light: _clayLight,
            dark: _clayDark,
          ),
        AppPalette.slate => const AppPaletteDefinition(
            displayName: 'Slate',
            light: _slateLight,
            dark: _slateDark,
          ),
        AppPalette.amber => const AppPaletteDefinition(
            displayName: 'Amber',
            light: _amberLight,
            dark: _amberDark,
          ),
        AppPalette.forest => const AppPaletteDefinition(
            displayName: 'Forest',
            light: _forestLight,
            dark: _forestDark,
          ),
      };
}
