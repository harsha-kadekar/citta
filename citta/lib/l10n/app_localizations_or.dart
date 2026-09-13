// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get actionCancel => 'ବାତିଲ';

  @override
  String get actionSave => 'ସଞ୍ଚୟ';

  @override
  String get actionSkip => 'ଛାଡ଼ନ୍ତୁ';

  @override
  String get actionContinue => 'ଜାରି ରଖନ୍ତୁ';

  @override
  String get actionDelete => 'ଲିଭାନ୍ତୁ';

  @override
  String get actionAdd => 'ଯୋଡ଼ନ୍ତୁ';

  @override
  String get actionBegin => 'ଆରମ୍ଭ କରନ୍ତୁ';

  @override
  String get navDhyana => 'ଧ୍ୟାନ';

  @override
  String get navHistory => 'ଇତିହାସ';

  @override
  String get navStats => 'ପରିସଂଖ୍ୟାନ';

  @override
  String get navSettings => 'ସେଟିଂ';

  @override
  String get splashGreeting => 'ନମସ୍କାର';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'ଆରମ୍ଭ କରିବାକୁ ଟ୍ୟାପ୍ କରନ୍ତୁ';

  @override
  String get welcomeTitle => 'Citta ରେ ଆପଣଙ୍କୁ ସ୍ୱାଗତ';

  @override
  String get welcomeNameHint => 'ଆପଣଙ୍କ ନାମ ଲିଖନ୍ତୁ';

  @override
  String get firstTimeSetupSubtitle =>
      'ଆରମ୍ଭ କରିବା ପୂର୍ବରୁ ଚାଲନ୍ତୁ କିଛି ଜିନିଷ ସେଟ୍ କରିବା।';

  @override
  String get firstTimeSetupThemeSectionTitle => 'ଆପଣଙ୍କ ଥିମ୍ ବାଛନ୍ତୁ';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice =>
      'ଆପଣଙ୍କ ଚିନ୍ତନ ପାଇଁ ଏନକ୍ରିପସନ୍ ପୂର୍ବରୁ ସକ୍ଷମ କରାଯାଇଛି।';

  @override
  String get firstTimeSetupContinueButton => 'ଆରମ୍ଭ କରନ୍ତୁ';

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
  String get historyDeleteTitle => 'ସ‌ଶନ ଲିଭାନ୍ତୁ';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'ସବୁ';

  @override
  String get historyEmpty => 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ସ‌ଶନ ନାହିଁ';

  @override
  String get historyEmptyHint =>
      'Complete your first dhyana session\nto see it here';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsToggleCalendar => 'Toggle calendar view';

  @override
  String get statsCurrentStreak => 'ବର୍ତ୍ତମାନ ଧାରା';

  @override
  String get statsLongestStreak => 'ଦୀର୍ଘତମ ଧାରା';

  @override
  String get statsTotalSessions => 'ମୋଟ ସ‌ଶନ';

  @override
  String get statsAverage => 'ହାରାହାରି';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ଦିନ',
      one: 'ଦିନ',
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
  String get settingsColorPalette => 'ରଙ୍ଗ ପାଲେଟ୍';

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
  String get settingsExportChooseTitle => 'ଡାଟା ରପ୍ତାନି କରନ୍ତୁ';

  @override
  String get settingsExportChooseMsg =>
      'ସାଧାରଣ JSON ଭାବରେ ରପ୍ତାନି କରିବେ, ନା ଏନକ୍ରିପ୍ଟେଡ୍?';

  @override
  String get settingsExportChoosePlain => 'ସାଧାରଣ JSON';

  @override
  String get settingsExportChooseEncrypted => 'ଏନକ୍ରିପ୍ଟେଡ୍';

  @override
  String get settingsImportEncryptedTitle => 'ଏନକ୍ରିପ୍ଟେଡ୍ ରପ୍ତାନି';

  @override
  String get settingsImportEncryptedSubtitle =>
      'ଏହି ରପ୍ତାନିକୁ ଏନକ୍ରିପ୍ଟ କରିବାକୁ ବ୍ୟବହୃତ ପାସୱାର୍ଡ କିମ୍ବା ରିକଭରୀ କୀ ପ୍ରବେଶ କରନ୍ତୁ।';

  @override
  String get settingsImportEncryptedInputLabel => 'ପାସୱାର୍ଡ କିମ୍ବା ରିକଭରୀ କୀ';

  @override
  String get settingsImportEncryptedSubmitButton => 'ଅନଲକ୍ କରନ୍ତୁ';

  @override
  String get settingsImportEncryptedErrorEmpty =>
      'ପାସୱାର୍ଡ କିମ୍ବା ରିକଭରୀ କୀ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get settingsImportEncryptedErrorWrong =>
      'ଭୁଲ ପାସୱାର୍ଡ କିମ୍ବା ରିକଭରୀ କୀ। ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ।';

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
  String get sessionComplete => 'ସ‌ଶନ ସ‌ମ୍ପୂର୍ଣ';

  @override
  String get sessionTitle => 'ସ‌ଶନ';

  @override
  String sessionDateAt(String date, String time) {
    return '$date, $time';
  }

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'ସ‌ମ୍ପୂର୍ଣ';

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
  String get langEnglish => 'ଇଂରାଜୀ';

  @override
  String get langHindi => 'ହିନ୍ଦୀ';

  @override
  String get langKannada => 'କନ୍ନଡ';

  @override
  String get langSanskrit => 'ସଂସ୍କୃତ';

  @override
  String get langTelugu => 'ତେଲୁଗୁ';

  @override
  String get langTamil => 'ତାମିଲ';

  @override
  String get langMalayalam => 'ମଲୟାଳମ';

  @override
  String get langFrench => 'ଫ୍ରେଞ୍ଚ';

  @override
  String get langGerman => 'ଜର୍ମାନ';

  @override
  String get langJapanese => 'ଜାପାନୀ';

  @override
  String get langHebrew => 'ହିବ୍ରୁ';

  @override
  String get langChinese => 'ଚୀନୀ';

  @override
  String get langMarathi => 'ମରାଠୀ';

  @override
  String get langGujarati => 'ଗୁଜୁରାଟୀ';

  @override
  String get langOdia => 'ଓଡ଼ିଆ';

  @override
  String get langBengali => 'ବଙ୍ଗାଳୀ';

  @override
  String get langTulu => 'ତୁଳୁ';

  @override
  String get langKonkani => 'କୋଙ୍କଣୀ';

  @override
  String get langUrdu => 'ଉର୍ଦ୍ଦୁ';

  @override
  String get langItalian => 'ଇଟାଲୀୟ';

  @override
  String get langSpanish => 'ସ୍ପ୍ୟାନିଶ';

  @override
  String get langArabic => 'ଆରବୀ';

  @override
  String get langRussian => 'ରଷ୍ୟ';

  @override
  String get langPortuguese => 'ପୋର୍ଚୁଗୀଜ';

  @override
  String get langMaithili => 'ମୈଥିଳୀ';

  @override
  String get langAssamese => 'ଅସମୀୟା';

  @override
  String get langPunjabi => 'ପଞ୍ଜାବୀ';

  @override
  String get langOther => 'ଅନ୍ୟ';

  @override
  String get preSessionSetup => 'ସ‌ଶନ ସେଟଅପ';

  @override
  String get timerPaused => 'ବିରତ';

  @override
  String get encryptionToggleTitle => 'ମୋର ଚିନ୍ତନ ଏନକ୍ରିପ୍ଟ କରନ୍ତୁ';

  @override
  String get encryptionToggleSubtitle =>
      'ଏହି ଡିଭାଇସରେ ଆପଣଙ୍କ ସେସନଗୁଡ଼ିକୁ ପାସୱାର୍ଡ ସହିତ ସୁରକ୍ଷିତ କରନ୍ତୁ';

  @override
  String get encryptionPasswordLabel => 'ପାସୱାର୍ଡ';

  @override
  String get encryptionConfirmPasswordLabel => 'ପାସୱାର୍ଡ ନିଶ୍ଚିତ କରନ୍ତୁ';

  @override
  String get encryptionEnableButton => 'ଏନକ୍ରିପସନ୍ ସକ୍ଷମ କରନ୍ତୁ';

  @override
  String get encryptionErrorEmpty => 'ଏକ ପାସୱାର୍ଡ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String encryptionErrorTooShort(int minLength) {
    return 'ପାସୱାର୍ଡ ଅତି କମରେ $minLength ଅକ୍ଷରର ହେବା ଆବଶ୍ୟକ';
  }

  @override
  String get encryptionErrorMismatch => 'ପାସୱାର୍ଡଗୁଡ଼ିକ ମେଳ ଖାଉନାହିଁ';

  @override
  String get encryptionErrorGeneric =>
      'ଏନକ୍ରିପସନ୍ ସକ୍ଷମ କରାଯାଇପାରିଲା ନାହିଁ। ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get recoveryKeyScreenTitle => 'ଆପଣଙ୍କ ରିକଭରୀ କୀ ସେଭ୍ କରନ୍ତୁ';

  @override
  String get recoveryKeyWarning =>
      'ଆପଣ ପାସୱାର୍ଡ ଭୁଲିଗଲେ ଆପଣଙ୍କ ଡାଟା ପୁନରୁଦ୍ଧାର କରିବାର ଏହା ହିଁ ଏକମାତ୍ର ଉପାୟ। ଉଭୟ ହରାଇଲେ, ଆପଣଙ୍କ ଡାଟା ସ୍ଥାୟୀ ଭାବରେ ଅପ୍ରାପ୍ୟ ହୋଇଯିବ।';

  @override
  String get recoveryKeyCopyButton => 'କପି କରନ୍ତୁ';

  @override
  String get recoveryKeyShareButton => 'ସେୟାର୍ କରନ୍ତୁ';

  @override
  String get recoveryKeyAckLabel =>
      'ମୁଁ ମୋର ରିକଭରୀ କୀ ଏକ ସୁରକ୍ଷିତ ସ୍ଥାନରେ ସେଭ୍ କରିଛି';

  @override
  String get recoveryKeyContinueButton => 'ଜାରି ରଖନ୍ତୁ';

  @override
  String get recoveryKeyErrorGeneric =>
      'ରିକଭରୀ କୀ ସୃଷ୍ଟି କରାଯାଇପାରିଲା ନାହିଁ। ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get unlockTitle => 'Citta ଅନଲକ୍ କରନ୍ତୁ';

  @override
  String get unlockSubtitle =>
      'ଆପଣଙ୍କ ଚିନ୍ତନ ଦେଖିବାକୁ ପାସୱାର୍ଡ କିମ୍ବା ରିକଭରୀ କୀ ପ୍ରବେଶ କରନ୍ତୁ।';

  @override
  String get unlockInputLabel => 'ପାସୱାର୍ଡ କିମ୍ବା ରିକଭରୀ କୀ';

  @override
  String get unlockSubmitButton => 'ଅନଲକ୍ କରନ୍ତୁ';

  @override
  String get unlockErrorEmpty =>
      'ଆପଣଙ୍କ ପାସୱାର୍ଡ କିମ୍ବା ରିକଭରୀ କୀ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get unlockErrorGeneric =>
      'ଭୁଲ ପାସୱାର୍ଡ କିମ୍ବା ରିକଭରୀ କୀ। ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get unlockErrorCorrupted =>
      'ଆପଣଙ୍କ ଏନକ୍ରିପ୍ଟେଡ୍ ଡାଟା ପଢ଼ାଯାଇପାରିଲା ନାହିଁ। ଏହା କ୍ଷତିଗ୍ରସ୍ତ ହୋଇଥାଇପାରେ।';

  @override
  String get settingsEncryptionTitle => 'ଏନକ୍ରିପସନ୍';

  @override
  String get settingsEncryptionSubtitleEnabled =>
      'ଆପଣଙ୍କ ସେସନଗୁଡ଼ିକ ଏହି ଡିଭାଇସରେ ଏନକ୍ରିପ୍ଟେଡ୍ ଅଛି';

  @override
  String get settingsEncryptionSubtitleDisabled =>
      'ପାସୱାର୍ଡ ସହିତ ଆପଣଙ୍କ ସେସନଗୁଡ଼ିକୁ ସୁରକ୍ଷିତ କରନ୍ତୁ';

  @override
  String get enableEncryptionScreenTitle => 'ଏନକ୍ରିପସନ୍ ସକ୍ଷମ କରନ୍ତୁ';

  @override
  String get settingsEncryptionDisableConfirmTitle => 'ଏନକ୍ରିପସନ୍ ଅକ୍ଷମ କରିବେ?';

  @override
  String get settingsEncryptionDisableConfirmMessage =>
      'ଆପଣଙ୍କ ସେସନଗୁଡ଼ିକ ଏହି ଡିଭାଇସରେ ପୁନର୍ବାର ସାଧାରଣ ଟେକ୍ସଟ୍ ଭାବରେ ସଂରକ୍ଷିତ ହେବ।';

  @override
  String get settingsEncryptionDisableConfirmButton => 'ଅକ୍ଷମ କରନ୍ତୁ';

  @override
  String get settingsEncryptionDisableError =>
      'ଏନକ୍ରିପସନ୍ ଅକ୍ଷମ କରାଯାଇପାରିଲା ନାହିଁ। ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get settingsChangePasswordTitle => 'ପାସୱାର୍ଡ ପରିବର୍ତ୍ତନ କରନ୍ତୁ';

  @override
  String get settingsChangePasswordSubtitle =>
      'ଆପଣଙ୍କ ସେସନକୁ ସୁରକ୍ଷା ଦେଉଥିବା ପାସୱାର୍ଡ ଅପଡେଟ୍ କରନ୍ତୁ';

  @override
  String get changePasswordScreenTitle => 'ପାସୱାର୍ଡ ପରିବର୍ତ୍ତନ କରନ୍ତୁ';

  @override
  String get changePasswordCurrentLabel => 'ବର୍ତ୍ତମାନ ପାସୱାର୍ଡ';

  @override
  String get changePasswordNewLabel => 'ନୂତନ ପାସୱାର୍ଡ';

  @override
  String get changePasswordConfirmLabel => 'ନୂତନ ପାସୱାର୍ଡ ନିଶ୍ଚିତ କରନ୍ତୁ';

  @override
  String get changePasswordSubmitButton => 'ପାସୱାର୍ଡ ପରିବର୍ତ୍ତନ କରନ୍ତୁ';

  @override
  String get changePasswordErrorEmpty =>
      'ଆପଣଙ୍କ ବର୍ତ୍ତମାନ ଏବଂ ନୂତନ ପାସୱାର୍ଡ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return 'ନୂତନ ପାସୱାର୍ଡ ଅତି କମରେ $minLength ଅକ୍ଷରର ହେବା ଆବଶ୍ୟକ';
  }

  @override
  String get changePasswordErrorMismatch => 'ନୂତନ ପାସୱାର୍ଡଗୁଡ଼ିକ ମେଳ ଖାଉନାହିଁ';

  @override
  String get changePasswordErrorWrongCurrent => 'ବର୍ତ୍ତମାନ ପାସୱାର୍ଡ ଭୁଲ ଅଛି';

  @override
  String get changePasswordErrorGeneric =>
      'ପାସୱାର୍ଡ ପରିବର୍ତ୍ତନ କରାଯାଇପାରିଲା ନାହିଁ। ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get changePasswordSuccess => 'ପାସୱାର୍ଡ ସଫଳତାର ସହିତ ପରିବର୍ତ୍ତିତ ହେଲା';
}
