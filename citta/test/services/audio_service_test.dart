import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:citta/services/audio_service.dart';

// ---------------------------------------------------------------------------
// Fake AudioPlayer
// ---------------------------------------------------------------------------

class FakeAudioPlayer implements AudioPlayerBase {
  final List<String> calls = [];
  bool shouldThrow = false;

  String? lastAsset;
  String? lastFilePath;
  LoopMode? lastLoopMode;
  double? lastVolume;

  void _maybeThrow() {
    if (shouldThrow) throw Exception('simulated audio failure');
  }

  @override
  Future<void> setAsset(String path) async {
    _maybeThrow();
    lastAsset = path;
    calls.add('setAsset:$path');
  }

  @override
  Future<void> setFilePath(String path) async {
    _maybeThrow();
    lastFilePath = path;
    calls.add('setFilePath:$path');
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    _maybeThrow();
    lastLoopMode = mode;
    calls.add('setLoopMode:$mode');
  }

  @override
  Future<void> setVolume(double volume) async {
    _maybeThrow();
    lastVolume = volume;
    calls.add('setVolume:$volume');
  }

  @override
  Future<void> seek(Duration position) async {
    _maybeThrow();
    calls.add('seek:${position.inMilliseconds}ms');
  }

  @override
  Future<void> play() async {
    _maybeThrow();
    calls.add('play');
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeAudioPlayer bellPlayer;
  late FakeAudioPlayer musicPlayer;
  late AudioService service;

  setUp(() {
    bellPlayer = FakeAudioPlayer();
    musicPlayer = FakeAudioPlayer();
    service = AudioService.withPlayers(
      bellPlayer: bellPlayer,
      musicPlayer: musicPlayer,
    );
  });

  // -------------------------------------------------------------------------
  // playBell()
  // -------------------------------------------------------------------------

  group('playBell()', () {
    test('1. plays a valid bundled sound', () async {
      await service.playBell('bundled:temple_bells');

      expect(
        bellPlayer.lastAsset,
        'assets/sounds/temple-bells.mp3',
      );
      expect(bellPlayer.calls, containsAllInOrder(['setAsset:assets/sounds/temple-bells.mp3', 'seek:1ms', 'play']));
    });

    test('2. does nothing for an unknown bundled name', () async {
      await service.playBell('bundled:nonexistent');

      expect(bellPlayer.calls, isEmpty);
    });

    test('3. plays a custom file path with prefix stripped', () async {
      await service.playBell('custom:/path/to/bell.mp3');

      expect(bellPlayer.lastFilePath, '/path/to/bell.mp3');
      expect(bellPlayer.calls, containsAllInOrder(['setFilePath:/path/to/bell.mp3', 'seek:1ms', 'play']));
    });

    test('4. does nothing for an unrecognised prefix', () async {
      await service.playBell('raw:something');

      expect(bellPlayer.calls, isEmpty);
    });

    test('5. silently handles playback failure', () async {
      bellPlayer.shouldThrow = true;

      await expectLater(
        service.playBell('bundled:temple_bells'),
        completes,
      );
    });
  });

  // -------------------------------------------------------------------------
  // previewSound()
  // -------------------------------------------------------------------------

  group('previewSound()', () {
    test('6. delegates to playBell() — plays the correct asset', () async {
      await service.previewSound('bundled:singing_bell');

      expect(bellPlayer.lastAsset, 'assets/sounds/singing-bell.mp3');
      expect(bellPlayer.calls, containsAllInOrder(['setAsset:assets/sounds/singing-bell.mp3', 'seek:1ms', 'play']));
    });
  });

  // -------------------------------------------------------------------------
  // startBackgroundMusic()
  // -------------------------------------------------------------------------

  group('startBackgroundMusic()', () {
    test('7. strips custom: prefix and sets loop, volume, plays', () async {
      await service.startBackgroundMusic('custom:/music/track.mp3');

      expect(musicPlayer.lastFilePath, '/music/track.mp3');
      expect(musicPlayer.lastLoopMode, LoopMode.all);
      expect(musicPlayer.lastVolume, 0.3);
      expect(musicPlayer.calls, containsAllInOrder([
        'setFilePath:/music/track.mp3',
        'setLoopMode:${LoopMode.all}',
        'setVolume:0.3',
        'play',
      ]));
    });

    test('8. uses path as-is for a raw path', () async {
      await service.startBackgroundMusic('/raw/music.mp3');

      expect(musicPlayer.lastFilePath, '/raw/music.mp3');
      expect(musicPlayer.calls, containsAllInOrder([
        'setFilePath:/raw/music.mp3',
        'setLoopMode:${LoopMode.all}',
        'setVolume:0.3',
        'play',
      ]));
    });

    test('9. sets isMusicPlaying to true on success', () async {
      await service.startBackgroundMusic('/music.mp3');

      expect(service.isMusicPlaying, isTrue);
    });

    test('10. sets isMusicPlaying to false when playback throws', () async {
      musicPlayer.shouldThrow = true;

      await service.startBackgroundMusic('/music.mp3');

      expect(service.isMusicPlaying, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // stopBackgroundMusic()
  // -------------------------------------------------------------------------

  group('stopBackgroundMusic()', () {
    test('11. stops the music player and sets isMusicPlaying to false',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      musicPlayer.calls.clear();

      await service.stopBackgroundMusic();

      expect(musicPlayer.calls, contains('stop'));
      expect(service.isMusicPlaying, isFalse);
    });

    test('12. does nothing when music is not playing', () async {
      await service.stopBackgroundMusic();

      expect(musicPlayer.calls, isNot(contains('stop')));
    });
  });

  // -------------------------------------------------------------------------
  // stopAll()
  // -------------------------------------------------------------------------

  group('stopAll()', () {
    test('13. stops both bell player and background music', () async {
      await service.startBackgroundMusic('/music.mp3');
      bellPlayer.calls.clear();
      musicPlayer.calls.clear();

      await service.stopAll();

      expect(bellPlayer.calls, contains('stop'));
      expect(musicPlayer.calls, contains('stop'));
      expect(service.isMusicPlaying, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // isMusicPlaying getter
  // -------------------------------------------------------------------------

  group('isMusicPlaying getter', () {
    test('14. returns false initially', () {
      expect(service.isMusicPlaying, isFalse);
    });

    test('15. returns true after successful startBackgroundMusic()', () async {
      await service.startBackgroundMusic('/music.mp3');

      expect(service.isMusicPlaying, isTrue);
    });

    test('16. returns false after stopBackgroundMusic()', () async {
      await service.startBackgroundMusic('/music.mp3');
      await service.stopBackgroundMusic();

      expect(service.isMusicPlaying, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // warmUp()
  // -------------------------------------------------------------------------

  group('warmUp()', () {
    test('17. runs full warm-up sequence for a valid bundled ID', () async {
      await service.warmUp('bundled:temple_bells');

      expect(bellPlayer.calls, containsAllInOrder([
        'setAsset:assets/sounds/temple-bells.mp3',
        'setVolume:0.0',
        'seek:1ms',
        'play',
        'stop',
        'setVolume:1.0',
      ]));
    });

    test('18. does nothing for an unknown bundled name', () async {
      await service.warmUp('bundled:nonexistent');

      expect(bellPlayer.calls, isEmpty);
    });

    test('19. runs warm-up sequence for a custom file path', () async {
      await service.warmUp('custom:/path/to/bell.mp3');

      expect(bellPlayer.calls, containsAllInOrder([
        'setFilePath:/path/to/bell.mp3',
        'setVolume:0.0',
        'seek:1ms',
        'play',
        'stop',
        'setVolume:1.0',
      ]));
    });

    test('20. does nothing for an unrecognised prefix', () async {
      await service.warmUp('raw:something');

      expect(bellPlayer.calls, isEmpty);
    });

    test('21. swallows errors without throwing', () async {
      bellPlayer.shouldThrow = true;

      await expectLater(
        service.warmUp('bundled:temple_bells'),
        completes,
      );
    });
  });
}
