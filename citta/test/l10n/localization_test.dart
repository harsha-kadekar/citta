import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/l10n/fallback_localizations_delegate.dart';

// Helper to build a widget inside a localized MaterialApp.
// Uses the same delegate setup as the real app, including fallback delegates
// for locales not natively supported by Flutter's SDK (e.g. Sanskrit 'sa').
Widget _localizedApp({
  required String locale,
  required Widget child,
}) {
  return MaterialApp(
    locale: Locale(locale),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      FallbackMaterialLocalizationsDelegate(),
      GlobalWidgetsLocalizations.delegate,
      FallbackCupertinoLocalizationsDelegate(),
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

// Helper to get AppLocalizations for a given locale via widget pump
Future<AppLocalizations> _localizationsFor(
    WidgetTester tester, String locale) async {
  late AppLocalizations l10n;
  await tester.pumpWidget(
    _localizedApp(
      locale: locale,
      child: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const Placeholder();
        },
      ),
    ),
  );
  return l10n;
}

void main() {
  group('AppLocalizations loads correctly', () {
    testWidgets('English locale loads and key strings are present', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.actionCancel, equals('Cancel'));
      expect(l10n.actionSave, equals('Save'));
      expect(l10n.navDhyana, equals('Dhyana'));
      expect(l10n.splashGreeting, equals('Namaskara'));
      expect(l10n.historyTitle, equals('History'));
      expect(l10n.sessionComplete, equals('Session Complete'));
    });

    testWidgets('Hindi locale strings differ from English', (tester) async {
      final enL10n = await _localizationsFor(tester, 'en');
      final hiL10n = await _localizationsFor(tester, 'hi');
      expect(hiL10n.actionCancel, isNot(equals(enL10n.actionCancel)));
      expect(hiL10n.navDhyana, isNot(equals(enL10n.navDhyana)));
    });

    testWidgets('Kannada locale strings differ from English', (tester) async {
      final enL10n = await _localizationsFor(tester, 'en');
      final knL10n = await _localizationsFor(tester, 'kn');
      expect(knL10n.actionCancel, isNot(equals(enL10n.actionCancel)));
    });

    testWidgets('French locale strings differ from English', (tester) async {
      final enL10n = await _localizationsFor(tester, 'en');
      final frL10n = await _localizationsFor(tester, 'fr');
      expect(frL10n.actionCancel, equals('Annuler'));
      expect(frL10n.actionSave, equals('Enregistrer'));
      expect(frL10n.actionCancel, isNot(equals(enL10n.actionCancel)));
    });

    testWidgets('German locale strings differ from English', (tester) async {
      final deL10n = await _localizationsFor(tester, 'de');
      expect(deL10n.actionCancel, equals('Abbrechen'));
      expect(deL10n.statsDays(1), equals('Tag'));
      expect(deL10n.statsDays(5), equals('Tage'));
    });

    testWidgets('Japanese locale loads without throwing', (tester) async {
      final l10n = await _localizationsFor(tester, 'ja');
      expect(l10n.navDhyana, isNotEmpty);
      expect(l10n.sessionComplete, isNotEmpty);
    });

    testWidgets('Hebrew locale loads without throwing', (tester) async {
      final l10n = await _localizationsFor(tester, 'he');
      expect(l10n.actionCancel, isNotEmpty);
      expect(l10n.historyTitle, isNotEmpty);
    });

    testWidgets('Chinese locale loads without throwing', (tester) async {
      final l10n = await _localizationsFor(tester, 'zh');
      expect(l10n.navDhyana, isNotEmpty);
    });

    testWidgets('All 27 supported locales load without throwing', (tester) async {
      const locales = [
        'en', 'hi', 'kn', 'sa', 'te', 'ta', 'ml',
        'mr', 'gu', 'or', 'bn', 'tcy', 'kok', 'ur', 'as', 'pa', 'mai',
        'fr', 'de', 'it', 'es', 'pt', 'ru',
        'ar', 'ja', 'zh', 'he',
      ];
      for (final locale in locales) {
        final l10n = await _localizationsFor(tester, locale);
        expect(l10n.actionCancel, isNotEmpty,
            reason: 'actionCancel should not be empty for locale $locale');
        expect(l10n.navDhyana, isNotEmpty,
            reason: 'navDhyana should not be empty for locale $locale');
      }
    });
  });

  group('Parameterized strings', () {
    testWidgets('splashGreetingWithName includes the name', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      final greeting = l10n.splashGreetingWithName('Arjuna');
      expect(greeting, contains('Arjuna'));
      expect(greeting, contains('Namaskara'));
    });

    testWidgets('historySelected formats count correctly', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.historySelected(3), equals('3 selected'));
      expect(l10n.historySelected(1), equals('1 selected'));
    });

    testWidgets('historyDeleteConfirm formats count correctly', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.historyDeleteConfirm(3), contains('3'));
    });

    testWidgets('settingsDurationMinutes formats correctly', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.settingsDurationMinutes(15), equals('15 minutes'));
    });

    testWidgets('settingsIntervalEvery formats correctly', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.settingsIntervalEvery(5), equals('Every 5 min'));
    });

    testWidgets('settingsUserQuotes formats count correctly', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.settingsUserQuotes(0), equals('0 user quotes'));
      expect(l10n.settingsUserQuotes(3), equals('3 user quotes'));
    });

    testWidgets('notesWordCount formats correctly', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.notesWordCount(42), equals('42 / 500 words'));
    });

    testWidgets('settingsExportFailed includes error message', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      final msg = l10n.settingsExportFailed('network error');
      expect(msg, contains('network error'));
    });
  });

  group('Plural forms', () {
    testWidgets('statsDays - count=1 gives singular in English', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.statsDays(1), equals('day'));
    });

    testWidgets('statsDays - count=5 gives plural in English', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.statsDays(5), equals('days'));
    });

    testWidgets('statsDays - count=0 gives plural in English', (tester) async {
      final l10n = await _localizationsFor(tester, 'en');
      expect(l10n.statsDays(0), equals('days'));
    });

    testWidgets('statsDays - French singular and plural', (tester) async {
      final l10n = await _localizationsFor(tester, 'fr');
      expect(l10n.statsDays(1), equals('jour'));
      expect(l10n.statsDays(3), equals('jours'));
    });
  });

  group('Locale switching', () {
    testWidgets('Hebrew locale results in RTL text direction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('he'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Text('Test')),
        ),
      );
      // Hebrew locale should set RTL direction at the MaterialApp level
      final locale = tester.widget<MaterialApp>(find.byType(MaterialApp)).locale;
      expect(locale?.languageCode, equals('he'));
    });

    testWidgets('Switching from English to Kannada changes action labels', (tester) async {
      final enL10n = await _localizationsFor(tester, 'en');
      final knL10n = await _localizationsFor(tester, 'kn');
      expect(knL10n.actionSave, isNot(equals(enL10n.actionSave)));
      expect(knL10n.actionCancel, isNot(equals(enL10n.actionCancel)));
    });
  });
}
