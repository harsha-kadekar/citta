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

  group('ConfigModel list immutability', () {
    test('tags list is unmodifiable after construction — add throws', () {
      final config = ConfigModel(tags: ['calm']);
      expect(
        () => config.tags.add('deep'),
        throwsUnsupportedError,
        reason: 'tags must be unmodifiable so callers cannot bypass copyWith',
      );
    });

    test('tags list is unmodifiable after construction — remove throws', () {
      final config = ConfigModel(tags: ['calm', 'deep']);
      expect(
        () => config.tags.remove('calm'),
        throwsUnsupportedError,
      );
    });

    test('quoteSources list is unmodifiable after construction — add throws', () {
      final config = ConfigModel();
      expect(
        () => config.quoteSources.add('new_source'),
        throwsUnsupportedError,
        reason: 'quoteSources must be unmodifiable so callers cannot bypass copyWith',
      );
    });

    test('tags list from copyWith is unmodifiable — add throws', () {
      final config = ConfigModel(tags: ['calm']);
      final updated = config.copyWith(tags: ['calm', 'deep']);
      expect(
        () => updated.tags.add('extra'),
        throwsUnsupportedError,
        reason: 'tags returned by copyWith must also be unmodifiable',
      );
    });

    test('quoteSources list from copyWith is unmodifiable — add throws', () {
      final config = ConfigModel();
      final updated = config.copyWith(quoteSources: ['subhashita']);
      expect(
        () => updated.quoteSources.add('extra'),
        throwsUnsupportedError,
      );
    });
  });

  group('ConfigModel default-constructor list reference identity', () {
    test('ConfigModel() tags is identical to defaultTags const', () {
      final config = ConfigModel();
      expect(
        identical(config.tags, ConfigModel.defaultTags),
        isTrue,
        reason: 'no-arg constructor must reuse the const reference so that two '
            'default ConfigModels produced by loadConfig() share the same '
            'tags object and context.select() does not fire spuriously',
      );
    });

    test('ConfigModel() quoteSources is identical to defaultQuoteSources const', () {
      final config = ConfigModel();
      expect(
        identical(config.quoteSources, ConfigModel.defaultQuoteSources),
        isTrue,
        reason: 'same rationale as tags — preserve the const reference',
      );
    });

    test('two consecutive ConfigModel() instances share the same tags reference', () {
      final a = ConfigModel();
      final b = ConfigModel();
      expect(
        identical(a.tags, b.tags),
        isTrue,
        reason: 'repeated no-arg construction must not allocate fresh lists '
            'on every call or context.select will rebuild on every loadConfig',
      );
    });

    test('ConfigModel() then copyWith without tags preserves the const reference', () {
      final config = ConfigModel();
      final updated = config.copyWith(themeMode: 'light');
      expect(
        identical(updated.tags, ConfigModel.defaultTags),
        isTrue,
        reason: 'copyWith already preserves this.tags; the const reference '
            'must flow through correctly',
      );
    });

    test('ConfigModel.fromJson with no tags key preserves defaultTags reference', () {
      final config = ConfigModel.fromJson(<String, dynamic>{});
      expect(
        identical(config.tags, ConfigModel.defaultTags),
        isTrue,
        reason: 'fromJson must not allocate a fresh list when the tags key '
            'is absent — this is the most common cold-start path',
      );
    });
  });

  group('ConfigModel.sanitizeForDevice', () {
    test('replaces custom: bellStart with default', () {
      final config = ConfigModel(bellStart: 'custom:/storage/bell.mp3');
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.bellStart, ConfigModel.defaultBellStart);
    });

    test('replaces custom: bellEnd with default', () {
      final config = ConfigModel(bellEnd: 'custom:/storage/bell.mp3');
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.bellEnd, ConfigModel.defaultBellEnd);
    });

    test('replaces custom: bellInterval with default', () {
      final config = ConfigModel(bellInterval: 'custom:/storage/bell.mp3');
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.bellInterval, ConfigModel.defaultBellInterval);
    });

    test('preserves bundled: bell paths unchanged', () {
      final config = ConfigModel(
        bellStart: 'bundled:bright_tibetan_bell',
        bellEnd: 'bundled:bell_meditation',
        bellInterval: 'bundled:singing_bell',
      );
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.bellStart, 'bundled:bright_tibetan_bell');
      expect(sanitized.bellEnd, 'bundled:bell_meditation');
      expect(sanitized.bellInterval, 'bundled:singing_bell');
    });

    test('always clears backgroundMusic regardless of value', () {
      final config = ConfigModel(backgroundMusic: '/storage/music.mp3');
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.backgroundMusic, isNull,
          reason: 'file paths from a different device are never valid here');
    });

    test('clears backgroundMusic even when already null', () {
      final config = ConfigModel();
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.backgroundMusic, isNull);
    });

    test('preserves all non-audio fields unchanged', () {
      final config = ConfigModel(
        timerMode: 'stopwatch',
        countdownDuration: 600,
        userName: 'Alice',
        themeMode: 'light',
        language: 'kn',
        tags: ['calm', 'deep'],
        calendarViewEnabled: true,
      );
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.timerMode, 'stopwatch');
      expect(sanitized.countdownDuration, 600);
      expect(sanitized.userName, 'Alice');
      expect(sanitized.themeMode, 'light');
      expect(sanitized.language, 'kn');
      expect(sanitized.tags, ['calm', 'deep']);
      expect(sanitized.calendarViewEnabled, isTrue);
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
