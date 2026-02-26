// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get actionCancel => 'ரத்து செய்';

  @override
  String get actionSave => 'சேமி';

  @override
  String get actionSkip => 'தவிர்';

  @override
  String get actionContinue => 'தொடர்';

  @override
  String get actionDelete => 'நீக்கு';

  @override
  String get actionAdd => 'சேர்';

  @override
  String get actionBegin => 'தொடங்கு';

  @override
  String get navDhyana => 'தியானம்';

  @override
  String get navHistory => 'வரலாறு';

  @override
  String get navStats => 'புள்ளிவிவரங்கள்';

  @override
  String get navSettings => 'அமைப்புகள்';

  @override
  String get splashGreeting => 'நமஸ்காரம்';

  @override
  String splashGreetingWithName(String name) {
    return 'நமஸ்காரம், $name';
  }

  @override
  String get splashTapToBegin => 'தொடங்க தட்டவும்';

  @override
  String get welcomeTitle => 'சித்தத்திற்கு வரவேற்கிறோம்';

  @override
  String get welcomeNameHint => 'உங்கள் பெயரை உள்ளிடவும்';

  @override
  String get homeBegin => 'தொடங்கு';

  @override
  String get homeCountdown => 'எண்ணிக்கை';

  @override
  String get homeStopwatch => 'நிறுத்த கடிகாரம்';

  @override
  String get homeMin => 'நி';

  @override
  String get historyTitle => 'வரலாறு';

  @override
  String historySelected(int count) {
    return '$count தேர்ந்தெடுக்கப்பட்டது';
  }

  @override
  String get historyDeleteTitle => 'அமர்வுகளை நீக்கு';

  @override
  String historyDeleteConfirm(int count) {
    return '$count அமர்வுகளை நீக்கவா? இதை மீட்டெடுக்க முடியாது.';
  }

  @override
  String get historyFilterAll => 'அனைத்தும்';

  @override
  String get historyEmpty => 'இன்னும் அமர்வுகள் இல்லை';

  @override
  String get historyEmptyHint =>
      'உங்கள் முதல் தியான அமர்வை முடிக்கவும்\nஇங்கே பார்க்க';

  @override
  String get statsTitle => 'புள்ளிவிவரங்கள்';

  @override
  String get statsToggleCalendar => 'நாட்காட்டி காட்சியை மாற்று';

  @override
  String get statsCurrentStreak => 'தற்போதைய தொடர்';

  @override
  String get statsLongestStreak => 'நீண்ட தொடர்';

  @override
  String get statsTotalSessions => 'மொத்த அமர்வுகள்';

  @override
  String get statsAverage => 'சராசரி';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'நாட்கள்',
      one: 'நாள்',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get settingsProfile => 'சுயவிவரம்';

  @override
  String get settingsName => 'பெயர்';

  @override
  String get settingsNameNotSet => 'அமைக்கப்படவில்லை';

  @override
  String get settingsEditName => 'பெயரை திருத்து';

  @override
  String get settingsAppearance => 'தோற்றம்';

  @override
  String get settingsTheme => 'தீம்';

  @override
  String get settingsThemeDark => 'இருண்ட';

  @override
  String get settingsThemeLight => 'ஒளி';

  @override
  String get settingsThemeSystem => 'கணினி';

  @override
  String get settingsLanguage => 'மொழி';

  @override
  String get settingsLanguageSystem => 'கணினி இயல்புநிலை';

  @override
  String get settingsTimer => 'நேரக்கடிகாரம்';

  @override
  String get settingsDefaultMode => 'இயல்புநிலை முறை';

  @override
  String get settingsDefaultDuration => 'இயல்புநிலை காலம்';

  @override
  String settingsDurationMinutes(int count) {
    return '$count நிமிடங்கள்';
  }

  @override
  String get settingsCountdown => 'எண்ணிக்கை';

  @override
  String get settingsCountdownDesc =>
      'காலத்தை அமை, நேரக்கடிகாரம் கீழே எண்ணுகிறது';

  @override
  String get settingsStopwatch => 'நிறுத்த கடிகாரம்';

  @override
  String get settingsStopwatchDesc => 'திறந்த முடிவு, கைமுறையாக நிறுத்து';

  @override
  String get settingsBellSounds => 'மணி ஒலிகள்';

  @override
  String get settingsStartBell => 'தொடக்க மணி';

  @override
  String get settingsEndBell => 'முடிவு மணி';

  @override
  String get settingsIntervalBell => 'இடைவெளி மணி';

  @override
  String get settingsBellNone => 'இல்லை';

  @override
  String get settingsPickFromDevice => 'சாதனத்திலிருந்து தேர்ந்தெடு...';

  @override
  String get settingsEnableInterval => 'இடைவெளி மணியை இயக்கு';

  @override
  String settingsIntervalEvery(int count) {
    return 'ஒவ்வொரு $count நி';
  }

  @override
  String get settingsOff => 'அணைவு';

  @override
  String get settingsIntervalDuration => 'இடைவெளி காலம்';

  @override
  String get settingsIntervalSound => 'இடைவெளி ஒலி';

  @override
  String get settingsBgMusic => 'பின்னணி இசை';

  @override
  String get settingsMusicFile => 'இசை கோப்பு';

  @override
  String get settingsMusicSelected => 'தேர்ந்தெடுக்கப்பட்டது';

  @override
  String get settingsMusicNone => 'இல்லை';

  @override
  String get settingsRemoveMusic => 'பின்னணி இசையை அகற்று';

  @override
  String get settingsTags => 'குறிச்சொற்கள்';

  @override
  String get settingsAddTag => '+ சேர்';

  @override
  String get settingsAddTagTitle => 'குறிச்சொல் சேர்';

  @override
  String get settingsAddTagHint => 'எ.கா., கவனம்';

  @override
  String get settingsQuotes => 'மேற்கோள்கள்';

  @override
  String get settingsAddCustomQuote => 'தனிப்பயன் மேற்கோள் சேர்';

  @override
  String settingsUserQuotes(int count) {
    return '$count பயனர் மேற்கோள்கள்';
  }

  @override
  String get settingsData => 'தரவு';

  @override
  String get settingsExport => 'தரவை ஏற்றுமதி';

  @override
  String get settingsExportDesc => 'உங்கள் அமர்வுகளை JSON ஆக பகிர்';

  @override
  String get settingsImport => 'தரவை இறக்குமதி';

  @override
  String get settingsImportDesc => 'சித்த JSON கோப்பிலிருந்து ஏற்று';

  @override
  String get settingsImportReplaceMsg =>
      'அனைத்து தரவையும் மாற்றவா, அல்லது தற்போதைய தரவுடன் இணைக்கவா?';

  @override
  String get settingsMerge => 'இணை';

  @override
  String get settingsReplaceAll => 'அனைத்தையும் மாற்று';

  @override
  String get settingsImportSuccess =>
      'தரவு வெற்றிகரமாக இறக்குமதி செய்யப்பட்டது';

  @override
  String get settingsImportError => 'தவறான இறக்குமதி கோப்பு';

  @override
  String settingsExportFailed(String error) {
    return 'ஏற்றுமதி தோல்வி: $error';
  }

  @override
  String get notesTitle => 'அமர்வு குறிப்புகள்';

  @override
  String get notesPrompt => 'உங்கள் பயிற்சி எப்படி இருந்தது?';

  @override
  String get notesHint => 'உங்கள் அனுபவத்தைப் பற்றி எழுதுங்கள்...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 வார்த்தைகள்';
  }

  @override
  String get notesTags => 'குறிச்சொற்கள்';

  @override
  String get sessionComplete => 'அமர்வு முடிந்தது';

  @override
  String get sessionTitle => 'அமர்வு';

  @override
  String get sessionCountdown => 'எண்ணிக்கை';

  @override
  String get sessionStopwatch => 'நிறுத்த கடிகாரம்';

  @override
  String get sessionCompleted => 'முடிந்தது';

  @override
  String get sessionNotes => 'குறிப்புகள்';

  @override
  String get sessionNoNotes => 'இந்த அமர்வுக்கு குறிப்புகள் இல்லை';

  @override
  String get addQuoteTitle => 'மேற்கோள் சேர்';

  @override
  String get addQuoteOriginalText => 'அசல் உரை *';

  @override
  String get addQuoteOriginalHint => 'அசல் எழுத்தில் மேற்கோள் உள்ளிடவும்...';

  @override
  String get addQuoteLanguage => 'மொழி';

  @override
  String get addQuoteTranslation => 'ஆங்கில மொழிபெயர்ப்பு *';

  @override
  String get addQuoteTranslationHint => 'ஆங்கில மொழிபெயர்ப்பை உள்ளிடவும்...';

  @override
  String get addQuoteSource => 'மூலம்';

  @override
  String get addQuoteSourceHint => 'எ.கா., பகவத் கீதை';

  @override
  String get addQuoteReference => 'குறிப்பு';

  @override
  String get addQuoteReferenceHint => 'எ.கா., அத்தியாயம் 2, சுலோகம் 47';

  @override
  String get addQuoteSave => 'மேற்கோளை சேமி';

  @override
  String get addQuoteAdded => 'மேற்கோள் சேர்க்கப்பட்டது';

  @override
  String get langEnglish => 'ஆங்கிலம்';

  @override
  String get langHindi => 'இந்தி';

  @override
  String get langKannada => 'கன்னடம்';

  @override
  String get langSanskrit => 'சமஸ்கிருதம்';

  @override
  String get langTelugu => 'தெலுங்கு';

  @override
  String get langTamil => 'தமிழ்';

  @override
  String get langMalayalam => 'மலையாளம்';

  @override
  String get langFrench => 'பிரெஞ்சு';

  @override
  String get langGerman => 'ஜெர்மன்';

  @override
  String get langJapanese => 'ஜப்பானியம்';

  @override
  String get langHebrew => 'ஹீப்ரு';

  @override
  String get langChinese => 'சீனம்';

  @override
  String get langMarathi => 'மராத்தி';

  @override
  String get langGujarati => 'குஜராத்தி';

  @override
  String get langOdia => 'ஒடியா';

  @override
  String get langBengali => 'வங்காளி';

  @override
  String get langTulu => 'துளு';

  @override
  String get langKonkani => 'கொங்கணி';

  @override
  String get langUrdu => 'உர்து';

  @override
  String get langItalian => 'இத்தாலியன்';

  @override
  String get langSpanish => 'ஸ்பானிஷ்';

  @override
  String get langArabic => 'அரபிக்';

  @override
  String get langRussian => 'ரஷ்யன்';

  @override
  String get langPortuguese => 'போர்ச்சுகீஸ்';

  @override
  String get langMaithili => 'மைதிலி';

  @override
  String get langAssamese => 'அசாமீஸ்';

  @override
  String get langPunjabi => 'பஞ்சாபி';

  @override
  String get langOther => 'மற்றவை';

  @override
  String get preSessionSetup => 'அமர்வு அமைப்பு';

  @override
  String get timerPaused => 'இடைநிறுத்தம்';
}
