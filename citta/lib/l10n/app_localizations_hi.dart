// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionSkip => 'छोड़ें';

  @override
  String get actionContinue => 'जारी रखें';

  @override
  String get actionDelete => 'हटाएं';

  @override
  String get actionAdd => 'जोड़ें';

  @override
  String get actionBegin => 'शुरू करें';

  @override
  String get navDhyana => 'ध्यान';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navStats => 'आंकड़े';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get splashGreeting => 'नमस्कार';

  @override
  String splashGreetingWithName(String name) {
    return 'नमस्कार, $name';
  }

  @override
  String get splashTapToBegin => 'शुरू करने के लिए टैप करें';

  @override
  String get welcomeTitle => 'चित्त में आपका स्वागत है';

  @override
  String get welcomeNameHint => 'अपना नाम दर्ज करें';

  @override
  String get firstTimeSetupSubtitle =>
      'शुरू करने से पहले आइए कुछ चीज़ें सेट करें।';

  @override
  String get firstTimeSetupThemeSectionTitle => 'अपनी थीम चुनें';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice =>
      'आपके रिफ्लेक्शन के लिए एन्क्रिप्शन पहले से ही सक्षम है।';

  @override
  String get firstTimeSetupContinueButton => 'शुरू करें';

  @override
  String get homeBegin => 'प्रारंभ';

  @override
  String get homeCountdown => 'काउंटडाउन';

  @override
  String get homeStopwatch => 'स्टॉपवॉच';

  @override
  String get homeMin => 'मिनट';

  @override
  String get historyTitle => 'इतिहास';

  @override
  String historySelected(int count) {
    return '$count चयनित';
  }

  @override
  String get historyDeleteTitle => 'सत्र हटाएं';

  @override
  String historyDeleteConfirm(int count) {
    return '$count सत्र हटाएं? यह पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String get historyFilterAll => 'सभी';

  @override
  String get historyEmpty => 'अभी तक कोई सत्र नहीं';

  @override
  String get historyEmptyHint =>
      'अपना पहला ध्यान सत्र पूर्ण करें\nयहाँ देखने के लिए';

  @override
  String get statsTitle => 'आंकड़े';

  @override
  String get statsToggleCalendar => 'कैलेंडर दृश्य टॉगल करें';

  @override
  String get statsCurrentStreak => 'वर्तमान स्ट्रीक';

  @override
  String get statsLongestStreak => 'सबसे लंबी स्ट्रीक';

  @override
  String get statsTotalSessions => 'कुल सत्र';

  @override
  String get statsAverage => 'औसत';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दिन',
      one: 'दिन',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsProfile => 'प्रोफ़ाइल';

  @override
  String get settingsName => 'नाम';

  @override
  String get settingsNameNotSet => 'सेट नहीं है';

  @override
  String get settingsEditName => 'नाम संपादित करें';

  @override
  String get settingsAppearance => 'रूप-रंग';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeDark => 'डार्क';

  @override
  String get settingsThemeLight => 'लाइट';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsColorPalette => 'रंग पैलेट';

  @override
  String get settingsLanguageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get settingsTimer => 'टाइमर';

  @override
  String get settingsDefaultMode => 'डिफ़ॉल्ट मोड';

  @override
  String get settingsDefaultDuration => 'डिफ़ॉल्ट अवधि';

  @override
  String settingsDurationMinutes(int count) {
    return '$count मिनट';
  }

  @override
  String get settingsCountdown => 'काउंटडाउन';

  @override
  String get settingsCountdownDesc => 'अवधि निर्धारित करें, टाइमर गिनता है';

  @override
  String get settingsStopwatch => 'स्टॉपवॉच';

  @override
  String get settingsStopwatchDesc => 'खुला-अंत, मैन्युअल रूप से रोकें';

  @override
  String get settingsBellSounds => 'घंटी ध्वनियाँ';

  @override
  String get settingsStartBell => 'शुरू की घंटी';

  @override
  String get settingsEndBell => 'अंत की घंटी';

  @override
  String get settingsIntervalBell => 'अंतराल घंटी';

  @override
  String get settingsBellNone => 'कोई नहीं';

  @override
  String get settingsPickFromDevice => 'डिवाइस से चुनें...';

  @override
  String get settingsEnableInterval => 'अंतराल घंटी सक्षम करें';

  @override
  String settingsIntervalEvery(int count) {
    return 'हर $count मिनट';
  }

  @override
  String get settingsOff => 'बंद';

  @override
  String get settingsIntervalDuration => 'अंतराल अवधि';

  @override
  String get settingsIntervalSound => 'अंतराल ध्वनि';

  @override
  String get settingsBgMusic => 'पृष्ठभूमि संगीत';

  @override
  String get settingsMusicFile => 'संगीत फ़ाइल';

  @override
  String get settingsMusicSelected => 'चयनित';

  @override
  String get settingsMusicNone => 'कोई नहीं';

  @override
  String get settingsRemoveMusic => 'पृष्ठभूमि संगीत हटाएं';

  @override
  String get settingsTags => 'टैग';

  @override
  String get settingsAddTag => '+ जोड़ें';

  @override
  String get settingsAddTagTitle => 'टैग जोड़ें';

  @override
  String get settingsAddTagHint => 'जैसे, केंद्रित';

  @override
  String get settingsQuotes => 'उद्धरण';

  @override
  String get settingsAddCustomQuote => 'कस्टम उद्धरण जोड़ें';

  @override
  String settingsUserQuotes(int count) {
    return '$count उपयोगकर्ता उद्धरण';
  }

  @override
  String get settingsData => 'डेटा';

  @override
  String get settingsExport => 'डेटा निर्यात';

  @override
  String get settingsExportDesc =>
      'अपने सत्र और कॉन्फ़िग JSON के रूप में साझा करें';

  @override
  String get settingsImport => 'डेटा आयात';

  @override
  String get settingsImportDesc => 'चित्त JSON निर्यात फ़ाइल से लोड करें';

  @override
  String get settingsImportReplaceMsg =>
      'सभी मौजूदा डेटा बदलें, या वर्तमान डेटा के साथ मर्ज करें?';

  @override
  String get settingsMerge => 'मर्ज';

  @override
  String get settingsReplaceAll => 'सब कुछ बदलें';

  @override
  String get settingsImportSuccess => 'डेटा सफलतापूर्वक आयात किया गया';

  @override
  String get settingsImportError => 'अमान्य आयात फ़ाइल';

  @override
  String settingsExportFailed(String error) {
    return 'निर्यात विफल: $error';
  }

  @override
  String get settingsExportChooseTitle => 'डेटा निर्यात करें';

  @override
  String get settingsExportChooseMsg =>
      'सामान्य JSON के रूप में निर्यात करें, या एन्क्रिप्टेड?';

  @override
  String get settingsExportChoosePlain => 'सामान्य JSON';

  @override
  String get settingsExportChooseEncrypted => 'एन्क्रिप्टेड';

  @override
  String get settingsImportEncryptedTitle => 'एन्क्रिप्टेड निर्यात';

  @override
  String get settingsImportEncryptedSubtitle =>
      'इस निर्यात को एन्क्रिप्ट करने के लिए उपयोग किया गया पासवर्ड या रिकवरी की दर्ज करें।';

  @override
  String get settingsImportEncryptedInputLabel => 'पासवर्ड या रिकवरी की';

  @override
  String get settingsImportEncryptedSubmitButton => 'अनलॉक करें';

  @override
  String get settingsImportEncryptedErrorEmpty =>
      'पासवर्ड या रिकवरी की दर्ज करें';

  @override
  String get settingsImportEncryptedErrorWrong =>
      'गलत पासवर्ड या रिकवरी की। कृपया फिर से प्रयास करें।';

  @override
  String get notesTitle => 'सत्र नोट्स';

  @override
  String get notesPrompt => 'आपका अभ्यास कैसा था?';

  @override
  String get notesHint => 'अपने अनुभव के बारे में लिखें...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 शब्द';
  }

  @override
  String get notesTags => 'टैग';

  @override
  String get sessionComplete => 'सत्र पूर्ण';

  @override
  String get sessionTitle => 'सत्र';

  @override
  String sessionDateAt(String date, String time) {
    return '$date को $time';
  }

  @override
  String get sessionCountdown => 'काउंटडाउन';

  @override
  String get sessionStopwatch => 'स्टॉपवॉच';

  @override
  String get sessionCompleted => 'पूर्ण हुआ';

  @override
  String get sessionNotes => 'नोट्स';

  @override
  String get sessionNoNotes => 'इस सत्र के लिए कोई नोट्स नहीं';

  @override
  String get addQuoteTitle => 'उद्धरण जोड़ें';

  @override
  String get addQuoteOriginalText => 'मूल पाठ *';

  @override
  String get addQuoteOriginalHint => 'मूल लिपि में उद्धरण दर्ज करें...';

  @override
  String get addQuoteLanguage => 'भाषा';

  @override
  String get addQuoteTranslation => 'अंग्रेज़ी अनुवाद *';

  @override
  String get addQuoteTranslationHint => 'अंग्रेज़ी अनुवाद दर्ज करें...';

  @override
  String get addQuoteSource => 'स्रोत';

  @override
  String get addQuoteSourceHint => 'जैसे, भगवद्गीता';

  @override
  String get addQuoteReference => 'संदर्भ';

  @override
  String get addQuoteReferenceHint => 'जैसे, अध्याय 2, श्लोक 47';

  @override
  String get addQuoteSave => 'उद्धरण सहेजें';

  @override
  String get addQuoteAdded => 'उद्धरण जोड़ा गया';

  @override
  String get langEnglish => 'अंग्रेज़ी';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langKannada => 'कन्नड़';

  @override
  String get langSanskrit => 'संस्कृत';

  @override
  String get langTelugu => 'तेलुगु';

  @override
  String get langTamil => 'तमिल';

  @override
  String get langMalayalam => 'मलयालम';

  @override
  String get langFrench => 'फ़्रेंच';

  @override
  String get langGerman => 'जर्मन';

  @override
  String get langJapanese => 'जापानी';

  @override
  String get langHebrew => 'हिब्रू';

  @override
  String get langChinese => 'चीनी';

  @override
  String get langMarathi => 'मराठी';

  @override
  String get langGujarati => 'गुजराती';

  @override
  String get langOdia => 'ओडिया';

  @override
  String get langBengali => 'बंगाली';

  @override
  String get langTulu => 'तुलु';

  @override
  String get langKonkani => 'कोंकणी';

  @override
  String get langUrdu => 'उर्दू';

  @override
  String get langItalian => 'इटालवी';

  @override
  String get langSpanish => 'स्पेनिश';

  @override
  String get langArabic => 'अरबी';

  @override
  String get langRussian => 'रूसी';

  @override
  String get langPortuguese => 'पुर्तगाली';

  @override
  String get langMaithili => 'मैथिली';

  @override
  String get langAssamese => 'असमिया';

  @override
  String get langPunjabi => 'पंजाबी';

  @override
  String get langOther => 'अन्य';

  @override
  String get preSessionSetup => 'सत्र सेटअप';

  @override
  String get timerPaused => 'रुका हुआ';

  @override
  String get encryptionToggleTitle => 'मेरे रिफ्लेक्शन एन्क्रिप्ट करें';

  @override
  String get encryptionToggleSubtitle =>
      'इस डिवाइस पर अपने सत्रों को पासवर्ड से सुरक्षित करें';

  @override
  String get encryptionPasswordLabel => 'पासवर्ड';

  @override
  String get encryptionConfirmPasswordLabel => 'पासवर्ड की पुष्टि करें';

  @override
  String get encryptionEnableButton => 'एन्क्रिप्शन सक्षम करें';

  @override
  String get encryptionErrorEmpty => 'एक पासवर्ड दर्ज करें';

  @override
  String encryptionErrorTooShort(int minLength) {
    return 'पासवर्ड कम से कम $minLength अक्षर लंबा होना चाहिए';
  }

  @override
  String get encryptionErrorMismatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get encryptionErrorGeneric =>
      'एन्क्रिप्शन सक्षम नहीं किया जा सका। कृपया फिर से प्रयास करें।';

  @override
  String get recoveryKeyScreenTitle => 'अपनी रिकवरी की सहेजें';

  @override
  String get recoveryKeyWarning =>
      'यदि आप अपना पासवर्ड भूल जाते हैं तो यह आपका डेटा पुनर्प्राप्त करने का एकमात्र तरीका है। यदि आप दोनों खो देते हैं, तो आपका डेटा स्थायी रूप से अप्राप्य हो जाएगा।';

  @override
  String get recoveryKeyCopyButton => 'कॉपी करें';

  @override
  String get recoveryKeyShareButton => 'शेयर करें';

  @override
  String get recoveryKeyAckLabel =>
      'मैंने अपनी रिकवरी की एक सुरक्षित जगह पर सहेज ली है';

  @override
  String get recoveryKeyContinueButton => 'जारी रखें';

  @override
  String get recoveryKeyErrorGeneric =>
      'रिकवरी की जनरेट नहीं की जा सकी। कृपया फिर से प्रयास करें।';

  @override
  String get unlockTitle => 'Citta अनलॉक करें';

  @override
  String get unlockSubtitle =>
      'अपने रिफ्लेक्शन तक पहुँचने के लिए अपना पासवर्ड या रिकवरी की दर्ज करें।';

  @override
  String get unlockInputLabel => 'पासवर्ड या रिकवरी की';

  @override
  String get unlockSubmitButton => 'अनलॉक करें';

  @override
  String get unlockErrorEmpty => 'अपना पासवर्ड या रिकवरी की दर्ज करें';

  @override
  String get unlockErrorGeneric =>
      'गलत पासवर्ड या रिकवरी की। कृपया फिर से प्रयास करें।';

  @override
  String get unlockErrorCorrupted =>
      'आपका एन्क्रिप्टेड डेटा पढ़ा नहीं जा सका। यह क्षतिग्रस्त हो सकता है।';

  @override
  String get settingsEncryptionTitle => 'एन्क्रिप्शन';

  @override
  String get settingsEncryptionSubtitleEnabled =>
      'आपके सत्र इस डिवाइस पर एन्क्रिप्टेड हैं';

  @override
  String get settingsEncryptionSubtitleDisabled =>
      'अपने सत्रों को पासवर्ड से सुरक्षित करें';

  @override
  String get enableEncryptionScreenTitle => 'एन्क्रिप्शन सक्षम करें';

  @override
  String get settingsEncryptionDisableConfirmTitle => 'एन्क्रिप्शन अक्षम करें?';

  @override
  String get settingsEncryptionDisableConfirmMessage =>
      'आपके सत्र इस डिवाइस पर फिर से सामान्य टेक्स्ट के रूप में संग्रहीत किए जाएंगे।';

  @override
  String get settingsEncryptionDisableConfirmButton => 'अक्षम करें';

  @override
  String get settingsEncryptionDisableError =>
      'एन्क्रिप्शन अक्षम नहीं किया जा सका। कृपया फिर से प्रयास करें।';

  @override
  String get settingsChangePasswordTitle => 'पासवर्ड बदलें';

  @override
  String get settingsChangePasswordSubtitle =>
      'अपने सत्रों की सुरक्षा करने वाला पासवर्ड अपडेट करें';

  @override
  String get changePasswordScreenTitle => 'पासवर्ड बदलें';

  @override
  String get changePasswordCurrentLabel => 'वर्तमान पासवर्ड';

  @override
  String get changePasswordNewLabel => 'नया पासवर्ड';

  @override
  String get changePasswordConfirmLabel => 'नए पासवर्ड की पुष्टि करें';

  @override
  String get changePasswordSubmitButton => 'पासवर्ड बदलें';

  @override
  String get changePasswordErrorEmpty =>
      'अपना वर्तमान और नया पासवर्ड दर्ज करें';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return 'नया पासवर्ड कम से कम $minLength अक्षर लंबा होना चाहिए';
  }

  @override
  String get changePasswordErrorMismatch => 'नए पासवर्ड मेल नहीं खाते';

  @override
  String get changePasswordErrorWrongCurrent => 'वर्तमान पासवर्ड गलत है';

  @override
  String get changePasswordErrorGeneric =>
      'पासवर्ड बदला नहीं जा सका। कृपया फिर से प्रयास करें।';

  @override
  String get changePasswordSuccess => 'पासवर्ड सफलतापूर्वक बदल दिया गया';
}
