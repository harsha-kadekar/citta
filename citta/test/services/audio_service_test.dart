import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:citta/services/audio_service.dart';

// ---------------------------------------------------------------------------
// Fake AudioPlayer
// ---------------------------------------------------------------------------

class FakeAudioPlayer implements AudioPlayerBase {
  final List<String> calls = [];
  bool shouldThrow = false;
  bool throwOnPause = false;
  bool throwOnPlay = false;
  bool throwOnStop = false;

  String? lastAsset;
  String? lastFilePath;
  LoopMode? lastLoopMode;
  double? lastVolume;

  void _maybeThrow(String method) {
    if (shouldThrow) throw Exception('simulated audio failure');
    if (method == 'pause' && throwOnPause) throw Exception('simulated pause failure');
    if (method == 'play' && throwOnPlay) throw Exception('simulated play failure');
    if (method == 'stop' && throwOnStop) throw Exception('simulated stop failure');
  }

  @override
  Future<void> setAsset(String path) async {
    _maybeThrow('setAsset');
    lastAsset = path;
    calls.add('setAsset:$path');
  }

  @override
  Future<void> setFilePath(String path) async {
    _maybeThrow('setFilePath');
    lastFilePath = path;
    calls.add('setFilePath:$path');
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async {
    _maybeThrow('setLoopMode');
    lastLoopMode = mode;
    calls.add('setLoopMode:$mode');
  }

  @override
  Future<void> setVolume(double volume) async {
    _maybeThrow('setVolume');
    lastVolume = volume;
    calls.add('setVolume:$volume');
  }

  @override
  Future<void> seek(Duration position) async {
    _maybeThrow('seek');
    calls.add('seek:${position.inMilliseconds}ms');
  }

  @override
  Future<void> play() async {
    _maybeThrow('play');
    calls.add('play');
  }

  @override
  Future<void> pause() async {
    _maybeThrow('pause');
    calls.add('pause');
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    _maybeThrow('stop');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}

// ---------------------------------------------------------------------------
// Fake AudioSession
// ---------------------------------------------------------------------------

class FakeAudioSession implements AudioSessionBase {
  AudioSessionConfiguration? lastConfiguration;
  final _controller = StreamController<AudioInterruptionEvent>.broadcast();

  @override
  Future<void> configure(AudioSessionConfiguration configuration) async {
    lastConfiguration = configuration;
  }

  @override
  Stream<AudioInterruptionEvent> get interruptionEventStream =>
      _controller.stream;

  void emitInterruption(AudioInterruptionEvent event) {
    _controller.add(event);
  }

  Future<void> close() => _controller.close();
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

    test('10b. clears both flags when restart fails while interrupted', () async {
      await service.startBackgroundMusic('/music.mp3');
      await service.handleInterruption(began: true, transient: true);
      // _isMusicPlaying=true, _musicInterrupted=true at this point
      musicPlayer.shouldThrow = true;

      await service.startBackgroundMusic('/new/music.mp3');

      expect(service.isMusicPlaying, isFalse);
      expect(service.isMusicInterrupted, isFalse);
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

  // -------------------------------------------------------------------------
  // handleInterruption()
  // -------------------------------------------------------------------------

  group('handleInterruption()', () {
    test('22. transient interruption while music playing pauses player and keeps isMusicPlaying true',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      musicPlayer.calls.clear();

      await service.handleInterruption(began: true, transient: true);

      expect(musicPlayer.calls, contains('pause'));
      expect(musicPlayer.calls, isNot(contains('stop')));
      expect(service.isMusicPlaying, isTrue);
      expect(service.isMusicInterrupted, isTrue);
    });

    test('23. focus regained after transient interruption resumes playback',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      await service.handleInterruption(began: true, transient: true);
      musicPlayer.calls.clear();

      await service.handleInterruption(began: false, transient: true);

      expect(musicPlayer.calls, contains('play'));
      expect(service.isMusicInterrupted, isFalse);
      expect(service.isMusicPlaying, isTrue);
    });

    test('24. permanent interruption while music playing stops both players and clears isMusicPlaying',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      musicPlayer.calls.clear();

      await service.handleInterruption(began: true, transient: false);

      expect(musicPlayer.calls, contains('stop'));
      expect(bellPlayer.calls, contains('stop'));
      expect(service.isMusicPlaying, isFalse);
      expect(service.isMusicInterrupted, isFalse);
    });

    test('25. transient interruption when no music is playing does nothing to either player',
        () async {
      await service.handleInterruption(began: true, transient: true);

      expect(musicPlayer.calls, isEmpty);
      expect(bellPlayer.calls, isEmpty);
      expect(service.isMusicInterrupted, isFalse);
    });

    test('26. focus regained when not interrupted does nothing', () async {
      await service.startBackgroundMusic('/music.mp3');
      musicPlayer.calls.clear();

      await service.handleInterruption(began: false, transient: true);

      expect(musicPlayer.calls, isEmpty);
    });

    test('27. stopBackgroundMusic while interrupted clears interruption state',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      await service.handleInterruption(began: true, transient: true);

      await service.stopBackgroundMusic();

      expect(service.isMusicPlaying, isFalse);
      expect(service.isMusicInterrupted, isFalse);
    });

    test('28. permanent interruption stops bell player even when no music is playing',
        () async {
      await service.handleInterruption(began: true, transient: false);

      expect(bellPlayer.calls, contains('stop'));
      expect(musicPlayer.calls, isEmpty);
    });

    test('34. permanent interruption while transiently interrupted clears both flags and stops both players',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      await service.handleInterruption(began: true, transient: true);
      bellPlayer.calls.clear();
      musicPlayer.calls.clear();

      await service.handleInterruption(began: true, transient: false);

      expect(bellPlayer.calls, contains('stop'));
      expect(musicPlayer.calls, contains('stop'));
      expect(service.isMusicPlaying, isFalse);
      expect(service.isMusicInterrupted, isFalse);
    });

    test('35. focus regained after permanent interruption does nothing',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      await service.handleInterruption(began: true, transient: false);
      bellPlayer.calls.clear();
      musicPlayer.calls.clear();

      await service.handleInterruption(began: false, transient: false);

      expect(bellPlayer.calls, isEmpty);
      expect(musicPlayer.calls, isEmpty);
      expect(service.isMusicPlaying, isFalse);
      expect(service.isMusicInterrupted, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // handleInterruption() — failure paths
  // -------------------------------------------------------------------------

  group('handleInterruption() — failure paths', () {
    test('29. pause fails during transient interruption — isMusicInterrupted stays false',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      musicPlayer.throwOnPause = true;

      await service.handleInterruption(began: true, transient: true);

      expect(service.isMusicInterrupted, isFalse);
      expect(service.isMusicPlaying, isTrue);
    });

    test('30. resume fails after transient interruption — both flags cleared, music not playing',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      await service.handleInterruption(began: true, transient: true);
      musicPlayer.throwOnPlay = true;
      musicPlayer.calls.clear();

      await service.handleInterruption(began: false, transient: true);

      expect(service.isMusicInterrupted, isFalse);
      expect(service.isMusicPlaying, isFalse);
    });

    test('36. music stop throws during permanent interruption — isMusicPlaying still cleared',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      musicPlayer.throwOnStop = true;

      await service.handleInterruption(began: true, transient: false);

      expect(bellPlayer.calls, contains('stop'));
      expect(musicPlayer.calls, contains('stop'));
      expect(service.isMusicPlaying, isFalse);
      expect(service.isMusicInterrupted, isFalse);
    });

    test('37. two consecutive transient interruptions — second pause also called',
        () async {
      await service.startBackgroundMusic('/music.mp3');
      await service.handleInterruption(began: true, transient: true);
      musicPlayer.calls.clear();

      await service.handleInterruption(began: true, transient: true);

      expect(musicPlayer.calls, contains('pause'));
      expect(service.isMusicInterrupted, isTrue);
      expect(service.isMusicPlaying, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // init() — session wiring
  // -------------------------------------------------------------------------

  group('init()', () {
    late FakeAudioSession fakeSession;
    late FakeAudioPlayer bell;
    late FakeAudioPlayer music;
    late AudioService sessionService;

    setUp(() {
      fakeSession = FakeAudioSession();
      bell = FakeAudioPlayer();
      music = FakeAudioPlayer();
      sessionService = AudioService.withPlayers(
        bellPlayer: bell,
        musicPlayer: music,
        sessionFactory: () async => fakeSession,
      );
    });

    tearDown(() async {
      await fakeSession.close();
    });

    test('31. configures session with media usage and gain focus type, no duckOthers',
        () async {
      await sessionService.init();

      expect(fakeSession.lastConfiguration, isNotNull);
      final cfg = fakeSession.lastConfiguration!;
      expect(cfg.androidAudioAttributes?.usage, AndroidAudioUsage.media);
      expect(cfg.androidAudioFocusGainType, AndroidAudioFocusGainType.gain);
      expect(cfg.avAudioSessionCategoryOptions,
          isNot(AVAudioSessionCategoryOptions.duckOthers));
    });

    test('32. interruption event from stream triggers handleInterruption',
        () async {
      await sessionService.init();
      await sessionService.startBackgroundMusic('/music.mp3');
      music.calls.clear();

      fakeSession.emitInterruption(
        AudioInterruptionEvent(true, AudioInterruptionType.pause),
      );
      await Future<void>.delayed(Duration.zero);

      expect(music.calls, contains('pause'));
      expect(sessionService.isMusicInterrupted, isTrue);
    });

    test('33. calling init() twice registers only one active subscription',
        () async {
      await sessionService.init();
      await sessionService.init();
      await sessionService.startBackgroundMusic('/music.mp3');
      music.calls.clear();

      fakeSession.emitInterruption(
        AudioInterruptionEvent(true, AudioInterruptionType.pause),
      );
      await Future<void>.delayed(Duration.zero);

      expect(music.calls.where((c) => c == 'pause').length, 1);
    });

    test('38. AudioInterruptionType.unknown via stream triggers non-transient path — stops both players',
        () async {
      await sessionService.init();
      await sessionService.startBackgroundMusic('/music.mp3');
      music.calls.clear();

      fakeSession.emitInterruption(
        AudioInterruptionEvent(true, AudioInterruptionType.unknown),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bell.calls, contains('stop'));
      expect(music.calls, contains('stop'));
      expect(sessionService.isMusicPlaying, isFalse);
      expect(sessionService.isMusicInterrupted, isFalse);
    });

    test('39. focus-regained event after transient interruption resumes playback via stream',
        () async {
      await sessionService.init();
      await sessionService.startBackgroundMusic('/music.mp3');
      fakeSession.emitInterruption(
        AudioInterruptionEvent(true, AudioInterruptionType.pause),
      );
      await Future<void>.delayed(Duration.zero);
      music.calls.clear();

      fakeSession.emitInterruption(
        AudioInterruptionEvent(false, AudioInterruptionType.pause),
      );
      await Future<void>.delayed(Duration.zero);

      expect(music.calls, contains('play'));
      expect(sessionService.isMusicInterrupted, isFalse);
      expect(sessionService.isMusicPlaying, isTrue);
    });

    test('40. init() swallows a session factory exception', () async {
      sessionService = AudioService.withPlayers(
        bellPlayer: FakeAudioPlayer(),
        musicPlayer: FakeAudioPlayer(),
        sessionFactory: () async => throw Exception('factory failed'),
      );

      await expectLater(sessionService.init(), completes);
    });
  });
}
