import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';

class AudioService {
  final AudioPlayer _bellPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

  static const Map<String, String> bundledSounds = {
    'tibetan_bowl': 'assets/sounds/tibetan_bowl.mp3',
    'soft_chime': 'assets/sounds/soft_chime.mp3',
    'singing_bowl': 'assets/sounds/singing_bowl.mp3',
    'temple_bell': 'assets/sounds/temple_bell.mp3',
    'wind_chime': 'assets/sounds/wind_chime.mp3',
    'zen_bell': 'assets/sounds/zen_bell.mp3',
  };

  static const Map<String, String> soundDisplayNames = {
    'tibetan_bowl': 'Tibetan Bowl',
    'soft_chime': 'Soft Chime',
    'singing_bowl': 'Singing Bowl',
    'temple_bell': 'Temple Bell',
    'wind_chime': 'Wind Chime',
    'zen_bell': 'Zen Bell',
  };

  /// Play a bell sound identified by its config string (e.g., "bundled:tibetan_bowl" or "custom:/path/to/file.mp3")
  Future<void> playBell(String bellId) async {
    try {
      if (bellId.startsWith('bundled:')) {
        final name = bellId.substring(8);
        final assetPath = bundledSounds[name];
        if (assetPath != null) {
          await _bellPlayer.setAsset(assetPath);
          await _bellPlayer.play();
        }
      } else if (bellId.startsWith('custom:')) {
        final path = bellId.substring(7);
        await _bellPlayer.setFilePath(path);
        await _bellPlayer.play();
      }
    } catch (_) {
      // Silently fail if audio playback fails
    }
  }

  /// Preview a bell sound (same as play, used for settings).
  Future<void> previewSound(String bellId) async {
    await playBell(bellId);
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
    } catch (_) {
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
