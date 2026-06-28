import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/config_model.dart';

void main() {
  group('ConfigModel.copyWith list-reference stability', () {
    test('copyWith preserves tags reference when tags not changed', () {
      final config = ConfigModel(tags: ['calm', 'deep']);
      final updated = config.copyWith(calendarViewEnabled: true);
      expect(
        identical(config.tags, updated.tags),
        isTrue,
        reason: 'context.select() uses reference equality for lists; '
            'creating a new list on every copyWith defeats selective rebuilds',
      );
    });

    test('copyWith preserves quoteSources reference when quoteSources not changed', () {
      final config = ConfigModel();
      final updated = config.copyWith(themeMode: 'light');
      expect(
        identical(config.quoteSources, updated.quoteSources),
        isTrue,
        reason: 'same as tags — preserve reference to avoid spurious rebuilds',
      );
    });

    test('copyWith replaces tags reference when tags explicitly provided', () {
      final config = ConfigModel(tags: ['calm']);
      final newTags = ['calm', 'deep'];
      final updated = config.copyWith(tags: newTags);
      expect(
        identical(config.tags, updated.tags),
        isFalse,
        reason: 'when tags are explicitly updated, a new list must be used',
      );
      expect(updated.tags, equals(['calm', 'deep']));
    });
  });

  group('ConfigModel.copyWith nullable field clearing', () {
    test('copyWith(backgroundMusic: null) clears an existing value', () {
      final config = ConfigModel(backgroundMusic: '/music/track.mp3');
      final updated = config.copyWith(backgroundMusic: null);
      expect(updated.backgroundMusic, isNull,
          reason: 'passing null to a nullable copyWith field must clear it, '
              'not keep the old value via ??');
    });

    test('copyWith() without backgroundMusic preserves existing value', () {
      final config = ConfigModel(backgroundMusic: '/music/track.mp3');
      final updated = config.copyWith(calendarViewEnabled: true);
      expect(updated.backgroundMusic, equals('/music/track.mp3'));
    });

    test('copyWith(userName: null) clears an existing value', () {
      final config = ConfigModel(userName: 'Alice');
      final updated = config.copyWith(userName: null);
      expect(updated.userName, isNull,
          reason: 'passing null to userName must clear it');
    });

    test('copyWith() without userName preserves existing value', () {
      final config = ConfigModel(userName: 'Alice');
      final updated = config.copyWith(calendarViewEnabled: true);
      expect(updated.userName, equals('Alice'));
    });
  });

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
