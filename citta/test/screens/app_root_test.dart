import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/app_language.dart';
import 'package:citta/models/app_theme_mode.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/app_root.dart';
import 'package:citta/screens/first_time_setup_screen.dart';
import 'package:citta/screens/language_selection_screen.dart';
import 'package:citta/screens/main_shell.dart';
import 'package:citta/screens/recovery_key_screen.dart';
import 'package:citta/screens/splash_screen.dart';
import 'package:citta/screens/unlock_screen.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/crypto_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';
import 'package:citta/widgets/encryption_opt_in.dart';

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

AudioService _fakeAudioService() => AudioService.withPlayers(
      bellPlayer: _FakeAudioPlayer(),
      musicPlayer: _FakeAudioPlayer(),
      sessionFactory: () async => _FakeAudioSession(),
    );

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Argon2id cost params for tests only: fast, not secure. Any test that
/// exercises real encryption (enableEncryption/prepareRecoveryKey) must use
/// this — the production defaults are deliberately expensive and, combined
/// with a fire-and-forget async chain outside tester.runAsync(), can hang a
/// test indefinitely rather than merely running slowly.
CryptoService _testCryptoService() => CryptoService(
      argon2Parallelism: 1,
      argon2MemoryKiB: 8,
      argon2Iterations: 1,
    );

/// FirstTimeSetupScreen's initState kicks off a real dart:io check
/// (StorageService.isEncryptionEnabled) to decide whether to show the
/// encryption opt-in or an "already enabled" notice. Like
/// EncryptionSection's own status check, that must run — and be given real
/// time to resolve — inside tester.runAsync(), or it never completes under
/// fakeAsync. Use this instead of a bare pumpWidget + pump() sequence
/// anywhere the pump might newly build FirstTimeSetupScreen.
Future<void> _pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(widget);
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pump();
}

/// Builds an [AppState] without initializing it, so it stays in its default
/// `isLoading == true` state until the caller awaits [AppState.initialize].
AppState _make(String basePath, {CryptoService? cryptoService}) {
  final storage = cryptoService == null
      ? StorageService.withBasePath(basePath)
      : StorageService.withBasePath(basePath, cryptoService: cryptoService);
  return AppState(
    storageService: storage,
    quoteService: QuoteService(storage),
    audioService: _fakeAudioService(),
    statsService: const StatsService(),
  );
}

Future<AppState> _makeAndInit(
  String basePath, {
  ConfigModel? initialConfig,
  CryptoService? cryptoService,
}) async {
  final appState = _make(basePath, cryptoService: cryptoService);
  if (initialConfig != null) {
    await appState.storageService.saveConfig(initialConfig);
  }
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
        home: AppRoot(),
      ),
    );

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('citta_app_root_test_');
  });

  tearDown(() => tmpDir.deleteSync(recursive: true));

  testWidgets('shows a loading indicator while AppState is still loading',
      (tester) async {
    final appState = _make(tmpDir.path);

    await tester.pumpWidget(_testApp(appState));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  group('first-launch language picker (issue #57)', () {
    testWidgets(
        'fresh install shows the language picker before any other first-run UI',
        (tester) async {
      final appState = await tester.runAsync(() => _makeAndInit(tmpDir.path));

      await tester.pumpWidget(_testApp(appState!));
      await tester.pump();
      await tester.pump();

      expect(find.byType(LanguageSelectionScreen), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('selecting a language persists it and marks selection completed',
        (tester) async {
      final appState = await tester.runAsync(() => _makeAndInit(tmpDir.path));

      await tester.pumpWidget(_testApp(appState!));
      await tester.pump();
      await tester.pump();

      expect(find.byType(LanguageSelectionScreen), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.text('हिंदी'));
        while (!appState.config.hasCompletedLanguageSelection) {
          await Future.delayed(const Duration(milliseconds: 5));
        }
      });
      await tester.pump();

      expect(appState.config.language, AppLanguage.hindi);
      expect(appState.config.hasCompletedLanguageSelection, isTrue);
      expect(find.byType(LanguageSelectionScreen), findsNothing);
    });

    testWidgets(
        'explicitly picking System Default also marks selection completed',
        (tester) async {
      final appState = await tester.runAsync(() => _makeAndInit(tmpDir.path));

      await tester.pumpWidget(_testApp(appState!));
      await tester.pump();
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('System Default'));
        while (!appState.config.hasCompletedLanguageSelection) {
          await Future.delayed(const Duration(milliseconds: 5));
        }
      });
      await tester.pump();

      expect(appState.config.language, AppLanguage.system);
      expect(appState.config.hasCompletedLanguageSelection, isTrue);
      expect(find.byType(LanguageSelectionScreen), findsNothing);
    });

    testWidgets('does not reappear on a subsequent launch after completion',
        (tester) async {
      final appState = await tester.runAsync(() => _makeAndInit(
            tmpDir.path,
            initialConfig: ConfigModel(hasCompletedLanguageSelection: true),
          ));

      await tester.pumpWidget(_testApp(appState!));
      await tester.pump();
      await tester.pump();

      expect(find.byType(LanguageSelectionScreen), findsNothing);
    });
  });

  group('combined first-time setup screen (issue #59)', () {
    testWidgets(
        'fresh install (after language selection) shows the combined setup '
        'screen instead of a name-prompt dialog', (tester) async {
      final appState = await tester.runAsync(() => _makeAndInit(
            tmpDir.path,
            initialConfig: ConfigModel(hasCompletedLanguageSelection: true),
          ));

      await _pumpAndSettle(tester, _testApp(appState!));

      expect(find.byType(FirstTimeSetupScreen), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('does not reappear on a subsequent launch after completion',
        (tester) async {
      final appState = await tester.runAsync(() => _makeAndInit(
            tmpDir.path,
            initialConfig: ConfigModel(
              userName: 'Asha',
              hasCompletedLanguageSelection: true,
              hasCompletedFirstTimeSetup: true,
            ),
          ));

      await _pumpAndSettle(tester, _testApp(appState!));

      expect(find.byType(FirstTimeSetupScreen), findsNothing);
      expect(find.textContaining('Namaskara'), findsOneWidget);
    });

    testWidgets(
        'completing without enabling encryption persists name and theme, '
        'marks setup completed, and proceeds straight to the splash screen',
        (tester) async {
      final appState = await tester.runAsync(() => _makeAndInit(
            tmpDir.path,
            initialConfig: ConfigModel(hasCompletedLanguageSelection: true),
          ));

      await _pumpAndSettle(tester, _testApp(appState!));

      await tester.enterText(
          find.byKey(const Key('firstTimeSetupNameField')), 'Asha');
      await tester.tap(find.byKey(const Key('firstTimeSetupTheme_dark')));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.ensureVisible(find.byKey(const Key('firstTimeSetupContinueButton')));
        await tester.tap(find.byKey(const Key('firstTimeSetupContinueButton')));
        while (!appState.config.hasCompletedFirstTimeSetup) {
          await Future.delayed(const Duration(milliseconds: 5));
        }
      });
      await tester.pump();
      await tester.pump();

      expect(appState.config.userName, 'Asha');
      expect(appState.config.themeMode, AppThemeMode.dark);
      expect(appState.config.hasCompletedFirstTimeSetup, isTrue);
      expect(find.byType(FirstTimeSetupScreen), findsNothing);
      expect(find.byType(RecoveryKeyScreen), findsNothing);
    });

    testWidgets('leaving the name field empty persists no name',
        (tester) async {
      final appState = await tester.runAsync(() => _makeAndInit(
            tmpDir.path,
            initialConfig: ConfigModel(hasCompletedLanguageSelection: true),
          ));

      await _pumpAndSettle(tester, _testApp(appState!));

      await tester.runAsync(() async {
        await tester.ensureVisible(find.byKey(const Key('firstTimeSetupContinueButton')));
        await tester.tap(find.byKey(const Key('firstTimeSetupContinueButton')));
        while (!appState.config.hasCompletedFirstTimeSetup) {
          await Future.delayed(const Duration(milliseconds: 5));
        }
      });
      await tester.pump();

      expect(appState.config.userName, isNull);
    });

    testWidgets(
        'enabling encryption routes through the recovery key screen before '
        'finishing setup', (tester) async {
      final appState = await tester.runAsync(() => _makeAndInit(
            tmpDir.path,
            initialConfig: ConfigModel(hasCompletedLanguageSelection: true),
            cryptoService: _testCryptoService(),
          ));

      await _pumpAndSettle(tester, _testApp(appState!));

      expect(find.byType(EncryptionOptIn), findsOneWidget);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('encryptionPasswordField')),
          'correct horse battery staple');
      await tester.enterText(
          find.byKey(const Key('encryptionConfirmPasswordField')),
          'correct horse battery staple');

      await tester.runAsync(() async {
        await tester.ensureVisible(find.byKey(const Key('encryptionEnableButton')));
        await tester.tap(find.byKey(const Key('encryptionEnableButton')));
        await tester.pump();
        while (!await appState.storageService.isEncryptionEnabled) {
          await Future.delayed(const Duration(milliseconds: 5));
        }
      });
      await tester.pump();
      await tester.pump();

      // The continue tap's fire-and-forget async work (persisting
      // name/theme, then pushing RecoveryKeyScreen, whose initState kicks
      // off a real prepareRecoveryKey() Argon2id derivation) must run and
      // fully settle inside this same runAsync call — pumping outside it
      // would build that widget tree in the fake-async zone instead, where
      // the real derivation Future never resolves (see
      // test/screens/recovery_key_screen_test.dart's _pumpAndSettle).
      await tester.runAsync(() async {
        await tester.ensureVisible(find.byKey(const Key('firstTimeSetupContinueButton')));
        await tester.tap(find.byKey(const Key('firstTimeSetupContinueButton')));
        await tester.pump();
        await tester.pump();
        while (find.byType(RecoveryKeyScreen).evaluate().isEmpty) {
          await Future.delayed(const Duration(milliseconds: 5));
          await tester.pump();
        }
      });
      await tester.pump();

      expect(find.byType(RecoveryKeyScreen), findsOneWidget);
      expect(appState.config.hasCompletedFirstTimeSetup, isFalse,
          reason:
              'setup is not complete until the recovery key step is acknowledged');

      await tester.tap(find.byKey(const Key('recoveryKeyAckCheckbox')));
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('recoveryKeyContinueButton')));
        await tester.pump();
        while (!appState.config.hasCompletedFirstTimeSetup) {
          await Future.delayed(const Duration(milliseconds: 5));
        }
      });
      await tester.pump();
      await tester.pump();

      expect(appState.config.hasCompletedFirstTimeSetup, isTrue);
      expect(find.byType(RecoveryKeyScreen), findsNothing);
      expect(find.byType(FirstTimeSetupScreen), findsNothing);
    });
  });

  group('resuming an interrupted setup (issue #59)', () {
    // NOTE: mirrors setUpLockedAppState in the "locked state" group below —
    // every StorageService/AppState here must be *constructed* inside
    // tester.runAsync(), not just initialized there. StorageService's write
    // lock chains off a Future created at construction time, and that
    // Future's zone must match the zone _writeLock.run() is later awaited
    // from, or every write (mutateConfig included) hangs for the full test
    // timeout instead of failing fast.
    Future<AppState> setUpInterruptedSetupAppState(String basePath) async {
      final setupStorage = StorageService.withBasePath(
        basePath,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.saveConfig(ConfigModel(
        hasCompletedLanguageSelection: true,
        userName: 'Asha',
        themeMode: AppThemeMode.dark,
      ));
      await setupStorage.enableEncryption(
          password: 'correct horse battery staple');

      final freshStorage = StorageService.withBasePath(
        basePath,
        cryptoService: _testCryptoService(),
      );
      final appState = AppState(
        storageService: freshStorage,
        quoteService: QuoteService(freshStorage),
        audioService: _fakeAudioService(),
        statsService: const StatsService(),
      );
      await appState.initialize();
      return appState;
    }

    testWidgets(
        'relaunching after enabling encryption but before finishing setup '
        'unlocks first, then resumes on the setup screen with encryption '
        'already enabled and name/theme preserved', (tester) async {
      final appState = await tester
          .runAsync(() => setUpInterruptedSetupAppState(tmpDir.path));

      await tester.pumpWidget(_testApp(appState!));
      await tester.pump();
      await tester.pump();

      // A fresh process with encryption enabled must unlock before anything
      // else, including a resumed setup.
      expect(find.byType(UnlockScreen), findsOneWidget);
      expect(find.byType(FirstTimeSetupScreen), findsNothing);

      // Unlocking rebuilds AppRoot into FirstTimeSetupScreen, whose
      // initState kicks off a real dart:io check — that pump must happen
      // (and be given real time to resolve) inside this same runAsync call.
      await tester.runAsync(() async {
        expect(
          await appState.unlockWithPassword('correct horse battery staple'),
          isTrue,
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.byType(UnlockScreen), findsNothing);
      expect(find.byType(FirstTimeSetupScreen), findsOneWidget,
          reason: 'setup was never marked complete, so it must resume '
              'rather than dropping into the app');

      final nameField = tester
          .widget<TextField>(find.byKey(const Key('firstTimeSetupNameField')));
      expect(nameField.controller!.text, 'Asha');

      // Encryption must not be re-prompted for.
      expect(find.byType(EncryptionOptIn), findsNothing);
      expect(find.byKey(const Key('firstTimeSetupEncryptionEnabledNotice')),
          findsOneWidget);

      // Completing now must still go through the (uncommitted) recovery key
      // step — it was never shown before the app was killed. As above, the
      // tap's fire-and-forget async chain (including RecoveryKeyScreen's
      // real prepareRecoveryKey() derivation) must run and settle inside
      // this same runAsync call.
      await tester.runAsync(() async {
        await tester.ensureVisible(find.byKey(const Key('firstTimeSetupContinueButton')));
        await tester.tap(find.byKey(const Key('firstTimeSetupContinueButton')));
        await tester.pump();
        await tester.pump();
        while (find.byType(RecoveryKeyScreen).evaluate().isEmpty) {
          await Future.delayed(const Duration(milliseconds: 5));
          await tester.pump();
        }
      });
      await tester.pump();

      expect(find.byType(RecoveryKeyScreen), findsOneWidget);
      expect(appState.config.themeMode, AppThemeMode.dark,
          reason: 'the pre-filled theme choice must survive completing setup');
    });
  });

  testWidgets('tapping the splash screen dismisses it into the main shell',
      (tester) async {
    final appState = await tester.runAsync(() => _makeAndInit(
          tmpDir.path,
          initialConfig: ConfigModel(
            userName: 'Asha',
            hasCompletedLanguageSelection: true,
            hasCompletedFirstTimeSetup: true,
          ),
        ));

    await tester.pumpWidget(_testApp(appState!));
    await tester.pump();
    await tester.pump();

    expect(find.byType(MainShell), findsNothing);

    await tester.tap(find.text('Namaskara, Asha'));
    await tester.pump();

    expect(find.byType(MainShell), findsOneWidget);
  });

  group('locked state (issue #53)', () {
    // NOTE: StorageService (and the AppState wrapping it) must be
    // constructed *inside* tester.runAsync(), not in the surrounding
    // fake-async test body — StorageService's internal write lock chains
    // off a Future created at construction time, and that Future's zone
    // must match the zone `_writeLock.run()` is later awaited from, or the
    // chained continuation never fires and every write hangs for the full
    // test timeout instead of failing fast.
    Future<AppState> setUpLockedAppState(String basePath) async {
      final setupStorage = StorageService.withBasePath(
        basePath,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');
      await setupStorage.saveConfig(ConfigModel(
        userName: 'Asha',
        hasCompletedLanguageSelection: true,
        hasCompletedFirstTimeSetup: true,
      ));

      final freshStorage = StorageService.withBasePath(
        basePath,
        cryptoService: _testCryptoService(),
      );
      final appState = AppState(
        storageService: freshStorage,
        quoteService: QuoteService(freshStorage),
        audioService: _fakeAudioService(),
        statsService: const StatsService(),
      );
      await appState.initialize();
      return appState;
    }

    testWidgets(
        'encryption enabled with no cached key shows UnlockScreen instead '
        'of the splash screen or main shell', (tester) async {
      final appState =
          await tester.runAsync(() => setUpLockedAppState(tmpDir.path));

      await tester.pumpWidget(_testApp(appState!));
      await tester.pump();
      await tester.pump();

      expect(find.byType(UnlockScreen), findsOneWidget);
      expect(find.byType(MainShell), findsNothing);
      expect(find.byType(AlertDialog), findsNothing,
          reason: 'the name prompt must not be superimposed over the lock screen');
    });

    testWidgets(
        'a successful unlock reveals the splash screen (no bypass path was '
        'needed)', (tester) async {
      final appState =
          await tester.runAsync(() => setUpLockedAppState(tmpDir.path));

      await tester.pumpWidget(_testApp(appState!));
      await tester.pump();
      await tester.pump();
      expect(find.byType(UnlockScreen), findsOneWidget);

      await tester.runAsync(() async {
        expect(
          await appState.unlockWithPassword('correct horse battery staple'),
          isTrue,
        );
      });
      await tester.pump();
      await tester.pump();

      expect(find.byType(UnlockScreen), findsNothing);
    });
  });
}
