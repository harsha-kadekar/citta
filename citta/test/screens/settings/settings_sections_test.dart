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
import 'package:citta/screens/settings/settings_widgets.dart';
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

// IMPORTANT: call only from setUp(), never inside testWidgets() — real async
// I/O does not complete under fakeAsync.
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
    statsService: const StatsService(),
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

  group('ProfileSection – no user name', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows "not set" when userName is null', (tester) async {
      await tester.pumpWidget(_wrap(appState, const ProfileSection()));
      await tester.pump();
      expect(find.text('Not set'), findsOneWidget);
    });

    testWidgets('tapping name tile opens edit dialog', (tester) async {
      await tester.pumpWidget(_wrap(appState, const ProfileSection()));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('ProfileSection – with user name', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(userName: 'Arjuna'));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows userName when set', (tester) async {
      await tester.pumpWidget(_wrap(appState, const ProfileSection()));
      await tester.pump();
      expect(find.text('Arjuna'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // AppearanceSection
  // ---------------------------------------------------------------------------

  group('AppearanceSection – light theme', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(themeMode: 'light'));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows current theme name', (tester) async {
      await tester.pumpWidget(_wrap(appState, const AppearanceSection()));
      await tester.pump();
      expect(find.textContaining('Light', findRichText: true), findsOneWidget);
    });
  });

  group('AppearanceSection – default', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('tapping theme tile opens picker dialog', (tester) async {
      await tester.pumpWidget(_wrap(appState, const AppearanceSection()));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      expect(find.byType(SimpleDialog), findsOneWidget);
    });

    testWidgets('tapping language tile opens picker dialog', (tester) async {
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

  group('TimerSection – countdown mode', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig:
              ConfigModel(timerMode: 'countdown', countdownDuration: 900));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows Countdown label', (tester) async {
      await tester.pumpWidget(_wrap(appState, const TimerSection()));
      await tester.pump();
      expect(
          find.textContaining('Countdown', findRichText: true), findsOneWidget);
    });

    testWidgets('shows duration tile (15 min)', (tester) async {
      await tester.pumpWidget(_wrap(appState, const TimerSection()));
      await tester.pump();
      expect(find.textContaining('15', findRichText: true), findsOneWidget);
    });

    testWidgets('tapping mode tile opens picker dialog', (tester) async {
      await tester.pumpWidget(_wrap(appState, const TimerSection()));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      expect(find.byType(SimpleDialog), findsOneWidget);
    });
  });

  group('TimerSection – stopwatch mode', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(timerMode: 'stopwatch'));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('hides duration tile in stopwatch mode', (tester) async {
      await tester.pumpWidget(_wrap(appState, const TimerSection()));
      await tester.pump();
      // Only the mode tile — no duration tile
      expect(find.byType(SettingsTile), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // BellsSection
  // ---------------------------------------------------------------------------

  group('BellsSection – interval disabled', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(intervalEnabled: false));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('renders start and end bell tiles and the interval switch',
        (tester) async {
      await tester.pumpWidget(_wrap(appState, const BellsSection()));
      await tester.pump();
      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('interval sub-tiles are hidden', (tester) async {
      await tester.pumpWidget(_wrap(appState, const BellsSection()));
      await tester.pump();
      // start bell + end bell = 2 SettingsTiles; no interval duration/sound
      expect(find.byType(SettingsTile), findsNWidgets(2));
    });
  });

  group('BellsSection – interval enabled', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(intervalEnabled: true));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('interval sub-tiles are visible', (tester) async {
      await tester.pumpWidget(_wrap(appState, const BellsSection()));
      await tester.pump();
      // start bell + end bell + interval duration + interval sound = 4
      expect(find.byType(SettingsTile), findsNWidgets(4));
    });
  });

  // ---------------------------------------------------------------------------
  // TagsSection
  // ---------------------------------------------------------------------------

  group('TagsSection – two tags', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(tags: ['calm', 'deep']));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('renders existing tags as chips', (tester) async {
      await tester.pumpWidget(_wrap(appState, const TagsSection()));
      await tester.pump();
      expect(find.widgetWithText(Chip, 'calm'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'deep'), findsOneWidget);
    });
  });

  group('TagsSection – default', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows add-tag ActionChip', (tester) async {
      await tester.pumpWidget(_wrap(appState, const TagsSection()));
      await tester.pump();
      expect(find.byType(ActionChip), findsOneWidget);
    });

    testWidgets('tapping add-tag chip opens dialog', (tester) async {
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
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows export and import tiles', (tester) async {
      await tester.pumpWidget(_wrap(appState, const DataSection()));
      await tester.pump();
      expect(find.byType(SettingsTile), findsNWidgets(2));
    });
  });
}
