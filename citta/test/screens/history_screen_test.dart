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
import 'package:citta/screens/history_screen.dart';
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

SessionModel _session(
  String id, {
  DateTime? date,
  List<String> tags = const [],
}) =>
    SessionModel(
      id: id,
      date: date ?? DateTime.utc(2024, 6, 1),
      duration: 300,
      timerMode: 'countdown',
      tags: tags,
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
        home: HistoryScreen(),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
//
// NOTE: AppState methods that do file IO (addSession, deleteSessions, …) must
// be called via tester.runAsync() inside testWidgets; real IO does not resolve
// inside fakeAsync, which is what testWidgets uses.
// ---------------------------------------------------------------------------

void main() {
  group('HistoryScreen — session list', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_history_test_');
      appState = await _makeAndInit(tmpDir.path);
      await appState.addSession(_session('s1', date: DateTime.utc(2024, 6, 3)));
      await appState.addSession(_session('s2', date: DateTime.utc(2024, 6, 2)));
      await appState.addSession(_session('s3', date: DateTime.utc(2024, 6, 1)));
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('1. sessions are rendered in the list', (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('2. deleted session is removed from the list', (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      expect(find.byType(Card), findsNWidgets(3));

      await tester.runAsync(() => appState.deleteSessions(['s1']));
      await tester.pump();

      expect(find.byType(Card), findsNWidgets(2));
    });

    testWidgets('3. unrelated config change (calendarViewEnabled) leaves the list intact',
        (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      expect(find.byType(Card), findsNWidgets(3));

      await tester.runAsync(() => appState.updateConfig(
            appState.config.copyWith(calendarViewEnabled: true),
          ));
      await tester.pump();

      expect(find.byType(Card), findsNWidgets(3),
          reason: 'toggling calendarViewEnabled must not affect the session list');
    });
  });

  group('HistoryScreen — tag filter', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_history_tag_test_');
      appState = await _makeAndInit(
        tmpDir.path,
        initialConfig: ConfigModel(tags: ['calm', 'deep']),
      );
      await appState.addSession(
        _session('s1', date: DateTime.utc(2024, 6, 3), tags: ['calm']),
      );
      await appState.addSession(
        _session('s2', date: DateTime.utc(2024, 6, 2), tags: ['deep']),
      );
      await appState.addSession(
        _session('s3', date: DateTime.utc(2024, 6, 1), tags: []),
      );
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('4. all sessions shown when no filter selected', (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('5. filter chip narrows list to matching sessions', (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      // find.text('calm').first selects the filter chip, not the session card tag.
      await tester.tap(find.text('calm').first);
      await tester.pump();

      expect(find.byType(Card), findsNWidgets(1));
    });

    testWidgets('7. deleting an active filter tag from config clears the ghost filter',
        (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      // Select 'calm' as a filter — now only s1 is visible.
      await tester.tap(find.text('calm').first);
      await tester.pump();
      expect(find.byType(Card), findsNWidgets(1));

      // Remove 'calm' from config tags (simulates a Settings change).
      await tester.runAsync(() => appState.removeTag('calm'));
      await tester.pump();

      // Ghost filter must be cleared: all 3 sessions are visible again.
      // (The 'calm' text still appears as a tag on s1's card, but the filter chip is gone
      // and the filter itself is no longer active.)
      expect(find.byType(Card), findsNWidgets(3),
          reason: 'removing the filtered tag must clear the active filter, showing all sessions');
    });
  });

  group('HistoryScreen — empty state', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_history_empty_test_');
      appState = await _makeAndInit(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('6. empty state is shown when there are no sessions', (tester) async {
      await tester.pumpWidget(_testApp(appState));
      await tester.pump();

      expect(find.byType(Card), findsNothing);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
    });
  });
}
