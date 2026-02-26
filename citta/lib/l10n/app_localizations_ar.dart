// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionSkip => 'تخطي';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionBegin => 'ابدأ';

  @override
  String get navDhyana => 'ديانا';

  @override
  String get navHistory => 'السجل';

  @override
  String get navStats => 'الإحصائيات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get splashGreeting => 'ناماسكارا';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'اضغط للبدء';

  @override
  String get welcomeTitle => 'مرحباً بك في Citta';

  @override
  String get welcomeNameHint => 'أدخل اسمك';

  @override
  String get homeBegin => 'ابدأ';

  @override
  String get homeCountdown => 'العد التنازلي';

  @override
  String get homeStopwatch => 'ساعة الإيقاف';

  @override
  String get homeMin => 'دقيقة';

  @override
  String get historyTitle => 'السجل';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'حذف الجلسات';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'الكل';

  @override
  String get historyEmpty => 'لا توجد جلسات بعد';

  @override
  String get historyEmptyHint => 'أكمل جلسة ديانا الأولى\nلرؤيتها هنا';

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get statsToggleCalendar => 'تبديل التقويم';

  @override
  String get statsCurrentStreak => 'السلسلة الحالية';

  @override
  String get statsLongestStreak => 'أطول سلسلة';

  @override
  String get statsTotalSessions => 'إجمالي الجلسات';

  @override
  String get statsAverage => 'المتوسط';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أيام',
      one: 'يوم',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsProfile => 'الملف الشخصي';

  @override
  String get settingsName => 'الاسم';

  @override
  String get settingsNameNotSet => 'غير محدد';

  @override
  String get settingsEditName => 'تعديل الاسم';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSystem => 'افتراضي النظام';

  @override
  String get settingsTimer => 'المؤقت';

  @override
  String get settingsDefaultMode => 'Default Mode';

  @override
  String get settingsDefaultDuration => 'Default Duration';

  @override
  String settingsDurationMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsCountdown => 'العد التنازلي';

  @override
  String get settingsCountdownDesc => 'Set a duration, timer counts down';

  @override
  String get settingsStopwatch => 'ساعة الإيقاف';

  @override
  String get settingsStopwatchDesc => 'Open-ended, stop manually';

  @override
  String get settingsBellSounds => 'أصوات الجرس';

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
  String get settingsOff => 'إيقاف';

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
  String get settingsData => 'البيانات';

  @override
  String get settingsExport => 'تصدير البيانات';

  @override
  String get settingsExportDesc => 'Share your sessions & config as JSON';

  @override
  String get settingsImport => 'استيراد البيانات';

  @override
  String get settingsImportDesc => 'Load from a Citta JSON export file';

  @override
  String get settingsImportReplaceMsg =>
      'Replace all existing data, or merge with current data?';

  @override
  String get settingsMerge => 'دمج';

  @override
  String get settingsReplaceAll => 'استبدال الكل';

  @override
  String get settingsImportSuccess => 'تم استيراد البيانات بنجاح';

  @override
  String get settingsImportError => 'ملف غير صالح';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'ملاحظات الجلسة';

  @override
  String get notesPrompt => 'كيف كانت ممارستك؟';

  @override
  String get notesHint => 'اكتب عن تجربتك...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'اكتملت الجلسة';

  @override
  String get sessionTitle => 'الجلسة';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'مكتمل';

  @override
  String get sessionNotes => 'الملاحظات';

  @override
  String get sessionNoNotes => 'لا توجد ملاحظات لهذه الجلسة';

  @override
  String get addQuoteTitle => 'إضافة اقتباس';

  @override
  String get addQuoteOriginalText => 'Original Text *';

  @override
  String get addQuoteOriginalHint => 'Enter the quote in original script...';

  @override
  String get addQuoteLanguage => 'اللغة';

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
  String get langEnglish => 'الإنجليزية';

  @override
  String get langHindi => 'الهندية';

  @override
  String get langKannada => 'الكانادا';

  @override
  String get langSanskrit => 'السنسكريتية';

  @override
  String get langTelugu => 'التيلوغو';

  @override
  String get langTamil => 'التاميل';

  @override
  String get langMalayalam => 'المالايالامية';

  @override
  String get langFrench => 'الفرنسية';

  @override
  String get langGerman => 'الألمانية';

  @override
  String get langJapanese => 'اليابانية';

  @override
  String get langHebrew => 'العبرية';

  @override
  String get langChinese => 'الصينية';

  @override
  String get langMarathi => 'الماراثية';

  @override
  String get langGujarati => 'الغوجاراتية';

  @override
  String get langOdia => 'الأوديا';

  @override
  String get langBengali => 'البنغالية';

  @override
  String get langTulu => 'التولو';

  @override
  String get langKonkani => 'الكونكانية';

  @override
  String get langUrdu => 'الأردية';

  @override
  String get langItalian => 'الإيطالية';

  @override
  String get langSpanish => 'الإسبانية';

  @override
  String get langArabic => 'العربية';

  @override
  String get langRussian => 'الروسية';

  @override
  String get langPortuguese => 'البرتغالية';

  @override
  String get langMaithili => 'الميثيلية';

  @override
  String get langAssamese => 'الأسامية';

  @override
  String get langPunjabi => 'البنجابية';

  @override
  String get langOther => 'أخرى';

  @override
  String get preSessionSetup => 'إعداد الجلسة';

  @override
  String get timerPaused => 'متوقف مؤقتاً';
}
