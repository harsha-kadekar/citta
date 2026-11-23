import 'dart:io';

import 'package:citta/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioService bundled sounds', () {
    test('offers the Indian temple bell family of sounds', () {
      const expected = {
        'shiva_bells': ('assets/sounds/shiva-bells.mp3', 'Shiva Bells'),
        'hindu_temple_bells':
            ('assets/sounds/hindu-temple-bells.mp3', 'Hindu Temple Bells'),
        'ghanta': ('assets/sounds/ghanta.mp3', 'Ghanta (Puja Bell)'),
        'brass_bell': ('assets/sounds/brass-bell.mp3', 'Brass Bell'),
      };
      expected.forEach((key, value) {
        expect(AudioService.bundledSounds[key], value.$1, reason: key);
        expect(AudioService.soundDisplayNames[key], value.$2, reason: key);
      });
    });

    test('every bundled sound has a display name', () {
      expect(AudioService.soundDisplayNames.keys.toSet(),
          equals(AudioService.bundledSounds.keys.toSet()));
    });

    test('every bundled sound file exists on disk', () {
      for (final path in AudioService.bundledSounds.values) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    });
  });
}
