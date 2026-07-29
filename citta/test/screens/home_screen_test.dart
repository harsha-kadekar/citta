import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/home_screen.dart';
import 'package:citta/screens/session_complete_screen.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';

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

/// Throws on its first [clearInProgressSession] call, then behaves normally —
/// simulates a transient I/O failure to verify a failing marker op doesn't
/// permanently disable later checkpoints (see home_screen.dart's
/// _enqueueMarkerOp, which must reset its chain regardless of success/failure).
class _ThrowOnceClearStorageService extends StorageService {
  _ThrowOnceClearStorageService(super.basePath) : super.withBasePath();
  bool _hasThrown = false;

  @override
  Future<void> clearInProgressSession() async {
    if (!_hasThrown) {
      _hasThrown = true;
      throw Exception('simulated transient clear failure');
    }
    return super.clearInProgressSession();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds and fully initialises an [AppState] from [basePath].
/// Optionally pre-writes [initialConfig] before calling initialize() so that
/// the loaded config reflects the desired settings.
/// All file I/O happens here — call this from setUp(), NOT from testWidgets().
Future<AppState> _makeAndInit(
  String basePath, {
  ConfigModel? initialConfig,
}) async {
  final storage = StorageService.withBasePath(basePath);
  if (initialConfig != null) {
    await storage.saveConfig(initialConfig);
  }
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

/// Like [_makeAndInit] but wires in a caller-supplied [StorageService], for
/// tests that need a fake with injected failure behavior.
Future<AppState> _makeAndInitWithStorage(StorageService storage) async {
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

Widget _testApp(AppState appState) => ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(),
      ),
    );

/// Reads the in-progress marker file directly, without going through
/// [StorageService.loadInProgressSession] (which calls `recoverIfNeeded` —
/// that method assumes a dangling `.tmp` file with no main file means a
/// previous run crashed, and "recovers" by renaming `.tmp` to the main path.
/// Calling it while [StorageService.saveInProgressSession]'s atomic write is
/// still in flight steals its `.tmp` file out from under it, corrupting the
/// write). This helper only ever reads the settled main file, so it's safe
/// to call repeatedly while a write may still be in progress.
Future<Map<String, dynamic>?> _readMarkerFile(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  } catch (_) {
    // Transient: caught mid-rename or mid-write. Caller retries.
    return null;
  }
}

/// Polls the in-progress marker file at [markerPath] until [predicate] is
/// satisfied or [timeout] elapses. The marker is written by a fire-and-forget
/// disk I/O call, so a fixed delay before reading it back is prone to
/// flaking under slow/loaded runners; polling waits only as long as needed.
Future<Map<String, dynamic>?> _waitForMarker(
  WidgetTester tester,
  String markerPath,
  bool Function(Map<String, dynamic>? data) predicate, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (true) {
    final data = await tester.runAsync(() => _readMarkerFile(markerPath));
    if (predicate(data) || DateTime.now().isAfter(deadline)) return data;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

/// Polls the widget tree via [predicate] until it's satisfied or [timeout]
/// elapses — same real-I/O-draining technique as [_waitForMarker], for
/// waits gated on a real disk write (e.g. NotesScreen's save-then-pop)
/// rather than the in-progress marker file specifically.
Future<void> _waitForCondition(
  WidgetTester tester,
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (true) {
    if (predicate() || DateTime.now().isAfter(deadline)) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

/// Asserts the in-progress marker at [markerPath] exists, via [_waitForMarker].
/// Call before stopping/completing a session so a later "marker cleared"
/// check can't pass trivially on a marker that was never written.
Future<void> _expectMarkerWritten(
  WidgetTester tester,
  String markerPath,
) async {
  final data = await _waitForMarker(tester, markerPath, (data) => data != null);
  expect(data, isNotNull, reason: 'marker must exist before stop');
}

/// Asserts the in-progress marker at [markerPath] has been cleared, via
/// [_waitForMarker]. This drains the real, unmocked clearInProgressSession
/// disk write before the test returns, so it can't leak into a later test's
/// FakeAsync zone and surface as a misattributed failure there.
Future<void> _expectMarkerCleared(
  WidgetTester tester,
  String markerPath,
) async {
  final data = await _waitForMarker(tester, markerPath, (data) => data == null);
  expect(data, isNull,
      reason: 'in-progress marker must be cleared once the session stops');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Each group manages its own tmpDir + AppState so configs don't bleed
  // across tests, and all file I/O stays in setUp (outside fakeAsync).

  group('HomeScreen – manually stop countdown', () {
    late Directory tmpDir;
    late AppState appState;
    late String markerPath;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      // Default config is countdown — no initialConfig override needed.
      appState = await _makeAndInit(tmpDir.path);
      markerPath = '${tmpDir.path}/in_progress_session.json';
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '1. manually stopping a countdown session persists completedFully=false',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        await _expectMarkerWritten(tester, markerPath);

        await tester.tap(find.byIcon(Icons.stop_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350)); // push animation

        expect(find.byType(SessionCompleteScreen), findsOneWidget);
        final screen = tester.widget<SessionCompleteScreen>(
          find.byType(SessionCompleteScreen),
        );
        expect(screen.session.completedFully, isFalse);

        await _expectMarkerCleared(tester, markerPath);

        // Drain SessionCompleteScreen's 3-second auto-advance timer.
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });

  group('HomeScreen – stop stopwatch', () {
    late Directory tmpDir;
    late AppState appState;
    late String markerPath;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      // Pre-write stopwatch config before initialize() so AppState loads it.
      appState = await _makeAndInit(
        tmpDir.path,
        initialConfig: ConfigModel(timerMode: TimerMode.stopwatch),
      );
      markerPath = '${tmpDir.path}/in_progress_session.json';
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '2. stopping a stopwatch session persists completedFully=true',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        await _expectMarkerWritten(tester, markerPath);

        await tester.tap(find.byIcon(Icons.stop_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.byType(SessionCompleteScreen), findsOneWidget);
        final screen = tester.widget<SessionCompleteScreen>(
          find.byType(SessionCompleteScreen),
        );
        expect(screen.session.completedFully, isTrue);

        await _expectMarkerCleared(tester, markerPath);

        // Drain SessionCompleteScreen's 3-second auto-advance timer.
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });

  group('HomeScreen – unrelated config change leaves screen intact', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      appState = await _makeAndInit(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '3a. toggling calendarViewEnabled does not affect the Begin button or config summary',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        expect(find.text('Begin'), findsOneWidget);

        await tester.runAsync(() => appState.updateConfig(
              appState.config.copyWith(calendarViewEnabled: true),
            ));
        await tester.pump();

        expect(find.text('Begin'), findsOneWidget,
            reason: 'toggling calendarViewEnabled must not crash or clear HomeScreen');
      },
    );
  });

  group('HomeScreen – natural countdown completion', () {
    late Directory tmpDir;
    late AppState appState;
    late String markerPath;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      // Pre-write a 1-second countdown so the timer fires quickly in tests.
      appState = await _makeAndInit(
        tmpDir.path,
        initialConfig: ConfigModel(countdownDuration: 1),
      );
      markerPath = '${tmpDir.path}/in_progress_session.json';
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '3. countdown that reaches its target persists completedFully=true',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        await _expectMarkerWritten(tester, markerPath);

        // Advance fake time past the 1-second target so onComplete fires.
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(milliseconds: 350)); // push animation

        expect(find.byType(SessionCompleteScreen), findsOneWidget);
        final screen = tester.widget<SessionCompleteScreen>(
          find.byType(SessionCompleteScreen),
        );
        expect(screen.session.completedFully, isTrue);

        await _expectMarkerCleared(tester, markerPath);

        // Drain SessionCompleteScreen's 3-second auto-advance timer.
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });

  group('HomeScreen – in-progress session marker', () {
    late Directory tmpDir;
    late AppState appState;
    late String markerPath;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      appState = await _makeAndInit(tmpDir.path);
      markerPath = '${tmpDir.path}/in_progress_session.json';
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '4. starting a session writes the in-progress marker',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        final data = await _waitForMarker(
          tester,
          markerPath,
          (data) => data != null,
        );

        expect(data, isNotNull,
            reason: 'in-progress marker must be written when a session starts');
        expect(data!['elapsedSeconds'], 0);
      },
    );

    testWidgets(
      '5. backgrounding a running session updates the marker with elapsed seconds',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        // Advance 5 seconds so elapsedSeconds > 0.
        await tester.pump(const Duration(seconds: 5));

        // Simulate app going to background.
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        final data = await _waitForMarker(
          tester,
          markerPath,
          (data) => data != null && (data['elapsedSeconds'] as int) >= 5,
        );

        expect(data, isNotNull);
        expect((data!['elapsedSeconds'] as int) >= 5, isTrue,
            reason: 'marker must record elapsed seconds on background');
      },
    );

    testWidgets(
      '7. backgrounding a paused session updates the marker with current elapsed seconds',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        // Advance 5 seconds so elapsedSeconds > 0.
        await tester.pump(const Duration(seconds: 5));

        // Manually pause the session.
        await tester.tap(find.byIcon(Icons.pause_rounded));
        await tester.pump();

        // Simulate app going to background while the timer is already paused.
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        final data = await _waitForMarker(
          tester,
          markerPath,
          (data) => data != null && (data['elapsedSeconds'] as int) >= 5,
        );

        expect(data, isNotNull,
            reason: 'marker must be written even when the session was already paused before backgrounding');
        expect((data!['elapsedSeconds'] as int) >= 5, isTrue,
            reason: 'marker must record elapsed seconds from the paused session');
      },
    );

    testWidgets(
      '6. stopping a session normally clears the in-progress marker',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        await _expectMarkerWritten(tester, markerPath);

        await tester.tap(find.byIcon(Icons.stop_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        await _expectMarkerCleared(tester, markerPath);

        // Drain SessionCompleteScreen's 3-second auto-advance timer.
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });

  group('HomeScreen – continuous checkpointing (issue #39)', () {
    late Directory tmpDir;
    late AppState appState;
    late String markerPath;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      appState = await _makeAndInit(tmpDir.path);
      markerPath = '${tmpDir.path}/in_progress_session.json';
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '8. a session running past 30s without backgrounding checkpoints the '
      'marker, so a crash before backgrounding does not lose all progress',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        // Never backgrounded — the only thing that can update the marker
        // past the initial elapsedSeconds=0 write is periodic checkpointing.
        await tester.pump(const Duration(seconds: 31));

        final data = await _waitForMarker(
          tester,
          markerPath,
          (data) => data != null && (data['elapsedSeconds'] as int) >= 30,
        );

        expect(data, isNotNull,
            reason: 'marker must be periodically checkpointed while running');
        expect((data!['elapsedSeconds'] as int) >= 30, isTrue,
            reason: 'checkpoint must reflect elapsed time, not the initial 0');
      },
    );

    testWidgets(
      '9. pausing a running session immediately checkpoints the marker',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        // Advance only 5s — well short of the periodic checkpoint cadence,
        // so any updated marker must come from the pause transition itself.
        await tester.pump(const Duration(seconds: 5));

        await tester.tap(find.byIcon(Icons.pause_rounded));
        await tester.pump();

        final data = await _waitForMarker(
          tester,
          markerPath,
          (data) => data != null && (data['elapsedSeconds'] as int) >= 5,
        );

        expect(data, isNotNull);
        expect((data!['elapsedSeconds'] as int) >= 5, isTrue,
            reason: 'pausing must checkpoint the marker immediately');
      },
    );

    testWidgets(
      '10. resuming a paused session checkpoints the marker again',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump(const Duration(seconds: 5));

        await tester.tap(find.byIcon(Icons.pause_rounded));
        await tester.pump();
        await _waitForMarker(
          tester,
          markerPath,
          (data) => data != null && (data['elapsedSeconds'] as int) >= 5,
        );

        // Delete the marker to simulate it being lost, so the only way it
        // can reappear is if resume() writes its own fresh checkpoint —
        // the periodic 30s cadence can't have fired yet at this point.
        await tester.runAsync(() => File(markerPath).delete());

        await tester.tap(find.byIcon(Icons.play_arrow_rounded));
        await tester.pump();

        final data = await _waitForMarker(
          tester,
          markerPath,
          (data) => data != null,
        );

        expect(data, isNotNull,
            reason: 'resuming must checkpoint the marker immediately, not '
                'just rely on the periodic cadence');
        expect((data!['elapsedSeconds'] as int) >= 5, isTrue);
      },
    );
  });

  group('HomeScreen – marker queue resilience (issue #39 code review)', () {
    late Directory tmpDir;
    late String markerPath;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      markerPath = '${tmpDir.path}/in_progress_session.json';
      appState = await _makeAndInitWithStorage(
        _ThrowOnceClearStorageService(tmpDir.path),
      );
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '11. a clear that throws does not permanently disable later '
      'checkpoints',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        // Session 1: start then immediately stop. The stop path's clear
        // throws once (by design of the fake), simulating a transient I/O
        // error — swallowed by the existing try/catch in _onSessionComplete.
        await tester.tap(find.text('Begin'));
        await tester.pump();
        final firstMarker = await _waitForMarker(
          tester,
          markerPath,
          (data) => data != null,
        );
        expect(firstMarker, isNotNull);
        final firstSessionId = firstMarker!['id'];

        await tester.tap(find.byIcon(Icons.stop_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        // Force-elapse SessionCompleteScreen's 3-second auto-advance timer —
        // it's a bare Future.delayed, not an active animation, so
        // pumpAndSettle (which only waits out scheduled frames) wouldn't
        // elapse it on its own.
        await tester.pump(const Duration(seconds: 4));
        // Now let NotesScreen's own incoming transition animation (an
        // active AnimationController) finish; pumpAndSettle is the right
        // tool for that part.
        await tester.pumpAndSettle();

        // Skip past NotesScreen (its save-then-pop is real I/O, so poll
        // rather than assume a fixed number of pumps suffices) to get back
        // to HomeScreen's idle "Begin" state.
        await tester.tap(find.text('Skip'));
        await tester.pump();
        await _waitForCondition(
          tester,
          () => find.text('Begin').evaluate().isNotEmpty,
        );
        // Let the pop transition's exit animation fully settle so a tap on
        // "Begin" doesn't hit-test against a still-departing overlay layer.
        await tester.pumpAndSettle();

        // Session 2: if the marker-op queue was poisoned by session 1's
        // failing clear, this save silently never runs its write, and the
        // marker stays stuck with session 1's id forever.
        await tester.tap(find.text('Begin'));
        await tester.pump();

        final secondMarker = await _waitForMarker(
          tester,
          markerPath,
          (data) => data != null && data['id'] != firstSessionId,
        );

        expect(secondMarker, isNotNull);
        expect(secondMarker!['id'], isNot(firstSessionId),
            reason: 'a failing clear must not permanently disable future '
                'marker checkpoints');
      },
    );
  });
}
