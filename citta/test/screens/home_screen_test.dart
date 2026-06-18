import 'dart:io';
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
}
