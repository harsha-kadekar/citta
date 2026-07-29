import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/app_theme_mode.dart';

void main() {
  group('AppThemeMode.toStorageString', () {
    test('dark serializes to "dark"', () {
      expect(AppThemeMode.dark.toStorageString(), equals('dark'));
    });

    test('light serializes to "light"', () {
      expect(AppThemeMode.light.toStorageString(), equals('light'));
    });

    test('system serializes to "system"', () {
      expect(AppThemeMode.system.toStorageString(), equals('system'));
    });
  });

  group('AppThemeModeStorage.fromStorageString', () {
    test('"dark" parses to AppThemeMode.dark', () {
      expect(AppThemeModeStorage.fromStorageString('dark'),
          equals(AppThemeMode.dark));
    });

    test('"light" parses to AppThemeMode.light', () {
      expect(AppThemeModeStorage.fromStorageString('light'),
          equals(AppThemeMode.light));
    });

    test('"system" parses to AppThemeMode.system', () {
      expect(AppThemeModeStorage.fromStorageString('system'),
          equals(AppThemeMode.system));
    });

    test('null falls back to AppThemeMode.dark by default', () {
      expect(AppThemeModeStorage.fromStorageString(null),
          equals(AppThemeMode.dark));
    });

    test('unrecognized value falls back to AppThemeMode.dark by default', () {
      expect(AppThemeModeStorage.fromStorageString('sepia'),
          equals(AppThemeMode.dark));
    });
  });

  group('AppThemeMode round-trip', () {
    test('every value survives toStorageString -> fromStorageString', () {
      for (final mode in AppThemeMode.values) {
        expect(
            AppThemeModeStorage.fromStorageString(mode.toStorageString()),
            equals(mode));
      }
    });
  });
}
