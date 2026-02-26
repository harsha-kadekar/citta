// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get actionCancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get actionSave => 'ಉಳಿಸಿ';

  @override
  String get actionSkip => 'ಬಿಟ್ಟುಬಿಡಿ';

  @override
  String get actionContinue => 'ಮುಂದುವರಿಯಿರಿ';

  @override
  String get actionDelete => 'ಅಳಿಸಿ';

  @override
  String get actionAdd => 'ಸೇರಿಸಿ';

  @override
  String get actionBegin => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get navDhyana => 'ಧ್ಯಾನ';

  @override
  String get navHistory => 'ಇತಿಹಾಸ';

  @override
  String get navStats => 'ಅಂಕಿಅಂಶ';

  @override
  String get navSettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get splashGreeting => 'ನಮಸ್ಕಾರ';

  @override
  String splashGreetingWithName(String name) {
    return 'ನಮಸ್ಕಾರ, $name';
  }

  @override
  String get splashTapToBegin => 'ಪ್ರಾರಂಭಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get welcomeTitle => 'ಚಿತ್ತಕ್ಕೆ ಸ್ವಾಗತ';

  @override
  String get welcomeNameHint => 'ನಿಮ್ಮ ಹೆಸರು ನಮೂದಿಸಿ';

  @override
  String get homeBegin => 'ಪ್ರಾರಂಭ';

  @override
  String get homeCountdown => 'ಕೌಂಟ್‌ಡೌನ್';

  @override
  String get homeStopwatch => 'ಸ್ಟಾಪ್‌ವಾಚ್';

  @override
  String get homeMin => 'ನಿ';

  @override
  String get historyTitle => 'ಇತಿಹಾಸ';

  @override
  String historySelected(int count) {
    return '$count ಆಯ್ಕೆಯಾಗಿದೆ';
  }

  @override
  String get historyDeleteTitle => 'ಸೆಷನ್‌ಗಳನ್ನು ಅಳಿಸಿ';

  @override
  String historyDeleteConfirm(int count) {
    return '$count ಸೆಷನ್‌ಗಳನ್ನು ಅಳಿಸುವುದೇ? ಇದನ್ನು ರದ್ದು ಮಾಡಲಾಗುವುದಿಲ್ಲ.';
  }

  @override
  String get historyFilterAll => 'ಎಲ್ಲಾ';

  @override
  String get historyEmpty => 'ಇನ್ನೂ ಯಾವ ಸೆಷನ್‌ಗಳಿಲ್ಲ';

  @override
  String get historyEmptyHint =>
      'ನಿಮ್ಮ ಮೊದಲ ಧ್ಯಾನ ಸೆಷನ್ ಪೂರ್ಣಗೊಳಿಸಿ\nಇಲ್ಲಿ ನೋಡಲು';

  @override
  String get statsTitle => 'ಅಂಕಿಅಂಶ';

  @override
  String get statsToggleCalendar => 'ಕ್ಯಾಲೆಂಡರ್ ನೋಟ ಬದಲಿಸಿ';

  @override
  String get statsCurrentStreak => 'ಪ್ರಸ್ತುತ ಸ್ಟ್ರೀಕ್';

  @override
  String get statsLongestStreak => 'ದೀರ್ಘ ಸ್ಟ್ರೀಕ್';

  @override
  String get statsTotalSessions => 'ಒಟ್ಟು ಸೆಷನ್‌ಗಳು';

  @override
  String get statsAverage => 'ಸರಾಸರಿ';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ದಿನಗಳು',
      one: 'ದಿನ',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get settingsProfile => 'ಪ್ರೊಫೈಲ್';

  @override
  String get settingsName => 'ಹೆಸರು';

  @override
  String get settingsNameNotSet => 'ಹೊಂದಿಸಲಾಗಿಲ್ಲ';

  @override
  String get settingsEditName => 'ಹೆಸರು ಸಂಪಾದಿಸಿ';

  @override
  String get settingsAppearance => 'ನೋಟ';

  @override
  String get settingsTheme => 'ಥೀಮ್';

  @override
  String get settingsThemeDark => 'ಕಡುಗತ್ತಲೆ';

  @override
  String get settingsThemeLight => 'ಬೆಳಕು';

  @override
  String get settingsThemeSystem => 'ವ್ಯವಸ್ಥೆ';

  @override
  String get settingsLanguage => 'ಭಾಷೆ';

  @override
  String get settingsLanguageSystem => 'ವ್ಯವಸ್ಥೆ ಡಿಫಾಲ್ಟ್';

  @override
  String get settingsTimer => 'ಟೈಮರ್';

  @override
  String get settingsDefaultMode => 'ಡಿಫಾಲ್ಟ್ ಮೋಡ್';

  @override
  String get settingsDefaultDuration => 'ಡಿಫಾಲ್ಟ್ ಅವಧಿ';

  @override
  String settingsDurationMinutes(int count) {
    return '$count ನಿಮಿಷ';
  }

  @override
  String get settingsCountdown => 'ಕೌಂಟ್‌ಡೌನ್';

  @override
  String get settingsCountdownDesc => 'ಅವಧಿ ನಿಗದಿಪಡಿಸಿ, ಟೈಮರ್ ಕ್ಷೀಣಿಸುತ್ತದೆ';

  @override
  String get settingsStopwatch => 'ಸ್ಟಾಪ್‌ವಾಚ್';

  @override
  String get settingsStopwatchDesc => 'ಮುಕ್ತ-ಅಂತ್ಯ, ಕೈಯಾರೆ ನಿಲ್ಲಿಸಿ';

  @override
  String get settingsBellSounds => 'ಗಂಟೆ ಶಬ್ದಗಳು';

  @override
  String get settingsStartBell => 'ಪ್ರಾರಂಭ ಗಂಟೆ';

  @override
  String get settingsEndBell => 'ಅಂತ್ಯ ಗಂಟೆ';

  @override
  String get settingsIntervalBell => 'ಮಧ್ಯಂತರ ಗಂಟೆ';

  @override
  String get settingsBellNone => 'ಇಲ್ಲ';

  @override
  String get settingsPickFromDevice => 'ಸಾಧನದಿಂದ ಆಯ್ಕೆ ಮಾಡಿ...';

  @override
  String get settingsEnableInterval => 'ಮಧ್ಯಂತರ ಗಂಟೆ ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String settingsIntervalEvery(int count) {
    return 'ಪ್ರತಿ $count ನಿ';
  }

  @override
  String get settingsOff => 'ಆಫ್';

  @override
  String get settingsIntervalDuration => 'ಮಧ್ಯಂತರ ಅವಧಿ';

  @override
  String get settingsIntervalSound => 'ಮಧ್ಯಂತರ ಶಬ್ದ';

  @override
  String get settingsBgMusic => 'ಹಿನ್ನೆಲೆ ಸಂಗೀತ';

  @override
  String get settingsMusicFile => 'ಸಂಗೀತ ಫೈಲ್';

  @override
  String get settingsMusicSelected => 'ಆಯ್ಕೆಯಾಗಿದೆ';

  @override
  String get settingsMusicNone => 'ಇಲ್ಲ';

  @override
  String get settingsRemoveMusic => 'ಹಿನ್ನೆಲೆ ಸಂಗೀತ ತೆಗೆದುಹಾಕಿ';

  @override
  String get settingsTags => 'ಟ್ಯಾಗ್‌ಗಳು';

  @override
  String get settingsAddTag => '+ ಸೇರಿಸಿ';

  @override
  String get settingsAddTagTitle => 'ಟ್ಯಾಗ್ ಸೇರಿಸಿ';

  @override
  String get settingsAddTagHint => 'ಉದಾ., ಏಕಾಗ್ರ';

  @override
  String get settingsQuotes => 'ಉದ್ಧರಣಗಳು';

  @override
  String get settingsAddCustomQuote => 'ಕಸ್ಟಮ್ ಉದ್ಧರಣ ಸೇರಿಸಿ';

  @override
  String settingsUserQuotes(int count) {
    return '$count ಬಳಕೆದಾರ ಉದ್ಧರಣಗಳು';
  }

  @override
  String get settingsData => 'ದತ್ತಾಂಶ';

  @override
  String get settingsExport => 'ದತ್ತಾಂಶ ರಫ್ತು';

  @override
  String get settingsExportDesc =>
      'ನಿಮ್ಮ ಸೆಷನ್‌ಗಳು ಮತ್ತು ಕಾನ್ಫಿಗ್ JSON ಆಗಿ ಹಂಚಿ';

  @override
  String get settingsImport => 'ದತ್ತಾಂಶ ಆಮದು';

  @override
  String get settingsImportDesc => 'ಚಿತ್ತ JSON ರಫ್ತು ಫೈಲ್‌ನಿಂದ ಲೋಡ್ ಮಾಡಿ';

  @override
  String get settingsImportReplaceMsg =>
      'ಎಲ್ಲಾ ಅಸ್ತಿತ್ವದಲ್ಲಿರುವ ದತ್ತಾಂಶ ಬದಲಿಸುವುದೇ, ಅಥವಾ ಪ್ರಸ್ತುತ ದತ್ತಾಂಶದೊಂದಿಗೆ ವಿಲೀನಗೊಳಿಸುವುದೇ?';

  @override
  String get settingsMerge => 'ವಿಲೀನ';

  @override
  String get settingsReplaceAll => 'ಎಲ್ಲವನ್ನೂ ಬದಲಿಸಿ';

  @override
  String get settingsImportSuccess => 'ದತ್ತಾಂಶ ಯಶಸ್ವಿಯಾಗಿ ಆಮದಾಗಿದೆ';

  @override
  String get settingsImportError => 'ಅಮಾನ್ಯ ಆಮದು ಫೈಲ್';

  @override
  String settingsExportFailed(String error) {
    return 'ರಫ್ತು ವಿಫಲವಾಗಿದೆ: $error';
  }

  @override
  String get notesTitle => 'ಸೆಷನ್ ಟಿಪ್ಪಣಿಗಳು';

  @override
  String get notesPrompt => 'ನಿಮ್ಮ ಅಭ್ಯಾಸ ಹೇಗಿತ್ತು?';

  @override
  String get notesHint => 'ನಿಮ್ಮ ಅನುಭವದ ಬಗ್ಗೆ ಬರೆಯಿರಿ...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 ಪದಗಳು';
  }

  @override
  String get notesTags => 'ಟ್ಯಾಗ್‌ಗಳು';

  @override
  String get sessionComplete => 'ಸೆಷನ್ ಪೂರ್ಣ';

  @override
  String get sessionTitle => 'ಸೆಷನ್';

  @override
  String get sessionCountdown => 'ಕೌಂಟ್‌ಡೌನ್';

  @override
  String get sessionStopwatch => 'ಸ್ಟಾಪ್‌ವಾಚ್';

  @override
  String get sessionCompleted => 'ಪೂರ್ಣಗೊಂಡಿದೆ';

  @override
  String get sessionNotes => 'ಟಿಪ್ಪಣಿಗಳು';

  @override
  String get sessionNoNotes => 'ಈ ಸೆಷನ್‌ಗೆ ಯಾವ ಟಿಪ್ಪಣಿಗಳಿಲ್ಲ';

  @override
  String get addQuoteTitle => 'ಉದ್ಧರಣ ಸೇರಿಸಿ';

  @override
  String get addQuoteOriginalText => 'ಮೂಲ ಪಠ್ಯ *';

  @override
  String get addQuoteOriginalHint => 'ಮೂಲ ಲಿಪಿಯಲ್ಲಿ ಉದ್ಧರಣ ನಮೂದಿಸಿ...';

  @override
  String get addQuoteLanguage => 'ಭಾಷೆ';

  @override
  String get addQuoteTranslation => 'ಇಂಗ್ಲಿಷ್ ಅನುವಾದ *';

  @override
  String get addQuoteTranslationHint => 'ಇಂಗ್ಲಿಷ್ ಅನುವಾದ ನಮೂದಿಸಿ...';

  @override
  String get addQuoteSource => 'ಮೂಲ';

  @override
  String get addQuoteSourceHint => 'ಉದಾ., ಭಗವದ್ಗೀತೆ';

  @override
  String get addQuoteReference => 'ಉಲ್ಲೇಖ';

  @override
  String get addQuoteReferenceHint => 'ಉದಾ., ಅಧ್ಯಾಯ 2, ಶ್ಲೋಕ 47';

  @override
  String get addQuoteSave => 'ಉದ್ಧರಣ ಉಳಿಸಿ';

  @override
  String get addQuoteAdded => 'ಉದ್ಧರಣ ಸೇರಿಸಲಾಗಿದೆ';

  @override
  String get langEnglish => 'ಇಂಗ್ಲಿಷ್';

  @override
  String get langHindi => 'ಹಿಂದಿ';

  @override
  String get langKannada => 'ಕನ್ನಡ';

  @override
  String get langSanskrit => 'ಸಂಸ್ಕೃತ';

  @override
  String get langTelugu => 'ತೆಲುಗು';

  @override
  String get langTamil => 'ತಮಿಳು';

  @override
  String get langMalayalam => 'ಮಲಯಾಳಂ';

  @override
  String get langFrench => 'ಫ್ರೆಂಚ್';

  @override
  String get langGerman => 'ಜರ್ಮನ್';

  @override
  String get langJapanese => 'ಜಪಾನಿ';

  @override
  String get langHebrew => 'ಹೀಬ್ರೂ';

  @override
  String get langChinese => 'ಚೀನಿ';

  @override
  String get langMarathi => 'ಮರಾಠಿ';

  @override
  String get langGujarati => 'ಗುಜರಾತಿ';

  @override
  String get langOdia => 'ಒಡಿಯಾ';

  @override
  String get langBengali => 'ಬಂಗಾಳಿ';

  @override
  String get langTulu => 'ತುಳು';

  @override
  String get langKonkani => 'ಕೊಂಕಣಿ';

  @override
  String get langUrdu => 'ಉರ್ದು';

  @override
  String get langItalian => 'ಇಟಾಲಿಯನ್';

  @override
  String get langSpanish => 'ಸ್ಪ್ಯಾನಿಷ್';

  @override
  String get langArabic => 'ಅರಬ್ಬಿ';

  @override
  String get langRussian => 'ರಷ್ಯನ್';

  @override
  String get langPortuguese => 'ಪೋರ್ಚುಗೀಸ್';

  @override
  String get langMaithili => 'ಮೈಥಿಲಿ';

  @override
  String get langAssamese => 'ಅಸಾಮಿ';

  @override
  String get langPunjabi => 'ಪಂಜಾಬಿ';

  @override
  String get langOther => 'ಇತರೆ';

  @override
  String get preSessionSetup => 'ಸೆಷನ್ ಸೆಟಪ್';

  @override
  String get timerPaused => 'ನಿಲ್ಲಿಸಲಾಗಿದೆ';
}
