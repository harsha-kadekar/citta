// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get actionCancel => 'ביטול';

  @override
  String get actionSave => 'שמור';

  @override
  String get actionSkip => 'דלג';

  @override
  String get actionContinue => 'המשך';

  @override
  String get actionDelete => 'מחק';

  @override
  String get actionAdd => 'הוסף';

  @override
  String get actionBegin => 'התחל';

  @override
  String get navDhyana => 'דיאנה';

  @override
  String get navHistory => 'היסטוריה';

  @override
  String get navStats => 'סטטיסטיקה';

  @override
  String get navSettings => 'הגדרות';

  @override
  String get splashGreeting => 'נמסקרה';

  @override
  String splashGreetingWithName(String name) {
    return 'נמסקרה, $name';
  }

  @override
  String get splashTapToBegin => 'הקש להתחלה';

  @override
  String get welcomeTitle => 'ברוך הבא ל-Citta';

  @override
  String get welcomeNameHint => 'הזן את שמך';

  @override
  String get homeBegin => 'התחל';

  @override
  String get homeCountdown => 'ספירה לאחור';

  @override
  String get homeStopwatch => 'שעון עצר';

  @override
  String get homeMin => 'דק\'';

  @override
  String get historyTitle => 'היסטוריה';

  @override
  String historySelected(int count) {
    return '$count נבחרו';
  }

  @override
  String get historyDeleteTitle => 'מחק מפגשים';

  @override
  String historyDeleteConfirm(int count) {
    return 'למחוק $count מפגשים? לא ניתן לבטל פעולה זו.';
  }

  @override
  String get historyFilterAll => 'הכל';

  @override
  String get historyEmpty => 'אין עדיין מפגשים';

  @override
  String get historyEmptyHint =>
      'השלם את מפגש הדיאנה הראשון שלך\nכדי לראות אותו כאן';

  @override
  String get statsTitle => 'סטטיסטיקה';

  @override
  String get statsToggleCalendar => 'החלף תצוגת לוח שנה';

  @override
  String get statsCurrentStreak => 'רצף נוכחי';

  @override
  String get statsLongestStreak => 'רצף ארוך ביותר';

  @override
  String get statsTotalSessions => 'סה\"כ מפגשים';

  @override
  String get statsAverage => 'ממוצע';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ימים',
      two: 'ימים',
      one: 'יום',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String get settingsProfile => 'פרופיל';

  @override
  String get settingsName => 'שם';

  @override
  String get settingsNameNotSet => 'לא הוגדר';

  @override
  String get settingsEditName => 'ערוך שם';

  @override
  String get settingsAppearance => 'מראה';

  @override
  String get settingsTheme => 'ערכת נושא';

  @override
  String get settingsThemeDark => 'כהה';

  @override
  String get settingsThemeLight => 'בהיר';

  @override
  String get settingsThemeSystem => 'מערכת';

  @override
  String get settingsLanguage => 'שפה';

  @override
  String get settingsLanguageSystem => 'ברירת מחדל של המערכת';

  @override
  String get settingsTimer => 'טיימר';

  @override
  String get settingsDefaultMode => 'מצב ברירת מחדל';

  @override
  String get settingsDefaultDuration => 'משך ברירת מחדל';

  @override
  String settingsDurationMinutes(int count) {
    return '$count דקות';
  }

  @override
  String get settingsCountdown => 'ספירה לאחור';

  @override
  String get settingsCountdownDesc => 'הגדר משך, הטיימר סופר לאחור';

  @override
  String get settingsStopwatch => 'שעון עצר';

  @override
  String get settingsStopwatchDesc => 'פתוח, עצירה ידנית';

  @override
  String get settingsBellSounds => 'צלילי פעמון';

  @override
  String get settingsStartBell => 'פעמון פתיחה';

  @override
  String get settingsEndBell => 'פעמון סיום';

  @override
  String get settingsIntervalBell => 'פעמון אינטרוול';

  @override
  String get settingsBellNone => 'ללא';

  @override
  String get settingsPickFromDevice => 'בחר מהמכשיר...';

  @override
  String get settingsEnableInterval => 'הפעל פעמון אינטרוול';

  @override
  String settingsIntervalEvery(int count) {
    return 'כל $count דק\'';
  }

  @override
  String get settingsOff => 'כבוי';

  @override
  String get settingsIntervalDuration => 'משך אינטרוול';

  @override
  String get settingsIntervalSound => 'צליל אינטרוול';

  @override
  String get settingsBgMusic => 'מוזיקת רקע';

  @override
  String get settingsMusicFile => 'קובץ מוזיקה';

  @override
  String get settingsMusicSelected => 'נבחר';

  @override
  String get settingsMusicNone => 'ללא';

  @override
  String get settingsRemoveMusic => 'הסר מוזיקת רקע';

  @override
  String get settingsTags => 'תגיות';

  @override
  String get settingsAddTag => '+ הוסף';

  @override
  String get settingsAddTagTitle => 'הוסף תגית';

  @override
  String get settingsAddTagHint => 'לדוגמה, ממוקד';

  @override
  String get settingsQuotes => 'ציטוטים';

  @override
  String get settingsAddCustomQuote => 'הוסף ציטוט מותאם אישית';

  @override
  String settingsUserQuotes(int count) {
    return '$count ציטוטי משתמש';
  }

  @override
  String get settingsData => 'נתונים';

  @override
  String get settingsExport => 'ייצא נתונים';

  @override
  String get settingsExportDesc => 'שתף את המפגשים וההגדרות כ-JSON';

  @override
  String get settingsImport => 'ייבא נתונים';

  @override
  String get settingsImportDesc => 'טען מקובץ ייצוא Citta JSON';

  @override
  String get settingsImportReplaceMsg =>
      'החלף את כל הנתונים הקיימים, או מזג עם הנתונים הנוכחיים?';

  @override
  String get settingsMerge => 'מזג';

  @override
  String get settingsReplaceAll => 'החלף הכל';

  @override
  String get settingsImportSuccess => 'הנתונים יובאו בהצלחה';

  @override
  String get settingsImportError => 'קובץ ייבוא לא חוקי';

  @override
  String settingsExportFailed(String error) {
    return 'הייצוא נכשל: $error';
  }

  @override
  String get notesTitle => 'הערות מפגש';

  @override
  String get notesPrompt => 'איך הייתה התרגול שלך?';

  @override
  String get notesHint => 'כתוב על החוויה שלך...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 מילים';
  }

  @override
  String get notesTags => 'תגיות';

  @override
  String get sessionComplete => 'המפגש הסתיים';

  @override
  String get sessionTitle => 'מפגש';

  @override
  String get sessionCountdown => 'ספירה לאחור';

  @override
  String get sessionStopwatch => 'שעון עצר';

  @override
  String get sessionCompleted => 'הושלם';

  @override
  String get sessionNotes => 'הערות';

  @override
  String get sessionNoNotes => 'אין הערות למפגש זה';

  @override
  String get addQuoteTitle => 'הוסף ציטוט';

  @override
  String get addQuoteOriginalText => 'טקסט מקורי *';

  @override
  String get addQuoteOriginalHint => 'הזן את הציטוט בכתב המקורי...';

  @override
  String get addQuoteLanguage => 'שפה';

  @override
  String get addQuoteTranslation => 'תרגום לאנגלית *';

  @override
  String get addQuoteTranslationHint => 'הזן את התרגום לאנגלית...';

  @override
  String get addQuoteSource => 'מקור';

  @override
  String get addQuoteSourceHint => 'לדוגמה, בהגוואד גיטה';

  @override
  String get addQuoteReference => 'הפניה';

  @override
  String get addQuoteReferenceHint => 'לדוגמה, פרק 2, פסוק 47';

  @override
  String get addQuoteSave => 'שמור ציטוט';

  @override
  String get addQuoteAdded => 'הציטוט נוסף';

  @override
  String get langEnglish => 'אנגלית';

  @override
  String get langHindi => 'הינדי';

  @override
  String get langKannada => 'קנאדה';

  @override
  String get langSanskrit => 'סנסקריט';

  @override
  String get langTelugu => 'טלוגו';

  @override
  String get langTamil => 'טמילית';

  @override
  String get langMalayalam => 'מלאיאלאם';

  @override
  String get langFrench => 'צרפתית';

  @override
  String get langGerman => 'גרמנית';

  @override
  String get langJapanese => 'יפנית';

  @override
  String get langHebrew => 'עברית';

  @override
  String get langChinese => 'סינית';

  @override
  String get langMarathi => 'מראטהי';

  @override
  String get langGujarati => 'גוג\'ראטי';

  @override
  String get langOdia => 'אודיה';

  @override
  String get langBengali => 'בנגלי';

  @override
  String get langTulu => 'טולו';

  @override
  String get langKonkani => 'קונקאני';

  @override
  String get langUrdu => 'אורדו';

  @override
  String get langItalian => 'איטלקית';

  @override
  String get langSpanish => 'ספרדית';

  @override
  String get langArabic => 'ערבית';

  @override
  String get langRussian => 'רוסית';

  @override
  String get langPortuguese => 'פורטוגזית';

  @override
  String get langMaithili => 'מייתילי';

  @override
  String get langAssamese => 'אסאמית';

  @override
  String get langPunjabi => 'פנג\'אבי';

  @override
  String get langOther => 'אחר';

  @override
  String get preSessionSetup => 'הגדרת מפגש';

  @override
  String get timerPaused => 'מושהה';
}
