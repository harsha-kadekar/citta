// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tulu (`tcy`).
class AppLocalizationsTcy extends AppLocalizations {
  AppLocalizationsTcy([String locale = 'tcy']) : super(locale);

  @override
  String get actionCancel => 'ರದ್ದ್ ಮಲ್ಪುಲೆ';

  @override
  String get actionSave => 'ದಾಕಿಲೆ';

  @override
  String get actionSkip => 'ಬುಡ್ಲೆ';

  @override
  String get actionContinue => 'ಮುಂದರಿಯೊಂದು ಪೋಲೆ';

  @override
  String get actionDelete => 'ತೊಲಗಾಯಿಲೆ';

  @override
  String get actionAdd => 'ಸೇರಾಯಿಲೆ';

  @override
  String get actionBegin => 'ಸುರು ಮಲ್ಪುಲೆ';

  @override
  String get navDhyana => 'ಧ್ಯಾನ';

  @override
  String get navHistory => 'ಇತಿಹಾಸ';

  @override
  String get navStats => 'ಅಂಕೆ-ಶಾಂಕೆ';

  @override
  String get navSettings => 'ಸೆಟ್ಟಿಂಗ್ಸ್';

  @override
  String get splashGreeting => 'ನಮಸ್ಕಾರ';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'ಸುರು ಮಲ್ಪೆರೆ ಟ್ಯಾಪ್ ಮಲ್ಪುಲೆ';

  @override
  String get welcomeTitle => 'Citta ರ್ ನಮಸ್ಕಾರ';

  @override
  String get welcomeNameHint => 'ಪೊಸ ಪೇರ್ ಬರೆಯಲೆ';

  @override
  String get homeBegin => 'Begin';

  @override
  String get homeCountdown => 'Countdown';

  @override
  String get homeStopwatch => 'Stopwatch';

  @override
  String get homeMin => 'min';

  @override
  String get historyTitle => 'History';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'ಸೆಶನ್ ತೊಲಗಾಯಿಲೆ';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'ಎಲ್ಲಾ';

  @override
  String get historyEmpty => 'ಇನ್ನು ಸೆಶನ್ ಉಂಡಾಂಡ್';

  @override
  String get historyEmptyHint =>
      'Complete your first dhyana session\nto see it here';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'ಇತ್ತೆ ಸರಣಿ';

  @override
  String get statsLongestStreak => 'ದೀರ್ಘ ಸರಣಿ';

  @override
  String get statsTotalSessions => 'ಒಟ್ಟು ಸೆಶನ್';

  @override
  String get statsAverage => 'ಸಾಮಾನ್ಯ';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ದಿನೊಕ್ಲು',
      one: 'ದಿನ',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsNameNotSet => 'Not set';

  @override
  String get settingsEditName => 'Edit Name';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System Default';

  @override
  String get settingsTimer => 'Timer';

  @override
  String get settingsDefaultMode => 'Default Mode';

  @override
  String get settingsDefaultDuration => 'Default Duration';

  @override
  String settingsDurationMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsCountdown => 'Countdown';

  @override
  String get settingsCountdownDesc => 'Set a duration, timer counts down';

  @override
  String get settingsStopwatch => 'Stopwatch';

  @override
  String get settingsStopwatchDesc => 'Open-ended, stop manually';

  @override
  String get settingsBellSounds => 'Bell Sounds';

  @override
  String get settingsStartBell => 'Start Bell';

  @override
  String get settingsEndBell => 'End Bell';

  @override
  String get settingsIntervalBell => 'Interval Bell';

  @override
  String get settingsBellNone => 'None';

  @override
  String get settingsPickFromDevice => 'Pick from device...';

  @override
  String get settingsEnableInterval => 'Enable Interval Bell';

  @override
  String settingsIntervalEvery(int count) {
    return 'Every $count min';
  }

  @override
  String get settingsOff => 'Off';

  @override
  String get settingsIntervalDuration => 'Interval Duration';

  @override
  String get settingsIntervalSound => 'Interval Sound';

  @override
  String get settingsBgMusic => 'Background Music';

  @override
  String get settingsMusicFile => 'Music File';

  @override
  String get settingsMusicSelected => 'Selected';

  @override
  String get settingsMusicNone => 'None';

  @override
  String get settingsRemoveMusic => 'Remove Background Music';

  @override
  String get settingsTags => 'Tags';

  @override
  String get settingsAddTag => '+ Add';

  @override
  String get settingsAddTagTitle => 'Add Tag';

  @override
  String get settingsAddTagHint => 'e.g., focused';

  @override
  String get settingsQuotes => 'Quotes';

  @override
  String get settingsAddCustomQuote => 'Add Custom Quote';

  @override
  String settingsUserQuotes(int count) {
    return '$count user quotes';
  }

  @override
  String get settingsData => 'Data';

  @override
  String get settingsExport => 'Export Data';

  @override
  String get settingsExportDesc => 'Share your sessions & config as JSON';

  @override
  String get settingsImport => 'Import Data';

  @override
  String get settingsImportDesc => 'Load from a Citta JSON export file';

  @override
  String get settingsImportReplaceMsg =>
      'Replace all existing data, or merge with current data?';

  @override
  String get settingsMerge => 'Merge';

  @override
  String get settingsReplaceAll => 'Replace All';

  @override
  String get settingsImportSuccess => 'Data imported successfully';

  @override
  String get settingsImportError => 'Invalid import file';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'Session Notes';

  @override
  String get notesPrompt => 'How was your practice?';

  @override
  String get notesHint => 'Write about your experience...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'ಸೆಶನ್ ಮುಗಿಪ್ಪಿ';

  @override
  String get sessionTitle => 'ಸೆಶನ್';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'ಮುಗಿಪ್ಪಿ';

  @override
  String get sessionNotes => 'Notes';

  @override
  String get sessionNoNotes => 'No notes for this session';

  @override
  String get addQuoteTitle => 'Add Quote';

  @override
  String get addQuoteOriginalText => 'Original Text *';

  @override
  String get addQuoteOriginalHint => 'Enter the quote in original script...';

  @override
  String get addQuoteLanguage => 'Language';

  @override
  String get addQuoteTranslation => 'English Translation *';

  @override
  String get addQuoteTranslationHint => 'Enter the English translation...';

  @override
  String get addQuoteSource => 'Source';

  @override
  String get addQuoteSourceHint => 'e.g., Bhagavad Gita';

  @override
  String get addQuoteReference => 'Reference';

  @override
  String get addQuoteReferenceHint => 'e.g., Chapter 2, Verse 47';

  @override
  String get addQuoteSave => 'Save Quote';

  @override
  String get addQuoteAdded => 'Quote added';

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
  String get langTamil => 'ತಮಿಳ್';

  @override
  String get langMalayalam => 'ಮಲಯಾಳಂ';

  @override
  String get langFrench => 'ಫ್ರೆಂಚ್';

  @override
  String get langGerman => 'ಜರ್ಮನ್';

  @override
  String get langJapanese => 'ಜಪಾನೀಸ್';

  @override
  String get langHebrew => 'ಹಿಬ್ರೂ';

  @override
  String get langChinese => 'ಚೀನೀ';

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
  String get langOther => 'ಬೇತೆ';

  @override
  String get preSessionSetup => 'ಸೆಶನ್ ಸೆಟಪ್';

  @override
  String get timerPaused => 'ನಿಲ್ಲಿನ';
}
