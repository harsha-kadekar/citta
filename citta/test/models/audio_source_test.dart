import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/audio_source.dart';

void main() {
  group('AudioSource.toStorageString', () {
    test('none serializes to "none"', () {
      expect(AudioSource.none.toStorageString(), equals('none'));
    });

    test('bundled serializes with the bundled: prefix', () {
      expect(const AudioSource.bundled('bright_tibetan_bell').toStorageString(),
          equals('bundled:bright_tibetan_bell'));
    });

    test('custom serializes with the custom: prefix', () {
      expect(const AudioSource.custom('/storage/bell.mp3').toStorageString(),
          equals('custom:/storage/bell.mp3'));
    });
  });

  group('AudioSource.fromStorageString', () {
    test('"none" parses to AudioSource.none', () {
      expect(AudioSource.fromStorageString('none'), equals(AudioSource.none));
    });

    test('bundled: prefix parses to a bundled source with the name stripped',
        () {
      final source =
          AudioSource.fromStorageString('bundled:bright_tibetan_bell');
      expect(source, equals(const AudioSource.bundled('bright_tibetan_bell')));
      expect(source.isBundled, isTrue);
      expect(source.bundledName, equals('bright_tibetan_bell'));
    });

    test('custom: prefix parses to a custom source with the path stripped',
        () {
      final source = AudioSource.fromStorageString('custom:/storage/bell.mp3');
      expect(source, equals(const AudioSource.custom('/storage/bell.mp3')));
      expect(source.isCustom, isTrue);
      expect(source.path, equals('/storage/bell.mp3'));
    });

    test('unrecognized value falls back to none when raw paths are disallowed',
        () {
      expect(AudioSource.fromStorageString('garbage'), equals(AudioSource.none));
    });

    test('legacy unprefixed path parses to custom when allowRawPath is true',
        () {
      final source = AudioSource.fromStorageString('/legacy/music.mp3',
          allowRawPath: true);
      expect(source, equals(const AudioSource.custom('/legacy/music.mp3')));
    });

    test('bundled: prefix is treated as a raw path when allowBundled is false',
        () {
      // Mirrors AudioService.startBackgroundMusic's historical behavior:
      // background music has no bundled options, so a value that happens to
      // start with "bundled:" is treated as an (unlikely) literal path.
      final source = AudioSource.fromStorageString('bundled:foo',
          allowBundled: false, allowRawPath: true);
      expect(source, equals(const AudioSource.custom('bundled:foo')));
    });

    test('"none" still takes precedence even when allowRawPath is true', () {
      expect(
          AudioSource.fromStorageString('none', allowRawPath: true),
          equals(AudioSource.none));
    });
  });

  group('AudioSource equality', () {
    test('two bundled sources with the same name are equal', () {
      expect(const AudioSource.bundled('x'), equals(const AudioSource.bundled('x')));
    });

    test('two bundled sources with different names are not equal', () {
      expect(const AudioSource.bundled('x') == const AudioSource.bundled('y'), isFalse);
    });

    test('a custom source and a bundled source with the same value are not equal',
        () {
      expect(const AudioSource.custom('x') == const AudioSource.bundled('x'), isFalse);
    });

    test('none equals none', () {
      expect(AudioSource.none, equals(AudioSource.none));
    });
  });

  group('AudioSource state getters', () {
    test('none reports isNone and no bundledName/path', () {
      expect(AudioSource.none.isNone, isTrue);
      expect(AudioSource.none.isBundled, isFalse);
      expect(AudioSource.none.isCustom, isFalse);
      expect(AudioSource.none.bundledName, isNull);
      expect(AudioSource.none.path, isNull);
    });

    test('bundled reports isBundled and no path', () {
      const source = AudioSource.bundled('singing_bell');
      expect(source.isBundled, isTrue);
      expect(source.isNone, isFalse);
      expect(source.isCustom, isFalse);
      expect(source.path, isNull);
    });

    test('custom reports isCustom and no bundledName', () {
      const source = AudioSource.custom('/a/b.mp3');
      expect(source.isCustom, isTrue);
      expect(source.isNone, isFalse);
      expect(source.isBundled, isFalse);
      expect(source.bundledName, isNull);
    });
  });
}
