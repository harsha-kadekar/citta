import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/screens/notes_screen.dart';
import 'package:citta/screens/session_complete_screen.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';

class _FakeAudioPlayer implements AudioPlayerBase {
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

class _FakeAudioSession implements AudioSessionBase {
  @override
  Future<void> configure(AudioSessionConfiguration _) async {}
  @override
  Stream<AudioInterruptionEvent> get interruptionEventStream =>
      const Stream.empty();
}

/// Builds an [AppState] with only in-memory defaults — no disk I/O and no
/// call to [AppState.initialize] — since [NotesScreen] (the screen
/// [SessionCompleteScreen] navigates to) only reads synchronous config
/// defaults during build.
AppState _fakeAppState() {
  return AppState(
    storageService: StorageService(),
    quoteService: QuoteService(StorageService()),
    audioService: AudioService.withPlayers(
      bellPlayer: _FakeAudioPlayer(),
      musicPlayer: _FakeAudioPlayer(),
      sessionFactory: () async => _FakeAudioSession(),
    ),
    statsService: const StatsService(),
  );
}

final _session = SessionModel(
  id: 'test-session',
  date: DateTime(2026, 1, 1),
  duration: 300,
  timerMode: TimerMode.countdown,
);

class _ReplaceCountingObserver extends NavigatorObserver {
  int replaceCount = 0;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replaceCount++;
  }
}

Widget _testApp(AppState appState, {List<NavigatorObserver> observers = const []}) =>
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: MaterialApp(
        navigatorObservers: observers,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: SessionCompleteScreen(session: _session),
      ),
    );

void main() {
  testWidgets(
    'auto-advances to NotesScreen after 3 seconds',
    (tester) async {
      await tester.pumpWidget(_testApp(_fakeAppState()));

      expect(find.byType(SessionCompleteScreen), findsOneWidget);
      expect(find.byType(NotesScreen), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(SessionCompleteScreen), findsNothing);
      expect(find.byType(NotesScreen), findsOneWidget);
    },
  );

  testWidgets(
    'manual continue navigates immediately and cancels the pending auto-advance',
    (tester) async {
      await tester.pumpWidget(_testApp(_fakeAppState()));

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(l10n.actionContinue));
      await tester.pumpAndSettle();

      expect(find.byType(SessionCompleteScreen), findsNothing);
      expect(find.byType(NotesScreen), findsOneWidget);

      // If the auto-advance timer weren't cancelled by manual continue,
      // letting it elapse now would attempt a second, stale navigation.
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(NotesScreen), findsOneWidget);
    },
  );

  testWidgets(
    'manual continue cancels the auto-advance timer even mid-transition, '
    'preventing a duplicate navigation',
    (tester) async {
      final observer = _ReplaceCountingObserver();
      await tester.pumpWidget(
        _testApp(_fakeAppState(), observers: [observer]),
      );

      // Get close to, but not past, the 3-second auto-advance mark.
      await tester.pump(const Duration(milliseconds: 2900));

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(l10n.actionContinue));
      await tester.pump();

      // Cross the original 3-second mark while the push-replacement
      // transition triggered by the manual tap is still animating —
      // SessionCompleteScreen is still `mounted` during this window. If the
      // auto-advance timer wasn't actually cancelled when the user tapped
      // continue, it fires here and pushes a second, duplicate NotesScreen.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(observer.replaceCount, 1);
      expect(find.byType(NotesScreen), findsOneWidget);
    },
  );

  testWidgets(
    'invoking the continue callback twice in a row pushes NotesScreen only once',
    (tester) async {
      final observer = _ReplaceCountingObserver();
      await tester.pumpWidget(
        _testApp(_fakeAppState(), observers: [observer]),
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, l10n.actionContinue),
      );

      // Calling onPressed directly, twice, back-to-back — as a double-tap
      // or a tap racing the push-replacement transition would — bypasses
      // gesture/hit-test timing so the re-entrancy guard is exercised
      // deterministically rather than depending on animation timing.
      button.onPressed!();
      button.onPressed!();
      await tester.pumpAndSettle();

      expect(observer.replaceCount, 1);
      expect(find.byType(NotesScreen), findsOneWidget);
    },
  );

  testWidgets(
    'leaving the screen before the timer fires does not throw or navigate',
    (tester) async {
      await tester.pumpWidget(_testApp(_fakeAppState()));

      expect(find.byType(SessionCompleteScreen), findsOneWidget);

      // Tear down the whole tree before the 3-second timer elapses, as if
      // the user left via some other path. Since the new root widget has a
      // different runtime type, Flutter can't reuse any element from the
      // old tree, so this fully disposes SessionCompleteScreen's state.
      await tester.pumpWidget(const SizedBox());

      // If dispose() didn't cancel the timer, it would fire here against an
      // unmounted state and (absent the `mounted` guard) throw.
      await tester.pump(const Duration(seconds: 4));

      expect(tester.takeException(), isNull);
    },
  );
}
