// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tulu (`tcy`).
class AppLocalizationsTcy extends AppLocalizations {
  AppLocalizationsTcy([String locale = 'tcy']) : super(locale);

  @override
  String get actionCancel => 'ರದ್ದ್ ಮಲ್ಪುಲೆ';

  @override
  String get actionSave => 'ದಾಕಿಲೆ';

  @override
  String get actionSkip => 'ಬುಡ್ಲೆ';

  @override
  String get actionContinue => 'ಮುಂದರಿಯೊಂದು ಪೋಲೆ';

  @override
  String get actionDelete => 'ತೊಲಗಾಯಿಲೆ';

  @override
  String get actionAdd => 'ಸೇರಾಯಿಲೆ';

  @override
  String get actionBegin => 'ಸುರು ಮಲ್ಪುಲೆ';

  @override
  String get navDhyana => 'ಧ್ಯಾನ';

  @override
  String get navHistory => 'ಇತಿಹಾಸ';

  @override
  String get navStats => 'ಅಂಕೆ-ಶಾಂಕೆ';

  @override
  String get navSettings => 'ಸೆಟ್ಟಿಂಗ್ಸ್';

  @override
  String get splashGreeting => 'ನಮಸ್ಕಾರ';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'ಸುರು ಮಲ್ಪೆರೆ ಟ್ಯಾಪ್ ಮಲ್ಪುಲೆ';

  @override
  String get welcomeTitle => 'Citta ರ್ ನಮಸ್ಕಾರ';

  @override
  String get welcomeNameHint => 'ಪೊಸ ಪೇರ್ ಬರೆಯಲೆ';

  @override
  String get firstTimeSetupSubtitle =>
      'ಸುರು ಮಲ್ಪುನ್ಡ್ ಮೊದಲು ನಮ ಕೆಲವು ಸಂಗತಿಲೆನ್ ಸೆಟ್ ಮಲ್ಪುವ.';

  @override
  String get firstTimeSetupThemeSectionTitle => 'ನಿಮ್ಮ ಥೀಮ್ ಆಯ್ಕೆ ಮಲ್ಪುಲೆ';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice =>
      'ನಿಮ್ಮ ಚಿಂತನೆಲೆಗ್ ಎನ್‌ಕ್ರಿಪ್ಶನ್ ಮೊದಲೇ ಸಕ್ರಿಯ ಆದುಂಡು.';

  @override
  String get firstTimeSetupContinueButton => 'ಸುರು ಮಲ್ಪುಲೆ';

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
  String get historyDeleteTitle => 'ಸೆಶನ್ ತೊಲಗಾಯಿಲೆ';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'ಎಲ್ಲಾ';

  @override
  String get historyEmpty => 'ಇನ್ನು ಸೆಶನ್ ಉಂಡಾಂಡ್';

  @override
  String get historyEmptyHint =>
      'Complete your first dhyana session\nto see it here';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'ಇತ್ತೆ ಸರಣಿ';

  @override
  String get statsLongestStreak => 'ದೀರ್ಘ ಸರಣಿ';

  @override
  String get statsTotalSessions => 'ಒಟ್ಟು ಸೆಶನ್';

  @override
  String get statsAverage => 'ಸಾಮಾನ್ಯ';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ದಿನೊಕ್ಲು',
      one: 'ದಿನ',
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
  String get settingsColorPalette => 'ಬಣ್ಣದ ಪ್ಯಾಲೆಟ್';

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
  String get settingsExportChooseTitle => 'ಡೇಟಾ ಎಕ್ಸ್‌ಪೋರ್ಟ್ ಮಲ್ಪುಲೆ';

  @override
  String get settingsExportChooseMsg =>
      'ಸಾಮಾನ್ಯ JSON ಆದ್ ಎಕ್ಸ್‌ಪೋರ್ಟ್ ಮಲ್ಪೊಡಾ, ಅತ್ತ್‌ಂಡ ಎನ್‌ಕ್ರಿಪ್ಟೆಡ್?';

  @override
  String get settingsExportChoosePlain => 'ಸಾಮಾನ್ಯ JSON';

  @override
  String get settingsExportChooseEncrypted => 'ಎನ್‌ಕ್ರಿಪ್ಟೆಡ್';

  @override
  String get settingsImportEncryptedTitle => 'ಎನ್‌ಕ್ರಿಪ್ಟೆಡ್ ಎಕ್ಸ್‌ಪೋರ್ಟ್';

  @override
  String get settingsImportEncryptedSubtitle =>
      'ಈ ಎಕ್ಸ್‌ಪೋರ್ಟ್ ಎನ್‌ಕ್ರಿಪ್ಟ್ ಮಲ್ಪುಗ ಬಳಸಿಯಪ್ಪೆ ಪಾಸ್‌ವರ್ಡ್ ಅತ್ತ್‌ಂಡ ರಿಕವರಿ ಕೀ ಪಾಡ್‌ಲೆ.';

  @override
  String get settingsImportEncryptedInputLabel =>
      'ಪಾಸ್‌ವರ್ಡ್ ಅತ್ತ್‌ಂಡ ರಿಕವರಿ ಕೀ';

  @override
  String get settingsImportEncryptedSubmitButton => 'ಅನ್‌ಲಾಕ್ ಮಲ್ಪುಲೆ';

  @override
  String get settingsImportEncryptedErrorEmpty =>
      'ಪಾಸ್‌ವರ್ಡ್ ಅತ್ತ್‌ಂಡ ರಿಕವರಿ ಕೀ ಪಾಡ್‌ಲೆ';

  @override
  String get settingsImportEncryptedErrorWrong =>
      'ತಪ್ಪು ಪಾಸ್‌ವರ್ಡ್ ಅತ್ತ್‌ಂಡ ರಿಕವರಿ ಕೀ. ದಯಮಲ್ಪಿನ್ದ್ ಮತ್ತೊಂತೆ ಪ್ರಯತ್ನ ಮಲ್ಪುಲೆ.';

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
  String get sessionComplete => 'ಸೆಶನ್ ಮುಗಿಪ್ಪಿ';

  @override
  String get sessionTitle => 'ಸೆಶನ್';

  @override
  String sessionDateAt(String date, String time) {
    return '$date, $time';
  }

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'ಮುಗಿಪ್ಪಿ';

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
  String get langEnglish => 'ಇಂಗ್ಲಿಷ್';

  @override
  String get langHindi => 'ಹಿಂದಿ';

  @override
  String get langKannada => 'ಕನ್ನಡ';

  @override
  String get langSanskrit => 'ಸಂಸ್ಕೃತ';

  @override
  String get langTelugu => 'ತೆಲುಗು';

  @override
  String get langTamil => 'ತಮಿಳ್';

  @override
  String get langMalayalam => 'ಮಲಯಾಳಂ';

  @override
  String get langFrench => 'ಫ್ರೆಂಚ್';

  @override
  String get langGerman => 'ಜರ್ಮನ್';

  @override
  String get langJapanese => 'ಜಪಾನೀಸ್';

  @override
  String get langHebrew => 'ಹಿಬ್ರೂ';

  @override
  String get langChinese => 'ಚೀನೀ';

  @override
  String get langMarathi => 'ಮರಾಠಿ';

  @override
  String get langGujarati => 'ಗುಜರಾತಿ';

  @override
  String get langOdia => 'ಒಡಿಯಾ';

  @override
  String get langBengali => 'ಬಂಗಾಳಿ';

  @override
  String get langTulu => 'ತುಳು';

  @override
  String get langKonkani => 'ಕೊಂಕಣಿ';

  @override
  String get langUrdu => 'ಉರ್ದು';

  @override
  String get langItalian => 'ಇಟಾಲಿಯನ್';

  @override
  String get langSpanish => 'ಸ್ಪ್ಯಾನಿಷ್';

  @override
  String get langArabic => 'ಅರಬ್ಬಿ';

  @override
  String get langRussian => 'ರಷ್ಯನ್';

  @override
  String get langPortuguese => 'ಪೋರ್ಚುಗೀಸ್';

  @override
  String get langMaithili => 'ಮೈಥಿಲಿ';

  @override
  String get langAssamese => 'ಅಸಾಮಿ';

  @override
  String get langPunjabi => 'ಪಂಜಾಬಿ';

  @override
  String get langOther => 'ಬೇತೆ';

  @override
  String get preSessionSetup => 'ಸೆಶನ್ ಸೆಟಪ್';

  @override
  String get timerPaused => 'ನಿಲ್ಲಿನ';

  @override
  String get encryptionToggleTitle => 'ಎನ್ನ ಚಿಂತನೆಲೆನ್ ಎನ್‌ಕ್ರಿಪ್ಟ್ ಮಲ್ಪುಲೆ';

  @override
  String get encryptionToggleSubtitle =>
      'ಈ ಸಾಧನೊಡು ನಿಮ್ಮ ಸೆಷನ್‌ಲೆನ್ ಪಾಸ್‌ವರ್ಡ್‌ಡ್ ರಕ್ಷಣೆ ಮಲ್ಪುಲೆ';

  @override
  String get encryptionPasswordLabel => 'ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get encryptionConfirmPasswordLabel => 'ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಣ ಮಲ್ಪುಲೆ';

  @override
  String get encryptionEnableButton => 'ಎನ್‌ಕ್ರಿಪ್ಶನ್ ಸಕ್ರಿಯ ಮಲ್ಪುಲೆ';

  @override
  String get encryptionErrorEmpty => 'ಒಂಜಿ ಪಾಸ್‌ವರ್ಡ್ ಪಾಡ್‌ಲೆ';

  @override
  String encryptionErrorTooShort(int minLength) {
    return 'ಪಾಸ್‌ವರ್ಡ್‌ಡ್ ಕಡಿಮೆ $minLength ಅಕ್ಷರೊಲು ಉಪ್ಪೊಡು';
  }

  @override
  String get encryptionErrorMismatch => 'ಪಾಸ್‌ವರ್ಡ್‌ಲು ಹೊಂದಾವೊಂದುಜ್ಜಿ';

  @override
  String get encryptionErrorGeneric =>
      'ಎನ್‌ಕ್ರಿಪ್ಶನ್ ಸಕ್ರಿಯ ಮಲ್ಪುಗ ಆಪುಜ್ಜಿ. ದಯಮಲ್ಪಿನ್ದ್ ಮತ್ತೊಂತೆ ಪ್ರಯತ್ನ ಮಲ್ಪುಲೆ.';

  @override
  String get recoveryKeyScreenTitle => 'ನಿಮ್ಮ ರಿಕವರಿ ಕೀ ದಾಕಿಲೆ';

  @override
  String get recoveryKeyWarning =>
      'ನಿಮ ಪಾಸ್‌ವರ್ಡ್ ಮರತ್ಂಡ ನಿಮ್ಮ ಡೇಟಾ ಮರಲ್ ಪಡೆಪುನ ಒಂಜೇ ದಾರಿ ಇತ್ತ್‍ಂಡ್. ಎರಡ್ಲಾ ಕಳೆದ್ಂಡ, ನಿಮ್ಮ ಡೇಟಾ ಸದಾಕಾಲೊಗು ಮರಲ್ ಪಡೆಪುಗಾವಂದೆ ಆಪುಂಡು.';

  @override
  String get recoveryKeyCopyButton => 'ಕಾಪಿ ಮಲ್ಪುಲೆ';

  @override
  String get recoveryKeyShareButton => 'ಶೇರ್ ಮಲ್ಪುಲೆ';

  @override
  String get recoveryKeyAckLabel =>
      'ಯಾನ್ ಎನ್ನ ರಿಕವರಿ ಕೀನ್ ಸುರಕ್ಷಿತ ಜಾಗೆಡ್ ದಾಕಿನಂದೆ';

  @override
  String get recoveryKeyContinueButton => 'ಮುಂದರಿಯೊಂದು ಪೋಲೆ';

  @override
  String get recoveryKeyErrorGeneric =>
      'ರಿಕವರಿ ಕೀ ತಯಾರ್ ಮಲ್ಪುಗ ಆಪುಜ್ಜಿ. ದಯಮಲ್ಪಿನ್ದ್ ಮತ್ತೊಂತೆ ಪ್ರಯತ್ನ ಮಲ್ಪುಲೆ.';

  @override
  String get unlockTitle => 'Citta ಅನ್‌ಲಾಕ್ ಮಲ್ಪುಲೆ';

  @override
  String get unlockSubtitle =>
      'ನಿಮ್ಮ ಚಿಂತನೆಲೆಗ್ ತಲುಪುಗ ಪಾಸ್‌ವರ್ಡ್ ಅತ್ತ್‌ಂಡ ರಿಕವರಿ ಕೀ ಪಾಡ್‌ಲೆ.';

  @override
  String get unlockInputLabel => 'ಪಾಸ್‌ವರ್ಡ್ ಅತ್ತ್‌ಂಡ ರಿಕವರಿ ಕೀ';

  @override
  String get unlockSubmitButton => 'ಅನ್‌ಲಾಕ್ ಮಲ್ಪುಲೆ';

  @override
  String get unlockErrorEmpty => 'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ಅತ್ತ್‌ಂಡ ರಿಕವರಿ ಕೀ ಪಾಡ್‌ಲೆ';

  @override
  String get unlockErrorGeneric =>
      'ತಪ್ಪು ಪಾಸ್‌ವರ್ಡ್ ಅತ್ತ್‌ಂಡ ರಿಕವರಿ ಕೀ. ದಯಮಲ್ಪಿನ್ದ್ ಮತ್ತೊಂತೆ ಪ್ರಯತ್ನ ಮಲ್ಪುಲೆ.';

  @override
  String get unlockErrorCorrupted =>
      'ನಿಮ್ಮ ಎನ್‌ಕ್ರಿಪ್ಟೆಡ್ ಡೇಟಾನ್ ಓದುಗ ಆಪುಜ್ಜಿ. ಅವು ಹಾಳಾದಿಪ್ಪೊಲಿ.';

  @override
  String get settingsEncryptionTitle => 'ಎನ್‌ಕ್ರಿಪ್ಶನ್';

  @override
  String get settingsEncryptionSubtitleEnabled =>
      'ನಿಮ್ಮ ಸೆಷನ್‌ಲು ಈ ಸಾಧನೊಡು ಎನ್‌ಕ್ರಿಪ್ಟ್ ಆದುಂಡು';

  @override
  String get settingsEncryptionSubtitleDisabled =>
      'ಪಾಸ್‌ವರ್ಡ್‌ಡ್ ನಿಮ್ಮ ಸೆಷನ್‌ಲೆನ್ ರಕ್ಷಣೆ ಮಲ್ಪುಲೆ';

  @override
  String get enableEncryptionScreenTitle => 'ಎನ್‌ಕ್ರಿಪ್ಶನ್ ಸಕ್ರಿಯ ಮಲ್ಪುಲೆ';

  @override
  String get settingsEncryptionDisableConfirmTitle =>
      'ಎನ್‌ಕ್ರಿಪ್ಶನ್ ನಿಷ್ಕ್ರಿಯ ಮಲ್ಪೊಡಾ?';

  @override
  String get settingsEncryptionDisableConfirmMessage =>
      'ನಿಮ್ಮ ಸೆಷನ್‌ಲು ಈ ಸಾಧನೊಡು ಮತ್ತೊಂತೆ ಸಾಮಾನ್ಯ ಪಠ್ಯ ಆದ್ ದಾಕಾವೊಂದುಂಡು.';

  @override
  String get settingsEncryptionDisableConfirmButton => 'ನಿಷ್ಕ್ರಿಯ ಮಲ್ಪುಲೆ';

  @override
  String get settingsEncryptionDisableError =>
      'ಎನ್‌ಕ್ರಿಪ್ಶನ್ ನಿಷ್ಕ್ರಿಯ ಮಲ್ಪುಗ ಆಪುಜ್ಜಿ. ದಯಮಲ್ಪಿನ್ದ್ ಮತ್ತೊಂತೆ ಪ್ರಯತ್ನ ಮಲ್ಪುಲೆ.';

  @override
  String get settingsChangePasswordTitle => 'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಪುಲೆ';

  @override
  String get settingsChangePasswordSubtitle =>
      'ನಿಮ್ಮ ಸೆಷನ್‌ಲೆನ್ ರಕ್ಷಣೆ ಮಲ್ಪುನ ಪಾಸ್‌ವರ್ಡ್ ಅಪ್‌ಡೇಟ್ ಮಲ್ಪುಲೆ';

  @override
  String get changePasswordScreenTitle => 'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಪುಲೆ';

  @override
  String get changePasswordCurrentLabel => 'ಈಗಿನ ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get changePasswordNewLabel => 'ಪೊಸ ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get changePasswordConfirmLabel => 'ಪೊಸ ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಣ ಮಲ್ಪುಲೆ';

  @override
  String get changePasswordSubmitButton => 'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಪುಲೆ';

  @override
  String get changePasswordErrorEmpty =>
      'ನಿಮ್ಮ ಈಗಿನ ಬೊಕ್ಕ ಪೊಸ ಪಾಸ್‌ವರ್ಡ್ ಪಾಡ್‌ಲೆ';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return 'ಪೊಸ ಪಾಸ್‌ವರ್ಡ್‌ಡ್ ಕಡಿಮೆ $minLength ಅಕ್ಷರೊಲು ಉಪ್ಪೊಡು';
  }

  @override
  String get changePasswordErrorMismatch => 'ಪೊಸ ಪಾಸ್‌ವರ್ಡ್‌ಲು ಹೊಂದಾವೊಂದುಜ್ಜಿ';

  @override
  String get changePasswordErrorWrongCurrent => 'ಈಗಿನ ಪಾಸ್‌ವರ್ಡ್ ತಪ್ಪುಂಡು';

  @override
  String get changePasswordErrorGeneric =>
      'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಪುಗ ಆಪುಜ್ಜಿ. ದಯಮಲ್ಪಿನ್ದ್ ಮತ್ತೊಂತೆ ಪ್ರಯತ್ನ ಮಲ್ಪುಲೆ.';

  @override
  String get changePasswordSuccess => 'ಪಾಸ್‌ವರ್ಡ್ ಯಶಸ್ವಿಯಾದ್ ಬದಲಾತ್‌ಂಡ್';
}
