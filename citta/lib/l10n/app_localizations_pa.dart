// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get actionCancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get actionSave => 'ਸੁਰੱਖਿਅਤ ਕਰੋ';

  @override
  String get actionSkip => 'ਛੱਡੋ';

  @override
  String get actionContinue => 'ਜਾਰੀ ਰੱਖੋ';

  @override
  String get actionDelete => 'ਮਿਟਾਓ';

  @override
  String get actionAdd => 'ਜੋੜੋ';

  @override
  String get actionBegin => 'ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get navDhyana => 'ਧਿਆਨ';

  @override
  String get navHistory => 'ਇਤਿਹਾਸ';

  @override
  String get navStats => 'ਅੰਕੜੇ';

  @override
  String get navSettings => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get splashGreeting => 'ਨਮਸਕਾਰ';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਟੈਪ ਕਰੋ';

  @override
  String get welcomeTitle => 'Citta ਵਿੱਚ ਜੀ ਆਇਆਂ';

  @override
  String get welcomeNameHint => 'ਆਪਣਾ ਨਾਮ ਦਰਜ ਕਰੋ';

  @override
  String get homeBegin => 'ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get homeCountdown => 'ਉਲਟੀ ਗਿਣਤੀ';

  @override
  String get homeStopwatch => 'ਸਟਾਪਵਾਚ';

  @override
  String get homeMin => 'ਮਿ';

  @override
  String get historyTitle => 'ਇਤਿਹਾਸ';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'ਸੈਸ਼ਨ ਮਿਟਾਓ';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'ਸਭ';

  @override
  String get historyEmpty => 'ਅਜੇ ਕੋਈ ਸੈਸ਼ਨ ਨਹੀਂ';

  @override
  String get historyEmptyHint => 'ਆਪਣਾ ਪਹਿਲਾ ਧਿਆਨ ਸੈਸ਼ਨ ਪੂਰਾ ਕਰੋ\nਇੱਥੇ ਦੇਖਣ ਲਈ';

  @override
  String get statsTitle => 'ਅੰਕੜੇ';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'ਮੌਜੂਦਾ ਲੜੀ';

  @override
  String get statsLongestStreak => 'ਸਭ ਤੋਂ ਲੰਮੀ ਲੜੀ';

  @override
  String get statsTotalSessions => 'ਕੁੱਲ ਸੈਸ਼ਨ';

  @override
  String get statsAverage => 'ਔਸਤ';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ਦਿਨ',
      one: 'ਦਿਨ',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get settingsProfile => 'ਪ੍ਰੋਫਾਈਲ';

  @override
  String get settingsName => 'ਨਾਮ';

  @override
  String get settingsNameNotSet => 'ਸੈੱਟ ਨਹੀਂ';

  @override
  String get settingsEditName => 'ਨਾਮ ਸੰਪਾਦਿਤ ਕਰੋ';

  @override
  String get settingsAppearance => 'ਦਿੱਖ';

  @override
  String get settingsTheme => 'ਥੀਮ';

  @override
  String get settingsThemeDark => 'ਗੂੜ੍ਹਾ';

  @override
  String get settingsThemeLight => 'ਹਲਕਾ';

  @override
  String get settingsThemeSystem => 'ਸਿਸਟਮ';

  @override
  String get settingsLanguage => 'ਭਾਸ਼ਾ';

  @override
  String get settingsLanguageSystem => 'ਸਿਸਟਮ ਡਿਫੌਲਟ';

  @override
  String get settingsTimer => 'ਟਾਈਮਰ';

  @override
  String get settingsDefaultMode => 'Default Mode';

  @override
  String get settingsDefaultDuration => 'Default Duration';

  @override
  String settingsDurationMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsCountdown => 'ਉਲਟੀ ਗਿਣਤੀ';

  @override
  String get settingsCountdownDesc => 'Set a duration, timer counts down';

  @override
  String get settingsStopwatch => 'ਸਟਾਪਵਾਚ';

  @override
  String get settingsStopwatchDesc => 'Open-ended, stop manually';

  @override
  String get settingsBellSounds => 'ਘੰਟੀ ਆਵਾਜ਼ਾਂ';

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
  String get settingsOff => 'ਬੰਦ';

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
  String get settingsData => 'ਡੇਟਾ';

  @override
  String get settingsExport => 'ਡੇਟਾ ਨਿਰਯਾਤ';

  @override
  String get settingsExportDesc => 'Share your sessions & config as JSON';

  @override
  String get settingsImport => 'ਡੇਟਾ ਆਯਾਤ';

  @override
  String get settingsImportDesc => 'Load from a Citta JSON export file';

  @override
  String get settingsImportReplaceMsg =>
      'Replace all existing data, or merge with current data?';

  @override
  String get settingsMerge => 'ਮਿਲਾਓ';

  @override
  String get settingsReplaceAll => 'ਸਭ ਬਦਲੋ';

  @override
  String get settingsImportSuccess => 'ਡੇਟਾ ਸਫਲਤਾਪੂਰਵਕ ਆਯਾਤ ਕੀਤਾ';

  @override
  String get settingsImportError => 'ਅਵੈਧ ਫਾਈਲ';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'ਸੈਸ਼ਨ ਨੋਟਸ';

  @override
  String get notesPrompt => 'ਤੁਹਾਡਾ ਅਭਿਆਸ ਕਿਵੇਂ ਰਿਹਾ?';

  @override
  String get notesHint => 'ਆਪਣੇ ਤਜ਼ਰਬੇ ਬਾਰੇ ਲਿਖੋ...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'ਸੈਸ਼ਨ ਪੂਰਾ';

  @override
  String get sessionTitle => 'ਸੈਸ਼ਨ';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'ਪੂਰਾ';

  @override
  String get sessionNotes => 'ਨੋਟਸ';

  @override
  String get sessionNoNotes => 'ਇਸ ਸੈਸ਼ਨ ਲਈ ਕੋਈ ਨੋਟਸ ਨਹੀਂ';

  @override
  String get addQuoteTitle => 'ਹਵਾਲਾ ਜੋੜੋ';

  @override
  String get addQuoteOriginalText => 'Original Text *';

  @override
  String get addQuoteOriginalHint => 'Enter the quote in original script...';

  @override
  String get addQuoteLanguage => 'ਭਾਸ਼ਾ';

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
  String get langEnglish => 'ਅੰਗਰੇਜ਼ੀ';

  @override
  String get langHindi => 'ਹਿੰਦੀ';

  @override
  String get langKannada => 'ਕੰਨੜ';

  @override
  String get langSanskrit => 'ਸੰਸਕ੍ਰਿਤ';

  @override
  String get langTelugu => 'ਤੇਲਗੂ';

  @override
  String get langTamil => 'ਤਮਿਲ';

  @override
  String get langMalayalam => 'ਮਲਿਆਲਮ';

  @override
  String get langFrench => 'ਫ਼ਰਾਂਸੀਸੀ';

  @override
  String get langGerman => 'ਜਰਮਨ';

  @override
  String get langJapanese => 'ਜਾਪਾਨੀ';

  @override
  String get langHebrew => 'ਹਿਬਰੂ';

  @override
  String get langChinese => 'ਚੀਨੀ';

  @override
  String get langMarathi => 'ਮਰਾਠੀ';

  @override
  String get langGujarati => 'ਗੁਜਰਾਤੀ';

  @override
  String get langOdia => 'ਓਡੀਆ';

  @override
  String get langBengali => 'ਬੰਗਾਲੀ';

  @override
  String get langTulu => 'ਤੁਲੂ';

  @override
  String get langKonkani => 'ਕੋਂਕਣੀ';

  @override
  String get langUrdu => 'ਉਰਦੂ';

  @override
  String get langItalian => 'ਇਤਾਲਵੀ';

  @override
  String get langSpanish => 'ਸਪੇਨੀ';

  @override
  String get langArabic => 'ਅਰਬੀ';

  @override
  String get langRussian => 'ਰੂਸੀ';

  @override
  String get langPortuguese => 'ਪੁਰਤਗਾਲੀ';

  @override
  String get langMaithili => 'ਮੈਥਿਲੀ';

  @override
  String get langAssamese => 'ਅਸਾਮੀ';

  @override
  String get langPunjabi => 'ਪੰਜਾਬੀ';

  @override
  String get langOther => 'ਹੋਰ';

  @override
  String get preSessionSetup => 'ਸੈਸ਼ਨ ਸੈੱਟਅੱਪ';

  @override
  String get timerPaused => 'ਰੁਕਿਆ ਹੋਇਆ';
}
