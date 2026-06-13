import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/settings/profile_section.dart';
import 'package:citta/screens/settings/appearance_section.dart';
import 'package:citta/screens/settings/timer_section.dart';
import 'package:citta/screens/settings/bells_section.dart';
import 'package:citta/screens/settings/tags_section.dart';
import 'package:citta/screens/settings/data_section.dart';
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
  @override Future<void> stop() async {}
  @override Future<void> dispose() async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<AppState> _makeAndInit(String basePath,
    {ConfigModel? initialConfig}) async {
  final storage = StorageService.withBasePath(basePath);
  if (initialConfig != null) await storage.saveConfig(initialConfig);
  final appState = AppState(
    storageService: storage,
    quoteService: QuoteService(storage),
    audioService: AudioService.withPlayers(
      bellPlayer: _FakeAudioPlayer(),
      musicPlayer: _FakeAudioPlayer(),
    ),
    statsService: StatsService(),
  );
  await appState.initialize();
  return appState;
}

Widget _wrap(AppState appState, Widget child) =>
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ListView(children: [child])),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ---------------------------------------------------------------------------
  // ProfileSection
  // ---------------------------------------------------------------------------

  group('ProfileSection', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows "not set" when userName is null', (tester) async {
      appState = await _makeAndInit(tmpDir.path);
      await tester.pumpWidget(_wrap(appState, const ProfileSection()));
      await tester.pump();
      expect(find.textContaining('not set', findRichText: true), findsOneWidget);
    });

    testWidgets('shows userName when set', (tester) async {
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(userName: 'Arjuna'));
      await tester.pumpWidget(_wrap(appState, const ProfileSection()));
      await tester.pump();
      expect(find.text('Arjuna'), findsOneWidget);
    });

    testWidgets('tapping name tile opens edit dialog', (tester) async {
      appState = await _makeAndInit(tmpDir.path);
      await tester.pumpWidget(_wrap(appState, const ProfileSection()));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // AppearanceSection
  // ---------------------------------------------------------------------------

  group('AppearanceSection', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows current theme name', (tester) async {
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(themeMode: 'light'));
      await tester.pumpWidget(_wrap(appState, const AppearanceSection()));
      await tester.pump();
      expect(find.textContaining('Light', findRichText: true), findsOneWidget);
    });

    testWidgets('tapping theme tile opens picker dialog', (tester) async {
      appState = await _makeAndInit(tmpDir.path);
      await tester.pumpWidget(_wrap(appState, const AppearanceSection()));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      expect(find.byType(SimpleDialog), findsOneWidget);
    });

    testWidgets('tapping language tile opens picker dialog', (tester) async {
      appState = await _makeAndInit(tmpDir.path);
      await tester.pumpWidget(_wrap(appState, const AppearanceSection()));
      await tester.pump();
      await tester.tap(find.byType(ListTile).at(1));
      await tester.pump();
      expect(find.byType(SimpleDialog), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // TimerSection
  // ---------------------------------------------------------------------------

  group('TimerSection', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows Countdown label when timerMode is countdown',
        (tester) async {
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(timerMode: 'countdown'));
      await tester.pumpWidget(_wrap(appState, const TimerSection()));
      await tester.pump();
      expect(find.textContaining('Countdown', findRichText: true),
          findsOneWidget);
    });

    testWidgets('shows duration tile when countdown mode is active',
        (tester) async {
      appState = await _makeAndInit(tmpDir.path,
          initialConfig:
              ConfigModel(timerMode: 'countdown', countdownDuration: 900));
      await tester.pumpWidget(_wrap(appState, const TimerSection()));
      await tester.pump();
      expect(find.textContaining('15', findRichText: true), findsOneWidget);
    });

    testWidgets('hides duration tile when stopwatch mode is active',
        (tester) async {
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(timerMode: 'stopwatch'));
      await tester.pumpWidget(_wrap(appState, const TimerSection()));
      await tester.pump();
      // Only the mode tile — no duration tile
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('tapping mode tile opens picker dialog', (tester) async {
      appState = await _makeAndInit(tmpDir.path);
      await tester.pumpWidget(_wrap(appState, const TimerSection()));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      expect(find.byType(SimpleDialog), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // BellsSection
  // ---------------------------------------------------------------------------

  group('BellsSection', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('renders start bell, end bell tiles and interval switch',
        (tester) async {
      appState = await _makeAndInit(tmpDir.path);
      await tester.pumpWidget(_wrap(appState, const BellsSection()));
      await tester.pump();
      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('interval sub-tiles hidden when interval is disabled',
        (tester) async {
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(intervalEnabled: false));
      await tester.pumpWidget(_wrap(appState, const BellsSection()));
      await tester.pump();
      // start bell + end bell = 2 ListTiles (no duration/sound)
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('interval sub-tiles visible when interval is enabled',
        (tester) async {
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(intervalEnabled: true));
      await tester.pumpWidget(_wrap(appState, const BellsSection()));
      await tester.pump();
      // start bell + end bell + interval duration + interval sound = 4
      expect(find.byType(ListTile), findsNWidgets(4));
    });
  });

  // ---------------------------------------------------------------------------
  // TagsSection
  // ---------------------------------------------------------------------------

  group('TagsSection', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('renders existing tags as chips', (tester) async {
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(tags: ['calm', 'deep']));
      await tester.pumpWidget(_wrap(appState, const TagsSection()));
      await tester.pump();
      expect(find.widgetWithText(Chip, 'calm'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'deep'), findsOneWidget);
    });

    testWidgets('shows add-tag ActionChip', (tester) async {
      appState = await _makeAndInit(tmpDir.path);
      await tester.pumpWidget(_wrap(appState, const TagsSection()));
      await tester.pump();
      expect(find.byType(ActionChip), findsOneWidget);
    });

    testWidgets('tapping add-tag chip opens dialog', (tester) async {
      appState = await _makeAndInit(tmpDir.path);
      await tester.pumpWidget(_wrap(appState, const TagsSection()));
      await tester.pump();
      await tester.tap(find.byType(ActionChip));
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // DataSection
  // ---------------------------------------------------------------------------

  group('DataSection', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows export and import tiles', (tester) async {
      appState = await _makeAndInit(tmpDir.path);
      await tester.pumpWidget(_wrap(appState, const DataSection()));
      await tester.pump();
      expect(find.byType(ListTile), findsNWidgets(2));
    });
  });
}
