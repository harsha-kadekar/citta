import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/session_model.dart';
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

// IMPORTANT: call only from setUp(), never inside testWidgets() or test() with
// fakeAsync — real async I/O does not complete under fakeAsync.
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

SessionModel _session(String id) => SessionModel(
      id: id,
      date: DateTime.utc(2024, 6, 1),
      duration: 300,
      timerMode: 'countdown',
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppState sessions identity contract', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_appstate_test_');
      appState = await _makeAndInit(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('1. sessions returns the same object reference on consecutive reads without mutation',
        () async {
      final ref1 = appState.sessions;
      final ref2 = appState.sessions;
      expect(identical(ref1, ref2), isTrue,
          reason:
              'sessions must return the same object reference when no mutation has occurred — '
              'CalendarView.didUpdateWidget relies on identical() to skip unnecessary regrouping');
    });

    test('2. sessions returns the same reference after a config-only update',
        () async {
      final before = appState.sessions;
      await appState.updateConfig(ConfigModel(countdownDuration: 20));
      final after = appState.sessions;
      expect(identical(before, after), isTrue,
          reason:
              'a config-only notifyListeners must not change the sessions reference — '
              'otherwise CalendarView will regroup on every config change');
    });

    test('3. sessions returns a NEW reference after addSession', () async {
      final before = appState.sessions;
      await appState.addSession(_session('s1'));
      final after = appState.sessions;
      expect(identical(before, after), isFalse,
          reason:
              'sessions reference must change after addSession so CalendarView '
              'regroups to reflect the new session');
    });

    test('4. sessions returns a NEW reference after deleteSessions', () async {
      await appState.addSession(_session('s1'));
      final before = appState.sessions;
      await appState.deleteSessions(['s1']);
      final after = appState.sessions;
      expect(identical(before, after), isFalse,
          reason:
              'sessions reference must change after deleteSessions so CalendarView '
              'regroups to reflect the deletion');
    });

    test('5. sessions list is unmodifiable — external mutation throws', () async {
      expect(
        () => appState.sessions.add(_session('x')),
        throwsUnsupportedError,
        reason: 'the returned list must be unmodifiable to prevent accidental mutation',
      );
    });
  });
}
