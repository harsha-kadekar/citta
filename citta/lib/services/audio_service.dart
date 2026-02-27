import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Abstraction over [AudioPlayer] to allow fake injection in tests.
abstract class AudioPlayerBase {
  Future<void> setAsset(String path);
  Future<void> setFilePath(String path);
  Future<void> setLoopMode(LoopMode mode);
  Future<void> setVolume(double volume);
  Future<void> seek(Duration position);
  Future<void> play();
  Future<void> stop();
  Future<void> dispose();
}

/// Production wrapper that delegates to [just_audio]'s [AudioPlayer].
/// Creates a fresh [AudioPlayer] for each source to avoid ExoPlayer stale
/// format state when switching between MP3 files with different encodings.
class _RealAudioPlayer implements AudioPlayerBase {
  AudioPlayer _player = AudioPlayer();

  @override
  Future<void> setAsset(String path) async {
    await _player.dispose();
    _player = AudioPlayer();
    await _player.setAsset(path);
  }

  @override
  Future<void> setFilePath(String path) async {
    await _player.dispose();
    _player = AudioPlayer();
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
  Future<void> stop() => _player.stop();
  @override
  Future<void> dispose() => _player.dispose();
}

class AudioService {
  final AudioPlayerBase _bellPlayer;
  final AudioPlayerBase _musicPlayer;
  bool _isMusicPlaying = false;

  AudioService()
      : _bellPlayer = _RealAudioPlayer(),
        _musicPlayer = _RealAudioPlayer();

  @visibleForTesting
  AudioService.withPlayers({
    required AudioPlayerBase bellPlayer,
    required AudioPlayerBase musicPlayer,
  })  : _bellPlayer = bellPlayer,
        _musicPlayer = musicPlayer;

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

  /// Play a bell sound identified by its config string (e.g., "bundled:tibetan_bowl" or "custom:/path/to/file.mp3")
  /// Retries once on failure — ExoPlayer bypass mode can fail on first attempt on some Android versions.
  Future<void> playBell(String bellId, {bool isRetry = false}) async {
    try {
      if (bellId.startsWith('bundled:')) {
        final name = bellId.substring(8);
        final assetPath = bundledSounds[name];
        if (assetPath != null) {
          await _bellPlayer.setAsset(assetPath);
          await _bellPlayer.seek(const Duration(milliseconds: 1));
          await _bellPlayer.play();
        }
      } else if (bellId.startsWith('custom:')) {
        final path = bellId.substring(7);
        await _bellPlayer.setFilePath(path);
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
      if (bellId.startsWith('bundled:')) {
        final name = bellId.substring(8);
        final assetPath = bundledSounds[name];
        if (assetPath == null) return;
        await _bellPlayer.setAsset(assetPath);
      } else if (bellId.startsWith('custom:')) {
        await _bellPlayer.setFilePath(bellId.substring(7));
      } else {
        return;
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
  Future<void> startBackgroundMusic(String path) async {
    try {
      if (path.startsWith('custom:')) {
        await _musicPlayer.setFilePath(path.substring(7));
      } else {
        await _musicPlayer.setFilePath(path);
      }
      await _musicPlayer.setLoopMode(LoopMode.all);
      await _musicPlayer.setVolume(0.3);
      await _musicPlayer.play();
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint('AudioService: startBackgroundMusic failed for "$path": $e');
      _isMusicPlaying = false;
    }
  }

  /// Stop background music.
  Future<void> stopBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _musicPlayer.stop();
      _isMusicPlaying = false;
    }
  }

  bool get isMusicPlaying => _isMusicPlaying;

  /// Stop all audio.
  Future<void> stopAll() async {
    await _bellPlayer.stop();
    await stopBackgroundMusic();
  }

  Future<void> dispose() async {
    await _bellPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
