import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../services/audio_service.dart';
import '../../models/audio_source.dart';
import '../../theme/app_theme.dart';
import 'audio_picker.dart';
import 'settings_widgets.dart';

String bellDisplayName(AudioSource bellId) {
  if (bellId.isNone) return 'None';
  if (bellId.isBundled) {
    final name = bellId.bundledName!;
    return AudioService.soundDisplayNames[name] ?? name;
  }
  return 'Custom file';
}

class BellsSection extends StatelessWidget {
  const BellsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final config = appState.config;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTile(
          title: l10n.settingsStartBell,
          subtitle: bellDisplayName(config.bellStart),
          trailing: config.bellStart.isNone
              ? null
              : IconButton(
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  onPressed: () =>
                      appState.audioService.previewSound(config.bellStart),
                ),
          onTap: () => _showBellPicker(
              context, appState, l10n.settingsStartBell, config.bellStart,
              (val) {
            appState.mutateConfig((current) => current.copyWith(bellStart: val));
          }, l10n),
        ),
        SettingsTile(
          title: l10n.settingsEndBell,
          subtitle: bellDisplayName(config.bellEnd),
          trailing: config.bellEnd.isNone
              ? null
              : IconButton(
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  onPressed: () =>
                      appState.audioService.previewSound(config.bellEnd),
                ),
          onTap: () => _showBellPicker(
              context, appState, l10n.settingsEndBell, config.bellEnd, (val) {
            appState.mutateConfig((current) => current.copyWith(bellEnd: val));
          }, l10n),
        ),
        SwitchListTile(
          title: Text(l10n.settingsEnableInterval),
          subtitle: Text(config.intervalEnabled
              ? l10n.settingsIntervalEvery(config.intervalDuration ~/ 60)
              : l10n.settingsOff),
          value: config.intervalEnabled,
          onChanged: (val) {
            appState.mutateConfig((current) => current.copyWith(intervalEnabled: val));
          },
        ),
        if (config.intervalEnabled) ...[
          SettingsTile(
            title: l10n.settingsIntervalDuration,
            subtitle:
                l10n.settingsDurationMinutes(config.intervalDuration ~/ 60),
            onTap: () =>
                _showIntervalDurationPicker(context, appState, l10n),
          ),
          SettingsTile(
            title: l10n.settingsIntervalSound,
            subtitle: bellDisplayName(config.bellInterval),
            trailing: config.bellInterval.isNone
                ? null
                : IconButton(
                    icon: const Icon(Icons.play_circle_outline, size: 20),
                    onPressed: () =>
                        appState.audioService.previewSound(config.bellInterval),
                  ),
            onTap: () => _showBellPicker(
                context,
                appState,
                l10n.settingsIntervalSound,
                config.bellInterval, (val) {
              appState.mutateConfig((current) => current.copyWith(bellInterval: val));
            }, l10n),
          ),
        ],
      ],
    );
  }

  void _showBellPicker(
      BuildContext context,
      AppState appState,
      String title,
      AudioSource currentValue,
      Function(AudioSource) onSelect,
      AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          SimpleDialogOption(
            onPressed: () {
              onSelect(AudioSource.none);
              Navigator.pop(context);
            },
            child: Text(
              l10n.settingsBellNone,
              style: TextStyle(
                fontWeight: currentValue.isNone
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: currentValue.isNone ? AppColors.primary : null,
              ),
            ),
          ),
          ...AudioService.bundledSounds.entries.map((entry) {
            final bellId = AudioSource.bundled(entry.key);
            return SimpleDialogOption(
              onPressed: () {
                onSelect(bellId);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AudioService.soundDisplayNames[entry.key] ?? entry.key,
                      style: TextStyle(
                        fontWeight: currentValue == bellId
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: currentValue == bellId ? AppColors.primary : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.play_circle_outline, size: 20),
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
              final selection = await pickCustomAudioSelection();
              if (selection != null) onSelect(selection);
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
                    appState.mutateConfig((current) =>
                        current.copyWith(intervalDuration: mins * 60));
                    Navigator.pop(context);
                  },
                  child: Text(
                    l10n.settingsDurationMinutes(mins),
                    style: TextStyle(
                      fontWeight:
                          appState.config.intervalDuration == mins * 60
                              ? FontWeight.w600
                              : FontWeight.w400,
                      color: appState.config.intervalDuration == mins * 60
                          ? AppColors.primary
                          : null,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
