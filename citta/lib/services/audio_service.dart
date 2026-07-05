import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Abstraction over [AudioSession] to allow fake injection in tests.
abstract class AudioSessionBase {
  Future<void> configure(AudioSessionConfiguration configuration);
  Stream<AudioInterruptionEvent> get interruptionEventStream;
}

class _RealAudioSession implements AudioSessionBase {
  final AudioSession _session;
  _RealAudioSession(this._session);

  @override
  Future<void> configure(AudioSessionConfiguration configuration) =>
      _session.configure(configuration);

  @override
  Stream<AudioInterruptionEvent> get interruptionEventStream =>
      _session.interruptionEventStream;
}

Future<AudioSessionBase> _defaultSessionFactory() async {
  final session = await AudioSession.instance;
  return _RealAudioSession(session);
}

/// Abstraction over [AudioPlayer] to allow fake injection in tests.
abstract class AudioPlayerBase {
  Future<void> setAsset(String path);
  Future<void> setFilePath(String path);
  Future<void> setLoopMode(LoopMode mode);
  Future<void> setVolume(double volume);
  Future<void> seek(Duration position);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}

/// Production wrapper that delegates to [just_audio]'s [AudioPlayer].
/// Creates a fresh [AudioPlayer] for each source to avoid ExoPlayer stale
/// format state when switching between MP3 files with different encodings.
///
/// [handleInterruptions] controls whether the player automatically responds
/// to audio session interruptions. Set to false for short one-shot sounds
/// (bells) that should play through without managing session focus.
class _RealAudioPlayer implements AudioPlayerBase {
  final bool _handleInterruptions;
  AudioPlayer _player;

  _RealAudioPlayer({bool handleInterruptions = true})
      : _handleInterruptions = handleInterruptions,
        _player = AudioPlayer(handleInterruptions: handleInterruptions);

  @override
  Future<void> setAsset(String path) async {
    await _player.dispose();
    _player = AudioPlayer(handleInterruptions: _handleInterruptions);
    await _player.setAsset(path);
  }

  @override
  Future<void> setFilePath(String path) async {
    await _player.dispose();
    _player = AudioPlayer(handleInterruptions: _handleInterruptions);
    await _player.setFilePath(path);
  }

  @override
  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);
  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> dispose() => _player.dispose();
}

class AudioService {
  final AudioPlayerBase _bellPlayer;
  final AudioPlayerBase _musicPlayer;
  final Future<AudioSessionBase> Function() _sessionFactory;
  bool _isMusicPlaying = false;
  bool _musicInterrupted = false;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;

  /// Bell player uses [handleInterruptions: false] — bells are short one-shot
  /// sounds that play without requesting or managing audio focus themselves.
  /// Background music uses the default [handleInterruptions: true] and holds
  /// full audio focus for the duration of the session.
  AudioService()
      : _bellPlayer = _RealAudioPlayer(handleInterruptions: false),
        _musicPlayer = _RealAudioPlayer(),
        _sessionFactory = _defaultSessionFactory;

  @visibleForTesting
  AudioService.withPlayers({
    required AudioPlayerBase bellPlayer,
    required AudioPlayerBase musicPlayer,
    Future<AudioSessionBase> Function()? sessionFactory,
  })  : _bellPlayer = bellPlayer,
        _musicPlayer = musicPlayer,
        _sessionFactory = sessionFactory ?? _defaultSessionFactory;

  static const Map<String, String> bundledSounds = {
    'bell_meditation': 'assets/sounds/bell-meditation.mp3',
    'bright_tibetan_bell': 'assets/sounds/bright-tibetan-bell.mp3',
    'flat_tibetan_singing_bowl': 'assets/sounds/flat-tibetan-singing-bowl.mp3',
    'indian_temple_bell': 'assets/sounds/indian-temple-bell.mp3',
    'singing_bell': 'assets/sounds/singing-bell.mp3',
    'temple_bells': 'assets/sounds/temple-bells.mp3',
    'wind_chime': 'assets/sounds/wind-chime.mp3',
  };

  static const Map<String, String> soundDisplayNames = {
    'bell_meditation': 'Bell Meditation',
    'bright_tibetan_bell': 'Bright Tibetan Bell',
    'flat_tibetan_singing_bowl': 'Flat Tibetan Singing Bowl',
    'indian_temple_bell': 'Indian Temple Bell',
    'singing_bell': 'Singing Bell',
    'temple_bells': 'Temple Bells',
    'wind_chime': 'Wind Chime',
  };

  /// Configures the audio session and subscribes to interruption events.
  /// Must be called once at app startup, before any session begins. Safe to
  /// call again — the previous subscription is cancelled first.
  Future<void> init() async {
    try {
      final session = await _sessionFactory();
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      await _interruptionSubscription?.cancel();
      _interruptionSubscription =
          session.interruptionEventStream.listen((event) async {
        // AudioInterruptionType.unknown is a non-transient interruption
        // (e.g. phone call). duck/pause are transient and can be resumed.
        final transient = event.type != AudioInterruptionType.unknown;
        await handleInterruption(began: event.begin, transient: transient);
      });
    } catch (e) {
      debugPrint('AudioService: init failed (non-fatal): $e');
    }
  }

  /// Reacts to audio focus changes.
  ///
  /// - [began] true = focus lost; false = focus returned.
  /// - [transient] true = temporary (e.g. notification); false = long-term
  ///   (e.g. phone call). Only meaningful when [began] is true.
  ///
  /// Player call failures are caught and logged so that flag state always
  /// reflects the last known safe state rather than crashing.
  Future<void> handleInterruption(
      {required bool began, required bool transient}) async {
    if (began) {
      if (transient) {
        if (!_isMusicPlaying) return;
        try {
          await _musicPlayer.pause();
          _musicInterrupted = true;
        } catch (e) {
          debugPrint('AudioService: pause on interruption failed: $e');
          // _musicInterrupted stays false — no retry will be attempted
        }
      } else {
        // Non-transient (e.g. phone call): stop all audio immediately.
        try {
          await _bellPlayer.stop();
        } catch (e) {
          debugPrint('AudioService: bell stop on interruption failed: $e');
        }
        if (_isMusicPlaying) {
          try {
            await _musicPlayer.stop();
          } catch (e) {
            debugPrint('AudioService: music stop on interruption failed: $e');
          }
          _isMusicPlaying = false;
        }
        _musicInterrupted = false;
      }
    } else {
      if (!_musicInterrupted) return;
      try {
        await _musicPlayer.play();
        _musicInterrupted = false;
      } catch (e) {
        debugPrint('AudioService: resume after interruption failed: $e');
        // Player state is unknown — clear both flags rather than leave stale
        // "playing" state that doesn't match reality.
        _isMusicPlaying = false;
        _musicInterrupted = false;
      }
    }
  }

  /// Resolves a `bundled:<name>` / `custom:<path>` selection id to a
  /// concrete playable source — the single place that decodes this
  /// convention, shared by bell and background-music playback.
  ///
  /// Set [allowBundled] to false for callers (background music) that don't
  /// support bundled options, so a string that happens to start with
  /// `bundled:` is treated as a raw/custom path instead. Set [allowRawPath]
  /// for callers that must also accept legacy configs saved before the
  /// `custom:` prefix convention existed. Returns null when the id names an
  /// unknown bundled sound, or an unrecognized id with [allowRawPath] false
  /// (e.g. "none").
  ({bool isAsset, String path})? _resolveSource(
    String id, {
    bool allowBundled = true,
    bool allowRawPath = false,
  }) {
    if (allowBundled && id.startsWith('bundled:')) {
      final assetPath = bundledSounds[id.substring(8)];
      return assetPath == null ? null : (isAsset: true, path: assetPath);
    }
    if (id.startsWith('custom:')) {
      return (isAsset: false, path: id.substring(7));
    }
    return allowRawPath ? (isAsset: false, path: id) : null;
  }

  /// Play a bell sound identified by its config string (e.g., "bundled:tibetan_bowl" or "custom:/path/to/file.mp3")
  /// Retries once on failure — ExoPlayer bypass mode can fail on first attempt on some Android versions.
  Future<void> playBell(String bellId, {bool isRetry = false}) async {
    try {
      final source = _resolveSource(bellId);
      if (source != null) {
        if (source.isAsset) {
          await _bellPlayer.setAsset(source.path);
        } else {
          await _bellPlayer.setFilePath(source.path);
        }
        await _bellPlayer.seek(const Duration(milliseconds: 1));
        await _bellPlayer.play();
      }
    } catch (e) {
      debugPrint('AudioService: playBell failed for "$bellId": $e');
      if (!isRetry) {
        debugPrint('AudioService: retrying playBell for "$bellId"');
        await playBell(bellId, isRetry: true);
      }
    }
  }

  /// Preview a bell sound (same as play, used for settings).
  Future<void> previewSound(String bellId) async {
    await playBell(bellId);
  }

  /// Pre-warms the Android audio subsystem by silently loading and playing
  /// the configured bell sound for a brief instant. Errors are swallowed —
  /// this is a best-effort warm-up only.
  Future<void> warmUp(String bellId) async {
    try {
      final source = _resolveSource(bellId);
      if (source == null) return;
      if (source.isAsset) {
        await _bellPlayer.setAsset(source.path);
      } else {
        await _bellPlayer.setFilePath(source.path);
      }
      await _bellPlayer.setVolume(0);
      await _bellPlayer.seek(const Duration(milliseconds: 1));
      await _bellPlayer.play();
      await _bellPlayer.stop();
      await _bellPlayer.setVolume(1);
    } catch (e) {
      debugPrint('AudioService: warmUp failed (non-fatal): $e');
    }
  }

  /// Start background music playback (looping).
  ///
  /// [path] follows the same `custom:<path>` convention as bell IDs (see
  /// [playBell]) — background music has no bundled options, so this is the
  /// only prefix in use. Raw, unprefixed paths are still accepted so configs
  /// saved before this convention was introduced keep working.
  Future<void> startBackgroundMusic(String path) async {
    try {
      final source =
          _resolveSource(path, allowBundled: false, allowRawPath: true)!;
      await _musicPlayer.setFilePath(source.path);
      await _musicPlayer.setLoopMode(LoopMode.all);
      await _musicPlayer.setVolume(0.3);
      await _musicPlayer.play();
      _isMusicPlaying = true;
      _musicInterrupted = false;
    } catch (e) {
      debugPrint('AudioService: startBackgroundMusic failed for "$path": $e');
      _isMusicPlaying = false;
      _musicInterrupted = false;
    }
  }

  /// Stop background music.
  Future<void> stopBackgroundMusic() async {
    if (_isMusicPlaying || _musicInterrupted) {
      try {
        await _musicPlayer.stop();
      } catch (e) {
        debugPrint('AudioService: stopBackgroundMusic failed: $e');
      }
      _isMusicPlaying = false;
      _musicInterrupted = false;
    }
  }

  bool get isMusicPlaying => _isMusicPlaying;

  /// True when music is paused due to an external interruption and will
  /// resume once audio focus is returned.
  bool get isMusicInterrupted => _musicInterrupted;

  /// Stop all audio.
  Future<void> stopAll() async {
    await _bellPlayer.stop();
    await stopBackgroundMusic();
  }

  Future<void> dispose() async {
    await _interruptionSubscription?.cancel();
    await _bellPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
