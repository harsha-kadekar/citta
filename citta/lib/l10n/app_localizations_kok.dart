// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Konkani (`kok`).
class AppLocalizationsKok extends AppLocalizations {
  AppLocalizationsKok([String locale = 'kok']) : super(locale);

  @override
  String get actionCancel => 'रद्द करात';

  @override
  String get actionSave => 'सांभाळात';

  @override
  String get actionSkip => 'सोडात';

  @override
  String get actionContinue => 'फुडें चलात';

  @override
  String get actionDelete => 'काडात';

  @override
  String get actionAdd => 'घालात';

  @override
  String get actionBegin => 'सुरू करात';

  @override
  String get navDhyana => 'ध्यान';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navStats => 'आंकडे';

  @override
  String get navSettings => 'सेटिंग्ज';

  @override
  String get splashGreeting => 'नमस्कार';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'सुरू करुंक टॅप करात';

  @override
  String get welcomeTitle => 'Citta मदीं तुमकां येवकार';

  @override
  String get welcomeNameHint => 'तुमचें नांव घालात';

  @override
  String get firstTimeSetupSubtitle =>
      'सुरू करचे पयलीं आमी कांय गजाली सेट करूया.';

  @override
  String get firstTimeSetupThemeSectionTitle => 'तुमची थीम निवडात';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice =>
      'तुमच्या चिंतनांखातीर एन्क्रिप्शन आदींच सक्षम आसा.';

  @override
  String get firstTimeSetupContinueButton => 'सुरू करात';

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
  String get historyDeleteTitle => 'सेशन काडात';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'सगळे';

  @override
  String get historyEmpty => 'हजी कसलोच सेशन ना';

  @override
  String get historyEmptyHint =>
      'Complete your first dhyana session\nto see it here';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'हालींची मालिका';

  @override
  String get statsLongestStreak => 'व्हडलीभशी मालिका';

  @override
  String get statsTotalSessions => 'एकूण सेशन';

  @override
  String get statsAverage => 'सरासरी';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दीस',
      one: 'दीस',
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
  String get settingsColorPalette => 'रंग पॅलेट';

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
  String get settingsExportChooseTitle => 'डेटा एक्सपोर्ट करात';

  @override
  String get settingsExportChooseMsg =>
      'सादो JSON म्हूण एक्सपोर्ट करचें, वा एन्क्रिप्टेड?';

  @override
  String get settingsExportChoosePlain => 'सादो JSON';

  @override
  String get settingsExportChooseEncrypted => 'एन्क्रिप्टेड';

  @override
  String get settingsImportEncryptedTitle => 'एन्क्रिप्टेड एक्सपोर्ट';

  @override
  String get settingsImportEncryptedSubtitle =>
      'हो एक्सपोर्ट एन्क्रिप्ट करपाक वापरिल्लो पासवर्ड वा रिकव्हरी की दियात.';

  @override
  String get settingsImportEncryptedInputLabel => 'पासवर्ड वा रिकव्हरी की';

  @override
  String get settingsImportEncryptedSubmitButton => 'अनलॉक करात';

  @override
  String get settingsImportEncryptedErrorEmpty =>
      'पासवर्ड वा रिकव्हरी की दियात';

  @override
  String get settingsImportEncryptedErrorWrong =>
      'चुकीचो पासवर्ड वा रिकव्हरी की. उपरांत परत यत्न करात.';

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
  String sessionDateAt(String date, String time) {
    return '$date, $time';
  }

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
  String get langEnglish => 'इंग्लिश';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langKannada => 'कानडी';

  @override
  String get langSanskrit => 'संस्कृत';

  @override
  String get langTelugu => 'तेलुगू';

  @override
  String get langTamil => 'तमिळ';

  @override
  String get langMalayalam => 'मलयाळम';

  @override
  String get langFrench => 'फ्रेंच';

  @override
  String get langGerman => 'जर्मन';

  @override
  String get langJapanese => 'जापानी';

  @override
  String get langHebrew => 'हिब्रू';

  @override
  String get langChinese => 'चिनी';

  @override
  String get langMarathi => 'मराठी';

  @override
  String get langGujarati => 'गुजराती';

  @override
  String get langOdia => 'ओडिया';

  @override
  String get langBengali => 'बंगाली';

  @override
  String get langTulu => 'तुळु';

  @override
  String get langKonkani => 'कोंकणी';

  @override
  String get langUrdu => 'उर्दू';

  @override
  String get langItalian => 'इटालियन';

  @override
  String get langSpanish => 'स्पॅनिश';

  @override
  String get langArabic => 'अरबी';

  @override
  String get langRussian => 'रशियन';

  @override
  String get langPortuguese => 'पोर्तुगीज';

  @override
  String get langMaithili => 'मैथिली';

  @override
  String get langAssamese => 'आसामी';

  @override
  String get langPunjabi => 'पंजाबी';

  @override
  String get langOther => 'हेर';

  @override
  String get preSessionSetup => 'सेशन सेटअप';

  @override
  String get timerPaused => 'थांबलां';

  @override
  String get encryptionToggleTitle => 'म्हजीं चिंतनां एन्क्रिप्ट करात';

  @override
  String get encryptionToggleSubtitle =>
      'ह्या उपकरणार तुमचीं सत्रां पासवर्डान राखात';

  @override
  String get encryptionPasswordLabel => 'पासवर्ड';

  @override
  String get encryptionConfirmPasswordLabel => 'पासवर्ड निश्चीत करात';

  @override
  String get encryptionEnableButton => 'एन्क्रिप्शन सक्षम करात';

  @override
  String get encryptionErrorEmpty => 'एक पासवर्ड दियात';

  @override
  String encryptionErrorTooShort(int minLength) {
    return 'पासवर्डांत उणेंत उणें $minLength अक्षरां आसपाक जाय';
  }

  @override
  String get encryptionErrorMismatch => 'पासवर्ड जुळनांत';

  @override
  String get encryptionErrorGeneric =>
      'एन्क्रिप्शन सक्षम करूंक जालें ना. उपरांत परत यत्न करात.';

  @override
  String get recoveryKeyScreenTitle => 'तुमची रिकव्हरी की सांबाळात';

  @override
  String get recoveryKeyWarning =>
      'तुमी पासवर्ड विसल्यार तुमचो डेटा परत मेळोवपाची ही एकच तरा. दोनूय व्हडल्यार, तुमचो डेटा कायमचो परत मेळचो ना.';

  @override
  String get recoveryKeyCopyButton => 'कॉपी करात';

  @override
  String get recoveryKeyShareButton => 'शेअर करात';

  @override
  String get recoveryKeyAckLabel =>
      'हांवें म्हजी रिकव्हरी की सुरक्षीत सुवातेर सांबाळ्ळ्या';

  @override
  String get recoveryKeyContinueButton => 'फुडें चलात';

  @override
  String get recoveryKeyErrorGeneric =>
      'रिकव्हरी की तयार करूंक जाली ना. उपरांत परत यत्न करात.';

  @override
  String get unlockTitle => 'Citta अनलॉक करात';

  @override
  String get unlockSubtitle =>
      'तुमच्या चिंतनांक पावपाक तुमचो पासवर्ड वा रिकव्हरी की दियात.';

  @override
  String get unlockInputLabel => 'पासवर्ड वा रिकव्हरी की';

  @override
  String get unlockSubmitButton => 'अनलॉक करात';

  @override
  String get unlockErrorEmpty => 'तुमचो पासवर्ड वा रिकव्हरी की दियात';

  @override
  String get unlockErrorGeneric =>
      'चुकीचो पासवर्ड वा रिकव्हरी की. उपरांत परत यत्न करात.';

  @override
  String get unlockErrorCorrupted =>
      'तुमचो एन्क्रिप्टेड डेटा वाचूंक जालो ना. तो बिगडला जावं येता.';

  @override
  String get settingsEncryptionTitle => 'एन्क्रिप्शन';

  @override
  String get settingsEncryptionSubtitleEnabled =>
      'तुमचीं सत्रां ह्या उपकरणार एन्क्रिप्टेड आसात';

  @override
  String get settingsEncryptionSubtitleDisabled =>
      'तुमचीं सत्रां पासवर्डान राखात';

  @override
  String get enableEncryptionScreenTitle => 'एन्क्रिप्शन सक्षम करात';

  @override
  String get settingsEncryptionDisableConfirmTitle => 'एन्क्रिप्शन बंद करचें?';

  @override
  String get settingsEncryptionDisableConfirmMessage =>
      'तुमचीं सत्रां ह्या उपकरणार परत सादो मजकूर म्हूण साठयतलीं.';

  @override
  String get settingsEncryptionDisableConfirmButton => 'बंद करात';

  @override
  String get settingsEncryptionDisableError =>
      'एन्क्रिप्शन बंद करूंक जालें ना. उपरांत परत यत्न करात.';

  @override
  String get settingsChangePasswordTitle => 'पासवर्ड बदलात';

  @override
  String get settingsChangePasswordSubtitle =>
      'तुमचीं सत्रां राखपी पासवर्ड अपडेट करात';

  @override
  String get changePasswordScreenTitle => 'पासवर्ड बदलात';

  @override
  String get changePasswordCurrentLabel => 'सद्याचो पासवर्ड';

  @override
  String get changePasswordNewLabel => 'नवो पासवर्ड';

  @override
  String get changePasswordConfirmLabel => 'नवो पासवर्ड निश्चीत करात';

  @override
  String get changePasswordSubmitButton => 'पासवर्ड बदलात';

  @override
  String get changePasswordErrorEmpty => 'तुमचो सद्याचो आनी नवो पासवर्ड दियात';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return 'नव्या पासवर्डांत उणेंत उणें $minLength अक्षरां आसपाक जाय';
  }

  @override
  String get changePasswordErrorMismatch => 'नवे पासवर्ड जुळनांत';

  @override
  String get changePasswordErrorWrongCurrent => 'सद्याचो पासवर्ड चुकीचो आसा';

  @override
  String get changePasswordErrorGeneric =>
      'पासवर्ड बदलूंक जालो ना. उपरांत परत यत्न करात.';

  @override
  String get changePasswordSuccess => 'पासवर्ड यशस्वीपणान बदल्लो';
}
