// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get actionCancel => 'ବାତିଲ';

  @override
  String get actionSave => 'ସଞ୍ଚୟ';

  @override
  String get actionSkip => 'ଛାଡ଼ନ୍ତୁ';

  @override
  String get actionContinue => 'ଜାରି ରଖନ୍ତୁ';

  @override
  String get actionDelete => 'ଲିଭାନ୍ତୁ';

  @override
  String get actionAdd => 'ଯୋଡ଼ନ୍ତୁ';

  @override
  String get actionBegin => 'ଆରମ୍ଭ କରନ୍ତୁ';

  @override
  String get navDhyana => 'ଧ୍ୟାନ';

  @override
  String get navHistory => 'ଇତିହାସ';

  @override
  String get navStats => 'ପରିସଂଖ୍ୟାନ';

  @override
  String get navSettings => 'ସେଟିଂ';

  @override
  String get splashGreeting => 'ନମସ୍କାର';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'ଆରମ୍ଭ କରିବାକୁ ଟ୍ୟାପ୍ କରନ୍ତୁ';

  @override
  String get welcomeTitle => 'Citta ରେ ଆପଣଙ୍କୁ ସ୍ୱାଗତ';

  @override
  String get welcomeNameHint => 'ଆପଣଙ୍କ ନାମ ଲିଖନ୍ତୁ';

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
  String get historyDeleteTitle => 'ସ‌ଶନ ଲିଭାନ୍ତୁ';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'ସବୁ';

  @override
  String get historyEmpty => 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ସ‌ଶନ ନାହିଁ';

  @override
  String get historyEmptyHint =>
      'Complete your first dhyana session\nto see it here';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'ବର୍ତ୍ତମାନ ଧାରା';

  @override
  String get statsLongestStreak => 'ଦୀର୍ଘତମ ଧାରା';

  @override
  String get statsTotalSessions => 'ମୋଟ ସ‌ଶନ';

  @override
  String get statsAverage => 'ହାରାହାରି';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ଦିନ',
      one: 'ଦିନ',
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
  String get sessionComplete => 'ସ‌ଶନ ସ‌ମ୍ପୂର୍ଣ';

  @override
  String get sessionTitle => 'ସ‌ଶନ';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'ସ‌ମ୍ପୂର୍ଣ';

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
  String get langEnglish => 'ଇଂରାଜୀ';

  @override
  String get langHindi => 'ହିନ୍ଦୀ';

  @override
  String get langKannada => 'କନ୍ନଡ';

  @override
  String get langSanskrit => 'ସଂସ୍କୃତ';

  @override
  String get langTelugu => 'ତେଲୁଗୁ';

  @override
  String get langTamil => 'ତାମିଲ';

  @override
  String get langMalayalam => 'ମଲୟାଳମ';

  @override
  String get langFrench => 'ଫ୍ରେଞ୍ଚ';

  @override
  String get langGerman => 'ଜର୍ମାନ';

  @override
  String get langJapanese => 'ଜାପାନୀ';

  @override
  String get langHebrew => 'ହିବ୍ରୁ';

  @override
  String get langChinese => 'ଚୀନୀ';

  @override
  String get langMarathi => 'ମରାଠୀ';

  @override
  String get langGujarati => 'ଗୁଜୁରାଟୀ';

  @override
  String get langOdia => 'ଓଡ଼ିଆ';

  @override
  String get langBengali => 'ବଙ୍ଗାଳୀ';

  @override
  String get langTulu => 'ତୁଳୁ';

  @override
  String get langKonkani => 'କୋଙ୍କଣୀ';

  @override
  String get langUrdu => 'ଉର୍ଦ୍ଦୁ';

  @override
  String get langItalian => 'ଇଟାଲୀୟ';

  @override
  String get langSpanish => 'ସ୍ପ୍ୟାନିଶ';

  @override
  String get langArabic => 'ଆରବୀ';

  @override
  String get langRussian => 'ରଷ୍ୟ';

  @override
  String get langPortuguese => 'ପୋର୍ଚୁଗୀଜ';

  @override
  String get langMaithili => 'ମୈଥିଳୀ';

  @override
  String get langAssamese => 'ଅସମୀୟା';

  @override
  String get langPunjabi => 'ପଞ୍ଜାବୀ';

  @override
  String get langOther => 'ଅନ୍ୟ';

  @override
  String get preSessionSetup => 'ସ‌ଶନ ସେଟଅପ';

  @override
  String get timerPaused => 'ବିରତ';
}
