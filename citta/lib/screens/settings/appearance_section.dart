import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'settings_widgets.dart';

const _languageOptions = [
  ('en', 'English', 'English'),
  ('hi', 'हिंदी', 'Hindi'),
  ('kn', 'ಕನ್ನಡ', 'Kannada'),
  ('sa', 'संस्कृत', 'Sanskrit'),
  ('te', 'తెలుగు', 'Telugu'),
  ('ta', 'தமிழ்', 'Tamil'),
  ('ml', 'മലയാളം', 'Malayalam'),
  ('mr', 'मराठी', 'Marathi'),
  ('gu', 'ગુજરાતી', 'Gujarati'),
  ('or', 'ଓଡ଼ିଆ', 'Odia'),
  ('bn', 'বাংলা', 'Bengali'),
  ('tcy', 'ತುಳು', 'Tulu'),
  ('kok', 'कोंकणी', 'Konkani'),
  ('ur', 'اردو', 'Urdu'),
  ('as', 'অসমীয়া', 'Assamese'),
  ('pa', 'ਪੰਜਾਬੀ', 'Punjabi'),
  ('mai', 'मैथिली', 'Maithili'),
  ('fr', 'Français', 'French'),
  ('de', 'Deutsch', 'German'),
  ('it', 'Italiano', 'Italian'),
  ('es', 'Español', 'Spanish'),
  ('pt', 'Português', 'Portuguese'),
  ('ru', 'Русский', 'Russian'),
  ('ar', 'العربية', 'Arabic'),
  ('ja', '日本語', 'Japanese'),
  ('zh', '中文', 'Chinese'),
  ('he', 'עברית', 'Hebrew'),
];

const _latinLocales = {'en', 'fr', 'de', 'it', 'es', 'pt'};

String languageDisplayName(String code, AppLocalizations l10n) {
  if (code == 'system') return l10n.settingsLanguageSystem;
  for (final opt in _languageOptions) {
    if (opt.$1 == code) {
      return _latinLocales.contains(code) ? opt.$2 : '${opt.$2} (${opt.$3})';
    }
  }
  return code;
}

String themeDisplayName(String mode, AppLocalizations l10n) {
  switch (mode) {
    case 'light':
      return l10n.settingsThemeLight;
    case 'system':
      return l10n.settingsThemeSystem;
    case 'dark':
    default:
      return l10n.settingsThemeDark;
  }
}

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTile(
          title: l10n.settingsTheme,
          subtitle: themeDisplayName(appState.config.themeMode, l10n),
          onTap: () => _showThemePicker(context, appState, l10n),
        ),
        SettingsTile(
          title: l10n.settingsLanguage,
          subtitle: languageDisplayName(appState.config.language, l10n),
          onTap: () => _showLanguagePicker(context, appState, l10n),
        ),
      ],
    );
  }

  void _showThemePicker(
      BuildContext context, AppState appState, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsTheme),
        children: [
          for (final entry in [
            ('dark', l10n.settingsThemeDark, Icons.dark_mode),
            ('light', l10n.settingsThemeLight, Icons.light_mode),
            ('system', l10n.settingsThemeSystem, Icons.settings_brightness),
          ])
            SimpleDialogOption(
              onPressed: () {
                appState.updateConfig(
                    appState.config.copyWith(themeMode: entry.$1));
                Navigator.pop(context);
              },
              child: ListTile(
                leading: Icon(entry.$3,
                    color: appState.config.themeMode == entry.$1
                        ? Theme.of(context).colorScheme.primary
                        : null),
                title: Text(entry.$2),
              ),
            ),
        ],
      ),
    );
  }

  void _showLanguagePicker(
      BuildContext context, AppState appState, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () {
              appState.setLanguage('system');
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Icon(Icons.language,
                  color: appState.config.language == 'system'
                      ? AppColors.primary
                      : null),
              title: Text(l10n.settingsLanguageSystem),
            ),
          ),
          for (final opt in _languageOptions)
            SimpleDialogOption(
              onPressed: () {
                appState.setLanguage(opt.$1);
                Navigator.pop(context);
              },
              child: ListTile(
                leading: Icon(Icons.translate,
                    color: appState.config.language == opt.$1
                        ? AppColors.primary
                        : null),
                title: Text(opt.$2),
                subtitle: ['en', 'fr', 'de'].contains(opt.$1)
                    ? null
                    : Text(opt.$3,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint)),
              ),
            ),
        ],
      ),
    );
  }
}
