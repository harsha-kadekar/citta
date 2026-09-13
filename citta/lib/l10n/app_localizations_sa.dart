// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sanskrit (`sa`).
class AppLocalizationsSa extends AppLocalizations {
  AppLocalizationsSa([String locale = 'sa']) : super(locale);

  @override
  String get actionCancel => 'रद्द करोतु';

  @override
  String get actionSave => 'रक्षतु';

  @override
  String get actionSkip => 'त्यजतु';

  @override
  String get actionContinue => 'अग्रे गच्छतु';

  @override
  String get actionDelete => 'मोचयतु';

  @override
  String get actionAdd => 'योजयतु';

  @override
  String get actionBegin => 'आरभ्यताम्';

  @override
  String get navDhyana => 'ध्यानम्';

  @override
  String get navHistory => 'इतिहासः';

  @override
  String get navStats => 'गणनाः';

  @override
  String get navSettings => 'व्यवस्था';

  @override
  String get splashGreeting => 'नमस्कारः';

  @override
  String splashGreetingWithName(String name) {
    return 'नमस्कारः, $name';
  }

  @override
  String get splashTapToBegin => 'आरम्भाय स्पृशतु';

  @override
  String get welcomeTitle => 'चित्ते स्वागतम्';

  @override
  String get welcomeNameHint => 'नाम लिखतु';

  @override
  String get firstTimeSetupSubtitle =>
      'आरम्भात् पूर्वं वयं किञ्चन सज्जीकुर्मः।';

  @override
  String get firstTimeSetupThemeSectionTitle => 'स्वविषयं चिनोतु';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice =>
      'भवतः चिन्तनानां कृते गुप्तीकरणं पूर्वमेव सक्षमम् अस्ति।';

  @override
  String get firstTimeSetupContinueButton => 'आरभताम्';

  @override
  String get homeBegin => 'आरभ्यताम्';

  @override
  String get homeCountdown => 'गणना';

  @override
  String get homeStopwatch => 'कालमापकम्';

  @override
  String get homeMin => 'मिनिट्';

  @override
  String get historyTitle => 'इतिहासः';

  @override
  String historySelected(int count) {
    return '$count चिताः';
  }

  @override
  String get historyDeleteTitle => 'सत्राणि निष्कासयतु';

  @override
  String historyDeleteConfirm(int count) {
    return '$count सत्राणि निष्कासयतु? एतत् प्रत्यावर्तयितुं न शक्यते।';
  }

  @override
  String get historyFilterAll => 'सर्वम्';

  @override
  String get historyEmpty => 'अद्यापि सत्राणि नास्ति';

  @override
  String get historyEmptyHint =>
      'प्रथमं ध्यानसत्रं पूर्णं करोतु\nअत्र द्रष्टुम्';

  @override
  String get statsTitle => 'गणनाः';

  @override
  String get statsToggleCalendar => 'दर्शपट्टं परिवर्तयतु';

  @override
  String get statsCurrentStreak => 'वर्तमानः क्रमः';

  @override
  String get statsLongestStreak => 'दीर्घतमः क्रमः';

  @override
  String get statsTotalSessions => 'सर्वसत्राणि';

  @override
  String get statsAverage => 'सरासरी';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दिनानि',
      one: 'दिनम्',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'व्यवस्था';

  @override
  String get settingsProfile => 'परिचयः';

  @override
  String get settingsName => 'नाम';

  @override
  String get settingsNameNotSet => 'न स्थापितम्';

  @override
  String get settingsEditName => 'नाम सम्पादयतु';

  @override
  String get settingsAppearance => 'रूपम्';

  @override
  String get settingsTheme => 'विषयः';

  @override
  String get settingsThemeDark => 'तमसा';

  @override
  String get settingsThemeLight => 'प्रकाशः';

  @override
  String get settingsThemeSystem => 'व्यवस्था';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsColorPalette => 'वर्णपटलम्';

  @override
  String get settingsLanguageSystem => 'व्यवस्था-पूर्वनिर्धारितम्';

  @override
  String get settingsTimer => 'कालमापकम्';

  @override
  String get settingsDefaultMode => 'पूर्वनिर्धारितः विधाः';

  @override
  String get settingsDefaultDuration => 'पूर्वनिर्धारिता अवधिः';

  @override
  String settingsDurationMinutes(int count) {
    return '$count मिनिट्';
  }

  @override
  String get settingsCountdown => 'गणना';

  @override
  String get settingsCountdownDesc => 'अवधिं निर्धारयतु, कालमापकः गणयति';

  @override
  String get settingsStopwatch => 'कालमापकम्';

  @override
  String get settingsStopwatchDesc => 'मुक्तान्तम्, हस्तेन निवारयतु';

  @override
  String get settingsBellSounds => 'घण्टाध्वनिः';

  @override
  String get settingsStartBell => 'आरम्भघण्टा';

  @override
  String get settingsEndBell => 'अन्तघण्टा';

  @override
  String get settingsIntervalBell => 'अन्तरालघण्टा';

  @override
  String get settingsBellNone => 'नास्ति';

  @override
  String get settingsPickFromDevice => 'यन्त्रात् चिनोतु...';

  @override
  String get settingsEnableInterval => 'अन्तरालघण्टा सक्रियं करोतु';

  @override
  String settingsIntervalEvery(int count) {
    return 'प्रति $count मिनिट्';
  }

  @override
  String get settingsOff => 'बन्धम्';

  @override
  String get settingsIntervalDuration => 'अन्तरालावधिः';

  @override
  String get settingsIntervalSound => 'अन्तरालध्वनिः';

  @override
  String get settingsBgMusic => 'पृष्ठभूमिसंगीतम्';

  @override
  String get settingsMusicFile => 'संगीतसञ्चिका';

  @override
  String get settingsMusicSelected => 'चितम्';

  @override
  String get settingsMusicNone => 'नास्ति';

  @override
  String get settingsRemoveMusic => 'पृष्ठभूमिसंगीतं निष्कासयतु';

  @override
  String get settingsTags => 'चिह्नानि';

  @override
  String get settingsAddTag => '+ योजयतु';

  @override
  String get settingsAddTagTitle => 'चिह्नं योजयतु';

  @override
  String get settingsAddTagHint => 'यथा, एकाग्रः';

  @override
  String get settingsQuotes => 'सुभाषितानि';

  @override
  String get settingsAddCustomQuote => 'स्वसुभाषितं योजयतु';

  @override
  String settingsUserQuotes(int count) {
    return '$count उपयोक्तृसुभाषितानि';
  }

  @override
  String get settingsData => 'दत्तांशः';

  @override
  String get settingsExport => 'दत्तांशः निर्यातयतु';

  @override
  String get settingsExportDesc => 'सत्राणि JSON रूपेण प्रेषयतु';

  @override
  String get settingsImport => 'दत्तांशः आयातयतु';

  @override
  String get settingsImportDesc => 'चित्त JSON सञ्चिकायाः लोडयतु';

  @override
  String get settingsImportReplaceMsg =>
      'सर्वं विद्यमानं दत्तांशं प्रतिस्थापयतु, अथवा वर्तमानेन सह संयोजयतु?';

  @override
  String get settingsMerge => 'संयोजनम्';

  @override
  String get settingsReplaceAll => 'सर्वं प्रतिस्थापयतु';

  @override
  String get settingsImportSuccess => 'दत्तांशः सफलतया आयातितः';

  @override
  String get settingsImportError => 'अमान्या आयातसञ्चिका';

  @override
  String settingsExportFailed(String error) {
    return 'निर्यातः विफलः: $error';
  }

  @override
  String get settingsExportChooseTitle => 'दत्तांशः निर्यातयतु';

  @override
  String get settingsExportChooseMsg =>
      'सामान्यं JSON रूपेण निर्यातयतु, अथवा गुप्तीकृतम्?';

  @override
  String get settingsExportChoosePlain => 'सामान्यं JSON';

  @override
  String get settingsExportChooseEncrypted => 'गुप्तीकृतम्';

  @override
  String get settingsImportEncryptedTitle => 'गुप्तीकृतः निर्यातः';

  @override
  String get settingsImportEncryptedSubtitle =>
      'एतस्य निर्यातस्य गुप्तीकरणे उपयुक्तं गुप्तशब्दं पुनःप्राप्तिकुञ्चिकां वा प्रविशतु।';

  @override
  String get settingsImportEncryptedInputLabel =>
      'गुप्तशब्दः अथवा पुनःप्राप्तिकुञ्चिका';

  @override
  String get settingsImportEncryptedSubmitButton => 'अनवरुद्धं करोतु';

  @override
  String get settingsImportEncryptedErrorEmpty =>
      'गुप्तशब्दं पुनःप्राप्तिकुञ्चिकां वा प्रविशतु';

  @override
  String get settingsImportEncryptedErrorWrong =>
      'अशुद्धः गुप्तशब्दः अथवा पुनःप्राप्तिकुञ्चिका। कृपया पुनः प्रयतताम्।';

  @override
  String get notesTitle => 'सत्रटिप्पणीः';

  @override
  String get notesPrompt => 'आपका अभ्यास कैसा था?';

  @override
  String get notesHint => 'अनुभवं लिखतु...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 पदानि';
  }

  @override
  String get notesTags => 'चिह्नानि';

  @override
  String get sessionComplete => 'सत्रं पूर्णम्';

  @override
  String get sessionTitle => 'सत्रम्';

  @override
  String sessionDateAt(String date, String time) {
    return '$date, $time';
  }

  @override
  String get sessionCountdown => 'गणना';

  @override
  String get sessionStopwatch => 'कालमापकम्';

  @override
  String get sessionCompleted => 'पूर्णम्';

  @override
  String get sessionNotes => 'टिप्पणयः';

  @override
  String get sessionNoNotes => 'अस्मिन् सत्रे टिप्पण्यः नास्ति';

  @override
  String get addQuoteTitle => 'सुभाषितं योजयतु';

  @override
  String get addQuoteOriginalText => 'मूलपाठः *';

  @override
  String get addQuoteOriginalHint => 'मूललिप्यां सुभाषितं लिखतु...';

  @override
  String get addQuoteLanguage => 'भाषा';

  @override
  String get addQuoteTranslation => 'आंग्लानुवादः *';

  @override
  String get addQuoteTranslationHint => 'आंग्लानुवादं लिखतु...';

  @override
  String get addQuoteSource => 'स्रोतः';

  @override
  String get addQuoteSourceHint => 'यथा, भगवद्गीता';

  @override
  String get addQuoteReference => 'संदर्भः';

  @override
  String get addQuoteReferenceHint => 'यथा, अध्यायः २, श्लोकः ४७';

  @override
  String get addQuoteSave => 'सुभाषितं रक्षतु';

  @override
  String get addQuoteAdded => 'सुभाषितं योजितम्';

  @override
  String get langEnglish => 'आंग्लम्';

  @override
  String get langHindi => 'हिन्दी';

  @override
  String get langKannada => 'कन्नडम्';

  @override
  String get langSanskrit => 'संस्कृतम्';

  @override
  String get langTelugu => 'तेलुगु';

  @override
  String get langTamil => 'तमिलम्';

  @override
  String get langMalayalam => 'मलयालम्';

  @override
  String get langFrench => 'फ्रेंचम्';

  @override
  String get langGerman => 'जर्मनम्';

  @override
  String get langJapanese => 'जापानीयम्';

  @override
  String get langHebrew => 'हिब्रूम्';

  @override
  String get langChinese => 'चीनीयम्';

  @override
  String get langMarathi => 'मराठी';

  @override
  String get langGujarati => 'गुजराती';

  @override
  String get langOdia => 'ओडिया';

  @override
  String get langBengali => 'बङ्गभाषा';

  @override
  String get langTulu => 'तुळु';

  @override
  String get langKonkani => 'कोंकणी';

  @override
  String get langUrdu => 'उर्दू';

  @override
  String get langItalian => 'इटालियनभाषा';

  @override
  String get langSpanish => 'स्पेनिशभाषा';

  @override
  String get langArabic => 'अरबी';

  @override
  String get langRussian => 'रुसी';

  @override
  String get langPortuguese => 'पोर्तुगीज़भाषा';

  @override
  String get langMaithili => 'मैथिली';

  @override
  String get langAssamese => 'असमीयभाषा';

  @override
  String get langPunjabi => 'पञ्जाबी';

  @override
  String get langOther => 'अन्यत्';

  @override
  String get preSessionSetup => 'सत्रसज्जा';

  @override
  String get timerPaused => 'विरतम्';

  @override
  String get encryptionToggleTitle => 'मम चिन्तनानि गुप्तीकरोतु';

  @override
  String get encryptionToggleSubtitle =>
      'अस्मिन् उपकरणे भवतः सत्राणि गुप्तशब्देन रक्षतु';

  @override
  String get encryptionPasswordLabel => 'गुप्तशब्दः';

  @override
  String get encryptionConfirmPasswordLabel => 'गुप्तशब्दं निश्चिनोतु';

  @override
  String get encryptionEnableButton => 'गुप्तीकरणं सक्षमं करोतु';

  @override
  String get encryptionErrorEmpty => 'गुप्तशब्दं प्रविशतु';

  @override
  String encryptionErrorTooShort(int minLength) {
    return 'गुप्तशब्दे न्यूनातिन्यूनं $minLength अक्षराणि भवेयुः';
  }

  @override
  String get encryptionErrorMismatch => 'गुप्तशब्दौ न मेलतः';

  @override
  String get encryptionErrorGeneric =>
      'गुप्तीकरणं सक्षमं कर्तुं न शक्तम्। कृपया पुनः प्रयतताम्।';

  @override
  String get recoveryKeyScreenTitle => 'स्वपुनःप्राप्तिकुञ्चिकां रक्षतु';

  @override
  String get recoveryKeyWarning =>
      'यदि भवान् गुप्तशब्दं विस्मरति तर्हि इयमेव भवतः दत्तांशस्य पुनःप्राप्तेः एकमात्रा उपायः। यदि उभे अपि नश्यतः, तर्हि भवतः दत्तांशः सर्वदा अप्राप्यः भविष्यति।';

  @override
  String get recoveryKeyCopyButton => 'प्रतिलिपिं करोतु';

  @override
  String get recoveryKeyShareButton => 'साझां करोतु';

  @override
  String get recoveryKeyAckLabel =>
      'मया स्वपुनःप्राप्तिकुञ्चिका सुरक्षितस्थाने रक्षिता';

  @override
  String get recoveryKeyContinueButton => 'अग्रे गच्छतु';

  @override
  String get recoveryKeyErrorGeneric =>
      'पुनःप्राप्तिकुञ्चिकां जनयितुं न शक्तम्। कृपया पुनः प्रयतताम्।';

  @override
  String get unlockTitle => 'Citta अनवरुद्धं करोतु';

  @override
  String get unlockSubtitle =>
      'स्वचिन्तनानि द्रष्टुं गुप्तशब्दं पुनःप्राप्तिकुञ्चिकां वा प्रविशतु।';

  @override
  String get unlockInputLabel => 'गुप्तशब्दः अथवा पुनःप्राप्तिकुञ्चिका';

  @override
  String get unlockSubmitButton => 'अनवरुद्धं करोतु';

  @override
  String get unlockErrorEmpty =>
      'स्वगुप्तशब्दं पुनःप्राप्तिकुञ्चिकां वा प्रविशतु';

  @override
  String get unlockErrorGeneric =>
      'अशुद्धः गुप्तशब्दः अथवा पुनःप्राप्तिकुञ्चिका। कृपया पुनः प्रयतताम्।';

  @override
  String get unlockErrorCorrupted =>
      'भवतः गुप्तीकृतः दत्तांशः पठितुं न शक्तः। सः दूषितः स्यात्।';

  @override
  String get settingsEncryptionTitle => 'गुप्तीकरणम्';

  @override
  String get settingsEncryptionSubtitleEnabled =>
      'भवतः सत्राणि अस्मिन् उपकरणे गुप्तीकृतानि सन्ति';

  @override
  String get settingsEncryptionSubtitleDisabled =>
      'स्वसत्राणि गुप्तशब्देन रक्षतु';

  @override
  String get enableEncryptionScreenTitle => 'गुप्तीकरणं सक्षमं करोतु';

  @override
  String get settingsEncryptionDisableConfirmTitle =>
      'गुप्तीकरणम् असक्षमं करणीयम् वा?';

  @override
  String get settingsEncryptionDisableConfirmMessage =>
      'भवतः सत्राणि अस्मिन् उपकरणे पुनः सरलपाठरूपेण संगृहीतानि भविष्यन्ति।';

  @override
  String get settingsEncryptionDisableConfirmButton => 'असक्षमं करोतु';

  @override
  String get settingsEncryptionDisableError =>
      'गुप्तीकरणम् असक्षमं कर्तुं न शक्तम्। कृपया पुनः प्रयतताम्।';

  @override
  String get settingsChangePasswordTitle => 'गुप्तशब्दं परिवर्तयतु';

  @override
  String get settingsChangePasswordSubtitle =>
      'स्वसत्राणि रक्षन्तं गुप्तशब्दं नवीकरोतु';

  @override
  String get changePasswordScreenTitle => 'गुप्तशब्दं परिवर्तयतु';

  @override
  String get changePasswordCurrentLabel => 'वर्तमानः गुप्तशब्दः';

  @override
  String get changePasswordNewLabel => 'नूतनः गुप्तशब्दः';

  @override
  String get changePasswordConfirmLabel => 'नूतनं गुप्तशब्दं निश्चिनोतु';

  @override
  String get changePasswordSubmitButton => 'गुप्तशब्दं परिवर्तयतु';

  @override
  String get changePasswordErrorEmpty =>
      'स्ववर्तमानं नूतनं च गुप्तशब्दं प्रविशतु';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return 'नूतने गुप्तशब्दे न्यूनातिन्यूनं $minLength अक्षराणि भवेयुः';
  }

  @override
  String get changePasswordErrorMismatch => 'नूतनौ गुप्तशब्दौ न मेलतः';

  @override
  String get changePasswordErrorWrongCurrent =>
      'वर्तमानः गुप्तशब्दः अशुद्धः अस्ति';

  @override
  String get changePasswordErrorGeneric =>
      'गुप्तशब्दं परिवर्तयितुं न शक्तम्। कृपया पुनः प्रयतताम्।';

  @override
  String get changePasswordSuccess => 'गुप्तशब्दः सफलतया परिवर्तितः';
}
