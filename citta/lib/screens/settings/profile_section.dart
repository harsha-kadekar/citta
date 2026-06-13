import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import 'settings_widgets.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    return SettingsTile(
      title: l10n.settingsName,
      subtitle: appState.config.userName ?? l10n.settingsNameNotSet,
      onTap: () => _showEditNameDialog(context, appState, l10n),
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
          decoration: InputDecoration(hintText: l10n.welcomeNameHint),
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
                appState.updateConfig(appState.config.copyWith(userName: name));
              }
              Navigator.pop(context);
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }
}
