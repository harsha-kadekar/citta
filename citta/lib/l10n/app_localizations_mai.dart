// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Maithili (`mai`).
class AppLocalizationsMai extends AppLocalizations {
  AppLocalizationsMai([String locale = 'mai']) : super(locale);

  @override
  String get actionCancel => 'रद्द करू';

  @override
  String get actionSave => 'सहेजू';

  @override
  String get actionSkip => 'छोड़ू';

  @override
  String get actionContinue => 'जारी राखू';

  @override
  String get actionDelete => 'हटाबू';

  @override
  String get actionAdd => 'जोड़ू';

  @override
  String get actionBegin => 'शुरू करू';

  @override
  String get navDhyana => 'ध्यान';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navStats => 'आँकड़ा';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get splashGreeting => 'नमस्कार';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'शुरू करबाक लेल टैप करू';

  @override
  String get welcomeTitle => 'Citta मे स्वागत अछि';

  @override
  String get welcomeNameHint => 'अपन नाम लिखू';

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
  String get historyDeleteTitle => 'सेशन हटाबू';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'सभ';

  @override
  String get historyEmpty => 'अखनि धरि कोनो सेशन नहि';

  @override
  String get historyEmptyHint =>
      'Complete your first dhyana session\nto see it here';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'बर्तमान क्रम';

  @override
  String get statsLongestStreak => 'दीर्घतम क्रम';

  @override
  String get statsTotalSessions => 'कुल सेशन';

  @override
  String get statsAverage => 'औसत';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दिन',
      one: 'दिन',
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
  String get sessionComplete => 'सेशन पूर्ण';

  @override
  String get sessionTitle => 'सेशन';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'पूर्ण';

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
  String get langEnglish => 'अंग्रेजी';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langKannada => 'कन्नड़';

  @override
  String get langSanskrit => 'संस्कृत';

  @override
  String get langTelugu => 'तेलुगु';

  @override
  String get langTamil => 'तमिल';

  @override
  String get langMalayalam => 'मलयालम';

  @override
  String get langFrench => 'फ्रेंच';

  @override
  String get langGerman => 'जर्मन';

  @override
  String get langJapanese => 'जापानी';

  @override
  String get langHebrew => 'हिब्रू';

  @override
  String get langChinese => 'चीनी';

  @override
  String get langMarathi => 'मराठी';

  @override
  String get langGujarati => 'गुजराती';

  @override
  String get langOdia => 'ओडिया';

  @override
  String get langBengali => 'बंगाली';

  @override
  String get langTulu => 'तुलु';

  @override
  String get langKonkani => 'कोंकणी';

  @override
  String get langUrdu => 'उर्दू';

  @override
  String get langItalian => 'इटालियन';

  @override
  String get langSpanish => 'स्पेनिश';

  @override
  String get langArabic => 'अरबी';

  @override
  String get langRussian => 'रूसी';

  @override
  String get langPortuguese => 'पुर्तगाली';

  @override
  String get langMaithili => 'मैथिली';

  @override
  String get langAssamese => 'असमिया';

  @override
  String get langPunjabi => 'पंजाबी';

  @override
  String get langOther => 'अन्य';

  @override
  String get preSessionSetup => 'सेशन सेटअप';

  @override
  String get timerPaused => 'रुकल';
}
