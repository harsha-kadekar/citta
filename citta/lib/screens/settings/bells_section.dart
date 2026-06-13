import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../services/audio_service.dart';
import '../../theme/app_theme.dart';
import 'settings_widgets.dart';

String bellDisplayName(String bellId) {
  if (bellId == 'none') return 'None';
  if (bellId.startsWith('bundled:')) {
    final name = bellId.substring(8);
    return AudioService.soundDisplayNames[name] ?? name;
  }
  if (bellId.startsWith('custom:')) return 'Custom file';
  return bellId;
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
        SettingsTile(
          title: l10n.settingsEndBell,
          subtitle: bellDisplayName(config.bellEnd),
          trailing: config.bellEnd == 'none'
              ? null
              : IconButton(
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  onPressed: () =>
                      appState.audioService.previewSound(config.bellEnd),
                ),
          onTap: () => _showBellPicker(
              context, appState, l10n.settingsEndBell, config.bellEnd, (val) {
            appState.updateConfig(config.copyWith(bellEnd: val));
          }, l10n),
        ),
        SwitchListTile(
          title: Text(l10n.settingsEnableInterval),
          subtitle: Text(config.intervalEnabled
              ? l10n.settingsIntervalEvery(config.intervalDuration ~/ 60)
              : l10n.settingsOff),
          value: config.intervalEnabled,
          onChanged: (val) {
            appState.updateConfig(config.copyWith(intervalEnabled: val));
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
            trailing: config.bellInterval == 'none'
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
              appState.updateConfig(config.copyWith(bellInterval: val));
            }, l10n),
          ),
        ],
      ],
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
                color: currentValue == 'none' ? AppColors.primary : null,
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
