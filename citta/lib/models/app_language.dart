/// The app's UI/content language, including the "follow system" option.
///
/// [code] is the persisted ISO/BCP-47-ish code used by [AppLanguageStorage]
/// and to build a [Locale]. [nativeName]/[englishName]/[isLatinScript] carry
/// the display metadata that used to live in parallel constant lists in
/// `appearance_section.dart`.
enum AppLanguage {
  system('system', 'System', 'System', false),
  english('en', 'English', 'English', true),
  hindi('hi', 'हिंदी', 'Hindi', false),
  kannada('kn', 'ಕನ್ನಡ', 'Kannada', false),
  sanskrit('sa', 'संस्कृत', 'Sanskrit', false),
  telugu('te', 'తెలుగు', 'Telugu', false),
  tamil('ta', 'தமிழ்', 'Tamil', false),
  malayalam('ml', 'മലയാളം', 'Malayalam', false),
  marathi('mr', 'मराठी', 'Marathi', false),
  gujarati('gu', 'ગુજરાતી', 'Gujarati', false),
  odia('or', 'ଓଡ଼ିଆ', 'Odia', false),
  bengali('bn', 'বাংলা', 'Bengali', false),
  tulu('tcy', 'ತುಳು', 'Tulu', false),
  konkani('kok', 'कोंकणी', 'Konkani', false),
  urdu('ur', 'اردو', 'Urdu', false),
  assamese('as', 'অসমীয়া', 'Assamese', false),
  punjabi('pa', 'ਪੰਜਾਬੀ', 'Punjabi', false),
  maithili('mai', 'मैथिली', 'Maithili', false),
  french('fr', 'Français', 'French', true),
  german('de', 'Deutsch', 'German', true),
  italian('it', 'Italiano', 'Italian', true),
  spanish('es', 'Español', 'Spanish', true),
  portuguese('pt', 'Português', 'Portuguese', true),
  russian('ru', 'Русский', 'Russian', false),
  arabic('ar', 'العربية', 'Arabic', false),
  japanese('ja', '日本語', 'Japanese', false),
  chinese('zh', '中文', 'Chinese', false),
  hebrew('he', 'עברית', 'Hebrew', false);

  final String code;
  final String nativeName;
  final String englishName;
  final bool isLatinScript;

  const AppLanguage(
      this.code, this.nativeName, this.englishName, this.isLatinScript);
}

extension AppLanguageStorage on AppLanguage {
  String toStorageString() => code;

  static AppLanguage fromStorageString(
    String? value, {
    AppLanguage fallback = AppLanguage.system,
  }) {
    for (final lang in AppLanguage.values) {
      if (lang.code == value) return lang;
    }
    return fallback;
  }
}
