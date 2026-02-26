// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Assamese (`as`).
class AppLocalizationsAs extends AppLocalizations {
  AppLocalizationsAs([String locale = 'as']) : super(locale);

  @override
  String get actionCancel => 'বাতিল';

  @override
  String get actionSave => 'সংৰক্ষণ';

  @override
  String get actionSkip => 'এৰক';

  @override
  String get actionContinue => 'অব্যাহত ৰাখক';

  @override
  String get actionDelete => 'মচক';

  @override
  String get actionAdd => 'যোগ দিয়ক';

  @override
  String get actionBegin => 'আৰম্ভ কৰক';

  @override
  String get navDhyana => 'ধ্যান';

  @override
  String get navHistory => 'ইতিহাস';

  @override
  String get navStats => 'পৰিসংখ্যা';

  @override
  String get navSettings => 'ছেটিংছ';

  @override
  String get splashGreeting => 'নমস্কাৰ';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'আৰম্ভ কৰিবলৈ টেপ কৰক';

  @override
  String get welcomeTitle => 'Citta ত স্বাগতম';

  @override
  String get welcomeNameHint => 'আপোনাৰ নাম লিখক';

  @override
  String get homeBegin => 'আৰম্ভ কৰক';

  @override
  String get homeCountdown => 'কাউন্টডাউন';

  @override
  String get homeStopwatch => 'ষ্টপৱাচ';

  @override
  String get homeMin => 'মি';

  @override
  String get historyTitle => 'ইতিহাস';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'অধিৱেশন মচক';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'সকলো';

  @override
  String get historyEmpty => 'এতিয়ালৈকে কোনো অধিৱেশন নাই';

  @override
  String get historyEmptyHint =>
      'প্ৰথম ধ্যান অধিৱেশন সম্পূৰ্ণ কৰক\nইয়াত চাবলৈ';

  @override
  String get statsTitle => 'পৰিসংখ্যা';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'বৰ্তমান ধাৰা';

  @override
  String get statsLongestStreak => 'দীৰ্ঘতম ধাৰা';

  @override
  String get statsTotalSessions => 'মুঠ অধিৱেশন';

  @override
  String get statsAverage => 'গড়';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'দিন',
      one: 'দিন',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'ছেটিংছ';

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
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsLanguageSystem => 'ছিষ্টেম ডিফল্ট';

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
  String get settingsMerge => 'একত্ৰিত কৰক';

  @override
  String get settingsReplaceAll => 'সকলো সলনি কৰক';

  @override
  String get settingsImportSuccess => 'ডেটা সফলতাৰে আমদানি হৈছে';

  @override
  String get settingsImportError => 'অবৈধ ফাইল';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'অধিৱেশন টোকা';

  @override
  String get notesPrompt => 'আপোনাৰ অনুশীলন কেনেকুৱা আছিল?';

  @override
  String get notesHint => 'আপোনাৰ অভিজ্ঞতাৰ বিষয়ে লিখক...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'অধিৱেশন সম্পূৰ্ণ';

  @override
  String get sessionTitle => 'অধিৱেশন';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'সম্পূৰ্ণ';

  @override
  String get sessionNotes => 'টোকা';

  @override
  String get sessionNoNotes => 'এই অধিৱেশনৰ বাবে কোনো টোকা নাই';

  @override
  String get addQuoteTitle => 'উদ্ধৃতি যোগ দিয়ক';

  @override
  String get addQuoteOriginalText => 'Original Text *';

  @override
  String get addQuoteOriginalHint => 'Enter the quote in original script...';

  @override
  String get addQuoteLanguage => 'ভাষা';

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
  String get langEnglish => 'ইংৰাজী';

  @override
  String get langHindi => 'হিন্দী';

  @override
  String get langKannada => 'কানাড়া';

  @override
  String get langSanskrit => 'সংস্কৃত';

  @override
  String get langTelugu => 'তেলুগু';

  @override
  String get langTamil => 'তামিল';

  @override
  String get langMalayalam => 'মালায়ালম';

  @override
  String get langFrench => 'ফৰাচী';

  @override
  String get langGerman => 'জাৰ্মান';

  @override
  String get langJapanese => 'জাপানী';

  @override
  String get langHebrew => 'হিব্ৰু';

  @override
  String get langChinese => 'চীনা';

  @override
  String get langMarathi => 'মাৰাঠী';

  @override
  String get langGujarati => 'গুজৰাটী';

  @override
  String get langOdia => 'ওড়িয়া';

  @override
  String get langBengali => 'বাংলা';

  @override
  String get langTulu => 'তুলু';

  @override
  String get langKonkani => 'কোঙ্কণী';

  @override
  String get langUrdu => 'উৰ্দু';

  @override
  String get langItalian => 'ইটালীয়';

  @override
  String get langSpanish => 'স্পেনিছ';

  @override
  String get langArabic => 'আৰবী';

  @override
  String get langRussian => 'ৰাছিয়ান';

  @override
  String get langPortuguese => 'পৰ্তুগীজ';

  @override
  String get langMaithili => 'মৈথিলী';

  @override
  String get langAssamese => 'অসমীয়া';

  @override
  String get langPunjabi => 'পাঞ্জাবী';

  @override
  String get langOther => 'আন';

  @override
  String get preSessionSetup => 'অধিৱেশন সংস্থাপন';

  @override
  String get timerPaused => 'বিৰতি';
}
