import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'settings_widgets.dart';

class TimerSection extends StatelessWidget {
  const TimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final config = appState.config;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTile(
          title: l10n.settingsDefaultMode,
          subtitle: config.timerMode == 'countdown'
              ? l10n.settingsCountdown
              : l10n.settingsStopwatch,
          onTap: () => _showTimerModeDialog(context, appState, l10n),
        ),
        if (config.timerMode == 'countdown')
          SettingsTile(
            title: l10n.settingsDefaultDuration,
            subtitle:
                l10n.settingsDurationMinutes(config.countdownDuration ~/ 60),
            onTap: () => _showDurationPicker(context, appState, l10n),
          ),
      ],
    );
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
                    appState.updateConfig(
                        appState.config.copyWith(countdownDuration: mins * 60));
                    Navigator.pop(context);
                  },
                  child: Text(
                    l10n.settingsDurationMinutes(mins),
                    style: TextStyle(
                      fontWeight: appState.config.countdownDuration == mins * 60
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: appState.config.countdownDuration == mins * 60
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
