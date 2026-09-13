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
  String get firstTimeSetupSubtitle =>
      'আৰম্ভ কৰাৰ আগতে আহক আমি কিছুমান কথা ছেট কৰোঁ।';

  @override
  String get firstTimeSetupThemeSectionTitle => 'আপোনাৰ থিম বাছনি কৰক';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice =>
      'আপোনাৰ চিন্তনৰ বাবে এনক্ৰিপশ্যন ইতিমধ্যে সক্ষম কৰা আছে।';

  @override
  String get firstTimeSetupContinueButton => 'আৰম্ভ কৰক';

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
  String get settingsColorPalette => 'ৰঙৰ পেলেট';

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
  String get settingsExportChooseTitle => 'ডেটা এক্সপ\'ৰ্ট কৰক';

  @override
  String get settingsExportChooseMsg =>
      'সাধাৰণ JSON হিচাপে এক্সপ\'ৰ্ট কৰিব, নে এনক্ৰিপ্টেড?';

  @override
  String get settingsExportChoosePlain => 'সাধাৰণ JSON';

  @override
  String get settingsExportChooseEncrypted => 'এনক্ৰিপ্টেড';

  @override
  String get settingsImportEncryptedTitle => 'এনক্ৰিপ্টেড এক্সপ\'ৰ্ট';

  @override
  String get settingsImportEncryptedSubtitle =>
      'এই এক্সপ\'ৰ্টটো এনক্ৰিপ্ট কৰিবলৈ ব্যৱহাৰ কৰা পাছৱৰ্ড বা ৰিকভাৰী কী প্ৰবিষ্ট কৰক।';

  @override
  String get settingsImportEncryptedInputLabel => 'পাছৱৰ্ড বা ৰিকভাৰী কী';

  @override
  String get settingsImportEncryptedSubmitButton => 'আনলক কৰক';

  @override
  String get settingsImportEncryptedErrorEmpty =>
      'পাছৱৰ্ড বা ৰিকভাৰী কী প্ৰবিষ্ট কৰক';

  @override
  String get settingsImportEncryptedErrorWrong =>
      'ভুল পাছৱৰ্ড বা ৰিকভাৰী কী। অনুগ্ৰহ কৰি পুনৰ চেষ্টা কৰক।';

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
  String sessionDateAt(String date, String time) {
    return '$date, $time';
  }

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

  @override
  String get encryptionToggleTitle => 'মোৰ চিন্তন এনক্ৰিপ্ট কৰক';

  @override
  String get encryptionToggleSubtitle =>
      'এই ডিভাইচত আপোনাৰ ছেছনসমূহ পাছৱৰ্ডেৰে সুৰক্ষিত কৰক';

  @override
  String get encryptionPasswordLabel => 'পাছৱৰ্ড';

  @override
  String get encryptionConfirmPasswordLabel => 'পাছৱৰ্ড নিশ্চিত কৰক';

  @override
  String get encryptionEnableButton => 'এনক্ৰিপশ্যন সক্ষম কৰক';

  @override
  String get encryptionErrorEmpty => 'এটা পাছৱৰ্ড প্ৰবিষ্ট কৰক';

  @override
  String encryptionErrorTooShort(int minLength) {
    return 'পাছৱৰ্ড কমেও $minLength আখৰৰ হ\'ব লাগিব';
  }

  @override
  String get encryptionErrorMismatch => 'পাছৱৰ্ড মিলা নাই';

  @override
  String get encryptionErrorGeneric =>
      'এনক্ৰিপশ্যন সক্ষম কৰিব পৰা নগ\'ল। অনুগ্ৰহ কৰি পুনৰ চেষ্টা কৰক।';

  @override
  String get recoveryKeyScreenTitle => 'আপোনাৰ ৰিকভাৰী কী সংৰক্ষণ কৰক';

  @override
  String get recoveryKeyWarning =>
      'আপুনি পাছৱৰ্ড পাহৰি গ\'লে আপোনাৰ ডেটা পুনৰুদ্ধাৰ কৰাৰ এইটোৱেই একমাত্ৰ উপায়। দুয়োটা হেৰুৱালে, আপোনাৰ ডেটা স্থায়ীভাৱে অপ্ৰাপ্য হৈ যাব।';

  @override
  String get recoveryKeyCopyButton => 'কপি কৰক';

  @override
  String get recoveryKeyShareButton => 'শ্বেয়াৰ কৰক';

  @override
  String get recoveryKeyAckLabel =>
      'মই মোৰ ৰিকভাৰী কী এটা সুৰক্ষিত ঠাইত সংৰক্ষণ কৰিছোঁ';

  @override
  String get recoveryKeyContinueButton => 'অব্যাহত ৰাখক';

  @override
  String get recoveryKeyErrorGeneric =>
      'ৰিকভাৰী কী সৃষ্টি কৰিব পৰা নগ\'ল। অনুগ্ৰহ কৰি পুনৰ চেষ্টা কৰক।';

  @override
  String get unlockTitle => 'Citta আনলক কৰক';

  @override
  String get unlockSubtitle =>
      'আপোনাৰ চিন্তন চাবলৈ পাছৱৰ্ড বা ৰিকভাৰী কী প্ৰবিষ্ট কৰক।';

  @override
  String get unlockInputLabel => 'পাছৱৰ্ড বা ৰিকভাৰী কী';

  @override
  String get unlockSubmitButton => 'আনলক কৰক';

  @override
  String get unlockErrorEmpty => 'আপোনাৰ পাছৱৰ্ড বা ৰিকভাৰী কী প্ৰবিষ্ট কৰক';

  @override
  String get unlockErrorGeneric =>
      'ভুল পাছৱৰ্ড বা ৰিকভাৰী কী। অনুগ্ৰহ কৰি পুনৰ চেষ্টা কৰক।';

  @override
  String get unlockErrorCorrupted =>
      'আপোনাৰ এনক্ৰিপ্টেড ডেটা পঢ়িব পৰা নগ\'ল। ই খতি হৈ থাকিব পাৰে।';

  @override
  String get settingsEncryptionTitle => 'এনক্ৰিপশ্যন';

  @override
  String get settingsEncryptionSubtitleEnabled =>
      'আপোনাৰ ছেছনসমূহ এই ডিভাইচত এনক্ৰিপ্টেড আছে';

  @override
  String get settingsEncryptionSubtitleDisabled =>
      'পাছৱৰ্ডেৰে আপোনাৰ ছেছনসমূহ সুৰক্ষিত কৰক';

  @override
  String get enableEncryptionScreenTitle => 'এনক্ৰিপশ্যন সক্ষম কৰক';

  @override
  String get settingsEncryptionDisableConfirmTitle =>
      'এনক্ৰিপশ্যন অক্ষম কৰিবনে?';

  @override
  String get settingsEncryptionDisableConfirmMessage =>
      'আপোনাৰ ছেছনসমূহ এই ডিভাইচত পুনৰ প্লেইন টেক্সট হিচাপে সংৰক্ষিত হ\'ব।';

  @override
  String get settingsEncryptionDisableConfirmButton => 'অক্ষম কৰক';

  @override
  String get settingsEncryptionDisableError =>
      'এনক্ৰিপশ্যন অক্ষম কৰিব পৰা নগ\'ল। অনুগ্ৰহ কৰি পুনৰ চেষ্টা কৰক।';

  @override
  String get settingsChangePasswordTitle => 'পাছৱৰ্ড সলনি কৰক';

  @override
  String get settingsChangePasswordSubtitle =>
      'আপোনাৰ ছেছন সুৰক্ষা কৰা পাছৱৰ্ড আপডেট কৰক';

  @override
  String get changePasswordScreenTitle => 'পাছৱৰ্ড সলনি কৰক';

  @override
  String get changePasswordCurrentLabel => 'বৰ্তমান পাছৱৰ্ড';

  @override
  String get changePasswordNewLabel => 'নতুন পাছৱৰ্ড';

  @override
  String get changePasswordConfirmLabel => 'নতুন পাছৱৰ্ড নিশ্চিত কৰক';

  @override
  String get changePasswordSubmitButton => 'পাছৱৰ্ড সলনি কৰক';

  @override
  String get changePasswordErrorEmpty =>
      'আপোনাৰ বৰ্তমান আৰু নতুন পাছৱৰ্ড প্ৰবিষ্ট কৰক';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return 'নতুন পাছৱৰ্ড কমেও $minLength আখৰৰ হ\'ব লাগিব';
  }

  @override
  String get changePasswordErrorMismatch => 'নতুন পাছৱৰ্ড মিলা নাই';

  @override
  String get changePasswordErrorWrongCurrent => 'বৰ্তমান পাছৱৰ্ড ভুল';

  @override
  String get changePasswordErrorGeneric =>
      'পাছৱৰ্ড সলনি কৰিব পৰা নগ\'ল। অনুগ্ৰহ কৰি পুনৰ চেষ্টা কৰক।';

  @override
  String get changePasswordSuccess => 'পাছৱৰ্ড সফলতাৰে সলনি কৰা হ\'ল';
}
