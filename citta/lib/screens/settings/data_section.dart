import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import 'settings_widgets.dart';

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTile(
          title: l10n.settingsExport,
          subtitle: l10n.settingsExportDesc,
          onTap: () => _exportData(context, appState, l10n),
        ),
        SettingsTile(
          title: l10n.settingsImport,
          subtitle: l10n.settingsImportDesc,
          onTap: () => _importData(context, appState, l10n),
        ),
      ],
    );
  }

  Future<void> _exportData(
      BuildContext context, AppState appState, AppLocalizations l10n) async {
    try {
      final path = await appState.storageService.writeExportFile();
      await Share.shareXFiles([XFile(path)], subject: 'Citta Data Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.settingsExportFailed(e.toString()))),
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

    final content = await File(result.files.single.path!).readAsString();

    if (!context.mounted) return;

    final replaceAll = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsImport),
        content: Text(l10n.settingsImportReplaceMsg),
        actionsAlignment: MainAxisAlignment.end,
        actionsOverflowAlignment: OverflowBarAlignment.end,
        actionsOverflowButtonSpacing: 8,
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
