// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get actionCancel => 'రద్దు చేయి';

  @override
  String get actionSave => 'సేవ్ చేయి';

  @override
  String get actionSkip => 'దాటవేయి';

  @override
  String get actionContinue => 'కొనసాగించు';

  @override
  String get actionDelete => 'తొలగించు';

  @override
  String get actionAdd => 'జోడించు';

  @override
  String get actionBegin => 'ప్రారంభించు';

  @override
  String get navDhyana => 'ధ్యానం';

  @override
  String get navHistory => 'చరిత్ర';

  @override
  String get navStats => 'గణాంకాలు';

  @override
  String get navSettings => 'సెట్టింగులు';

  @override
  String get splashGreeting => 'నమస్కారం';

  @override
  String splashGreetingWithName(String name) {
    return 'నమస్కారం, $name';
  }

  @override
  String get splashTapToBegin => 'ప్రారంభించడానికి నొక్కండి';

  @override
  String get welcomeTitle => 'చిత్తకు స్వాగతం';

  @override
  String get welcomeNameHint => 'మీ పేరు నమోదు చేయండి';

  @override
  String get homeBegin => 'ప్రారంభం';

  @override
  String get homeCountdown => 'కౌంట్‌డౌన్';

  @override
  String get homeStopwatch => 'స్టాప్‌వాచ్';

  @override
  String get homeMin => 'నిమి';

  @override
  String get historyTitle => 'చరిత్ర';

  @override
  String historySelected(int count) {
    return '$count ఎంచుకున్నారు';
  }

  @override
  String get historyDeleteTitle => 'సెషన్లు తొలగించు';

  @override
  String historyDeleteConfirm(int count) {
    return '$count సెషన్లు తొలగించాలా? ఇది రద్దు చేయలేరు.';
  }

  @override
  String get historyFilterAll => 'అన్నీ';

  @override
  String get historyEmpty => 'ఇంకా సెషన్లు లేవు';

  @override
  String get historyEmptyHint =>
      'మీ మొదటి ధ్యాన సెషన్ పూర్తి చేయండి\nఇక్కడ చూడండి';

  @override
  String get statsTitle => 'గణాంకాలు';

  @override
  String get statsToggleCalendar => 'క్యాలెండర్ వ్యూ మార్చండి';

  @override
  String get statsCurrentStreak => 'ప్రస్తుత స్ట్రీక్';

  @override
  String get statsLongestStreak => 'పొడవైన స్ట్రీక్';

  @override
  String get statsTotalSessions => 'మొత్తం సెషన్లు';

  @override
  String get statsAverage => 'సగటు';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'రోజులు',
      one: 'రోజు',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'సెట్టింగులు';

  @override
  String get settingsProfile => 'ప్రొఫైల్';

  @override
  String get settingsName => 'పేరు';

  @override
  String get settingsNameNotSet => 'సెట్ చేయబడలేదు';

  @override
  String get settingsEditName => 'పేరు సవరించు';

  @override
  String get settingsAppearance => 'రూపం';

  @override
  String get settingsTheme => 'థీమ్';

  @override
  String get settingsThemeDark => 'డార్క్';

  @override
  String get settingsThemeLight => 'లైట్';

  @override
  String get settingsThemeSystem => 'సిస్టమ్';

  @override
  String get settingsLanguage => 'భాష';

  @override
  String get settingsLanguageSystem => 'సిస్టమ్ డిఫాల్ట్';

  @override
  String get settingsTimer => 'టైమర్';

  @override
  String get settingsDefaultMode => 'డిఫాల్ట్ మోడ్';

  @override
  String get settingsDefaultDuration => 'డిఫాల్ట్ వ్యవధి';

  @override
  String settingsDurationMinutes(int count) {
    return '$count నిమిషాలు';
  }

  @override
  String get settingsCountdown => 'కౌంట్‌డౌన్';

  @override
  String get settingsCountdownDesc => 'వ్యవధి నిర్ణయించు, టైమర్ తగ్గుతుంది';

  @override
  String get settingsStopwatch => 'స్టాప్‌వాచ్';

  @override
  String get settingsStopwatchDesc => 'ముక్త-అంత్యం, మానవీయంగా ఆపండి';

  @override
  String get settingsBellSounds => 'గంట శబ్దాలు';

  @override
  String get settingsStartBell => 'ప్రారంభ గంట';

  @override
  String get settingsEndBell => 'ముగింపు గంట';

  @override
  String get settingsIntervalBell => 'అంతర గంట';

  @override
  String get settingsBellNone => 'లేదు';

  @override
  String get settingsPickFromDevice => 'పరికరం నుండి ఎంచుకోండి...';

  @override
  String get settingsEnableInterval => 'అంతర గంట ప్రారంభించు';

  @override
  String settingsIntervalEvery(int count) {
    return 'ప్రతి $count నిమి';
  }

  @override
  String get settingsOff => 'ఆఫ్';

  @override
  String get settingsIntervalDuration => 'అంతర వ్యవధి';

  @override
  String get settingsIntervalSound => 'అంతర శబ్దం';

  @override
  String get settingsBgMusic => 'నేపథ్య సంగీతం';

  @override
  String get settingsMusicFile => 'సంగీత ఫైల్';

  @override
  String get settingsMusicSelected => 'ఎంచుకున్నారు';

  @override
  String get settingsMusicNone => 'లేదు';

  @override
  String get settingsRemoveMusic => 'నేపథ్య సంగీతం తొలగించు';

  @override
  String get settingsTags => 'ట్యాగులు';

  @override
  String get settingsAddTag => '+ జోడించు';

  @override
  String get settingsAddTagTitle => 'ట్యాగ్ జోడించు';

  @override
  String get settingsAddTagHint => 'ఉదా., దృష్టి';

  @override
  String get settingsQuotes => 'కోట్లు';

  @override
  String get settingsAddCustomQuote => 'కస్టమ్ కోట్ జోడించు';

  @override
  String settingsUserQuotes(int count) {
    return '$count వినియోగదారు కోట్లు';
  }

  @override
  String get settingsData => 'డేటా';

  @override
  String get settingsExport => 'డేటా ఎగుమతి';

  @override
  String get settingsExportDesc => 'మీ సెషన్లు JSON గా పంచుకోండి';

  @override
  String get settingsImport => 'డేటా దిగుమతి';

  @override
  String get settingsImportDesc => 'చిత్త JSON ఫైల్ నుండి లోడ్ చేయండి';

  @override
  String get settingsImportReplaceMsg =>
      'అన్ని ఉన్న డేటా భర్తీ చేయాలా, లేదా ప్రస్తుత డేటాతో విలీనం చేయాలా?';

  @override
  String get settingsMerge => 'విలీనం';

  @override
  String get settingsReplaceAll => 'అన్నీ భర్తీ చేయి';

  @override
  String get settingsImportSuccess => 'డేటా విజయవంతంగా దిగుమతి అయింది';

  @override
  String get settingsImportError => 'చెల్లని దిగుమతి ఫైల్';

  @override
  String settingsExportFailed(String error) {
    return 'ఎగుమతి విఫలమైంది: $error';
  }

  @override
  String get notesTitle => 'సెషన్ నోట్స్';

  @override
  String get notesPrompt => 'మీ సాధన ఎలా ఉంది?';

  @override
  String get notesHint => 'మీ అనుభవం గురించి రాయండి...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 పదాలు';
  }

  @override
  String get notesTags => 'ట్యాగులు';

  @override
  String get sessionComplete => 'సెషన్ పూర్తి';

  @override
  String get sessionTitle => 'సెషన్';

  @override
  String get sessionCountdown => 'కౌంట్‌డౌన్';

  @override
  String get sessionStopwatch => 'స్టాప్‌వాచ్';

  @override
  String get sessionCompleted => 'పూర్తయింది';

  @override
  String get sessionNotes => 'నోట్స్';

  @override
  String get sessionNoNotes => 'ఈ సెషన్‌కు నోట్స్ లేవు';

  @override
  String get addQuoteTitle => 'కోట్ జోడించు';

  @override
  String get addQuoteOriginalText => 'మూల పాఠం *';

  @override
  String get addQuoteOriginalHint => 'మూల లిపిలో కోట్ నమోదు చేయండి...';

  @override
  String get addQuoteLanguage => 'భాష';

  @override
  String get addQuoteTranslation => 'ఇంగ్లీష్ అనువాదం *';

  @override
  String get addQuoteTranslationHint => 'ఇంగ్లీష్ అనువాదం నమోదు చేయండి...';

  @override
  String get addQuoteSource => 'మూలం';

  @override
  String get addQuoteSourceHint => 'ఉదా., భగవద్గీత';

  @override
  String get addQuoteReference => 'సూచన';

  @override
  String get addQuoteReferenceHint => 'ఉదా., అధ్యాయం 2, శ్లోకం 47';

  @override
  String get addQuoteSave => 'కోట్ సేవ్ చేయి';

  @override
  String get addQuoteAdded => 'కోట్ జోడించబడింది';

  @override
  String get langEnglish => 'ఇంగ్లీష్';

  @override
  String get langHindi => 'హిందీ';

  @override
  String get langKannada => 'కన్నడ';

  @override
  String get langSanskrit => 'సంస్కృతం';

  @override
  String get langTelugu => 'తెలుగు';

  @override
  String get langTamil => 'తమిళం';

  @override
  String get langMalayalam => 'మలయాళం';

  @override
  String get langFrench => 'ఫ్రెంచ్';

  @override
  String get langGerman => 'జర్మన్';

  @override
  String get langJapanese => 'జపనీస్';

  @override
  String get langHebrew => 'హీబ్రూ';

  @override
  String get langChinese => 'చైనీస్';

  @override
  String get langMarathi => 'మరాఠీ';

  @override
  String get langGujarati => 'గుజరాతీ';

  @override
  String get langOdia => 'ఒడియా';

  @override
  String get langBengali => 'బెంగాలీ';

  @override
  String get langTulu => 'తుళు';

  @override
  String get langKonkani => 'కొంకణి';

  @override
  String get langUrdu => 'ఉర్దూ';

  @override
  String get langItalian => 'ఇటాలియన్';

  @override
  String get langSpanish => 'స్పానిష్';

  @override
  String get langArabic => 'అరబిక్';

  @override
  String get langRussian => 'రష్యన్';

  @override
  String get langPortuguese => 'పోర్చుగీస్';

  @override
  String get langMaithili => 'మైథిలి';

  @override
  String get langAssamese => 'అస్సామీ';

  @override
  String get langPunjabi => 'పంజాబీ';

  @override
  String get langOther => 'ఇతర';

  @override
  String get preSessionSetup => 'సెషన్ సెటప్';

  @override
  String get timerPaused => 'ఆపబడింది';
}
