import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/quote_model.dart';
import 'package:citta/screens/splash_screen.dart';

const _longQuote = QuoteModel(
  id: 'q1',
  source: 'bhagavad_gita',
  reference: 'Chapter 2, Verse 47',
  originalText:
      'karmaṇyevādhikāraste mā phaleṣu kadācana mā karmaphalahetur bhūrmā te '
      'saṅgo\'stvakarmaṇi yogasthaḥ kuru karmāṇi saṅgaṃ tyaktvā dhanañjaya '
      'siddhyasiddhyoḥ samo bhūtvā samatvaṃ yoga ucyate',
  translation:
      'You have a right to perform your prescribed duties, but you are not '
      'entitled to the fruits of your actions. Never consider yourself the '
      'cause of the results of your activities, and never be attached to '
      'not doing your duty.',
);

Widget _testApp(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  testWidgets(
      'a long name and quote on a short screen do not overflow the layout',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_testApp(SplashScreen(
      quote: _longQuote,
      userName: 'Padmanabhasubramanian',
      onDismiss: () {},
    )));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('all quote content remains reachable by scrolling on a short screen',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_testApp(SplashScreen(
      quote: _longQuote,
      userName: 'Padmanabhasubramanian',
      onDismiss: () {},
    )));
    await tester.pump();

    await tester.dragUntilVisible(
      find.textContaining('right to perform'),
      find.byType(SingleChildScrollView),
      const Offset(0, -50),
    );

    expect(find.textContaining('right to perform'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
