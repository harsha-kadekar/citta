import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' hide AudioSource;
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/settings/encryption_section.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';
import 'package:citta/widgets/encryption_opt_in.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _NoopAudioPlayer implements AudioPlayerBase {
  @override
  Future<void> setAsset(String path) async {}
  @override
  Future<void> setFilePath(String path) async {}
  @override
  Future<void> setLoopMode(LoopMode mode) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

class _NoopAudioSession implements AudioSessionBase {
  @override
  Future<void> configure(AudioSessionConfiguration _) async {}
  @override
  Stream<AudioInterruptionEvent> get interruptionEventStream =>
      const Stream.empty();
}

/// A [StorageService] whose [deleteEncryptionMetadataFile] always throws —
/// used to simulate a crash between [StorageService.disableEncryption]'s two
/// steps (the plaintext `sessions.json` write has already committed, but the
/// metadata deletion that would normally follow never runs). Mirrors the
/// equivalent double in `test/services/storage_service_test.dart`.
class _FlakyDeleteMetadataStorageService extends StorageService {
  _FlakyDeleteMetadataStorageService.withBasePath(super.basePath)
      : super.withBasePath();

  @override
  Future<void> deleteEncryptionMetadataFile() async {
    throw const FileSystemException('simulated crash before metadata delete');
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

AppState _appStateFor(StorageService storage) => AppState(
      storageService: storage,
      quoteService: QuoteService(storage),
      audioService: AudioService.withPlayers(
        bellPlayer: _NoopAudioPlayer(),
        musicPlayer: _NoopAudioPlayer(),
        sessionFactory: () async => _NoopAudioSession(),
      ),
      statsService: const StatsService(),
    );

// IMPORTANT: call only from setUp(), never inside testWidgets() — real async
// I/O does not complete under fakeAsync.
Future<AppState> _makeAndInit(String basePath) async {
  final appState = _appStateFor(StorageService.withBasePath(basePath));
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
        home: Scaffold(body: child),
      ),
    );

// EncryptionSection's initial status check and every encryption operation
// perform real dart:io / KDF work, so pumping it (and tapping through it)
// must happen inside tester.runAsync(), or it hangs under fakeAsync.
Future<void> _pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(widget);
    await Future<void>.delayed(const Duration(seconds: 1));
  });
  await tester.pump();
}

Future<bool> _isEncryptionEnabled(WidgetTester tester, AppState appState) =>
    tester
        .runAsync(() => appState.storageService.isEncryptionEnabled)
        .then((v) => v!);

SessionModel _makeSession({String notes = 'peaceful sit'}) => SessionModel(
      id: 'session-1',
      date: DateTime.utc(2024, 1, 1, 8, 0),
      duration: 600,
      timerMode: TimerMode.countdown,
      notes: notes,
      tags: const [],
      completedFully: true,
    );

final _switchFinder = find.byKey(const Key('encryptionSectionSwitch'));
// Scoped to EncryptionOptIn specifically: previous routes (e.g. Settings'
// own SwitchListTile) stay mounted (MaterialPageRoute's maintainState
// defaults to true), so an unscoped find.byType(SwitchListTile) would match
// more than one widget once EnableEncryptionScreen is pushed on top.
final _optInToggle = find.descendant(
  of: find.byType(EncryptionOptIn),
  matching: find.byType(SwitchListTile),
);
final _passwordField = find.byKey(const Key('encryptionPasswordField'));
final _confirmField = find.byKey(const Key('encryptionConfirmPasswordField'));
final _enableButton = find.byKey(const Key('encryptionEnableButton'));
final _ackCheckbox = find.byKey(const Key('recoveryKeyAckCheckbox'));
final _continueButton = find.byKey(const Key('recoveryKeyContinueButton'));
final _disableCancelButton =
    find.byKey(const Key('encryptionDisableCancelButton'));
final _disableConfirmButton =
    find.byKey(const Key('encryptionDisableConfirmButton'));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EncryptionSection – disabled by default', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_enc_section_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows the switch off with the disabled subtitle',
        (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const EncryptionSection()));

      expect(tester.widget<SwitchListTile>(_switchFinder).value, isFalse);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(EncryptionSection)))!;
      expect(find.text(l10n.settingsEncryptionSubtitleDisabled),
          findsOneWidget);
    });
  });

  group('EncryptionSection – already enabled', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_enc_section_test_');
      appState = await _makeAndInit(tmpDir.path);
      await appState.storageService
          .enableEncryption(password: 'correct horse battery staple');
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows the switch on with the enabled subtitle',
        (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const EncryptionSection()));

      expect(tester.widget<SwitchListTile>(_switchFinder).value, isTrue);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(EncryptionSection)))!;
      expect(
          find.text(l10n.settingsEncryptionSubtitleEnabled), findsOneWidget);
    });
  });

  group('EncryptionSection – enabling later', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_enc_section_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
        'tapping the switch walks through opt-in and the recovery key '
        'screen, ending back on Settings with encryption enabled',
        (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const EncryptionSection()));

      // The whole flow runs in a single runAsync call: the switch tap starts
      // an async chain (Navigator.push awaited inside EncryptionSection,
      // eventually resolved only once RecoveryKeyScreen pops all the way
      // back) that must stay in one zone throughout — completing part of it
      // from a separate runAsync call would resume the rest back in the
      // fake-async test zone, where none of the real KDF/file I/O below it
      // (enableEncryption, prepareRecoveryKey, commitRecoveryKey,
      // isEncryptionEnabled) can actually progress.
      await tester.runAsync(() async {
        await tester.tap(_switchFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Now on EnableEncryptionScreen: reveal EncryptionOptIn's fields.
        await tester.tap(_optInToggle);
        await tester.pump();

        await tester.enterText(_passwordField, 'correcthorse');
        await tester.enterText(_confirmField, 'correcthorse');

        await tester.tap(_enableButton);
        await Future<void>.delayed(const Duration(seconds: 2));

        // onEncryptionEnabled pushes RecoveryKeyScreen, whose initState
        // kicks off prepareRecoveryKey()'s real KDF/file work.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await Future<void>.delayed(const Duration(seconds: 1));
        await tester.pump();

        await tester.tap(_ackCheckbox);
        await tester.pump();

        await tester.tap(_continueButton);
        await Future<void>.delayed(const Duration(seconds: 1));

        // onContinue pops both routes, back to Settings, where
        // EncryptionSection re-checks isEncryptionEnabled.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      expect(_switchFinder, findsOneWidget);
      expect(tester.widget<SwitchListTile>(_switchFinder).value, isTrue);
      expect(await _isEncryptionEnabled(tester, appState), isTrue);
    });
  });

  group('EncryptionSection – disabling', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_enc_section_test_');
      appState = await _makeAndInit(tmpDir.path);
      await appState.storageService
          .enableEncryption(password: 'correct horse battery staple');
      await appState.storageService.saveSessions([_makeSession()]);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('Cancel on the confirm dialog leaves encryption enabled',
        (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const EncryptionSection()));

      await tester.tap(_switchFinder);
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(_disableCancelButton);
      await tester.pump();

      expect(tester.widget<SwitchListTile>(_switchFinder).value, isTrue);
      expect(await _isEncryptionEnabled(tester, appState), isTrue);
    });

    testWidgets(
        'confirming disables encryption and preserves session content',
        (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const EncryptionSection()));

      // The whole chain (switch tap -> dialog -> confirm tap ->
      // disableEncryption's real I/O) must run in a single runAsync call:
      // showDialog's Future is created here, and completing it from a
      // *separate* runAsync call would resume its continuation back in the
      // fake-async test zone, where the real I/O inside disableEncryption()
      // never progresses.
      await tester.runAsync(() async {
        await tester.tap(_switchFinder);
        await tester.pump();
        await tester.tap(_disableConfirmButton);
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      expect(tester.widget<SwitchListTile>(_switchFinder).value, isFalse);
      expect(await _isEncryptionEnabled(tester, appState), isFalse);

      final sessions =
          await tester.runAsync(() => appState.storageService.loadSessions());
      expect(sessions!.single.notes, 'peaceful sit');
    });
  });

  group('EncryptionSection – interrupted disable', () {
    late Directory tmpDir;
    late StorageService flakyStorage;
    late AppState flakyAppState;

    // Real I/O setup happens here, not inside testWidgets(), for the same
    // reason _makeAndInit()-style helpers elsewhere in this codebase always
    // run from setUp(): this body runs outside the fake-async test zone, so
    // real Argon2/file work completes normally instead of stalling.
    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_enc_section_test_');
      flakyStorage =
          _FlakyDeleteMetadataStorageService.withBasePath(tmpDir.path);
      flakyAppState = _appStateFor(flakyStorage);
      await flakyAppState.initialize();
      await flakyStorage.enableEncryption(
          password: 'correct horse battery staple');
      await flakyStorage.saveSessions([_makeSession()]);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
        'a crash mid-disable does not lose data and can be completed on '
        'retry after a restart', (tester) async {
      await _pumpAndSettle(
          tester, _wrap(flakyAppState, const EncryptionSection()));

      await tester.runAsync(() async {
        await tester.tap(_switchFinder);
        await tester.pump();
        await tester.tap(_disableConfirmButton);
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      final l10n = AppLocalizations.of(
          tester.element(find.byType(EncryptionSection)))!;
      expect(
          find.text(l10n.settingsEncryptionDisableError), findsOneWidget);
      // The failed attempt must not misreport encryption as off.
      expect(tester.widget<SwitchListTile>(_switchFinder).value, isTrue);
      // Tear down this tree (disposing its ScaffoldMessenger/SnackBar,
      // including the SnackBar's real dismiss timer) before building the
      // next one, so nothing from this attempt is left running in the
      // background once the test finishes.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // "Restart": a fresh, non-flaky StorageService over the same directory
      // must still see the metadata (untouched by the crash) and the
      // plaintext sessions.json the interrupted write already committed —
      // proving no data was lost. A bare StorageService (rather than a
      // second full AppState) keeps this to pure dart:io/crypto work, which
      // is what tester.runAsync() is for; AppState.initialize() also loads
      // bundled quote assets over a platform channel, which — unlike file
      // I/O — must run in the normal test zone, not runAsync's real zone.
      await tester.runAsync(() async {
        final freshStorage = StorageService.withBasePath(tmpDir.path);
        expect(await freshStorage.isEncryptionEnabled, isTrue);
        final unlocked = await freshStorage
            .unlockWithPassword('correct horse battery staple');
        expect(unlocked, isTrue);
        final sessions = await freshStorage.loadSessions();
        expect(sessions.single.notes, 'peaceful sit');

        // Retrying the disable now completes cleanly.
        await freshStorage.disableEncryption();
        expect(await freshStorage.isEncryptionEnabled, isFalse);
        final sessionsAfter = await freshStorage.loadSessions();
        expect(sessionsAfter.single.notes, 'peaceful sit');
      });
    });
  });
}
