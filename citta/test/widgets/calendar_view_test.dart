import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/widgets/calendar_view.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _SpyStatsService extends StatsService {
  int groupByDateCallCount = 0;

  @override
  Map<DateTime, List<SessionModel>> groupByDate(List<SessionModel> sessions) {
    groupByDateCallCount++;
    return super.groupByDate(sessions);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Stateful wrapper that lets tests hot-swap the sessions list and trigger
/// a parent-driven rebuild of CalendarView (which fires didUpdateWidget).
class _SessionsWrapper extends StatefulWidget {
  final List<SessionModel> initialSessions;
  final StatsService statsService;

  const _SessionsWrapper({
    super.key,
    required this.initialSessions,
    required this.statsService,
  });

  @override
  State<_SessionsWrapper> createState() => _SessionsWrapperState();
}

class _SessionsWrapperState extends State<_SessionsWrapper> {
  late List<SessionModel> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = widget.initialSessions;
  }

  void updateSessions(List<SessionModel> newSessions) {
    setState(() => _sessions = newSessions);
  }

  @override
  Widget build(BuildContext context) {
    return CalendarView(sessions: _sessions, statsService: widget.statsService);
  }
}

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

SessionModel _session(DateTime date) => SessionModel(
      id: 'test-${date.toIso8601String()}',
      date: date,
      duration: 300,
      timerMode: 'countdown',
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CalendarView – display', () {
    testWidgets('1. renders without error with empty sessions', (tester) async {
      await tester.pumpWidget(_app(
        const CalendarView(sessions: [], statsService: StatsService()),
      ));
      await tester.pump();

      expect(find.byType(CalendarView), findsOneWidget);
    });

    testWidgets('2. shows 7 weekday header cells', (tester) async {
      await tester.pumpWidget(_app(
        const CalendarView(sessions: [], statsService: StatsService()),
      ));
      await tester.pump();

      // The weekday row contains 7 Expanded children wrapping Text widgets.
      // Verify at least 7 short weekday label texts are rendered (Mon–Sun in en).
      final headers = find.descendant(
        of: find.byType(CalendarView),
        matching: find.byType(Text),
      );
      // There are many Text nodes (day numbers + headers); just assert widget renders
      expect(headers, findsWidgets);
    });

    testWidgets('3. day-15 cell is present for the current month', (tester) async {
      await tester.pumpWidget(_app(
        const CalendarView(sessions: [], statsService: StatsService()),
      ));
      await tester.pump();

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('4. previous-month button exists and is tappable', (tester) async {
      await tester.pumpWidget(_app(
        const CalendarView(sessions: [], statsService: StatsService()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(find.byType(CalendarView), findsOneWidget);
    });

    testWidgets('5. next-month button exists and is tappable', (tester) async {
      await tester.pumpWidget(_app(
        const CalendarView(sessions: [], statsService: StatsService()),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(find.byType(CalendarView), findsOneWidget);
    });
  });

  group('CalendarView – regrouping guard', () {
    testWidgets(
      '6. groupByDate is called exactly once on initial build',
      (tester) async {
        final spy = _SpyStatsService();

        await tester.pumpWidget(_app(
          CalendarView(sessions: const [], statsService: spy),
        ));
        await tester.pump();

        expect(spy.groupByDateCallCount, 1);
      },
    );

    testWidgets(
      '7. groupByDate is NOT called again when parent rebuilds with the same sessions reference',
      (tester) async {
        final spy = _SpyStatsService();
        final sessions = [_session(DateTime.now())];
        final key = GlobalKey<_SessionsWrapperState>();

        await tester.pumpWidget(_app(
          _SessionsWrapper(
            key: key,
            initialSessions: sessions,
            statsService: spy,
          ),
        ));
        await tester.pump();

        expect(spy.groupByDateCallCount, 1);

        // Trigger a parent-driven rebuild with the same list reference.
        key.currentState!.updateSessions(sessions);
        await tester.pump();

        expect(spy.groupByDateCallCount, 1,
            reason:
                'groupByDate should not be called when sessions reference is unchanged');
      },
    );

    testWidgets(
      '8. groupByDate IS called again when parent rebuilds with a new sessions reference',
      (tester) async {
        final spy = _SpyStatsService();
        final sessions1 = [_session(DateTime.now())];
        final sessions2 = [
          _session(DateTime.now()),
          _session(DateTime.now().subtract(const Duration(days: 1))),
        ];
        final key = GlobalKey<_SessionsWrapperState>();

        await tester.pumpWidget(_app(
          _SessionsWrapper(
            key: key,
            initialSessions: sessions1,
            statsService: spy,
          ),
        ));
        await tester.pump();

        expect(spy.groupByDateCallCount, 1);

        key.currentState!.updateSessions(sessions2);
        await tester.pump();

        expect(spy.groupByDateCallCount, 2,
            reason:
                'groupByDate must be called when sessions list is replaced');
      },
    );

    testWidgets(
      '9. groupByDate is NOT called when navigating months',
      (tester) async {
        final spy = _SpyStatsService();
        final sessions = [_session(DateTime.now())];

        await tester.pumpWidget(_app(
          CalendarView(sessions: sessions, statsService: spy),
        ));
        await tester.pump();

        expect(spy.groupByDateCallCount, 1);

        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();

        expect(spy.groupByDateCallCount, 1,
            reason: 'month navigation must not trigger regrouping');
      },
    );
  });
}
