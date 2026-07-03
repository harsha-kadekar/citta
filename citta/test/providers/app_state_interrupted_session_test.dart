import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
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

Future<void> _writeInProgressMarker(
  String basePath, {
  required String id,
  required int elapsedSeconds,
  String timerMode = 'countdown',
  int targetDuration = 1200,
}) async {
  final path = '$basePath/in_progress_session.json';
  final json = jsonEncode({
    'id': id,
    'startDate': DateTime.utc(2024, 6, 15, 8, 0).toIso8601String(),
    'elapsedSeconds': elapsedSeconds,
    'timerMode': timerMode,
    'targetDuration': targetDuration,
  });
  await File(path).writeAsString(json);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppState — interrupted session recovery', () {
    late Directory tmpDir;
    late StorageService storage;

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('citta_interrupted_test_');
      storage = StorageService.withBasePath(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('1. initialize with no marker starts with zero sessions', () async {
      final appState = await _makeAndInit(tmpDir.path);
      expect(appState.sessions, isEmpty);
    });

    test(
      '2. initialize with marker (elapsed > 0) adds one incomplete session and clears marker',
      () async {
        await _writeInProgressMarker(
          tmpDir.path,
          id: 'interrupted-1',
          elapsedSeconds: 300,
          timerMode: 'countdown',
        );

        final appState = await _makeAndInit(tmpDir.path);

        expect(appState.sessions.length, 1);
        final recovered = appState.sessions.first;
        expect(recovered.id, 'interrupted-1');
        expect(recovered.duration, 300);
        expect(recovered.timerMode, 'countdown');
        expect(recovered.completedFully, isFalse);

        // Marker must be cleared after recovery
        expect(await storage.loadInProgressSession(), isNull);
      },
    );

    test(
      '3. initialize with marker (elapsed == 0) discards the session but still clears the marker',
      () async {
        await _writeInProgressMarker(
          tmpDir.path,
          id: 'zero-elapsed',
          elapsedSeconds: 0,
        );

        final appState = await _makeAndInit(tmpDir.path);

        expect(appState.sessions, isEmpty,
            reason: 'zero-elapsed interrupted session must not be added to history');
        expect(await storage.loadInProgressSession(), isNull,
            reason: 'marker must still be cleared even when session is discarded');
      },
    );

    test(
      '4. initialize with corrupt marker does not crash — no session added',
      () async {
        final path = '${tmpDir.path}/in_progress_session.json';
        await File(path).writeAsString('this is not json');

        final appState = await _makeAndInit(tmpDir.path);

        expect(appState.sessions, isEmpty);
      },
    );

    test(
      '5. recovered session is persisted to sessions.json so a second init sees it',
      () async {
        await _writeInProgressMarker(
          tmpDir.path,
          id: 'persisted-session',
          elapsedSeconds: 600,
        );

        await _makeAndInit(tmpDir.path);

        // Initialize again — simulates second cold launch
        final appState2 = await _makeAndInit(tmpDir.path);
        expect(appState2.sessions.length, 1);
        expect(appState2.sessions.first.id, 'persisted-session');
      },
    );

    test(
      '6. existing sessions are preserved alongside recovered session',
      () async {
        // Pre-write one existing session
        await storage.saveSessions([
          SessionModel(
            id: 'prior-session',
            date: DateTime.utc(2024, 6, 1),
            duration: 900,
            timerMode: 'stopwatch',
          ),
        ]);

        await _writeInProgressMarker(
          tmpDir.path,
          id: 'interrupted-2',
          elapsedSeconds: 120,
        );

        final appState = await _makeAndInit(tmpDir.path);

        expect(appState.sessions.length, 2);
        final ids = appState.sessions.map((s) => s.id).toSet();
        expect(ids, containsAll(['prior-session', 'interrupted-2']));
      },
    );

    test(
      '7. initialize with marker whose id field is null does not crash — isLoading becomes false',
      () async {
        final path = '${tmpDir.path}/in_progress_session.json';
        await File(path).writeAsString(jsonEncode({
          'id': null,
          'startDate': DateTime.utc(2024, 6, 15).toIso8601String(),
          'elapsedSeconds': 300,
          'timerMode': 'countdown',
          'targetDuration': 1200,
        }));

        final appState = await _makeAndInit(tmpDir.path);

        expect(appState.isLoading, isFalse);
        expect(appState.sessions, isEmpty);
      },
    );

    test(
      '8. initialize with marker whose id matches an existing session does not create a duplicate',
      () async {
        await storage.saveSessions([
          SessionModel(
            id: 'already-saved',
            date: DateTime.utc(2024, 6, 14),
            duration: 600,
            timerMode: 'countdown',
          ),
        ]);

        await _writeInProgressMarker(
          tmpDir.path,
          id: 'already-saved',
          elapsedSeconds: 300,
        );

        final appState = await _makeAndInit(tmpDir.path);

        expect(appState.sessions.length, 1,
            reason: 'should not create duplicate when id already in sessions');
        expect(appState.sessions.first.id, 'already-saved');
      },
    );
  });

  group('AppState — saveInProgressSession / clearInProgressSession', () {
    late Directory tmpDir;
    late StorageService storage;

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('citta_inprogress_test_');
      storage = StorageService.withBasePath(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('7. saveInProgressSession writes a marker readable by StorageService',
        () async {
      final appState = await _makeAndInit(tmpDir.path);

      await appState.saveInProgressSession(
        id: 'test-id',
        startDate: DateTime.utc(2024, 6, 15),
        elapsedSeconds: 450,
        timerMode: 'stopwatch',
        targetDuration: 0,
      );

      final data = await storage.loadInProgressSession();
      expect(data, isNotNull);
      expect(data!['id'], 'test-id');
      expect(data['elapsedSeconds'], 450);
      expect(data['timerMode'], 'stopwatch');
    });

    test('8. clearInProgressSession removes the marker', () async {
      final appState = await _makeAndInit(tmpDir.path);

      await appState.saveInProgressSession(
        id: 'to-clear',
        startDate: DateTime.utc(2024, 6, 15),
        elapsedSeconds: 100,
        timerMode: 'countdown',
        targetDuration: 600,
      );

      await appState.clearInProgressSession();

      expect(await storage.loadInProgressSession(), isNull);
    });
  });
}
