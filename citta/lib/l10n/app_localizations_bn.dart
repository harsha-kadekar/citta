// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get actionCancel => 'বাতিল';

  @override
  String get actionSave => 'সংরক্ষণ';

  @override
  String get actionSkip => 'বাদ দাও';

  @override
  String get actionContinue => 'চালিয়ে যাও';

  @override
  String get actionDelete => 'মুছুন';

  @override
  String get actionAdd => 'যোগ করুন';

  @override
  String get actionBegin => 'শুরু করুন';

  @override
  String get navDhyana => 'ধ্যান';

  @override
  String get navHistory => 'ইতিহাস';

  @override
  String get navStats => 'পরিসংখ্যান';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get splashGreeting => 'নমস্কার';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'শুরু করতে ট্যাপ করুন';

  @override
  String get welcomeTitle => 'Citta তে স্বাগতম';

  @override
  String get welcomeNameHint => 'আপনার নাম লিখুন';

  @override
  String get homeBegin => 'শুরু করুন';

  @override
  String get homeCountdown => 'কাউন্টডাউন';

  @override
  String get homeStopwatch => 'স্টপওয়াচ';

  @override
  String get homeMin => 'মি';

  @override
  String get historyTitle => 'ইতিহাস';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'সেশন মুছুন';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'সব';

  @override
  String get historyEmpty => 'এখনও কোনো সেশন নেই';

  @override
  String get historyEmptyHint => 'প্রথম ধ্যান সেশন সম্পূর্ণ করুন\nএখানে দেখতে';

  @override
  String get statsTitle => 'পরিসংখ্যান';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'বর্তমান ধারা';

  @override
  String get statsLongestStreak => 'দীর্ঘতম ধারা';

  @override
  String get statsTotalSessions => 'মোট সেশন';

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
  String get settingsTitle => 'সেটিংস';

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
  String get settingsLanguageSystem => 'সিস্টেম ডিফল্ট';

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
  String get settingsMerge => 'মার্জ করুন';

  @override
  String get settingsReplaceAll => 'সব প্রতিস্থাপন করুন';

  @override
  String get settingsImportSuccess => 'ডেটা সফলভাবে আমদানি হয়েছে';

  @override
  String get settingsImportError => 'অবৈধ ফাইল';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'সেশন নোট';

  @override
  String get notesPrompt => 'আপনার অনুশীলন কেমন ছিল?';

  @override
  String get notesHint => 'আপনার অভিজ্ঞতা লিখুন...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'সেশন সম্পূর্ণ';

  @override
  String get sessionTitle => 'সেশন';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'সম্পূর্ণ';

  @override
  String get sessionNotes => 'নোট';

  @override
  String get sessionNoNotes => 'এই সেশনের কোনো নোট নেই';

  @override
  String get addQuoteTitle => 'উদ্ধৃতি যোগ করুন';

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
  String get langEnglish => 'ইংরেজি';

  @override
  String get langHindi => 'হিন্দি';

  @override
  String get langKannada => 'কন্নড';

  @override
  String get langSanskrit => 'সংস্কৃত';

  @override
  String get langTelugu => 'তেলুগু';

  @override
  String get langTamil => 'তামিল';

  @override
  String get langMalayalam => 'মালয়ালম';

  @override
  String get langFrench => 'ফরাসি';

  @override
  String get langGerman => 'জার্মান';

  @override
  String get langJapanese => 'জাপানি';

  @override
  String get langHebrew => 'হিব্রু';

  @override
  String get langChinese => 'চীনা';

  @override
  String get langMarathi => 'মারাঠি';

  @override
  String get langGujarati => 'গুজরাটি';

  @override
  String get langOdia => 'ওড়িয়া';

  @override
  String get langBengali => 'বাংলা';

  @override
  String get langTulu => 'তুলু';

  @override
  String get langKonkani => 'কোঙ্কণি';

  @override
  String get langUrdu => 'উর্দু';

  @override
  String get langItalian => 'ইতালীয়';

  @override
  String get langSpanish => 'স্প্যানিশ';

  @override
  String get langArabic => 'আরবি';

  @override
  String get langRussian => 'রাশিয়ান';

  @override
  String get langPortuguese => 'পর্তুগিজ';

  @override
  String get langMaithili => 'মৈথিলি';

  @override
  String get langAssamese => 'অসমিয়া';

  @override
  String get langPunjabi => 'পাঞ্জাবি';

  @override
  String get langOther => 'অন্যান্য';

  @override
  String get preSessionSetup => 'সেশন সেটআপ';

  @override
  String get timerPaused => 'বিরতি';
}
