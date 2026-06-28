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
import 'package:citta/models/session_model.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/stats_screen.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';
import 'package:citta/widgets/calendar_view.dart';

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

SessionModel _session(String id, {DateTime? date}) => SessionModel(
      id: id,
      date: date ?? DateTime.utc(2024, 6, 1),
      duration: 600,
      timerMode: 'countdown',
      completedFully: true,
    );

Widget _testApp(AppState appState) => ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatsScreen(),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
//
// NOTE: AppState methods that do file IO (addSession, updateConfig, …) must be
// called via tester.runAsync() inside testWidgets; real IO does not resolve
// inside fakeAsync, which is what testWidgets uses.
// ---------------------------------------------------------------------------

void main() {
  group('StatsScreen — stats display', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_stats_test_');
      appState = await _makeAndInit(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('1. shows zero total sessions initially', (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      expect(find.text('0'), findsWidgets);
    });

    testWidgets('2. total sessions updates after addSession', (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      await tester.runAsync(() => appState.addSession(_session('s1')));
      await tester.pump();

      expect(find.text('1'), findsWidgets,
          reason: 'totalSessions stat card must update after a session is added');
    });

    testWidgets('3. calendar is hidden when calendarViewEnabled is false', (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      expect(find.byType(CalendarView), findsNothing);
    });

    testWidgets('4. calendar appears after calendarViewEnabled is set to true',
        (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      await tester.runAsync(() => appState.updateConfig(
            appState.config.copyWith(calendarViewEnabled: true),
          ));
      await tester.pump();

      expect(find.byType(CalendarView), findsOneWidget);
    });

    testWidgets(
        '5. unrelated config change (timerMode) does not remove stats from screen',
        (tester) async {
      await tester.runAsync(() => appState.addSession(_session('s1')));
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      expect(find.text('1'), findsWidgets);

      await tester.runAsync(() => appState.updateConfig(
            appState.config.copyWith(timerMode: 'stopwatch'),
          ));
      await tester.pump();

      expect(find.text('1'), findsWidgets,
          reason: 'a timerMode config change must not clear or corrupt the stats display');
    });
  });

  group('StatsScreen — calendar toggle', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_stats_cal_test_');
      appState = await _makeAndInit(
        tmpDir.path,
        initialConfig: ConfigModel(calendarViewEnabled: true),
      );
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('6. calendar disappears after calendarViewEnabled is set to false',
        (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      expect(find.byType(CalendarView), findsOneWidget);

      await tester.runAsync(() => appState.updateConfig(
            appState.config.copyWith(calendarViewEnabled: false),
          ));
      await tester.pump();

      expect(find.byType(CalendarView), findsNothing,
          reason: 'disabling calendarViewEnabled must hide the CalendarView');
    });
  });
}
