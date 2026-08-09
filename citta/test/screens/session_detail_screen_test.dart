import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/screens/session_detail_screen.dart';
import 'package:citta/widgets/tag_chip.dart';

Widget _app(SessionModel session) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: SessionDetailScreen(session: session),
    );

void main() {
  testWidgets('session tags render via the shared TagChip widget',
      (tester) async {
    final session = SessionModel(
      id: 's1',
      date: DateTime.utc(2024, 6, 1, 8),
      duration: 600,
      timerMode: TimerMode.countdown,
      tags: const ['calm', 'deep'],
      completedFully: true,
    );

    await tester.pumpWidget(_app(session));
    await tester.pump();

    expect(find.byType(TagChip), findsNWidgets(2));
    expect(find.text('calm'), findsOneWidget);
    expect(find.text('deep'), findsOneWidget);
  });
}
