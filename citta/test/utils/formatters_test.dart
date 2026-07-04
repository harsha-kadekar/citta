import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:citta/l10n/fallback_localizations_delegate.dart';
import 'package:citta/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('de');
    await initializeDateFormatting('fr');
  });

  group('formatDuration - short style (default)', () {
    test('zero seconds', () {
      expect(formatDuration(0), equals('0s'));
    });

    test('sub-minute duration', () {
      expect(formatDuration(45), equals('45s'));
    });

    test('exact minutes', () {
      expect(formatDuration(60), equals('1m'));
    });

    test('minutes and seconds', () {
      expect(formatDuration(90), equals('1m 30s'));
    });

    test('does not roll over into hours', () {
      expect(formatDuration(3661), equals('61m 1s'));
    });
  });

  group('formatDuration - full style', () {
    const style = DurationDisplayStyle.full;

    test('zero seconds', () {
      expect(formatDuration(0, style: style), equals('0s'));
    });

    test('sub-minute duration falls back to short logic', () {
      expect(formatDuration(45, style: style), equals('45s'));
    });

    test('minutes and seconds falls back to short logic', () {
      expect(formatDuration(90, style: style), equals('1m 30s'));
    });

    test('exact hour rolls into hours+minutes', () {
      expect(formatDuration(3600, style: style), equals('1h 0m'));
    });

    test('hour with partial minutes', () {
      expect(formatDuration(3660, style: style), equals('1h 1m'));
    });
  });

  group('formatDuration - compact style', () {
    const style = DurationDisplayStyle.compact;

    test('zero seconds', () {
      expect(formatDuration(0, style: style), equals('0m'));
    });

    test('sub-minute rounds down to 0m', () {
      expect(formatDuration(45, style: style), equals('0m'));
    });

    test('exact minutes', () {
      expect(formatDuration(125, style: style), equals('2m'));
    });

    test('past an hour stays in minutes', () {
      expect(formatDuration(3661, style: style), equals('61m'));
    });
  });

  group('formatSessionDate', () {
    test('formats month, day, year for en', () {
      final date = DateTime(2024, 3, 5, 9, 5);
      expect(formatSessionDate(date, 'en'), equals('Mar 5, 2024'));
    });

    test('uses locale-appropriate order and month name for de', () {
      final date = DateTime(2024, 3, 5, 9, 5);
      expect(formatSessionDate(date, 'de'), equals('5. März 2024'));
    });

    test('uses locale-appropriate order and month name for fr', () {
      final date = DateTime(2024, 3, 5, 9, 5);
      expect(formatSessionDate(date, 'fr'), equals('5 mars 2024'));
    });
  });

  group('formatSessionTime', () {
    test('en uses a 12-hour clock with AM/PM', () {
      final date = DateTime(2024, 3, 5, 9, 5);
      // intl separates the AM/PM marker with a narrow no-break space (U+202F).
      expect(formatSessionTime(date, 'en'), equals('9:05 AM'));
    });

    test('en formats late night time with PM', () {
      final date = DateTime(2024, 3, 5, 23, 59);
      expect(formatSessionTime(date, 'en'), equals('11:59 PM'));
    });

    test('de uses a zero-padded 24-hour clock', () {
      final date = DateTime(2024, 3, 5, 9, 5);
      expect(formatSessionTime(date, 'de'), equals('09:05'));
    });

    test('de formats late night time on a 24-hour clock', () {
      final date = DateTime(2024, 3, 5, 23, 59);
      expect(formatSessionTime(date, 'de'), equals('23:59'));
    });
  });

  group('formatMonthYear', () {
    test('formats full month name and year', () {
      final date = DateTime(2024, 3, 1);
      expect(formatMonthYear(date, 'en'), equals('March 2024'));
    });
  });

  group('formatWeekdayShort', () {
    test('formats abbreviated weekday name', () {
      // 2024-01-01 is a Monday.
      final date = DateTime(2024, 1, 1);
      expect(formatWeekdayShort(date, 'en'), equals('Mon'));
    });
  });

  group('currentLocaleStr', () {
    testWidgets('falls back to en for locales intl has no data for', (tester) async {
      late String result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('sa'),
          localizationsDelegates: const [
            FallbackMaterialLocalizationsDelegate(),
            GlobalWidgetsLocalizations.delegate,
            FallbackCupertinoLocalizationsDelegate(),
          ],
          supportedLocales: const [Locale('sa'), Locale('en')],
          home: Builder(
            builder: (context) {
              result = currentLocaleStr(context);
              return const Placeholder();
            },
          ),
        ),
      );
      expect(result, equals('en'));
    });

    testWidgets('passes through a locale intl supports', (tester) async {
      late String result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              result = currentLocaleStr(context);
              return const Placeholder();
            },
          ),
        ),
      );
      expect(result, equals('en'));
    });
  });
}
