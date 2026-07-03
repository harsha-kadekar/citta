import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/config_model.dart';
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Each group manages its own tmpDir + AppState so configs don't bleed
  // across tests, and all file I/O stays in setUp (outside fakeAsync).

  group('HomeScreen – manually stop countdown', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      // Default config is countdown — no initialConfig override needed.
      appState = await _makeAndInit(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '1. manually stopping a countdown session persists completedFully=false',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.stop_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350)); // push animation

        expect(find.byType(SessionCompleteScreen), findsOneWidget);
        final screen = tester.widget<SessionCompleteScreen>(
          find.byType(SessionCompleteScreen),
        );
        expect(screen.session.completedFully, isFalse);

        // Drain SessionCompleteScreen's 3-second auto-advance timer.
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });

  group('HomeScreen – stop stopwatch', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      // Pre-write stopwatch config before initialize() so AppState loads it.
      appState = await _makeAndInit(
        tmpDir.path,
        initialConfig: ConfigModel(timerMode: 'stopwatch'),
      );
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '2. stopping a stopwatch session persists completedFully=true',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.stop_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.byType(SessionCompleteScreen), findsOneWidget);
        final screen = tester.widget<SessionCompleteScreen>(
          find.byType(SessionCompleteScreen),
        );
        expect(screen.session.completedFully, isTrue);

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

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      // Pre-write a 1-second countdown so the timer fires quickly in tests.
      appState = await _makeAndInit(
        tmpDir.path,
        initialConfig: ConfigModel(countdownDuration: 1),
      );
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '3. countdown that reaches its target persists completedFully=true',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        // Advance fake time past the 1-second target so onComplete fires.
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(milliseconds: 350)); // push animation

        expect(find.byType(SessionCompleteScreen), findsOneWidget);
        final screen = tester.widget<SessionCompleteScreen>(
          find.byType(SessionCompleteScreen),
        );
        expect(screen.session.completedFully, isTrue);

        // Drain SessionCompleteScreen's 3-second auto-advance timer.
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });

  group('HomeScreen – in-progress session marker', () {
    late Directory tmpDir;
    late AppState appState;
    late StorageService storage;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_home_test_');
      appState = await _makeAndInit(tmpDir.path);
      storage = StorageService.withBasePath(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
      '4. starting a session writes the in-progress marker',
      (tester) async {
        await tester.pumpWidget(_testApp(appState));
        await tester.pump();

        await tester.tap(find.text('Begin'));
        await tester.pump();

        // Phase 1: let real I/O complete (fire-and-forget save on native thread).
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        // Phase 2: drain fakeAsync queue so I/O completion callbacks execute.
        await tester.pump();
        // Phase 3: read the file in real async.
        final data = await tester.runAsync(() => storage.loadInProgressSession());

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

        // Phase 1: let real I/O complete.
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        // Phase 2: drain fakeAsync queue.
        await tester.pump();
        // Phase 3: read the file.
        final data = await tester.runAsync(() => storage.loadInProgressSession());

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

        // Phase 1: let real I/O complete.
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        // Phase 2: drain fakeAsync queue.
        await tester.pump();
        // Phase 3: read the file.
        final data = await tester.runAsync(() => storage.loadInProgressSession());

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

        // Ensure marker was written first.
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        await tester.pump();
        final dataBefore = await tester.runAsync(() => storage.loadInProgressSession());
        expect(dataBefore, isNotNull, reason: 'marker must exist before stop');

        await tester.tap(find.byIcon(Icons.stop_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Wait for clearInProgressSession I/O.
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        await tester.pump();
        final dataAfter = await tester.runAsync(() => storage.loadInProgressSession());

        expect(dataAfter, isNull,
            reason: 'in-progress marker must be cleared when session completes normally');

        // Drain SessionCompleteScreen's 3-second auto-advance timer.
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });
}
