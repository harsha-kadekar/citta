import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/app_theme_mode.dart';
import '../../models/app_language.dart';
import 'settings_widgets.dart';

String languageDisplayName(AppLanguage language, AppLocalizations l10n) {
  if (language == AppLanguage.system) return l10n.settingsLanguageSystem;
  return language.isLatinScript
      ? language.nativeName
      : '${language.nativeName} (${language.englishName})';
}

String themeDisplayName(AppThemeMode mode, AppLocalizations l10n) {
  switch (mode) {
    case AppThemeMode.light:
      return l10n.settingsThemeLight;
    case AppThemeMode.system:
      return l10n.settingsThemeSystem;
    case AppThemeMode.dark:
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
            (AppThemeMode.dark, l10n.settingsThemeDark, Icons.dark_mode),
            (AppThemeMode.light, l10n.settingsThemeLight, Icons.light_mode),
            (AppThemeMode.system, l10n.settingsThemeSystem,
                Icons.settings_brightness),
          ])
            SimpleDialogOption(
              onPressed: () {
                appState.mutateConfig(
                    (current) => current.copyWith(themeMode: entry.$1));
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
          for (final language in AppLanguage.values)
            SimpleDialogOption(
              onPressed: () {
                appState.setLanguage(language);
                Navigator.pop(context);
              },
              child: ListTile(
                leading: Icon(
                    language == AppLanguage.system
                        ? Icons.language
                        : Icons.translate,
                    color: appState.config.language == language
                        ? AppColors.primary
                        : null),
                title: Text(language == AppLanguage.system
                    ? l10n.settingsLanguageSystem
                    : language.nativeName),
                // Matches the picker's historical subtitle rule, which is
                // narrower than isLatinScript (only these three codes
                // suppress the English-name subtitle here).
                subtitle: {
                  AppLanguage.system,
                  AppLanguage.english,
                  AppLanguage.french,
                  AppLanguage.german,
                }.contains(language)
                    ? null
                    : Text(language.englishName,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint)),
              ),
            ),
        ],
      ),
    );
  }
}
