import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/theme/app_palette.dart';
import 'package:citta/theme/app_theme.dart';

/// WCAG 2.x relative luminance / contrast ratio helpers, used to assert each
/// new palette meets reasonable accessibility standards rather than trusting
/// hand-picked hex values.
double _relativeLuminance(Color color) {
  double channel(double c) {
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(color.r);
  final g = channel(color.g);
  final b = channel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a) + 0.05;
  final lb = _relativeLuminance(b) + 0.05;
  return la > lb ? la / lb : lb / la;
}

/// Checks contrast for the color pairs [PaletteColors] actually renders in
/// the app: [AppTheme] draws `onPrimary` text on a `primary`-filled button
/// (elevatedButtonTheme), `textPrimary` body text directly on `surface`/
/// `background`, and `error` as literal text/icon color on `surface` (e.g.
/// history_screen.dart, recovery_key_screen.dart). `secondary` is rendered
/// as a meaningful icon color directly on `surface` (e.g. the pause button
/// in timer_controls.dart) - WCAG 1.4.11 non-text contrast applies there.
/// `tertiary`/`onTertiary` and `onSecondary` are excluded: this app never
/// renders them as an actual on-screen pair (tertiary is a decorative
/// "streak flame" accent, and secondary is never used as a fill).
void _expectAccessibleContrast(PaletteColors colors) {
  expect(_contrastRatio(colors.onPrimary, colors.primary), greaterThanOrEqualTo(4.5),
      reason: 'onPrimary text on a primary-filled button is too low contrast');
  expect(_contrastRatio(colors.textPrimary, colors.surface), greaterThanOrEqualTo(4.5),
      reason: 'body text on surface is too low contrast');
  expect(_contrastRatio(colors.textPrimary, colors.background), greaterThanOrEqualTo(4.5),
      reason: 'body text on background is too low contrast');
  expect(_contrastRatio(colors.error, colors.surface), greaterThanOrEqualTo(4.5),
      reason: 'error text/icon on surface is too low contrast');
  expect(_contrastRatio(colors.secondary, colors.surface), greaterThanOrEqualTo(3.0),
      reason: 'secondary icon color on surface is too low contrast');
}

void main() {
  group('AppPalette', () {
    test('exposes exactly 7 distinct named palettes', () {
      expect(AppPalette.values.length, 7);

      final names = AppPalette.values.map((p) => p.definition.displayName).toSet();
      expect(names.length, 7, reason: 'display names must be distinct');
    });

    test('every palette produces a light ColorScheme with the right brightness', () {
      for (final palette in AppPalette.values) {
        final scheme = palette.definition.light.toColorScheme(Brightness.light);
        expect(scheme.brightness, Brightness.light, reason: '${palette.name} light');
      }
    });

    test('every palette produces a dark ColorScheme with the right brightness', () {
      for (final palette in AppPalette.values) {
        final scheme = palette.definition.dark.toColorScheme(Brightness.dark);
        expect(scheme.brightness, Brightness.dark, reason: '${palette.name} dark');
      }
    });

    test('palettes are pairwise distinct in both light and dark', () {
      for (var i = 0; i < AppPalette.values.length; i++) {
        for (var j = i + 1; j < AppPalette.values.length; j++) {
          final a = AppPalette.values[i];
          final b = AppPalette.values[j];
          final lightA = a.definition.light.toColorScheme(Brightness.light);
          final lightB = b.definition.light.toColorScheme(Brightness.light);
          expect(lightA.primary, isNot(lightB.primary),
              reason: '${a.name} and ${b.name} share a light primary color');

          final darkA = a.definition.dark.toColorScheme(Brightness.dark);
          final darkB = b.definition.dark.toColorScheme(Brightness.dark);
          expect(darkA.primary, isNot(darkB.primary),
              reason: '${a.name} and ${b.name} share a dark primary color');
        }
      }
    });

    // The 6 newly authored palettes must clear a real accessibility bar.
    // `sage` (the pre-existing default, see below) is intentionally excluded
    // here: its colors are frozen exactly as shipped today (some of which
    // pre-date this issue and fall slightly short, e.g. its secondary icon
    // color is ~2.7:1 on white) because changing them would be the very
    // "behavior change for end users" this issue must avoid.
    final newPalettes = AppPalette.values.where((p) => p != AppPalette.sage);

    test('every new palette light variant is accessible', () {
      for (final palette in newPalettes) {
        _expectAccessibleContrast(palette.definition.light);
      }
    });

    test('every new palette dark variant is accessible', () {
      for (final palette in newPalettes) {
        _expectAccessibleContrast(palette.definition.dark);
      }
    });

    test('sage palette matches the original hardcoded AppColors exactly', () {
      final light = AppPalette.sage.definition.light.toColorScheme(Brightness.light);
      expect(light.primary, AppColors.primary);
      expect(light.secondary, AppColors.secondary);
      expect(light.tertiary, AppColors.tertiary);
      expect(light.surface, AppColors.surface);
      expect(light.onSurface, AppColors.textPrimary);
      expect(light.error, AppColors.error);

      final dark = AppPalette.sage.definition.dark.toColorScheme(Brightness.dark);
      expect(dark.primary, DarkAppColors.primary);
      expect(dark.secondary, DarkAppColors.secondary);
      expect(dark.tertiary, DarkAppColors.tertiary);
      expect(dark.surface, DarkAppColors.surface);
      expect(dark.onSurface, DarkAppColors.textPrimary);
      expect(dark.error, DarkAppColors.error);
    });
  });

  group('AppPaletteStorage', () {
    test('fromStorageString resolves each palette\'s own stored id', () {
      for (final palette in AppPalette.values) {
        expect(
            AppPaletteStorage.fromStorageString(palette.toStorageString()),
            palette);
      }
    });

    test('fromStorageString falls back to sage for null or unknown ids', () {
      expect(AppPaletteStorage.fromStorageString(null), AppPalette.sage);
      expect(AppPaletteStorage.fromStorageString('not-a-real-palette'),
          AppPalette.sage);
    });

    // Regression test (code review, issue #66): the palette picker persisted
    // ConfigModel.colorPalette but main.dart still always built
    // AppTheme.lightTheme()/darkTheme() with the default sage palette, so a
    // selected palette never actually changed the rendered app. This
    // reconstructs main.dart's resolve-then-build wiring end to end.
    test('a selected palette id resolves to a visibly different theme', () {
      final resolved = AppPaletteStorage.fromStorageString('ocean');
      final theme = AppTheme.lightTheme(resolved);
      expect(theme.colorScheme.primary, AppPalette.ocean.definition.light.primary);
      expect(theme.colorScheme.primary, isNot(AppPalette.sage.definition.light.primary));
    });
  });

  group('AppTheme parameterized by palette', () {
    test('lightTheme()/darkTheme() default to the sage palette unchanged', () {
      final light = AppTheme.lightTheme();
      expect(light.colorScheme.primary, AppColors.primary);
      expect(light.dividerColor, AppColors.divider);

      final dark = AppTheme.darkTheme();
      expect(dark.colorScheme.primary, DarkAppColors.primary);
      expect(dark.dividerColor, DarkAppColors.divider);
    });

    test('lightTheme(palette)/darkTheme(palette) reflect the given palette', () {
      final light = AppTheme.lightTheme(AppPalette.ocean);
      final expectedLight = AppPalette.ocean.definition.light;
      expect(light.colorScheme.primary, expectedLight.primary);
      expect(light.dividerColor, expectedLight.divider);
      expect(light.brightness, Brightness.light);

      final dark = AppTheme.darkTheme(AppPalette.ocean);
      final expectedDark = AppPalette.ocean.definition.dark;
      expect(dark.colorScheme.primary, expectedDark.primary);
      expect(dark.dividerColor, expectedDark.divider);
      expect(dark.brightness, Brightness.dark);
    });
  });
}
