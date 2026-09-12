import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/services/timer_service.dart';
import 'package:citta/theme/app_theme.dart';
import 'package:citta/widgets/timer_controls.dart';

/// No-op ticker so [TimerService.start]/[pause] don't schedule a real
/// [Timer.periodic] that would otherwise leak past the test.
class _FakeTicker implements TimerTickerBase {
  @override
  void start(Duration interval, void Function() onTick) {}

  @override
  void cancel() {}
}

Widget _app(ThemeData theme, Widget child) => MaterialApp(
      theme: theme,
      home: Scaffold(body: child),
    );

void main() {
  group('TimerControls — running state', () {
    testWidgets(
        'pause/stop icons use colorScheme.secondary/error under the light theme',
        (tester) async {
      final timerService = TimerService(ticker: _FakeTicker())..start();

      await tester.pumpWidget(_app(
        AppTheme.lightTheme,
        TimerControls(
          timerService: timerService,
          onPause: () {},
          onResume: () {},
          onStop: () {},
        ),
      ));

      final pauseIcon = tester.widget<Icon>(find.byIcon(Icons.pause_rounded));
      final stopIcon = tester.widget<Icon>(find.byIcon(Icons.stop_rounded));
      expect(pauseIcon.color, AppColors.secondary);
      expect(stopIcon.color, AppColors.error);
    });

    testWidgets(
        'pause/stop icons adapt to colorScheme.secondary/error under the dark theme',
        (tester) async {
      final timerService = TimerService(ticker: _FakeTicker())..start();

      await tester.pumpWidget(_app(
        AppTheme.darkTheme,
        TimerControls(
          timerService: timerService,
          onPause: () {},
          onResume: () {},
          onStop: () {},
        ),
      ));

      final pauseIcon = tester.widget<Icon>(find.byIcon(Icons.pause_rounded));
      final stopIcon = tester.widget<Icon>(find.byIcon(Icons.stop_rounded));
      expect(pauseIcon.color, DarkAppColors.secondary,
          reason: 'pause icon must not hardcode the light-theme AppColors.secondary');
      expect(pauseIcon.color, isNot(AppColors.secondary));
      expect(stopIcon.color, DarkAppColors.error,
          reason: 'stop icon must not hardcode the light-theme AppColors.error');
      expect(stopIcon.color, isNot(AppColors.error));
    });
  });

  group('TimerControls — paused state', () {
    testWidgets(
        'resume/stop icons use colorScheme.primary/error under the light theme',
        (tester) async {
      final timerService = TimerService(ticker: _FakeTicker())
        ..start()
        ..pause();

      await tester.pumpWidget(_app(
        AppTheme.lightTheme,
        TimerControls(
          timerService: timerService,
          onPause: () {},
          onResume: () {},
          onStop: () {},
        ),
      ));

      final resumeIcon =
          tester.widget<Icon>(find.byIcon(Icons.play_arrow_rounded));
      final stopIcon = tester.widget<Icon>(find.byIcon(Icons.stop_rounded));
      expect(resumeIcon.color, AppColors.primary);
      expect(stopIcon.color, AppColors.error);
    });

    testWidgets(
        'resume/stop icons adapt to colorScheme.primary/error under the dark theme',
        (tester) async {
      final timerService = TimerService(ticker: _FakeTicker())
        ..start()
        ..pause();

      await tester.pumpWidget(_app(
        AppTheme.darkTheme,
        TimerControls(
          timerService: timerService,
          onPause: () {},
          onResume: () {},
          onStop: () {},
        ),
      ));

      final resumeIcon =
          tester.widget<Icon>(find.byIcon(Icons.play_arrow_rounded));
      final stopIcon = tester.widget<Icon>(find.byIcon(Icons.stop_rounded));
      expect(resumeIcon.color, DarkAppColors.primary,
          reason: 'resume icon must not hardcode the light-theme AppColors.primary');
      expect(resumeIcon.color, isNot(AppColors.primary));
      expect(stopIcon.color, DarkAppColors.error);
      expect(stopIcon.color, isNot(AppColors.error));
    });
  });
}
