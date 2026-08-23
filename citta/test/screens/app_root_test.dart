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
import 'package:citta/screens/app_root.dart';
import 'package:citta/screens/main_shell.dart';
import 'package:citta/screens/unlock_screen.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/crypto_service.dart';
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

AudioService _fakeAudioService() => AudioService.withPlayers(
      bellPlayer: _FakeAudioPlayer(),
      musicPlayer: _FakeAudioPlayer(),
      sessionFactory: () async => _FakeAudioSession(),
    );

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds an [AppState] without initializing it, so it stays in its default
/// `isLoading == true` state until the caller awaits [AppState.initialize].
AppState _make(String basePath) {
  final storage = StorageService.withBasePath(basePath);
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
}) async {
  final appState = _make(basePath);
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

  testWidgets(
      'first launch with no saved name shows the splash screen and prompts for a name',
      (tester) async {
    final appState = await tester.runAsync(() => _makeAndInit(tmpDir.path));

    await tester.pumpWidget(_testApp(appState!));
    await tester.pump(); // let AppState finish notifying "loaded"
    await tester.pump(); // let the post-frame callback open the dialog

    expect(find.text('Namaskara'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Welcome to Citta'), findsOneWidget);
  });

  testWidgets('already-configured startup (name already set) skips the prompt',
      (tester) async {
    final appState = await tester.runAsync(() => _makeAndInit(
          tmpDir.path,
          initialConfig: ConfigModel(userName: 'Asha'),
        ));

    await tester.pumpWidget(_testApp(appState!));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Namaskara'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('submitting a name in the prompt persists it and the prompt does not return',
      (tester) async {
    final appState = await tester.runAsync(() => _makeAndInit(tmpDir.path));

    await tester.pumpWidget(_testApp(appState!));
    await tester.pump();
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Asha');
    // The dialog's Continue button fires appState.mutateConfig without
    // awaiting it, so the real storage write it triggers must run (and be
    // waited out) inside runAsync's real zone rather than the fake-async
    // test zone tester.tap() would otherwise run in.
    await tester.runAsync(() async {
      await tester.tap(find.text('Continue'));
      while (appState.config.userName == null) {
        await Future.delayed(const Duration(milliseconds: 5));
      }
    });
    await tester.pump();

    expect(appState.config.userName, 'Asha');
    expect(find.byType(AlertDialog), findsNothing);

    // A later, unrelated AppState change must not resurrect the prompt.
    await tester.runAsync(() => appState.setLanguage(appState.config.language));
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('skipping the prompt leaves the name unset and does not ask again',
      (tester) async {
    final appState = await tester.runAsync(() => _makeAndInit(tmpDir.path));

    await tester.pumpWidget(_testApp(appState!));
    await tester.pump();
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pump();

    expect(appState.config.userName, isNull);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.runAsync(() => appState.setLanguage(appState.config.language));
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('tapping the splash screen dismisses it into the main shell',
      (tester) async {
    final appState = await tester.runAsync(() => _makeAndInit(
          tmpDir.path,
          initialConfig: ConfigModel(userName: 'Asha'),
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
    /// Argon2id cost params for tests only: fast, not secure.
    CryptoService testCryptoService() => CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        );

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
        cryptoService: testCryptoService(),
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');
      await setupStorage.saveConfig(ConfigModel(userName: 'Asha'));

      final freshStorage = StorageService.withBasePath(
        basePath,
        cryptoService: testCryptoService(),
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
