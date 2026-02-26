// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get actionCancel => 'रद्द करा';

  @override
  String get actionSave => 'जतन करा';

  @override
  String get actionSkip => 'वगळा';

  @override
  String get actionContinue => 'सुरू ठेवा';

  @override
  String get actionDelete => 'हटवा';

  @override
  String get actionAdd => 'जोडा';

  @override
  String get actionBegin => 'सुरू करा';

  @override
  String get navDhyana => 'ध्यान';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navStats => 'आकडेवारी';

  @override
  String get navSettings => 'सेटिंग्ज';

  @override
  String get splashGreeting => 'नमस्कार';

  @override
  String splashGreetingWithName(String name) {
    return 'नमस्कार, $name';
  }

  @override
  String get splashTapToBegin => 'सुरू करण्यासाठी टॅप करा';

  @override
  String get welcomeTitle => 'Citta मध्ये स्वागत आहे';

  @override
  String get welcomeNameHint => 'तुमचे नाव प्रविष्ट करा';

  @override
  String get homeBegin => 'सुरू करा';

  @override
  String get homeCountdown => 'उलटगणती';

  @override
  String get homeStopwatch => 'स्टॉपवॉच';

  @override
  String get homeMin => 'मि';

  @override
  String get historyTitle => 'इतिहास';

  @override
  String historySelected(int count) {
    return '$count निवडले';
  }

  @override
  String get historyDeleteTitle => 'सत्रे हटवा';

  @override
  String historyDeleteConfirm(int count) {
    return '$count सत्रे हटवायची? हे पूर्ववत होणार नाही.';
  }

  @override
  String get historyFilterAll => 'सर्व';

  @override
  String get historyEmpty => 'अद्याप कोणतेही सत्र नाही';

  @override
  String get historyEmptyHint =>
      'पहिले ध्यान सत्र पूर्ण करा\nते येथे पाहण्यासाठी';

  @override
  String get statsTitle => 'आकडेवारी';

  @override
  String get statsToggleCalendar => 'कॅलेंडर दृश्य टॉगल करा';

  @override
  String get statsCurrentStreak => 'सध्याची मालिका';

  @override
  String get statsLongestStreak => 'सर्वात मोठी मालिका';

  @override
  String get statsTotalSessions => 'एकूण सत्रे';

  @override
  String get statsAverage => 'सरासरी';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दिवस',
      one: 'दिवस',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'सेटिंग्ज';

  @override
  String get settingsProfile => 'प्रोफाइल';

  @override
  String get settingsName => 'नाव';

  @override
  String get settingsNameNotSet => 'सेट केलेले नाही';

  @override
  String get settingsEditName => 'नाव संपादित करा';

  @override
  String get settingsAppearance => 'दिसणे';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeDark => 'गडद';

  @override
  String get settingsThemeLight => 'हलकी';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageSystem => 'सिस्टम डीफॉल्ट';

  @override
  String get settingsTimer => 'टाइमर';

  @override
  String get settingsDefaultMode => 'डीफॉल्ट मोड';

  @override
  String get settingsDefaultDuration => 'डीफॉल्ट कालावधी';

  @override
  String settingsDurationMinutes(int count) {
    return '$count मिनिटे';
  }

  @override
  String get settingsCountdown => 'उलटगणती';

  @override
  String get settingsCountdownDesc => 'कालावधी सेट करा, टाइमर उलट मोजतो';

  @override
  String get settingsStopwatch => 'स्टॉपवॉच';

  @override
  String get settingsStopwatchDesc => 'मुक्त, मॅन्युअली थांबवा';

  @override
  String get settingsBellSounds => 'बेल आवाज';

  @override
  String get settingsStartBell => 'सुरुवातीची बेल';

  @override
  String get settingsEndBell => 'शेवटची बेल';

  @override
  String get settingsIntervalBell => 'मध्यांतर बेल';

  @override
  String get settingsBellNone => 'काहीही नाही';

  @override
  String get settingsPickFromDevice => 'डिव्हाइसमधून निवडा...';

  @override
  String get settingsEnableInterval => 'मध्यांतर बेल सक्षम करा';

  @override
  String settingsIntervalEvery(int count) {
    return 'दर $count मि';
  }

  @override
  String get settingsOff => 'बंद';

  @override
  String get settingsIntervalDuration => 'मध्यांतर कालावधी';

  @override
  String get settingsIntervalSound => 'मध्यांतर आवाज';

  @override
  String get settingsBgMusic => 'पार्श्वसंगीत';

  @override
  String get settingsMusicFile => 'संगीत फाइल';

  @override
  String get settingsMusicSelected => 'निवडले';

  @override
  String get settingsMusicNone => 'काहीही नाही';

  @override
  String get settingsRemoveMusic => 'पार्श्वसंगीत काढा';

  @override
  String get settingsTags => 'टॅग्ज';

  @override
  String get settingsAddTag => '+ जोडा';

  @override
  String get settingsAddTagTitle => 'टॅग जोडा';

  @override
  String get settingsAddTagHint => 'उदा., केंद्रित';

  @override
  String get settingsQuotes => 'उद्धरणे';

  @override
  String get settingsAddCustomQuote => 'कस्टम उद्धरण जोडा';

  @override
  String settingsUserQuotes(int count) {
    return '$count वापरकर्ता उद्धरणे';
  }

  @override
  String get settingsData => 'डेटा';

  @override
  String get settingsExport => 'डेटा निर्यात करा';

  @override
  String get settingsExportDesc =>
      'तुमची सत्रे आणि कॉन्फिग JSON म्हणून शेअर करा';

  @override
  String get settingsImport => 'डेटा आयात करा';

  @override
  String get settingsImportDesc => 'Citta JSON निर्यात फाइलमधून लोड करा';

  @override
  String get settingsImportReplaceMsg =>
      'सर्व विद्यमान डेटा पुनर्स्थित करायचा, किंवा वर्तमान डेटासह विलीन करायचा?';

  @override
  String get settingsMerge => 'विलीन करा';

  @override
  String get settingsReplaceAll => 'सर्व पुनर्स्थित करा';

  @override
  String get settingsImportSuccess => 'डेटा यशस्वीपणे आयात केला';

  @override
  String get settingsImportError => 'अवैध आयात फाइल';

  @override
  String settingsExportFailed(String error) {
    return 'निर्यात अयशस्वी: $error';
  }

  @override
  String get notesTitle => 'सत्र नोट्स';

  @override
  String get notesPrompt => 'तुमचा सराव कसा होता?';

  @override
  String get notesHint => 'तुमचा अनुभव लिहा...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 शब्द';
  }

  @override
  String get notesTags => 'टॅग्ज';

  @override
  String get sessionComplete => 'सत्र पूर्ण';

  @override
  String get sessionTitle => 'सत्र';

  @override
  String get sessionCountdown => 'उलटगणती';

  @override
  String get sessionStopwatch => 'स्टॉपवॉच';

  @override
  String get sessionCompleted => 'पूर्ण';

  @override
  String get sessionNotes => 'नोट्स';

  @override
  String get sessionNoNotes => 'या सत्रासाठी नोट्स नाहीत';

  @override
  String get addQuoteTitle => 'उद्धरण जोडा';

  @override
  String get addQuoteOriginalText => 'मूळ मजकूर *';

  @override
  String get addQuoteOriginalHint => 'मूळ लिपीत उद्धरण प्रविष्ट करा...';

  @override
  String get addQuoteLanguage => 'भाषा';

  @override
  String get addQuoteTranslation => 'इंग्रजी भाषांतर *';

  @override
  String get addQuoteTranslationHint => 'इंग्रजी भाषांतर प्रविष्ट करा...';

  @override
  String get addQuoteSource => 'स्रोत';

  @override
  String get addQuoteSourceHint => 'उदा., भगवद्गीता';

  @override
  String get addQuoteReference => 'संदर्भ';

  @override
  String get addQuoteReferenceHint => 'उदा., अध्याय 2, श्लोक 47';

  @override
  String get addQuoteSave => 'उद्धरण जतन करा';

  @override
  String get addQuoteAdded => 'उद्धरण जोडले';

  @override
  String get langEnglish => 'इंग्रजी';

  @override
  String get langHindi => 'हिंदी';

  @override
  String get langKannada => 'कन्नड';

  @override
  String get langSanskrit => 'संस्कृत';

  @override
  String get langTelugu => 'तेलुगू';

  @override
  String get langTamil => 'तमिळ';

  @override
  String get langMalayalam => 'मल्याळम';

  @override
  String get langFrench => 'फ्रेंच';

  @override
  String get langGerman => 'जर्मन';

  @override
  String get langJapanese => 'जपानी';

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
  String get langTulu => 'तुळू';

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
  String get langOther => 'इतर';

  @override
  String get preSessionSetup => 'सत्र सेटअप';

  @override
  String get timerPaused => 'थांबले';
}
