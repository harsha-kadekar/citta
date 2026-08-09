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
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/notes_screen.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';
import 'package:citta/widgets/tag_chip.dart';

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

SessionModel _pendingSession() => SessionModel(
      id: 'pending-1',
      date: DateTime.utc(2024, 6, 1),
      duration: 600,
      timerMode: TimerMode.countdown,
      completedFully: true,
    );

/// Polls [appState.sessions] until a session with [id] appears or [timeout]
/// elapses. addSession performs real file I/O triggered fire-and-forget by a
/// button tap, so a fixed delay before checking is prone to flaking; polling
/// waits only as long as needed.
Future<void> _waitForSession(
  WidgetTester tester,
  AppState appState,
  String id, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!appState.sessions.any((s) => s.id == id)) {
    if (DateTime.now().isAfter(deadline)) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

Widget _testApp(AppState appState, SessionModel session) =>
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: NotesScreen(session: session),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NotesScreen — tag selection', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_notes_test_');
      appState = await _makeAndInit(
        tmpDir.path,
        initialConfig: ConfigModel(tags: ['calm', 'deep']),
      );
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('1. available tags render as SelectableTagChip widgets',
        (tester) async {
      await tester.pumpWidget(_testApp(appState, _pendingSession()));
      await tester.pump();

      expect(find.byType(SelectableTagChip), findsNWidgets(2));
      expect(find.text('calm'), findsOneWidget);
      expect(find.text('deep'), findsOneWidget);
    });

    testWidgets('2. tapping a tag then saving stores it on the session',
        (tester) async {
      await tester.pumpWidget(_testApp(appState, _pendingSession()));
      await tester.pump();

      await tester.tap(find.text('calm'));
      await tester.pump();

      await tester.ensureVisible(find.text('Save'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await _waitForSession(tester, appState, 'pending-1');

      final saved = appState.sessions.firstWhere((s) => s.id == 'pending-1');
      expect(saved.tags, ['calm'],
          reason: 'selecting a tag chip and saving must persist it on the session');
    });
  });
}
