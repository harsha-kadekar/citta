import 'dart:io';
import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_state.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'add_quote_screen.dart';

// Language options: (locale code, native label, English label)
const _languageOptions = [
  ('en', 'English', 'English'),
  // Indian languages
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
  // European languages
  ('fr', 'Français', 'French'),
  ('de', 'Deutsch', 'German'),
  ('it', 'Italiano', 'Italian'),
  ('es', 'Español', 'Spanish'),
  ('pt', 'Português', 'Portuguese'),
  ('ru', 'Русский', 'Russian'),
  // Asian & Middle Eastern
  ('ar', 'العربية', 'Arabic'),
  ('ja', '日本語', 'Japanese'),
  ('zh', '中文', 'Chinese'),
  ('he', 'עברית', 'Hebrew'),
];

// Locale codes that use Latin script — show native name only (no English subtitle)
const _latinLocales = {'en', 'fr', 'de', 'it', 'es', 'pt'};

String _languageDisplayName(String code, AppLocalizations l10n) {
  if (code == 'system') return l10n.settingsLanguageSystem;
  for (final opt in _languageOptions) {
    if (opt.$1 == code) {
      return _latinLocales.contains(code) ? opt.$2 : '${opt.$2} (${opt.$3})';
    }
  }
  return code;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final config = appState.config;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // --- Profile Section ---
          _SectionHeader(title: l10n.settingsProfile),
          _SettingsTile(
            title: l10n.settingsName,
            subtitle: config.userName ?? l10n.settingsNameNotSet,
            onTap: () => _showEditNameDialog(context, appState, l10n),
          ),
          const Divider(),

          // --- Appearance Section ---
          _SectionHeader(title: l10n.settingsAppearance),
          _SettingsTile(
            title: l10n.settingsTheme,
            subtitle: _themeDisplayName(config.themeMode, l10n),
            onTap: () => _showThemePicker(context, appState, l10n),
          ),
          _SettingsTile(
            title: l10n.settingsLanguage,
            subtitle: _languageDisplayName(config.language, l10n),
            onTap: () => _showLanguagePicker(context, appState, l10n),
          ),
          const Divider(),

          // --- Timer Section ---
          _SectionHeader(title: l10n.settingsTimer),
          _SettingsTile(
            title: l10n.settingsDefaultMode,
            subtitle: config.timerMode == 'countdown'
                ? l10n.settingsCountdown
                : l10n.settingsStopwatch,
            onTap: () => _showTimerModeDialog(context, appState, l10n),
          ),
          if (config.timerMode == 'countdown')
            _SettingsTile(
              title: l10n.settingsDefaultDuration,
              subtitle: l10n.settingsDurationMinutes(config.countdownDuration ~/ 60),
              onTap: () => _showDurationPicker(context, appState, l10n),
            ),
          const Divider(),

          // --- Bell Sounds ---
          _SectionHeader(title: l10n.settingsBellSounds),
          _SettingsTile(
            title: l10n.settingsStartBell,
            subtitle: _bellDisplayName(config.bellStart),
            trailing: config.bellStart == 'none'
                ? null
                : IconButton(
                    icon: const Icon(Icons.play_circle_outline, size: 20),
                    onPressed: () =>
                        appState.audioService.previewSound(config.bellStart),
                  ),
            onTap: () => _showBellPicker(
                context, appState, l10n.settingsStartBell, config.bellStart,
                (val) {
              appState.updateConfig(config.copyWith(bellStart: val));
            }, l10n),
          ),
          _SettingsTile(
            title: l10n.settingsEndBell,
            subtitle: _bellDisplayName(config.bellEnd),
            trailing: config.bellEnd == 'none'
                ? null
                : IconButton(
                    icon: const Icon(Icons.play_circle_outline, size: 20),
                    onPressed: () =>
                        appState.audioService.previewSound(config.bellEnd),
                  ),
            onTap: () => _showBellPicker(
                context, appState, l10n.settingsEndBell, config.bellEnd,
                (val) {
              appState.updateConfig(config.copyWith(bellEnd: val));
            }, l10n),
          ),
          const Divider(),

          // --- Interval ---
          _SectionHeader(title: l10n.settingsIntervalBell),
          SwitchListTile(
            title: Text(l10n.settingsEnableInterval),
            subtitle: Text(config.intervalEnabled
                ? l10n.settingsIntervalEvery(config.intervalDuration ~/ 60)
                : l10n.settingsOff),
            value: config.intervalEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              appState
                  .updateConfig(config.copyWith(intervalEnabled: val));
            },
          ),
          if (config.intervalEnabled) ...[
            _SettingsTile(
              title: l10n.settingsIntervalDuration,
              subtitle: l10n.settingsDurationMinutes(config.intervalDuration ~/ 60),
              onTap: () =>
                  _showIntervalDurationPicker(context, appState, l10n),
            ),
            _SettingsTile(
              title: l10n.settingsIntervalSound,
              subtitle: _bellDisplayName(config.bellInterval),
              trailing: config.bellInterval == 'none'
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.play_circle_outline, size: 20),
                      onPressed: () => appState.audioService
                          .previewSound(config.bellInterval),
                    ),
              onTap: () => _showBellPicker(context, appState,
                  l10n.settingsIntervalSound, config.bellInterval, (val) {
                appState
                    .updateConfig(config.copyWith(bellInterval: val));
              }, l10n),
            ),
          ],
          const Divider(),

          // --- Background Music ---
          _SectionHeader(title: l10n.settingsBgMusic),
          _SettingsTile(
            title: l10n.settingsMusicFile,
            subtitle:
                config.backgroundMusic != null ? l10n.settingsMusicSelected : l10n.settingsMusicNone,
            onTap: () => _pickBackgroundMusic(context, appState),
          ),
          if (config.backgroundMusic != null)
            ListTile(
              leading: const Icon(Icons.clear, color: AppColors.error),
              title: Text(l10n.settingsRemoveMusic),
              onTap: () {
                appState.updateConfig(
                    config.copyWith(backgroundMusic: null));
              },
            ),
          const Divider(),

          // --- Tags ---
          _SectionHeader(title: l10n.settingsTags),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...config.tags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => appState.removeTag(tag),
                      deleteIconColor: AppColors.textHint,
                    )),
                ActionChip(
                  label: Text(l10n.settingsAddTag),
                  onPressed: () => _showAddTagDialog(context, appState, l10n),
                ),
              ],
            ),
          ),
          const Divider(),

          // --- Quotes ---
          _SectionHeader(title: l10n.settingsQuotes),
          _SettingsTile(
            title: l10n.settingsAddCustomQuote,
            subtitle: l10n.settingsUserQuotes(
                appState.quoteService.userQuotes.length),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const AddQuoteScreen()),
              );
            },
          ),
          const Divider(),

          // --- Data ---
          _SectionHeader(title: l10n.settingsData),
          _SettingsTile(
            title: l10n.settingsExport,
            subtitle: l10n.settingsExportDesc,
            onTap: () => _exportData(context, appState, l10n),
          ),
          _SettingsTile(
            title: l10n.settingsImport,
            subtitle: l10n.settingsImportDesc,
            onTap: () => _importData(context, appState, l10n),
          ),
        ],
      ),
    );
  }

  String _themeDisplayName(String mode, AppLocalizations l10n) {
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
          // System Default
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
          // 12 supported languages
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
                            fontSize: 12,
                            color: AppColors.textHint)),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context, AppState appState, AppLocalizations l10n) {
    final controller =
        TextEditingController(text: appState.config.userName ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsEditName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              InputDecoration(hintText: l10n.welcomeNameHint),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                appState.updateConfig(
                  appState.config.copyWith(userName: name),
                );
              }
              Navigator.pop(context);
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  String _bellDisplayName(String bellId) {
    if (bellId == 'none') return 'None';
    if (bellId.startsWith('bundled:')) {
      final name = bellId.substring(8);
      return AudioService.soundDisplayNames[name] ?? name;
    }
    if (bellId.startsWith('custom:')) {
      return 'Custom file';
    }
    return bellId;
  }

  void _showTimerModeDialog(
      BuildContext context, AppState appState, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsDefaultMode),
        children: [
          SimpleDialogOption(
            onPressed: () {
              appState.updateConfig(
                  appState.config.copyWith(timerMode: 'countdown'));
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Icon(Icons.timer,
                  color: appState.config.timerMode == 'countdown'
                      ? AppColors.primary
                      : null),
              title: Text(l10n.settingsCountdown),
              subtitle: Text(l10n.settingsCountdownDesc),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              appState.updateConfig(
                  appState.config.copyWith(timerMode: 'stopwatch'));
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Icon(Icons.timer_off,
                  color: appState.config.timerMode == 'stopwatch'
                      ? AppColors.primary
                      : null),
              title: Text(l10n.settingsStopwatch),
              subtitle: Text(l10n.settingsStopwatchDesc),
            ),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker(
      BuildContext context, AppState appState, AppLocalizations l10n) {
    final durations = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsDefaultDuration),
        children: durations
            .map((mins) => SimpleDialogOption(
                  onPressed: () {
                    appState.updateConfig(appState.config
                        .copyWith(countdownDuration: mins * 60));
                    Navigator.pop(context);
                  },
                  child: Text(
                    l10n.settingsDurationMinutes(mins),
                    style: TextStyle(
                      fontWeight:
                          appState.config.countdownDuration == mins * 60
                              ? FontWeight.w600
                              : FontWeight.w400,
                      color:
                          appState.config.countdownDuration == mins * 60
                              ? AppColors.primary
                              : null,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showIntervalDurationPicker(
      BuildContext context, AppState appState, AppLocalizations l10n) {
    final intervals = [1, 2, 3, 5, 10, 15, 20];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.settingsIntervalDuration),
        children: intervals
            .map((mins) => SimpleDialogOption(
                  onPressed: () {
                    appState.updateConfig(appState.config
                        .copyWith(intervalDuration: mins * 60));
                    Navigator.pop(context);
                  },
                  child: Text(
                    l10n.settingsDurationMinutes(mins),
                    style: TextStyle(
                      fontWeight:
                          appState.config.intervalDuration == mins * 60
                              ? FontWeight.w600
                              : FontWeight.w400,
                      color:
                          appState.config.intervalDuration == mins * 60
                              ? AppColors.primary
                              : null,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showBellPicker(BuildContext context, AppState appState, String title,
      String currentValue, Function(String) onSelect, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          SimpleDialogOption(
            onPressed: () {
              onSelect('none');
              Navigator.pop(context);
            },
            child: Text(
              l10n.settingsBellNone,
              style: TextStyle(
                fontWeight: currentValue == 'none'
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: currentValue == 'none'
                    ? AppColors.primary
                    : null,
              ),
            ),
          ),
          ...AudioService.bundledSounds.entries.map((entry) {
            final bellId = 'bundled:${entry.key}';
            return SimpleDialogOption(
              onPressed: () {
                onSelect(bellId);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AudioService.soundDisplayNames[entry.key] ??
                          entry.key,
                      style: TextStyle(
                        fontWeight: currentValue == bellId
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: currentValue == bellId
                            ? AppColors.primary
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline,
                        size: 20),
                    onPressed: () =>
                        appState.audioService.previewSound(bellId),
                  ),
                ],
              ),
            );
          }),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              final result = await FilePicker.platform.pickFiles(
                type: FileType.audio,
              );
              if (result != null && result.files.single.path != null) {
                onSelect('custom:${result.files.single.path}');
              }
            },
            child: Row(
              children: [
                const Icon(Icons.folder_open, size: 20),
                const SizedBox(width: 12),
                Text(l10n.settingsPickFromDevice),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBackgroundMusic(
      BuildContext context, AppState appState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.single.path != null) {
      appState.updateConfig(appState.config
          .copyWith(backgroundMusic: result.files.single.path));
    }
  }

  void _showAddTagDialog(
      BuildContext context, AppState appState, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsAddTagTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.settingsAddTagHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = controller.text.trim().toLowerCase();
              if (tag.isNotEmpty) {
                appState.addTag(tag);
              }
              Navigator.pop(context);
            },
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(
      BuildContext context, AppState appState, AppLocalizations l10n) async {
    try {
      final path = await appState.storageService.writeExportFile();
      await Share.shareXFiles([XFile(path)],
          subject: 'Citta Data Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsExportFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _importData(
      BuildContext context, AppState appState, AppLocalizations l10n) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = result.files.single;
    final content = await File(file.path!).readAsString();

    if (!context.mounted) return;

    // Ask merge strategy
    final replaceAll = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsImport),
        content: Text(l10n.settingsImportReplaceMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.settingsMerge),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.settingsReplaceAll),
          ),
        ],
      ),
    );

    if (replaceAll == null || !context.mounted) return;

    final success =
        await appState.importData(content, replaceAll: replaceAll);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? l10n.settingsImportSuccess
              : l10n.settingsImportError),
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ??
          const Icon(Icons.chevron_right,
              color: AppColors.textHint, size: 20),
      onTap: onTap,
    );
  }
}
