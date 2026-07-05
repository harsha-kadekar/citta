import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'audio_picker.dart';
import 'settings_widgets.dart';

class BgMusicSection extends StatelessWidget {
  const BgMusicSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final config = appState.config;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTile(
          title: l10n.settingsMusicFile,
          subtitle: config.backgroundMusic != null
              ? l10n.settingsMusicSelected
              : l10n.settingsMusicNone,
          onTap: () => _pickBackgroundMusic(context, appState),
        ),
        if (config.backgroundMusic != null)
          ListTile(
            leading: const Icon(Icons.clear, color: AppColors.error),
            title: Text(l10n.settingsRemoveMusic),
            onTap: () {
              appState.updateConfig(config.copyWith(backgroundMusic: null));
            },
          ),
      ],
    );
  }

  Future<void> _pickBackgroundMusic(
      BuildContext context, AppState appState) async {
    final selection = await pickCustomAudioSelection();
    if (selection != null) {
      appState.updateConfig(
          appState.config.copyWith(backgroundMusic: selection));
    }
  }
}
