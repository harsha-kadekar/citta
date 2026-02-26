// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get actionCancel => 'منسوخ';

  @override
  String get actionSave => 'محفوظ کریں';

  @override
  String get actionSkip => 'چھوڑیں';

  @override
  String get actionContinue => 'جاری رکھیں';

  @override
  String get actionDelete => 'حذف کریں';

  @override
  String get actionAdd => 'شامل کریں';

  @override
  String get actionBegin => 'شروع کریں';

  @override
  String get navDhyana => 'دھیان';

  @override
  String get navHistory => 'تاریخ';

  @override
  String get navStats => 'اعداد و شمار';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get splashGreeting => 'نمسکار';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'شروع کرنے کے لیے ٹیپ کریں';

  @override
  String get welcomeTitle => 'Citta میں خوش آمدید';

  @override
  String get welcomeNameHint => 'اپنا نام درج کریں';

  @override
  String get homeBegin => 'شروع کریں';

  @override
  String get homeCountdown => 'الٹی گنتی';

  @override
  String get homeStopwatch => 'اسٹاپ واچ';

  @override
  String get homeMin => 'منٹ';

  @override
  String get historyTitle => 'تاریخ';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'سیشن حذف کریں';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'سب';

  @override
  String get historyEmpty => 'ابھی تک کوئی سیشن نہیں';

  @override
  String get historyEmptyHint =>
      'اپنا پہلا دھیان سیشن مکمل کریں\nیہاں دیکھنے کے لیے';

  @override
  String get statsTitle => 'اعداد و شمار';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'موجودہ سلسلہ';

  @override
  String get statsLongestStreak => 'طویل ترین سلسلہ';

  @override
  String get statsTotalSessions => 'کل سیشن';

  @override
  String get statsAverage => 'اوسط';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'دن',
      one: 'دن',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'ترتیبات';

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
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageSystem => 'سسٹم ڈیفالٹ';

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
  String get settingsMerge => 'ضم کریں';

  @override
  String get settingsReplaceAll => 'سب بدلیں';

  @override
  String get settingsImportSuccess => 'ڈیٹا کامیابی سے درآمد ہوا';

  @override
  String get settingsImportError => 'غلط فائل';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'سیشن نوٹس';

  @override
  String get notesPrompt => 'آپ کی مشق کیسی رہی؟';

  @override
  String get notesHint => 'اپنا تجربہ لکھیں...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'سیشن مکمل';

  @override
  String get sessionTitle => 'سیشن';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'مکمل';

  @override
  String get sessionNotes => 'نوٹس';

  @override
  String get sessionNoNotes => 'اس سیشن کے لیے کوئی نوٹس نہیں';

  @override
  String get addQuoteTitle => 'اقتباس شامل کریں';

  @override
  String get addQuoteOriginalText => 'Original Text *';

  @override
  String get addQuoteOriginalHint => 'Enter the quote in original script...';

  @override
  String get addQuoteLanguage => 'زبان';

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
  String get langEnglish => 'انگریزی';

  @override
  String get langHindi => 'ہندی';

  @override
  String get langKannada => 'کنڑ';

  @override
  String get langSanskrit => 'سنسکرت';

  @override
  String get langTelugu => 'تیلگو';

  @override
  String get langTamil => 'تامل';

  @override
  String get langMalayalam => 'ملیالم';

  @override
  String get langFrench => 'فرانسیسی';

  @override
  String get langGerman => 'جرمن';

  @override
  String get langJapanese => 'جاپانی';

  @override
  String get langHebrew => 'عبرانی';

  @override
  String get langChinese => 'چینی';

  @override
  String get langMarathi => 'مراٹھی';

  @override
  String get langGujarati => 'گجراتی';

  @override
  String get langOdia => 'اوڈیہ';

  @override
  String get langBengali => 'بنگالی';

  @override
  String get langTulu => 'تلو';

  @override
  String get langKonkani => 'کونکنی';

  @override
  String get langUrdu => 'اردو';

  @override
  String get langItalian => 'اطالوی';

  @override
  String get langSpanish => 'ہسپانوی';

  @override
  String get langArabic => 'عربی';

  @override
  String get langRussian => 'روسی';

  @override
  String get langPortuguese => 'پرتگالی';

  @override
  String get langMaithili => 'میتھلی';

  @override
  String get langAssamese => 'آسامی';

  @override
  String get langPunjabi => 'پنجابی';

  @override
  String get langOther => 'دیگر';

  @override
  String get preSessionSetup => 'سیشن سیٹ اپ';

  @override
  String get timerPaused => 'رکا ہوا';
}
