import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' hide AudioSource;
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/change_password_screen.dart';
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
const _kNewPassword = 'a brand new password';

/// Sets up an encrypted install (already unlocked, matching how a user
/// reaches this screen from Settings) and returns an [AppState] over it.
Future<AppState> _makeUnlockedAppState(String basePath) async {
  final storage =
      StorageService.withBasePath(basePath, cryptoService: _testCryptoService());
  await storage.enableEncryption(password: _kTestPassword);
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

// Wraps [child] behind a placeholder home route, with a button that pushes
// it via Navigator — needed to test that a successful change pops back,
// since [_wrap] makes the screen the app's only route (nothing to pop to).
Widget _wrapPushed(AppState appState, Widget child) =>
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const Key('openChangePasswordScreen'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => child),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

final _currentField = find.byKey(const Key('changePasswordCurrentField'));
final _newField = find.byKey(const Key('changePasswordNewField'));
final _confirmField = find.byKey(const Key('changePasswordConfirmField'));
final _submitButton = find.byKey(const Key('changePasswordSubmitButton'));
final _errorTextFinder = find.byKey(const Key('changePasswordErrorText'));

// changePassword() performs real Argon2id KDF work and real file I/O —
// pumping and tapping submit must happen inside tester.runAsync(), or it
// hangs under fakeAsync.
Future<void> _pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(widget);
    await Future<void>.delayed(const Duration(seconds: 1));
  });
  await tester.pump();
}

Future<void> _submit(
  WidgetTester tester, {
  required String current,
  required String newPassword,
  required String confirm,
}) async {
  await tester.enterText(_currentField, current);
  await tester.enterText(_newField, newPassword);
  await tester.enterText(_confirmField, confirm);
  await tester.runAsync(() async {
    await tester.tap(_submitButton);
    await Future<void>.delayed(const Duration(seconds: 2));
  });
  await tester.pump();
}

String? _errorTextOf(WidgetTester tester) {
  if (!tester.any(_errorTextFinder)) return null;
  return (tester.widget(_errorTextFinder) as Text).data;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ChangePasswordScreen', () {
    late Directory tmpDir;
    late AppState appState;

    setUp(() async {
      tmpDir =
          Directory.systemTemp.createTempSync('citta_change_password_test_');
      appState = await _makeUnlockedAppState(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    testWidgets('empty fields show an error and never call storage',
        (tester) async {
      await _pumpAndSettle(
          tester, _wrap(appState, const ChangePasswordScreen()));

      await _submit(tester, current: '', newPassword: '', confirm: '');

      expect(_errorTextOf(tester), isNotNull);
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });

    testWidgets('a new password shorter than the minimum shows an error',
        (tester) async {
      await _pumpAndSettle(
          tester, _wrap(appState, const ChangePasswordScreen()));

      await _submit(
        tester,
        current: _kTestPassword,
        newPassword: 'short',
        confirm: 'short',
      );

      expect(_errorTextOf(tester), isNotNull);
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });

    testWidgets('mismatched new/confirm passwords show an error',
        (tester) async {
      await _pumpAndSettle(
          tester, _wrap(appState, const ChangePasswordScreen()));

      await _submit(
        tester,
        current: _kTestPassword,
        newPassword: _kNewPassword,
        confirm: 'something else entirely',
      );

      expect(_errorTextOf(tester), isNotNull);
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });

    testWidgets(
        'the wrong current password shows an inline error and leaves the '
        'screen open with the old password still working', (tester) async {
      await _pumpAndSettle(
          tester, _wrap(appState, const ChangePasswordScreen()));

      await _submit(
        tester,
        current: 'totally wrong',
        newPassword: _kNewPassword,
        confirm: _kNewPassword,
      );

      expect(_errorTextOf(tester), isNotNull);
      expect(find.byType(ChangePasswordScreen), findsOneWidget);

      final freshService = StorageService.withBasePath(tmpDir.path,
          cryptoService: _testCryptoService());
      final stillWorks =
          await tester.runAsync(() => freshService.unlockWithPassword(_kTestPassword));
      expect(stillWorks, true);
    });

    testWidgets(
        'a successful change pops the screen; the old password stops '
        'working and the new one works', (tester) async {
      await _pumpAndSettle(
          tester, _wrapPushed(appState, const ChangePasswordScreen()));
      await tester.tap(find.byKey(const Key('openChangePasswordScreen')));
      await tester.pumpAndSettle();

      await _submit(
        tester,
        current: _kTestPassword,
        newPassword: _kNewPassword,
        confirm: _kNewPassword,
      );
      await tester.pumpAndSettle();

      expect(find.byType(ChangePasswordScreen), findsNothing);

      final oldPasswordService = StorageService.withBasePath(tmpDir.path,
          cryptoService: _testCryptoService());
      final oldWorks = await tester
          .runAsync(() => oldPasswordService.unlockWithPassword(_kTestPassword));
      expect(oldWorks, false);

      final newPasswordService = StorageService.withBasePath(tmpDir.path,
          cryptoService: _testCryptoService());
      final newWorks = await tester
          .runAsync(() => newPasswordService.unlockWithPassword(_kNewPassword));
      expect(newWorks, true);
    });
  });
}
