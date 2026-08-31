import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' hide AudioSource;
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/recovery_key_screen.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';

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
        home: child,
      ),
    );

// Wraps [child] behind a placeholder home route, with a button that pushes
// it via Navigator — needed to test back-navigation, since [_wrap] makes
// the screen the app's only route (nothing to pop to, so no back button
// would ever appear regardless of the screen's own behavior).
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
                key: const Key('openRecoveryKeyScreen'),
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

final _recoveryKeyText = find.byKey(const Key('recoveryKeyText'));
final _copyButton = find.byKey(const Key('recoveryKeyCopyButton'));
final _shareButton = find.byKey(const Key('recoveryKeyShareButton'));
final _ackCheckbox = find.byKey(const Key('recoveryKeyAckCheckbox'));
final _continueButton = find.byKey(const Key('recoveryKeyContinueButton'));

// prepareRecoveryKey() performs real Argon2id KDF work, and commitRecoveryKey()
// performs real file I/O — pumping the screen, and tapping Continue, must
// happen inside tester.runAsync(), or they hang under fakeAsync.
Future<void> _pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(widget);
    await Future<void>.delayed(const Duration(seconds: 2));
  });
  await tester.pump();
}

String _recoveryKeyOf(WidgetTester tester) =>
    (tester.widget(find.descendant(
      of: _recoveryKeyText,
      matching: find.byType(SelectableText),
    )) as SelectableText)
        .data!;

Future<bool> _hasCommittedRecoveryKey(
  WidgetTester tester,
  String basePath,
) =>
    tester.runAsync(() async {
      final content =
          await File('$basePath/encryption_meta.json').readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return json['wrappedMasterKeyRecovery'] != null;
    }).then((v) => v!);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RecoveryKeyScreen', () {
    late Directory tmpDir;
    late AppState appState;

    // Clipboard.setData/getData go through a real platform channel with no
    // handler under the test binding, which hangs forever inside pump()'s
    // fake-async zone rather than throwing — so tests stub the channel with
    // an in-memory fake instead of exercising the real Clipboard round-trip.
    String? clipboardText;

    setUp(() async {
      tmpDir = Directory.systemTemp.createTempSync('citta_recovery_key_test_');
      appState = await _makeAndInit(tmpDir.path);
      await appState.storageService
          .enableEncryption(password: 'correct horse battery staple');

      clipboardText = null;
      TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardText = (call.arguments as Map)['text'] as String?;
        }
        return null;
      });
    });
    tearDown(() {
      TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
      tmpDir.deleteSync(recursive: true);
    });

    testWidgets('generates and displays a recovery key matching the '
        'expected format, without persisting it yet', (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const RecoveryKeyScreen()));

      expect(_recoveryKeyText, findsOneWidget);
      final key = _recoveryKeyOf(tester);
      expect(key, matches(RegExp(r'^[A-Z2-9]{4}(-[A-Z2-9]{4}){7}$')));
      // Merely showing the key must not commit it — only an explicit
      // acknowledgment + Continue may.
      expect(await _hasCommittedRecoveryKey(tester, tmpDir.path), isFalse);
    });

    // Regression test (codex review, issue #54): encryption is already
    // committed by the time this screen shows (enableEncryption() ran
    // before it was pushed), so backing out of it — unlike backing out of
    // the password-entry step before that — doesn't "cancel" anything; it
    // just strands the installation with no recovery key and no way to set
    // one up later. This screen must be un-skippable, the same way
    // UnlockScreen has no skip/back affordance.
    testWidgets('has no back button and cannot be popped before Continue is '
        'tapped', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
            _wrapPushed(appState, const RecoveryKeyScreen()));
        await tester.tap(find.byKey(const Key('openRecoveryKeyScreen')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      expect(find.byType(RecoveryKeyScreen), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);

      // Simulates the Android hardware/gesture back button (this is the
      // exact call WidgetsApp.didPopRoute() makes in response to it).
      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(find.byType(RecoveryKeyScreen), findsOneWidget);
    });

    testWidgets('Continue is disabled until the acknowledgment checkbox is '
        'checked, then enabled, and commits the key on tap', (tester) async {
      var continueCount = 0;
      await _pumpAndSettle(
        tester,
        _wrap(
          appState,
          RecoveryKeyScreen(onContinue: () => continueCount++),
        ),
      );

      expect(
        tester.widget<ElevatedButton>(_continueButton).onPressed,
        isNull,
      );

      await tester.tap(_ackCheckbox);
      await tester.pump();

      expect(
        tester.widget<ElevatedButton>(_continueButton).onPressed,
        isNotNull,
      );

      // commitRecoveryKey() performs real file I/O.
      await tester.runAsync(() async {
        await tester.tap(_continueButton);
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      expect(continueCount, 1);
      expect(await _hasCommittedRecoveryKey(tester, tmpDir.path), isTrue);
    });

    // Regression test: a recovery-key screen instance is disposed (e.g. the
    // user navigates away, or a fresh instance replaces it after an app
    // restart) before acknowledging/continuing. The abandoned candidate must
    // never have been persisted, so a fresh screen instance can generate a
    // new candidate and complete setup normally — not be permanently stuck
    // because a wrap was already committed for a plaintext key nobody has
    // anymore.
    testWidgets(
        'a screen instance disposed before Continue leaves nothing '
        'committed, so a fresh instance can still complete setup',
        (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const RecoveryKeyScreen()));
      final abandonedKey = _recoveryKeyOf(tester);

      // Simulate disposal by pumping an unrelated widget in its place,
      // without ever checking the box or tapping Continue.
      await tester.pumpWidget(_wrap(appState, const SizedBox()));
      await tester.pump();
      expect(await _hasCommittedRecoveryKey(tester, tmpDir.path), isFalse);

      var continueCount = 0;
      await _pumpAndSettle(
        tester,
        _wrap(
          appState,
          RecoveryKeyScreen(onContinue: () => continueCount++),
        ),
      );
      final freshKey = _recoveryKeyOf(tester);
      expect(freshKey, isNot(abandonedKey));

      await tester.tap(_ackCheckbox);
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(_continueButton);
        await Future<void>.delayed(const Duration(seconds: 1));
      });
      await tester.pump();

      expect(continueCount, 1);
      expect(await _hasCommittedRecoveryKey(tester, tmpDir.path), isTrue);
    });

    testWidgets('Copy puts the recovery key on the clipboard', (tester) async {
      await _pumpAndSettle(tester, _wrap(appState, const RecoveryKeyScreen()));
      final key = _recoveryKeyOf(tester);

      await tester.tap(_copyButton);
      await tester.pump();

      expect(clipboardText, key);
    });

    testWidgets('Share invokes the injected share callback with the '
        'recovery key', (tester) async {
      String? shared;
      await _pumpAndSettle(
        tester,
        _wrap(
          appState,
          RecoveryKeyScreen(onShare: (key) => shared = key),
        ),
      );
      final key = _recoveryKeyOf(tester);

      await tester.tap(_shareButton);
      await tester.pump();

      expect(shared, key);
    });
  });
}
