import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' hide AudioSource;
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/unlock_screen.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/crypto_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Test doubles / helpers
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

/// Argon2id cost params for tests only: fast, not secure.
CryptoService _testCryptoService() => CryptoService(
      argon2Parallelism: 1,
      argon2MemoryKiB: 8,
      argon2Iterations: 1,
    );

const _kTestPassword = 'correct horse battery staple';

/// The result of [_makeLockedAppState]: the locked [appState] plus the
/// plaintext [recoveryKey] generated during setup (never persisted, so it
/// can only be recovered by capturing it at generation time like this).
class _LockedInstall {
  final AppState appState;
  final String recoveryKey;

  const _LockedInstall({required this.appState, required this.recoveryKey});
}

/// Sets up an encrypted, committed-recovery-key install with one session on
/// disk, then returns an [AppState] built against a *fresh* [StorageService]
/// instance (no cached key) — i.e. exactly the cache-miss state this screen
/// exists to handle.
Future<_LockedInstall> _makeLockedAppState(String basePath) async {
  final setupStorage =
      StorageService.withBasePath(basePath, cryptoService: _testCryptoService());
  await setupStorage.enableEncryption(password: _kTestPassword);
  final pending = await setupStorage.prepareRecoveryKey();
  await setupStorage.commitRecoveryKey(pending);
  await setupStorage.saveSessions([]);

  final freshStorage =
      StorageService.withBasePath(basePath, cryptoService: _testCryptoService());
  final appState = AppState(
    storageService: freshStorage,
    quoteService: QuoteService(freshStorage),
    audioService: AudioService.withPlayers(
      bellPlayer: _NoopAudioPlayer(),
      musicPlayer: _NoopAudioPlayer(),
      sessionFactory: () async => _NoopAudioSession(),
    ),
    statsService: const StatsService(),
  );
  await appState.initialize();
  return _LockedInstall(appState: appState, recoveryKey: pending.recoveryKey);
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
        home: child,
      ),
    );

final _inputField = find.byKey(const Key('unlockInputField'));
final _submitButton = find.byKey(const Key('unlockSubmitButton'));

// unlockWithPassword()/unlockWithRecoveryKey() perform real Argon2id KDF work
// and real file I/O — pumping and tapping submit must happen inside
// tester.runAsync(), or they hang under fakeAsync.
Future<void> _pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(widget);
    await Future<void>.delayed(const Duration(seconds: 1));
  });
  await tester.pump();
}

Future<void> _submit(WidgetTester tester, String input) async {
  await tester.enterText(_inputField, input);
  await tester.runAsync(() async {
    await tester.tap(_submitButton);
    await Future<void>.delayed(const Duration(seconds: 2));
  });
  await tester.pump();
}

final _errorTextFinder = find.byKey(const Key('unlockErrorText'));

String? _errorTextOf(WidgetTester tester) {
  if (!tester.any(_errorTextFinder)) return null;
  return (tester.widget(_errorTextFinder) as Text).data;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('UnlockScreen', () {
    late Directory tmpDir;
    late AppState appState;
    late String recoveryKey;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_unlock_screen_test_');
      final install = await _makeLockedAppState(tmpDir.path);
      appState = install.appState;
      recoveryKey = install.recoveryKey;
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('the correct password unlocks', (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const UnlockScreen()));
      expect(appState.needsUnlock, isTrue);

      await _submit(tester, _kTestPassword);

      expect(appState.needsUnlock, isFalse);
    });

    testWidgets('the correct recovery key unlocks', (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const UnlockScreen()));
      expect(appState.needsUnlock, isTrue);

      await _submit(tester, recoveryKey);

      expect(appState.needsUnlock, isFalse);
    });

    testWidgets(
        'wrong input shows a generic error, does not crash, and does not '
        'corrupt sessions.json', (tester) async {
      final sessionsPath = '${tmpDir.path}/sessions.json';
      final before =
          await tester.runAsync(() => File(sessionsPath).readAsString());

      await _pumpAndSettle(tester, _wrap(appState, const UnlockScreen()));
      await _submit(tester, 'definitely wrong');

      expect(_errorTextOf(tester), isNotNull);
      expect(appState.needsUnlock, isTrue);
      final after =
          await tester.runAsync(() => File(sessionsPath).readAsString());
      expect(after, before);
    });

    testWidgets(
        'the error is identical for a wrong password-shaped input and a '
        'wrong recovery-key-shaped input — it must not reveal which format '
        'was attempted', (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const UnlockScreen()));

      await _submit(tester, 'wrong plain password');
      final passwordShapedError = _errorTextOf(tester);

      await _submit(tester, 'WRNG-WRNG-WRNG-WRNG-WRNG-WRNG-WRNG-WRNG');
      final recoveryShapedError = _errorTextOf(tester);

      expect(passwordShapedError, isNotNull);
      expect(recoveryShapedError, isNotNull);
      expect(passwordShapedError, recoveryShapedError);
    });

    testWidgets(
        'a recovery key entered in lowercase with stray whitespace still '
        'unlocks', (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const UnlockScreen()));

      await _submit(tester, '  ${recoveryKey.toLowerCase()}  ');

      expect(appState.needsUnlock, isFalse);
      expect(_errorTextOf(tester), isNull);
    });

    testWidgets(
        'corrupt encryption_meta.json shows a distinct error from a wrong '
        'password or recovery key, instead of implying a retry with the '
        'right credential would work', (tester) async {
      await tester.runAsync(
        () => File('${tmpDir.path}/encryption_meta.json')
            .writeAsString('not valid json'),
      );

      await _pumpAndSettle(tester, _wrap(appState, const UnlockScreen()));
      await _submit(tester, _kTestPassword);

      expect(appState.needsUnlock, isTrue);
      final l10n = AppLocalizations.of(tester.element(find.byType(UnlockScreen)))!;
      expect(_errorTextOf(tester), l10n.unlockErrorCorrupted);
      expect(
        _errorTextOf(tester),
        isNot(l10n.unlockErrorGeneric),
        reason: 'a corrupt metadata file must not be reported as if a '
            'different password or recovery key would have worked',
      );
    });
  });
}
