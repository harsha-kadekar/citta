import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' hide AudioSource;
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';
import 'package:citta/widgets/encryption_opt_in.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// IMPORTANT: call only from setUp(), never inside testWidgets() — real async
// I/O does not complete under fakeAsync.
Future<AppState> _makeAndInit(String basePath) async {
  final storage = StorageService.withBasePath(basePath);
  final appState = AppState(
    storageService: storage,
    quoteService: QuoteService(storage),
    audioService: AudioService.withPlayers(
      bellPlayer: _NoopAudioPlayer(),
      musicPlayer: _NoopAudioPlayer(),
      sessionFactory: () async => _NoopAudioSession(),
    ),
    statsService: const StatsService(),
  );
  await appState.initialize();
  return appState;
}

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

final _passwordField = find.byKey(const Key('encryptionPasswordField'));
final _confirmField = find.byKey(const Key('encryptionConfirmPasswordField'));
final _enableButton = find.byKey(const Key('encryptionEnableButton'));
final _toggle = find.byType(SwitchListTile);

Future<void> _enterText(WidgetTester tester, Finder field, String text) =>
    tester.enterText(field, text);

// isEncryptionEnabled performs real dart:io file access — it must run inside
// tester.runAsync(), never awaited directly in a testWidgets body, or it
// hangs for the test's full timeout under the fake-async test zone.
Future<bool> _isEncryptionEnabled(WidgetTester tester, AppState appState) =>
    tester.runAsync(() => appState.storageService.isEncryptionEnabled)
        .then((v) => v!);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EncryptionOptIn – default (off)', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_encryption_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('shows only the toggle, no password fields or button',
        (tester) async {
      await tester.pumpWidget(_wrap(appState, const EncryptionOptIn()));
      await tester.pump();

      expect(_toggle, findsOneWidget);
      expect(_passwordField, findsNothing);
      expect(_confirmField, findsNothing);
      expect(_enableButton, findsNothing);
      expect((tester.widget(_toggle) as SwitchListTile).value, isFalse);
    });
  });

  group('EncryptionOptIn – toggling on', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_encryption_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('reveals password, confirm fields and enable button',
        (tester) async {
      await tester.pumpWidget(_wrap(appState, const EncryptionOptIn()));
      await tester.pump();

      await tester.tap(_toggle);
      await tester.pump();

      expect(_passwordField, findsOneWidget);
      expect(_confirmField, findsOneWidget);
      expect(_enableButton, findsOneWidget);
    });
  });

  group('EncryptionOptIn – toggling off after on', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_encryption_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('hides fields again and leaves encryption disabled',
        (tester) async {
      await tester.pumpWidget(_wrap(appState, const EncryptionOptIn()));
      await tester.pump();

      await tester.tap(_toggle);
      await tester.pump();
      expect(_passwordField, findsOneWidget);

      await tester.tap(_toggle);
      await tester.pump();

      expect(_passwordField, findsNothing);
      expect(_confirmField, findsNothing);
      expect(_enableButton, findsNothing);
      expect(await _isEncryptionEnabled(tester, appState), isFalse);
    });
  });

  group('EncryptionOptIn – validation', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_encryption_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('empty password shows an error and does not enable encryption',
        (tester) async {
      await tester.pumpWidget(_wrap(appState, const EncryptionOptIn()));
      await tester.pump();
      await tester.tap(_toggle);
      await tester.pump();

      await tester.tap(_enableButton);
      await tester.pump();

      final l10n = AppLocalizations.of(
          tester.element(find.byType(EncryptionOptIn)))!;
      expect(find.text(l10n.encryptionErrorEmpty), findsOneWidget);
      expect(await _isEncryptionEnabled(tester, appState), isFalse);
    });

    testWidgets(
        'password shorter than the minimum shows an error and does not enable encryption',
        (tester) async {
      await tester.pumpWidget(_wrap(appState, const EncryptionOptIn()));
      await tester.pump();
      await tester.tap(_toggle);
      await tester.pump();

      await _enterText(tester, _passwordField, 'short1');
      await _enterText(tester, _confirmField, 'short1');
      await tester.tap(_enableButton);
      await tester.pump();

      final l10n = AppLocalizations.of(
          tester.element(find.byType(EncryptionOptIn)))!;
      expect(find.text(l10n.encryptionErrorTooShort(8)), findsOneWidget);
      expect(await _isEncryptionEnabled(tester, appState), isFalse);
    });

    testWidgets(
        'mismatched passwords show an error and do not enable encryption',
        (tester) async {
      await tester.pumpWidget(_wrap(appState, const EncryptionOptIn()));
      await tester.pump();
      await tester.tap(_toggle);
      await tester.pump();

      await _enterText(tester, _passwordField, 'correcthorse');
      await _enterText(tester, _confirmField, 'correctHORSE');
      await tester.tap(_enableButton);
      await tester.pump();

      final l10n = AppLocalizations.of(
          tester.element(find.byType(EncryptionOptIn)))!;
      expect(find.text(l10n.encryptionErrorMismatch), findsOneWidget);
      expect(await _isEncryptionEnabled(tester, appState), isFalse);
    });
  });

  group('EncryptionOptIn – successful submission', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_encryption_test_');
      appState = await _makeAndInit(tmpDir.path);
    });
    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets(
        'valid matching password enables encryption and calls onEncryptionEnabled',
        (tester) async {
      var enabledCallbackCount = 0;
      await tester.pumpWidget(_wrap(
        appState,
        EncryptionOptIn(
          onEncryptionEnabled: () => enabledCallbackCount++,
        ),
      ));
      await tester.pump();
      await tester.tap(_toggle);
      await tester.pump();

      await _enterText(tester, _passwordField, 'correcthorse');
      await _enterText(tester, _confirmField, 'correcthorse');

      // enableEncryption() performs real Argon2id KDF + file I/O, so the tap
      // must run under tester.runAsync() to get genuine wall-clock time.
      await tester.runAsync(() async {
        await tester.tap(_enableButton);
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      await tester.pump();

      expect(await _isEncryptionEnabled(tester, appState), isTrue);
      expect(enabledCallbackCount, equals(1));

      // The form locks after success: no resubmission is possible (a second
      // enableEncryption() call always throws), and the plaintext password
      // is no longer sitting in the widget tree.
      expect(_passwordField, findsNothing);
      expect(_confirmField, findsNothing);
      expect(_enableButton, findsNothing);
      final toggleAfter = tester.widget(_toggle) as SwitchListTile;
      expect(toggleAfter.value, isTrue);
      expect(toggleAfter.onChanged, isNull);
    });

    testWidgets(
        'toggling off while a submission is in flight does not cancel or race it',
        (tester) async {
      var enabledCallbackCount = 0;
      await tester.pumpWidget(_wrap(
        appState,
        EncryptionOptIn(
          onEncryptionEnabled: () => enabledCallbackCount++,
        ),
      ));
      await tester.pump();
      await tester.tap(_toggle);
      await tester.pump();

      await _enterText(tester, _passwordField, 'correcthorse');
      await _enterText(tester, _confirmField, 'correcthorse');

      // Trigger the submit (fire-and-forget from the tap's perspective) and
      // pump once — by then _submitting is already true, since the async
      // handler runs synchronously up to its first await.
      await tester.runAsync(() => tester.tap(_enableButton));
      await tester.pump();

      final duringSubmit = tester.widget(_toggle) as SwitchListTile;
      expect(duringSubmit.value, isTrue);
      expect(duringSubmit.onChanged, isNull,
          reason: 'toggle must be locked while a submission is in flight');

      // Attempting to toggle off mid-flight must be a no-op (disabled
      // switches ignore taps) rather than resetting the UI while the
      // in-flight write still completes underneath it.
      await tester.tap(_toggle);
      await tester.pump();
      expect((tester.widget(_toggle) as SwitchListTile).value, isTrue);

      await tester.runAsync(
          () => Future<void>.delayed(const Duration(seconds: 2)));
      await tester.pump();

      expect(await _isEncryptionEnabled(tester, appState), isTrue);
      expect(enabledCallbackCount, equals(1));
    });
  });
}
