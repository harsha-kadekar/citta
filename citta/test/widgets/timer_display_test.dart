import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/services/timer_service.dart';
import 'package:citta/theme/app_theme.dart';
import 'package:citta/widgets/timer_display.dart';

Widget _app(ThemeData theme, TimerService timerService) => MaterialApp(
      theme: theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: TimerDisplay(timerService: timerService)),
    );

void main() {
  group('TimerDisplay — countdown ring color', () {
    testWidgets('background ring uses the light theme divider color',
        (tester) async {
      await tester.pumpWidget(_app(AppTheme.lightTheme(), TimerService()));

      final ring =
          tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(ring.backgroundColor, AppColors.divider);
    });

    testWidgets('background ring adapts to the dark theme divider color',
        (tester) async {
      await tester.pumpWidget(_app(AppTheme.darkTheme(), TimerService()));

      final ring =
          tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(ring.backgroundColor, DarkAppColors.divider);
      expect(ring.backgroundColor, isNot(AppColors.divider),
          reason: 'the countdown ring must not stay pinned to the '
              'light-theme literal under dark theme');
    });
  });
}
