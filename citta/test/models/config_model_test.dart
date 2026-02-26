import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/config_model.dart';

void main() {
  group('ConfigModel language field', () {
    test('default language is system', () {
      final config = ConfigModel();
      expect(config.language, equals('system'));
    });

    test('language serializes to JSON correctly', () {
      final config = ConfigModel(language: 'kn');
      final json = config.toJson();
      expect(json['language'], equals('kn'));
    });

    test('language deserializes from JSON correctly', () {
      final json = {'language': 'hi'};
      final config = ConfigModel.fromJson(json);
      expect(config.language, equals('hi'));
    });

    test('missing language key in JSON falls back to system', () {
      final json = <String, dynamic>{};
      final config = ConfigModel.fromJson(json);
      expect(config.language, equals('system'));
    });

    test('copyWith language works correctly', () {
      final config = ConfigModel();
      final updated = config.copyWith(language: 'kn');
      expect(updated.language, equals('kn'));
      expect(config.language, equals('system')); // original unchanged
    });

    test('copyWith without language preserves existing value', () {
      final config = ConfigModel(language: 'fr');
      final updated = config.copyWith(themeMode: 'light');
      expect(updated.language, equals('fr'));
    });

    test('all 12 language codes round-trip through JSON', () {
      const codes = ['en', 'hi', 'kn', 'sa', 'te', 'ta', 'ml', 'fr', 'de', 'ja', 'he', 'zh'];
      for (final code in codes) {
        final config = ConfigModel(language: code);
        final json = config.toJson();
        final restored = ConfigModel.fromJson(json);
        expect(restored.language, equals(code),
            reason: 'Code $code did not round-trip correctly');
      }
    });

    test('system language code round-trips through JSON', () {
      final config = ConfigModel(language: 'system');
      final json = config.toJson();
      final restored = ConfigModel.fromJson(json);
      expect(restored.language, equals('system'));
    });
  });
}
