import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' hide AudioSource;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/app_language.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/models/app_theme_mode.dart';
import 'package:citta/models/audio_source.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/settings/profile_section.dart';
import 'package:citta/screens/settings/appearance_section.dart';
import 'package:citta/screens/settings/language_picker.dart';
import 'package:citta/screens/settings/timer_section.dart';
import 'package:citta/screens/settings/bells_section.dart';
import 'package:citta/screens/settings/bg_music_section.dart';
import 'package:citta/screens/settings/tags_section.dart';
import 'package:citta/screens/settings/data_section.dart';
import 'package:citta/screens/settings/settings_widgets.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';
import 'package:citta/theme/app_theme.dart';

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

// Stubs FilePicker.platform so tests can simulate a user picking a file
// without touching the real OS file picker.
class _FakeFilePicker extends FilePicker with MockPlatformInterfaceMixin {
  _FakeFilePicker(this._resultPath);
  final String? _resultPath;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    if (_resultPath == null) return null;
    return FilePickerResult([
      PlatformFile(path: _resultPath, name: 'music.mp3', size: 0),
    ]);
  }
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
      sessionFactory: () async => _FakeAudioSession(),
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

// Wraps with the app's real light/dark themes (unlike `_wrap`, which relies
// on Flutter's default MaterialApp theme) so tests can assert on the actual
// resolved AppColors/DarkAppColors value behind Theme.of(context).
Widget _themedWrap(AppState appState, Widget child, {required bool dark}) =>
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
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
          initialConfig: ConfigModel(themeMode: AppThemeMode.light));
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
              ConfigModel(timerMode: TimerMode.countdown, countdownDuration: 900));
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
          initialConfig: ConfigModel(timerMode: TimerMode.stopwatch));
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

  // ---------------------------------------------------------------------------
  // BgMusicSection
  // ---------------------------------------------------------------------------

  group('BgMusicSection – picking a file', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path);
      FilePicker.platform = _FakeFilePicker('/storage/music/track.mp3');
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('stores the picked path with a custom: prefix',
        (tester) async {
      await tester.pumpWidget(_wrap(appState, const BgMusicSection()));
      await tester.pump();
      // The tap triggers a fire-and-forget async chain (file pick, then a
      // real-disk read+write via AppState.mutateConfig) that testWidgets'
      // onTap dispatch does not await. Run the tap and a real delay inside
      // the same tester.runAsync() zone so that chain gets genuine
      // wall-clock time to finish before we assert on its result.
      await tester.runAsync(() async {
        await tester.tap(find.byType(SettingsTile));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      expect(appState.config.backgroundMusic,
          equals(const AudioSource.custom('/storage/music/track.mp3')));
    });
  });

  group('BgMusicSection – cancelling the file picker', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path);
      FilePicker.platform = _FakeFilePicker(null);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('leaves backgroundMusic unset when the picker returns null',
        (tester) async {
      await tester.pumpWidget(_wrap(appState, const BgMusicSection()));
      await tester.pump();
      await tester.runAsync(() => tester.tap(find.byType(SettingsTile)));
      await tester.pump();
      expect(appState.config.backgroundMusic, isNull);
    });
  });

  group('BgMusicSection – legacy raw-path config', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      // Represents the parsed form of a pre-`custom:`-prefix legacy config
      // (the string-parsing itself is covered by ConfigModel.fromJson tests).
      appState = await _makeAndInit(tmpDir.path,
          initialConfig:
              ConfigModel(backgroundMusic: const AudioSource.custom('/legacy/music.mp3')));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('renders as selected and can be removed', (tester) async {
      await tester.pumpWidget(_wrap(appState, const BgMusicSection()));
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.byIcon(Icons.clear));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      expect(appState.config.backgroundMusic, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Theme.of(context) migration (issue #62)
  // ---------------------------------------------------------------------------

  group('SettingsTile — default trailing chevron color', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    const tile = SettingsTile(title: 'Foo', subtitle: 'Bar');

    testWidgets('uses the light theme hint color in light mode',
        (tester) async {
      await tester.pumpWidget(_themedWrap(appState, tile, dark: false));
      await tester.pump();
      final icon = tester.widget<Icon>(find.byIcon(Icons.chevron_right));
      expect(icon.color, AppColors.textHint,
          reason:
              'default chevron must come from context.adaptiveColors.textHint, not a stray hardcoded literal');
    });

    testWidgets('adapts to the dark theme hint color in dark mode',
        (tester) async {
      await tester.pumpWidget(_themedWrap(appState, tile, dark: true));
      await tester.pump();
      final icon = tester.widget<Icon>(find.byIcon(Icons.chevron_right));
      expect(icon.color, DarkAppColors.textHint);
      expect(icon.color, isNot(AppColors.textHint),
          reason: 'must not stay pinned to the light-theme literal under dark theme');
    });
  });

  group('SectionHeader — title color', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    const header = SectionHeader(title: 'foo');

    testWidgets('uses the light theme hint color in light mode',
        (tester) async {
      await tester.pumpWidget(_themedWrap(appState, header, dark: false));
      await tester.pump();
      final text = tester.widget<Text>(find.text('FOO'));
      expect(text.style?.color, AppColors.textHint);
    });

    testWidgets('adapts to the dark theme hint color in dark mode',
        (tester) async {
      await tester.pumpWidget(_themedWrap(appState, header, dark: true));
      await tester.pump();
      final text = tester.widget<Text>(find.text('FOO'));
      expect(text.style?.color, DarkAppColors.textHint);
      expect(text.style?.color, isNot(AppColors.textHint));
    });
  });

  group('BgMusicSection — remove-music icon color', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(
              backgroundMusic: const AudioSource.custom('/legacy/music.mp3')));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('uses the light theme error color in light mode',
        (tester) async {
      await tester.pumpWidget(
          _themedWrap(appState, const BgMusicSection(), dark: false));
      await tester.pump();
      final icon = tester.widget<Icon>(find.byIcon(Icons.clear));
      expect(icon.color, AppColors.error,
          reason: 'must come from colorScheme.error, not a stray hardcoded literal');
    });

    testWidgets('adapts to the dark theme error color in dark mode',
        (tester) async {
      await tester.pumpWidget(
          _themedWrap(appState, const BgMusicSection(), dark: true));
      await tester.pump();
      final icon = tester.widget<Icon>(find.byIcon(Icons.clear));
      expect(icon.color, DarkAppColors.error);
      expect(icon.color, isNot(AppColors.error));
    });
  });

  group('BellsSection — selected picker option color', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(bellStart: AudioSource.none));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    Future<void> openStartBellPicker(WidgetTester tester) async {
      await tester
          .pumpWidget(_themedWrap(appState, const BellsSection(), dark: false));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
    }

    testWidgets('selected "None" option uses the light theme primary color',
        (tester) async {
      await openStartBellPicker(tester);
      final text = tester.widget<Text>(
          find.descendant(of: find.byType(SimpleDialog), matching: find.text('None')));
      expect(text.style?.color, AppColors.primary);
    });

    testWidgets('selected "None" option adapts to the dark theme primary color',
        (tester) async {
      await tester
          .pumpWidget(_themedWrap(appState, const BellsSection(), dark: true));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      final text = tester.widget<Text>(
          find.descendant(of: find.byType(SimpleDialog), matching: find.text('None')));
      expect(text.style?.color, DarkAppColors.primary);
      expect(text.style?.color, isNot(AppColors.primary));
    });
  });

  group('TimerSection — selected picker option icon color', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(timerMode: TimerMode.countdown));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('selected mode icon uses the light theme primary color',
        (tester) async {
      await tester
          .pumpWidget(_themedWrap(appState, const TimerSection(), dark: false));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      final icon = tester.widget<Icon>(find.byIcon(Icons.timer));
      expect(icon.color, AppColors.primary);
    });

    testWidgets('selected mode icon adapts to the dark theme primary color',
        (tester) async {
      await tester
          .pumpWidget(_themedWrap(appState, const TimerSection(), dark: true));
      await tester.pump();
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();
      final icon = tester.widget<Icon>(find.byIcon(Icons.timer));
      expect(icon.color, DarkAppColors.primary);
      expect(icon.color, isNot(AppColors.primary));
    });
  });

  group('TagsSection — chip delete icon color', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(tags: ['calm']));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('uses the light theme hint color in light mode',
        (tester) async {
      await tester
          .pumpWidget(_themedWrap(appState, const TagsSection(), dark: false));
      await tester.pump();
      final chip = tester.widget<Chip>(find.widgetWithText(Chip, 'calm'));
      expect(chip.deleteIconColor, AppColors.textHint);
    });

    testWidgets('adapts to the dark theme hint color in dark mode',
        (tester) async {
      await tester
          .pumpWidget(_themedWrap(appState, const TagsSection(), dark: true));
      await tester.pump();
      final chip = tester.widget<Chip>(find.widgetWithText(Chip, 'calm'));
      expect(chip.deleteIconColor, DarkAppColors.textHint);
      expect(chip.deleteIconColor, isNot(AppColors.textHint));
    });
  });

  group('LanguagePickerOptions — selected icon and subtitle color', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_settings_test_');
      appState = await _makeAndInit(tmpDir.path,
          initialConfig: ConfigModel(language: AppLanguage.hindi));
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    Widget picker() => LanguagePickerOptions(onSelected: (_) {});

    testWidgets(
        'selected language icon and non-Latin subtitle use light theme colors',
        (tester) async {
      await tester.pumpWidget(_themedWrap(appState, picker(), dark: false));
      await tester.pump();

      final icon = tester.widget<Icon>(find.descendant(
          of: find.widgetWithText(ListTile, 'हिंदी'),
          matching: find.byType(Icon)));
      expect(icon.color, AppColors.primary);

      final subtitle = tester.widget<Text>(find.text('Hindi'));
      expect(subtitle.style?.color, AppColors.textHint);
    });

    testWidgets(
        'selected language icon and non-Latin subtitle adapt to dark theme colors',
        (tester) async {
      await tester.pumpWidget(_themedWrap(appState, picker(), dark: true));
      await tester.pump();

      final icon = tester.widget<Icon>(find.descendant(
          of: find.widgetWithText(ListTile, 'हिंदी'),
          matching: find.byType(Icon)));
      expect(icon.color, DarkAppColors.primary);
      expect(icon.color, isNot(AppColors.primary));

      final subtitle = tester.widget<Text>(find.text('Hindi'));
      expect(subtitle.style?.color, DarkAppColors.textHint);
      expect(subtitle.style?.color, isNot(AppColors.textHint));
    });
  });
}
