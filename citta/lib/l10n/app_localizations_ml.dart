// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get actionCancel => 'റദ്ദാക്കുക';

  @override
  String get actionSave => 'സംരക്ഷിക്കുക';

  @override
  String get actionSkip => 'ഒഴിവാക്കുക';

  @override
  String get actionContinue => 'തുടരുക';

  @override
  String get actionDelete => 'ഇല്ലാതാക്കുക';

  @override
  String get actionAdd => 'ചേർക്കുക';

  @override
  String get actionBegin => 'ആരംഭിക്കുക';

  @override
  String get navDhyana => 'ധ്യാനം';

  @override
  String get navHistory => 'ചരിത്രം';

  @override
  String get navStats => 'സ്ഥിതിവിവരം';

  @override
  String get navSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get splashGreeting => 'നമസ്കാരം';

  @override
  String splashGreetingWithName(String name) {
    return 'നമസ്കാരം, $name';
  }

  @override
  String get splashTapToBegin => 'ആരംഭിക്കാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String get welcomeTitle => 'ചിത്തത്തിലേക്ക് സ്വാഗതം';

  @override
  String get welcomeNameHint => 'നിങ്ങളുടെ പേര് നൽകുക';

  @override
  String get homeBegin => 'ആരംഭം';

  @override
  String get homeCountdown => 'കൗണ്ട്ഡൗൺ';

  @override
  String get homeStopwatch => 'സ്റ്റോപ്‌വാച്ച്';

  @override
  String get homeMin => 'മി';

  @override
  String get historyTitle => 'ചരിത്രം';

  @override
  String historySelected(int count) {
    return '$count തിരഞ്ഞെടുത്തു';
  }

  @override
  String get historyDeleteTitle => 'സെഷനുകൾ ഇല്ലാതാക്കുക';

  @override
  String historyDeleteConfirm(int count) {
    return '$count സെഷനുകൾ ഇല്ലാതാക്കണോ? ഇത് പഴയപടിയാക്കാൻ കഴിയില്ല.';
  }

  @override
  String get historyFilterAll => 'എല്ലാം';

  @override
  String get historyEmpty => 'ഇതുവരെ സെഷനുകൾ ഇല്ല';

  @override
  String get historyEmptyHint =>
      'നിങ്ങളുടെ ആദ്യ ധ്യാന സെഷൻ പൂർത്തിയാക്കുക\nഇവിടെ കാണാൻ';

  @override
  String get statsTitle => 'സ്ഥിതിവിവരം';

  @override
  String get statsToggleCalendar => 'കലണ്ടർ കാഴ്ച മാറ്റുക';

  @override
  String get statsCurrentStreak => 'നിലവിലെ സ്ട്രീക്ക്';

  @override
  String get statsLongestStreak => 'ഏറ്റവും ദൈർഘ്യമേറിയ സ്ട്രീക്ക്';

  @override
  String get statsTotalSessions => 'ആകെ സെഷനുകൾ';

  @override
  String get statsAverage => 'ശരാശരി';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ദിവസങ്ങൾ',
      one: 'ദിവസം',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'ക്രമീകരണങ്ങൾ';

  @override
  String get settingsProfile => 'പ്രൊഫൈൽ';

  @override
  String get settingsName => 'പേര്';

  @override
  String get settingsNameNotSet => 'സജ്ജീകരിച്ചിട്ടില്ല';

  @override
  String get settingsEditName => 'പേര് തിരുത്തുക';

  @override
  String get settingsAppearance => 'രൂപം';

  @override
  String get settingsTheme => 'തീം';

  @override
  String get settingsThemeDark => 'ഇരുണ്ട';

  @override
  String get settingsThemeLight => 'പ്രകാശം';

  @override
  String get settingsThemeSystem => 'സിസ്റ്റം';

  @override
  String get settingsLanguage => 'ഭാഷ';

  @override
  String get settingsLanguageSystem => 'സിസ്റ്റം ഡിഫോൾട്ട്';

  @override
  String get settingsTimer => 'ടൈമർ';

  @override
  String get settingsDefaultMode => 'ഡിഫോൾട്ട് മോഡ്';

  @override
  String get settingsDefaultDuration => 'ഡിഫോൾട്ട് ദൈർഘ്യം';

  @override
  String settingsDurationMinutes(int count) {
    return '$count മിനിറ്റ്';
  }

  @override
  String get settingsCountdown => 'കൗണ്ട്ഡൗൺ';

  @override
  String get settingsCountdownDesc => 'ദൈർഘ്യം സജ്ജീകരിക്കുക, ടൈമർ കുറഞ്ഞുവരും';

  @override
  String get settingsStopwatch => 'സ്റ്റോപ്‌വാച്ച്';

  @override
  String get settingsStopwatchDesc => 'തുറന്ന-അവസാനം, ഒരു കൈകൊണ്ട് നിർത്തുക';

  @override
  String get settingsBellSounds => 'മണി ശബ്ദങ്ങൾ';

  @override
  String get settingsStartBell => 'ആരംഭ മണി';

  @override
  String get settingsEndBell => 'അവസാന മണി';

  @override
  String get settingsIntervalBell => 'ഇടവേള മണി';

  @override
  String get settingsBellNone => 'ഒന്നുമില്ല';

  @override
  String get settingsPickFromDevice => 'ഉപകരണത്തിൽ നിന്ന് തിരഞ്ഞെടുക്കുക...';

  @override
  String get settingsEnableInterval => 'ഇടവേള മണി പ്രവർത്തനക്ഷമമാക്കുക';

  @override
  String settingsIntervalEvery(int count) {
    return 'ഓരോ $count മി';
  }

  @override
  String get settingsOff => 'ഓഫ്';

  @override
  String get settingsIntervalDuration => 'ഇടവേള ദൈർഘ്യം';

  @override
  String get settingsIntervalSound => 'ഇടവേള ശബ്ദം';

  @override
  String get settingsBgMusic => 'പശ്ചാത്തല സംഗീതം';

  @override
  String get settingsMusicFile => 'സംഗീത ഫയൽ';

  @override
  String get settingsMusicSelected => 'തിരഞ്ഞെടുത്തു';

  @override
  String get settingsMusicNone => 'ഒന്നുമില്ല';

  @override
  String get settingsRemoveMusic => 'പശ്ചാത്തല സംഗീതം നീക്കം ചെയ്യുക';

  @override
  String get settingsTags => 'ടാഗുകൾ';

  @override
  String get settingsAddTag => '+ ചേർക്കുക';

  @override
  String get settingsAddTagTitle => 'ടാഗ് ചേർക്കുക';

  @override
  String get settingsAddTagHint => 'ഉദാ., ശ്രദ്ധ';

  @override
  String get settingsQuotes => 'ഉദ്ധരണികൾ';

  @override
  String get settingsAddCustomQuote => 'ഇഷ്ടാനുസൃത ഉദ്ധരണി ചേർക്കുക';

  @override
  String settingsUserQuotes(int count) {
    return '$count ഉപയോക്തൃ ഉദ്ധരണികൾ';
  }

  @override
  String get settingsData => 'ഡേറ്റ';

  @override
  String get settingsExport => 'ഡേറ്റ കയറ്റുമതി';

  @override
  String get settingsExportDesc => 'നിങ്ങളുടെ സെഷനുകൾ JSON ആയി പങ്കിടുക';

  @override
  String get settingsImport => 'ഡേറ്റ ഇറക്കുമതി';

  @override
  String get settingsImportDesc => 'ചിത്ത JSON ഫയലിൽ നിന്ന് ലോഡ് ചെയ്യുക';

  @override
  String get settingsImportReplaceMsg =>
      'എല്ലാ നിലവിലുള്ള ഡേറ്റയും മാറ്റുക, അല്ലെങ്കിൽ നിലവിലെ ഡേറ്റയുമായി ലയിപ്പിക്കുക?';

  @override
  String get settingsMerge => 'ലയിപ്പിക്കുക';

  @override
  String get settingsReplaceAll => 'എല്ലാം മാറ്റുക';

  @override
  String get settingsImportSuccess => 'ഡേറ്റ വിജയകരമായി ഇറക്കുമതി ചെയ്തു';

  @override
  String get settingsImportError => 'അസാധുവായ ഇറക്കുമതി ഫയൽ';

  @override
  String settingsExportFailed(String error) {
    return 'കയറ്റുമതി പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get notesTitle => 'സെഷൻ കുറിപ്പുകൾ';

  @override
  String get notesPrompt => 'നിങ്ങളുടെ അഭ്യാസം എങ്ങനെയായിരുന്നു?';

  @override
  String get notesHint => 'നിങ്ങളുടെ അനുഭവത്തെ കുറിച്ച് എഴുതുക...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 വാക്കുകൾ';
  }

  @override
  String get notesTags => 'ടാഗുകൾ';

  @override
  String get sessionComplete => 'സെഷൻ പൂർത്തിയായി';

  @override
  String get sessionTitle => 'സെഷൻ';

  @override
  String get sessionCountdown => 'കൗണ്ട്ഡൗൺ';

  @override
  String get sessionStopwatch => 'സ്റ്റോപ്‌വാച്ച്';

  @override
  String get sessionCompleted => 'പൂർത്തിയായി';

  @override
  String get sessionNotes => 'കുറിപ്പുകൾ';

  @override
  String get sessionNoNotes => 'ഈ സെഷനിൽ കുറിപ്പുകൾ ഇല്ല';

  @override
  String get addQuoteTitle => 'ഉദ്ധരണി ചേർക്കുക';

  @override
  String get addQuoteOriginalText => 'യഥാർത്ഥ ഉള്ളടക്കം *';

  @override
  String get addQuoteOriginalHint => 'യഥാർത്ഥ ലിപിയിൽ ഉദ്ധരണി നൽകുക...';

  @override
  String get addQuoteLanguage => 'ഭാഷ';

  @override
  String get addQuoteTranslation => 'ഇംഗ്ലീഷ് വിവർത്തനം *';

  @override
  String get addQuoteTranslationHint => 'ഇംഗ്ലീഷ് വിവർത്തനം നൽകുക...';

  @override
  String get addQuoteSource => 'ഉറവിടം';

  @override
  String get addQuoteSourceHint => 'ഉദാ., ഭഗവദ്ഗീത';

  @override
  String get addQuoteReference => 'റഫറൻസ്';

  @override
  String get addQuoteReferenceHint => 'ഉദാ., അദ്ധ്യായം 2, ശ്ലോകം 47';

  @override
  String get addQuoteSave => 'ഉദ്ധരണി സംരക്ഷിക്കുക';

  @override
  String get addQuoteAdded => 'ഉദ്ധരണി ചേർത്തു';

  @override
  String get langEnglish => 'ഇംഗ്ലീഷ്';

  @override
  String get langHindi => 'ഹിന്ദി';

  @override
  String get langKannada => 'കന്നഡ';

  @override
  String get langSanskrit => 'സംസ്കൃതം';

  @override
  String get langTelugu => 'തെലുഗു';

  @override
  String get langTamil => 'തമിഴ്';

  @override
  String get langMalayalam => 'മലയാളം';

  @override
  String get langFrench => 'ഫ്രഞ്ച്';

  @override
  String get langGerman => 'ജർമ്മൻ';

  @override
  String get langJapanese => 'ജാപ്പനീസ്';

  @override
  String get langHebrew => 'ഹീബ്രു';

  @override
  String get langChinese => 'ചൈനീസ്';

  @override
  String get langMarathi => 'മറാത്തി';

  @override
  String get langGujarati => 'ഗുജറാത്തി';

  @override
  String get langOdia => 'ഒഡിയ';

  @override
  String get langBengali => 'ബംഗാളി';

  @override
  String get langTulu => 'തുളു';

  @override
  String get langKonkani => 'കൊങ്കണി';

  @override
  String get langUrdu => 'ഉർദ്ദു';

  @override
  String get langItalian => 'ഇറ്റാലിയൻ';

  @override
  String get langSpanish => 'സ്പാനിഷ്';

  @override
  String get langArabic => 'അറബിക്';

  @override
  String get langRussian => 'റഷ്യൻ';

  @override
  String get langPortuguese => 'പോർട്ടുഗീസ്';

  @override
  String get langMaithili => 'മൈഥിലി';

  @override
  String get langAssamese => 'അസമീസ്';

  @override
  String get langPunjabi => 'പഞ്ചാബി';

  @override
  String get langOther => 'മറ്റുള്ളവ';

  @override
  String get preSessionSetup => 'സെഷൻ സജ്ജീകരണം';

  @override
  String get timerPaused => 'നിർത്തിവച്ചു';
}
