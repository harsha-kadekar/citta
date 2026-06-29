import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';
import 'package:just_audio/just_audio.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _FakeAudioPlayer implements AudioPlayerBase {
  @override Future<void> setAsset(String path) async {}
  @override Future<void> setFilePath(String path) async {}
  @override Future<void> setLoopMode(LoopMode mode) async {}
  @override Future<void> setVolume(double volume) async {}
  @override Future<void> seek(Duration position) async {}
  @override Future<void> play() async {}
  @override Future<void> pause() async {}
  @override Future<void> stop() async {}
  @override Future<void> dispose() async {}
}

class _FakeAudioSession implements AudioSessionBase {
  @override Future<void> configure(AudioSessionConfiguration _) async {}
  @override Stream<AudioInterruptionEvent> get interruptionEventStream =>
      const Stream.empty();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<AppState> _makeAndInit(String basePath) async {
  final storage = StorageService.withBasePath(basePath);
  final appState = AppState(
    storageService: storage,
    quoteService: QuoteService(storage),
    audioService: AudioService.withPlayers(
      bellPlayer: _FakeAudioPlayer(),
      musicPlayer: _FakeAudioPlayer(),
      sessionFactory: () async => _FakeAudioSession(),
    ),
    statsService: const StatsService(),
  );
  await appState.initialize();
  return appState;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppState tag operations — immutability contract', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_tags_test_');
      appState = await _makeAndInit(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('1. addTag with new tag changes config reference', () async {
      final before = appState.config;
      await appState.addTag('focus');
      expect(
        identical(before, appState.config),
        isFalse,
        reason: 'addTag must produce a new ConfigModel via copyWith, '
            'not mutate the existing one in place',
      );
    });

    test('2. addTag with existing tag is a no-op — config reference unchanged',
        () async {
      final defaultTag = appState.config.tags.first;
      final before = appState.config;
      await appState.addTag(defaultTag);
      expect(
        identical(before, appState.config),
        isTrue,
        reason: 'addTag must not create a new config when the tag already exists',
      );
    });

    test('3. removeTag with existing tag changes config reference', () async {
      final existingTag = appState.config.tags.first;
      final before = appState.config;
      await appState.removeTag(existingTag);
      expect(
        identical(before, appState.config),
        isFalse,
        reason: 'removeTag must produce a new ConfigModel via copyWith, '
            'not mutate the existing one in place',
      );
    });

    test('4. after addTag, the tag appears in config.tags', () async {
      await appState.addTag('focus');
      expect(appState.config.tags, contains('focus'));
    });

    test('5. after removeTag, the tag is absent from config.tags', () async {
      final tagToRemove = appState.config.tags.first;
      await appState.removeTag(tagToRemove);
      expect(appState.config.tags, isNot(contains(tagToRemove)));
    });

    test('6. addTag then removeTag round-trips correctly', () async {
      await appState.addTag('roundtrip');
      expect(appState.config.tags, contains('roundtrip'));
      await appState.removeTag('roundtrip');
      expect(appState.config.tags, isNot(contains('roundtrip')));
    });

    test('7. config.tags is unmodifiable — external add throws', () {
      expect(
        () => appState.config.tags.add('external'),
        throwsUnsupportedError,
        reason: 'config.tags must be unmodifiable to prevent callers from '
            'bypassing the copyWith update path',
      );
    });

    test('8. addTag does not change pre-existing tags', () async {
      final originalTags = List<String>.from(appState.config.tags);
      await appState.addTag('new_tag');
      for (final tag in originalTags) {
        expect(appState.config.tags, contains(tag),
            reason: 'existing tag "$tag" must be preserved after addTag');
      }
    });

    test('9. removeTag does not change other tags', () async {
      final tagToRemove = appState.config.tags.first;
      final remaining = appState.config.tags.skip(1).toList();
      await appState.removeTag(tagToRemove);
      for (final tag in remaining) {
        expect(appState.config.tags, contains(tag),
            reason: 'tag "$tag" must be preserved after removing "$tagToRemove"');
      }
    });

    test('10. removeTag with non-existing tag is a no-op — config reference unchanged',
        () async {
      final before = appState.config;
      await appState.removeTag('nonexistent_tag_xyz');
      expect(
        identical(before, appState.config),
        isTrue,
        reason: 'removeTag must not create a new config, save, or notify when '
            'the tag does not exist — mirrors addTag no-op behavior',
      );
    });

    test('11. removeTag with non-existing tag does not alter the tags list',
        () async {
      final tagsBefore = List<String>.from(appState.config.tags);
      await appState.removeTag('nonexistent_tag_xyz');
      expect(appState.config.tags, equals(tagsBefore));
    });
  });
}
