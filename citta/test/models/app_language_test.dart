import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/app_language.dart';

void main() {
  group('AppLanguage.code', () {
    test('system code is "system"', () {
      expect(AppLanguage.system.code, equals('system'));
    });

    test('spot-check codes match ISO/BCP-47 values used historically', () {
      expect(AppLanguage.english.code, equals('en'));
      expect(AppLanguage.hindi.code, equals('hi'));
      expect(AppLanguage.kannada.code, equals('kn'));
      expect(AppLanguage.sanskrit.code, equals('sa'));
      expect(AppLanguage.telugu.code, equals('te'));
      expect(AppLanguage.tamil.code, equals('ta'));
      expect(AppLanguage.malayalam.code, equals('ml'));
      expect(AppLanguage.marathi.code, equals('mr'));
      expect(AppLanguage.gujarati.code, equals('gu'));
      expect(AppLanguage.odia.code, equals('or'));
      expect(AppLanguage.bengali.code, equals('bn'));
      expect(AppLanguage.tulu.code, equals('tcy'));
      expect(AppLanguage.konkani.code, equals('kok'));
      expect(AppLanguage.urdu.code, equals('ur'));
      expect(AppLanguage.assamese.code, equals('as'));
      expect(AppLanguage.punjabi.code, equals('pa'));
      expect(AppLanguage.maithili.code, equals('mai'));
      expect(AppLanguage.french.code, equals('fr'));
      expect(AppLanguage.german.code, equals('de'));
      expect(AppLanguage.italian.code, equals('it'));
      expect(AppLanguage.spanish.code, equals('es'));
      expect(AppLanguage.portuguese.code, equals('pt'));
      expect(AppLanguage.russian.code, equals('ru'));
      expect(AppLanguage.arabic.code, equals('ar'));
      expect(AppLanguage.japanese.code, equals('ja'));
      expect(AppLanguage.chinese.code, equals('zh'));
      expect(AppLanguage.hebrew.code, equals('he'));
    });

    test('every enum value has a unique code', () {
      final codes = AppLanguage.values.map((l) => l.code).toList();
      expect(codes.toSet().length, equals(codes.length),
          reason: 'duplicate codes would make fromStorageString ambiguous');
    });
  });

  group('AppLanguage.isLatinScript', () {
    test('latin-script languages are flagged correctly', () {
      for (final lang in [
        AppLanguage.english,
        AppLanguage.french,
        AppLanguage.german,
        AppLanguage.italian,
        AppLanguage.spanish,
        AppLanguage.portuguese,
      ]) {
        expect(lang.isLatinScript, isTrue, reason: '$lang should be latin-script');
      }
    });

    test('non-latin-script languages are flagged correctly', () {
      for (final lang in [
        AppLanguage.hindi,
        AppLanguage.kannada,
        AppLanguage.sanskrit,
        AppLanguage.arabic,
        AppLanguage.japanese,
        AppLanguage.chinese,
        AppLanguage.hebrew,
      ]) {
        expect(lang.isLatinScript, isFalse,
            reason: '$lang should not be latin-script');
      }
    });
  });

  group('AppLanguageStorage.fromStorageString', () {
    test('known codes parse back to their enum value', () {
      for (final lang in AppLanguage.values) {
        expect(AppLanguageStorage.fromStorageString(lang.code), equals(lang));
      }
    });

    test('null falls back to AppLanguage.system', () {
      expect(AppLanguageStorage.fromStorageString(null),
          equals(AppLanguage.system));
    });

    test('unrecognized code falls back to AppLanguage.system', () {
      expect(AppLanguageStorage.fromStorageString('xx'),
          equals(AppLanguage.system));
    });
  });

  group('AppLanguage round-trip', () {
    test('every value survives code -> fromStorageString', () {
      for (final lang in AppLanguage.values) {
        expect(AppLanguageStorage.fromStorageString(lang.code), equals(lang));
      }
    });
  });
}
