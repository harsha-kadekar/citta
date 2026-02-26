// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get actionCancel => 'રદ કરો';

  @override
  String get actionSave => 'સાચવો';

  @override
  String get actionSkip => 'છોડો';

  @override
  String get actionContinue => 'ચાલુ રાખો';

  @override
  String get actionDelete => 'કાઢો';

  @override
  String get actionAdd => 'ઉમેરો';

  @override
  String get actionBegin => 'શરૂ કરો';

  @override
  String get navDhyana => 'ધ્યાન';

  @override
  String get navHistory => 'ઇતિહાસ';

  @override
  String get navStats => 'આંકડા';

  @override
  String get navSettings => 'સેટિંગ્સ';

  @override
  String get splashGreeting => 'નમસ્કાર';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'શરૂ કરવા ટૅપ કરો';

  @override
  String get welcomeTitle => 'Citta માં આપનું સ્વાગત છે';

  @override
  String get welcomeNameHint => 'તમારું નામ દાખલ કરો';

  @override
  String get homeBegin => 'શરૂ કરો';

  @override
  String get homeCountdown => 'કાઉન્ટડાઉન';

  @override
  String get homeStopwatch => 'સ્ટૉપવૉચ';

  @override
  String get homeMin => 'મિ';

  @override
  String get historyTitle => 'ઇતિહાસ';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'સત્રો કાઢો';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'બધા';

  @override
  String get historyEmpty => 'હજી કોઈ સત્ર નથી';

  @override
  String get historyEmptyHint =>
      'પ્રથમ ધ્યાન સત્ર પૂર્ણ કરો\nતેને અહીં જોવા માટે';

  @override
  String get statsTitle => 'આંકડા';

  @override
  String get statsToggleCalendar => 'કૅલેન્ડર ટૉગલ';

  @override
  String get statsCurrentStreak => 'વર્તમાન ક્રમ';

  @override
  String get statsLongestStreak => 'સૌથી લાંબો ક્રમ';

  @override
  String get statsTotalSessions => 'કુલ સત્રો';

  @override
  String get statsAverage => 'સરેરાશ';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'દિવસ',
      one: 'દિવસ',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'સેટિંગ્સ';

  @override
  String get settingsProfile => 'પ્રોફાઇલ';

  @override
  String get settingsName => 'નામ';

  @override
  String get settingsNameNotSet => 'સેટ નથી';

  @override
  String get settingsEditName => 'નામ સંપાદિત કરો';

  @override
  String get settingsAppearance => 'દેખાવ';

  @override
  String get settingsTheme => 'થીમ';

  @override
  String get settingsThemeDark => 'ઘેરી';

  @override
  String get settingsThemeLight => 'હળવી';

  @override
  String get settingsThemeSystem => 'સિસ્ટમ';

  @override
  String get settingsLanguage => 'ભાષા';

  @override
  String get settingsLanguageSystem => 'સિસ્ટમ ડિફૉલ્ટ';

  @override
  String get settingsTimer => 'ટાઇમર';

  @override
  String get settingsDefaultMode => 'Default Mode';

  @override
  String get settingsDefaultDuration => 'Default Duration';

  @override
  String settingsDurationMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsCountdown => 'કાઉન્ટડાઉન';

  @override
  String get settingsCountdownDesc => 'Set a duration, timer counts down';

  @override
  String get settingsStopwatch => 'સ્ટૉપવૉચ';

  @override
  String get settingsStopwatchDesc => 'Open-ended, stop manually';

  @override
  String get settingsBellSounds => 'ઘંટ અવાજ';

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
  String get settingsOff => 'બંધ';

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
  String get settingsData => 'ડેટા';

  @override
  String get settingsExport => 'ડેટા નિકાસ';

  @override
  String get settingsExportDesc => 'Share your sessions & config as JSON';

  @override
  String get settingsImport => 'ડેટા આયાત';

  @override
  String get settingsImportDesc => 'Load from a Citta JSON export file';

  @override
  String get settingsImportReplaceMsg =>
      'Replace all existing data, or merge with current data?';

  @override
  String get settingsMerge => 'ભેળવો';

  @override
  String get settingsReplaceAll => 'બધું બદલો';

  @override
  String get settingsImportSuccess => 'ડેટા સફળતાપૂર્વક આયાત થયો';

  @override
  String get settingsImportError => 'અમાન્ય ફાઇલ';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'સત્ર નોંધ';

  @override
  String get notesPrompt => 'તમારો અભ્યાસ કેવો હતો?';

  @override
  String get notesHint => 'તમારો અનુભવ લખો...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'સત્ર પૂર્ણ';

  @override
  String get sessionTitle => 'સત્ર';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'પૂર્ણ';

  @override
  String get sessionNotes => 'નોંધ';

  @override
  String get sessionNoNotes => 'આ સત્ર માટે કોઈ નોંધ નથી';

  @override
  String get addQuoteTitle => 'અવતરણ ઉમેરો';

  @override
  String get addQuoteOriginalText => 'Original Text *';

  @override
  String get addQuoteOriginalHint => 'Enter the quote in original script...';

  @override
  String get addQuoteLanguage => 'ભાષા';

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
  String get langEnglish => 'અંગ્રેજી';

  @override
  String get langHindi => 'હિન્દી';

  @override
  String get langKannada => 'કન્નડ';

  @override
  String get langSanskrit => 'સંસ્કૃત';

  @override
  String get langTelugu => 'તેલુગુ';

  @override
  String get langTamil => 'તમિળ';

  @override
  String get langMalayalam => 'મળિયાળમ';

  @override
  String get langFrench => 'ફ્રેંચ';

  @override
  String get langGerman => 'જર્મન';

  @override
  String get langJapanese => 'જાપાની';

  @override
  String get langHebrew => 'હિબ્રુ';

  @override
  String get langChinese => 'ચીની';

  @override
  String get langMarathi => 'મરાઠી';

  @override
  String get langGujarati => 'ગુજરાતી';

  @override
  String get langOdia => 'ઓડિયા';

  @override
  String get langBengali => 'બંગાળી';

  @override
  String get langTulu => 'તુળુ';

  @override
  String get langKonkani => 'કોંકણી';

  @override
  String get langUrdu => 'ઉર્દૂ';

  @override
  String get langItalian => 'ઇટાલિયન';

  @override
  String get langSpanish => 'સ્પૅનિશ';

  @override
  String get langArabic => 'અરબી';

  @override
  String get langRussian => 'રશિયન';

  @override
  String get langPortuguese => 'પોર્ટુગીઝ';

  @override
  String get langMaithili => 'મૈથિળી';

  @override
  String get langAssamese => 'આસામી';

  @override
  String get langPunjabi => 'પંજાબી';

  @override
  String get langOther => 'અન્ય';

  @override
  String get preSessionSetup => 'સત્ર સેટઅપ';

  @override
  String get timerPaused => 'અટકી ગયો';
}
