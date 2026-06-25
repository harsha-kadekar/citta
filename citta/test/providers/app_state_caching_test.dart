import 'dart:convert';
import 'dart:io';
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
    ),
    statsService: const StatsService(),
  );
  await appState.initialize();
  return appState;
}

SessionModel _session(String id, {DateTime? date}) => SessionModel(
      id: id,
      date: date ?? DateTime.utc(2024, 6, 1),
      duration: 300,
      timerMode: 'countdown',
    );

String _importJson({List<SessionModel> sessions = const []}) {
  return jsonEncode({
    'config': ConfigModel().toJson(),
    'sessions': sessions.map((s) => s.toJson()).toList(),
  });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppState derived-data caching — stats', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_caching_test_');
      appState = await _makeAndInit(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('1. stats returns the same object reference on consecutive reads without mutation',
        () {
      final ref1 = appState.stats;
      final ref2 = appState.stats;
      expect(identical(ref1, ref2), isTrue,
          reason: 'stats must be a cached value — recalculating on every get '
              'wastes CPU on unrelated notifyListeners calls');
    });

    test('2. stats reference is stable after a config-only updateConfig call',
        () async {
      final before = appState.stats;
      await appState.updateConfig(ConfigModel(countdownDuration: 20));
      final after = appState.stats;
      expect(identical(before, after), isTrue,
          reason: 'a config-only update must not invalidate the stats cache');
    });

    test('3. stats.totalSessions increments and reference changes after addSession',
        () async {
      final before = appState.stats;
      expect(before.totalSessions, 0);
      await appState.addSession(_session('s1'));
      final after = appState.stats;
      expect(after.totalSessions, 1,
          reason: 'stats must reflect the new session after addSession');
      expect(identical(before, after), isFalse,
          reason: 'stats reference must change when _sessions changes');
    });

    test('4. stats.totalSessions decrements and reference changes after deleteSessions',
        () async {
      await appState.addSession(_session('s1'));
      await appState.addSession(_session('s2'));
      final before = appState.stats;
      expect(before.totalSessions, 2);
      await appState.deleteSessions(['s1']);
      final after = appState.stats;
      expect(after.totalSessions, 1,
          reason: 'stats must reflect the deletion after deleteSessions');
      expect(identical(before, after), isFalse,
          reason: 'stats reference must change when _sessions changes');
    });

    test('5. stats is updated after importData', () async {
      final importContent = _importJson(
        sessions: [_session('imp1'), _session('imp2')],
      );
      final ok = await appState.importData(importContent);
      expect(ok, isTrue);
      expect(appState.stats.totalSessions, 2,
          reason: 'stats must reflect imported sessions');
    });
  });

  group('AppState derived-data caching — sortedSessions', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_caching_test_');
      appState = await _makeAndInit(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('6. sortedSessions returns the same object reference on consecutive reads without mutation',
        () {
      final ref1 = appState.sortedSessions;
      final ref2 = appState.sortedSessions;
      expect(identical(ref1, ref2), isTrue,
          reason: 'sortedSessions must be cached — sorting on every get wastes '
              'CPU on unrelated notifyListeners calls');
    });

    test('7. sortedSessions reference is stable after a config-only updateConfig call',
        () async {
      final before = appState.sortedSessions;
      await appState.updateConfig(ConfigModel(countdownDuration: 20));
      final after = appState.sortedSessions;
      expect(identical(before, after), isTrue,
          reason: 'a config-only update must not invalidate the sortedSessions cache');
    });

    test('8. sortedSessions includes new session after addSession', () async {
      await appState.addSession(_session('s1'));
      expect(appState.sortedSessions.map((s) => s.id), contains('s1'),
          reason: 'sortedSessions must include the new session after addSession');
    });

    test('9. sortedSessions excludes deleted session after deleteSessions',
        () async {
      await appState.addSession(_session('s1'));
      await appState.deleteSessions(['s1']);
      expect(appState.sortedSessions.map((s) => s.id), isNot(contains('s1')),
          reason: 'sortedSessions must not include deleted sessions');
    });

    test('10. sortedSessions is ordered newest-first', () async {
      final older = _session('old', date: DateTime.utc(2024, 1, 1));
      final newer = _session('new', date: DateTime.utc(2024, 6, 1));
      await appState.addSession(older);
      await appState.addSession(newer);
      final ids = appState.sortedSessions.map((s) => s.id).toList();
      expect(ids.first, 'new',
          reason: 'sortedSessions must be sorted newest-first (descending by date)');
      expect(ids.last, 'old');
    });

    test('11. filterByTags([]) returns the same reference as sortedSessions',
        () {
      final sorted = appState.sortedSessions;
      final filtered = appState.filterByTags([]);
      expect(identical(sorted, filtered), isTrue,
          reason: 'filterByTags([]) must return the cached sortedSessions — '
              'not a newly allocated copy');
    });

    test('12. sortedSessions is unmodifiable — external mutation throws', () {
      expect(
        () => appState.sortedSessions.add(_session('x')),
        throwsUnsupportedError,
        reason: 'sortedSessions must be unmodifiable to prevent accidental mutation',
      );
    });
  });
}
