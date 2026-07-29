import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/models/app_theme_mode.dart';
import 'package:citta/models/app_language.dart';
import 'package:citta/models/audio_source.dart';

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
      final updated = config.copyWith(themeMode: AppThemeMode.light);
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
      final config =
          ConfigModel(backgroundMusic: const AudioSource.custom('/music/track.mp3'));
      final updated = config.copyWith(backgroundMusic: null);
      expect(updated.backgroundMusic, isNull,
          reason: 'passing null to a nullable copyWith field must clear it, '
              'not keep the old value via ??');
    });

    test('copyWith() without backgroundMusic preserves existing value', () {
      final config =
          ConfigModel(backgroundMusic: const AudioSource.custom('/music/track.mp3'));
      final updated = config.copyWith(calendarViewEnabled: true);
      expect(updated.backgroundMusic, equals(const AudioSource.custom('/music/track.mp3')));
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
      final updated = config.copyWith(themeMode: AppThemeMode.light);
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
    test('replaces a custom bellStart with the default', () {
      final config = ConfigModel(bellStart: const AudioSource.custom('/storage/bell.mp3'));
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.bellStart, ConfigModel.defaultBellStart);
    });

    test('replaces a custom bellEnd with the default', () {
      final config = ConfigModel(bellEnd: const AudioSource.custom('/storage/bell.mp3'));
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.bellEnd, ConfigModel.defaultBellEnd);
    });

    test('replaces a custom bellInterval with the default', () {
      final config = ConfigModel(bellInterval: const AudioSource.custom('/storage/bell.mp3'));
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.bellInterval, ConfigModel.defaultBellInterval);
    });

    test('preserves bundled bell sources unchanged', () {
      final config = ConfigModel(
        bellStart: const AudioSource.bundled('bright_tibetan_bell'),
        bellEnd: const AudioSource.bundled('bell_meditation'),
        bellInterval: const AudioSource.bundled('singing_bell'),
      );
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.bellStart, const AudioSource.bundled('bright_tibetan_bell'));
      expect(sanitized.bellEnd, const AudioSource.bundled('bell_meditation'));
      expect(sanitized.bellInterval, const AudioSource.bundled('singing_bell'));
    });

    test('always clears backgroundMusic regardless of value', () {
      final config =
          ConfigModel(backgroundMusic: const AudioSource.custom('/storage/music.mp3'));
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
        timerMode: TimerMode.stopwatch,
        countdownDuration: 600,
        userName: 'Alice',
        themeMode: AppThemeMode.light,
        language: AppLanguage.kannada,
        tags: ['calm', 'deep'],
        calendarViewEnabled: true,
      );
      final sanitized = config.sanitizeForDevice();
      expect(sanitized.timerMode, TimerMode.stopwatch);
      expect(sanitized.countdownDuration, 600);
      expect(sanitized.userName, 'Alice');
      expect(sanitized.themeMode, AppThemeMode.light);
      expect(sanitized.language, AppLanguage.kannada);
      expect(sanitized.tags, ['calm', 'deep']);
      expect(sanitized.calendarViewEnabled, isTrue);
    });
  });

  group('ConfigModel default values', () {
    test('default timerMode is TimerMode.countdown', () {
      expect(ConfigModel().timerMode, equals(TimerMode.countdown));
    });

    test('default themeMode is AppThemeMode.dark', () {
      expect(ConfigModel().themeMode, equals(AppThemeMode.dark));
    });

    test('default language is AppLanguage.system', () {
      expect(ConfigModel().language, equals(AppLanguage.system));
    });
  });

  group('ConfigModel enum fields — JSON round trip', () {
    test('timerMode toJson/fromJson round-trips for every value', () {
      for (final mode in TimerMode.values) {
        final config = ConfigModel(timerMode: mode);
        final restored = ConfigModel.fromJson(config.toJson());
        expect(restored.timerMode, equals(mode));
      }
    });

    test('themeMode toJson/fromJson round-trips for every value', () {
      for (final mode in AppThemeMode.values) {
        final config = ConfigModel(themeMode: mode);
        final restored = ConfigModel.fromJson(config.toJson());
        expect(restored.themeMode, equals(mode));
      }
    });

    test('language toJson/fromJson round-trips for every value', () {
      for (final lang in AppLanguage.values) {
        final config = ConfigModel(language: lang);
        final restored = ConfigModel.fromJson(config.toJson());
        expect(restored.language, equals(lang));
      }
    });

    test('bellStart/bellEnd/bellInterval round-trip for bundled and custom sources',
        () {
      final config = ConfigModel(
        bellStart: const AudioSource.bundled('bright_tibetan_bell'),
        bellEnd: const AudioSource.custom('/storage/bell.mp3'),
        bellInterval: AudioSource.none,
      );
      final restored = ConfigModel.fromJson(config.toJson());
      expect(restored.bellStart, const AudioSource.bundled('bright_tibetan_bell'));
      expect(restored.bellEnd, const AudioSource.custom('/storage/bell.mp3'));
      expect(restored.bellInterval, AudioSource.none);
    });

    test('backgroundMusic round-trips when set and stays null when unset', () {
      final withMusic =
          ConfigModel(backgroundMusic: const AudioSource.custom('/music/track.mp3'));
      expect(ConfigModel.fromJson(withMusic.toJson()).backgroundMusic,
          const AudioSource.custom('/music/track.mp3'));

      final withoutMusic = ConfigModel();
      expect(ConfigModel.fromJson(withoutMusic.toJson()).backgroundMusic, isNull);
    });
  });

  group('ConfigModel backward compatibility with pre-enum saved data', () {
    test('fromJson parses legacy raw timerMode strings', () {
      final config = ConfigModel.fromJson({'timerMode': 'stopwatch'});
      expect(config.timerMode, equals(TimerMode.stopwatch));
    });

    test('fromJson parses legacy raw themeMode strings', () {
      final config = ConfigModel.fromJson({'themeMode': 'light'});
      expect(config.themeMode, equals(AppThemeMode.light));
    });

    test('fromJson parses legacy raw language strings', () {
      final config = ConfigModel.fromJson({'language': 'hi'});
      expect(config.language, equals(AppLanguage.hindi));
    });

    test('fromJson parses legacy bundled: / custom: bell strings', () {
      final config = ConfigModel.fromJson({
        'bellStart': 'bundled:singing_bell',
        'bellEnd': 'custom:/legacy/bell.mp3',
      });
      expect(config.bellStart, equals(const AudioSource.bundled('singing_bell')));
      expect(config.bellEnd, equals(const AudioSource.custom('/legacy/bell.mp3')));
    });

    test('fromJson parses a legacy unprefixed backgroundMusic path', () {
      final config =
          ConfigModel.fromJson({'backgroundMusic': '/legacy/music.mp3'});
      expect(config.backgroundMusic, equals(const AudioSource.custom('/legacy/music.mp3')));
    });

    test('fromJson falls back to defaults for unrecognized legacy values', () {
      final config = ConfigModel.fromJson({
        'timerMode': 'interval',
        'themeMode': 'sepia',
        'language': 'xx',
      });
      expect(config.timerMode, equals(TimerMode.countdown));
      expect(config.themeMode, equals(AppThemeMode.dark));
      expect(config.language, equals(AppLanguage.system));
    });

    test('missing keys fall back to documented defaults', () {
      final config = ConfigModel.fromJson(<String, dynamic>{});
      expect(config.timerMode, equals(TimerMode.countdown));
      expect(config.themeMode, equals(AppThemeMode.dark));
      expect(config.language, equals(AppLanguage.system));
      expect(config.bellStart, equals(ConfigModel.defaultBellStart));
    });
  });
}
