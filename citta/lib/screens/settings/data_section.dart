import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import 'encryption_section.dart';
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
        const EncryptionSection(),
      ],
    );
  }

  Future<void> _exportData(
      BuildContext context, AppState appState, AppLocalizations l10n) async {
    try {
      var encrypted = false;
      if (await appState.storageService.isEncryptionEnabled) {
        if (!context.mounted) return;
        final choice = await _chooseExportMode(context, l10n);
        if (choice == null) return;
        encrypted = choice;
      }

      final path =
          await appState.storageService.writeExportFile(encrypted: encrypted);
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

  /// Shown only when encryption is enabled — otherwise export behaves
  /// exactly as before. Returns true for an encrypted export, false for
  /// plain JSON, or null if the user dismissed the dialog.
  Future<bool?> _chooseExportMode(
          BuildContext context, AppLocalizations l10n) =>
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.settingsExportChooseTitle),
          content: Text(l10n.settingsExportChooseMsg),
          actionsAlignment: MainAxisAlignment.end,
          actionsOverflowAlignment: OverflowBarAlignment.end,
          actionsOverflowButtonSpacing: 8,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel),
            ),
            OutlinedButton(
              key: const Key('exportChoosePlainButton'),
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.settingsExportChoosePlain),
            ),
            ElevatedButton(
              key: const Key('exportChooseEncryptedButton'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.settingsExportChooseEncrypted),
            ),
          ],
        ),
      );

  Future<void> _importData(
      BuildContext context, AppState appState, AppLocalizations l10n) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    var content = await File(result.files.single.path!).readAsString();

    if (!context.mounted) return;

    if (appState.storageService.isEncryptedExport(content)) {
      final decrypted =
          await _promptAndDecryptImport(context, appState, l10n, content);
      if (decrypted == null || !context.mounted) return;
      content = decrypted;
    }

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

  /// Prompts for the password or recovery key that encrypted [content],
  /// retrying on a wrong entry. Returns the decrypted plain-export JSON, or
  /// null if the user cancels. Reuses [StorageService.decryptExportContent]
  /// directly — decrypting a bundle's own embedded metadata never touches
  /// this device's own encryption state, so it works even if this device
  /// has encryption disabled or is a fresh install (see issue #56).
  Future<String?> _promptAndDecryptImport(
    BuildContext context,
    AppState appState,
    AppLocalizations l10n,
    String content,
  ) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EncryptedImportPasswordDialog(
        storageService: appState.storageService,
        content: content,
      ),
    );
  }
}

/// Modal prompt shown by [DataSection._importData] when the picked file is
/// an encrypted export (see [StorageService.isEncryptedExport]). Mirrors
/// [UnlockScreen]'s single-field "try password, then recovery key" pattern,
/// but as a dialog scoped to one import instead of a full-screen device
/// gate, and against the encrypted export's own bundled metadata rather
/// than this device's `encryption_meta.json`.
class _EncryptedImportPasswordDialog extends StatefulWidget {
  const _EncryptedImportPasswordDialog({
    required this.storageService,
    required this.content,
  });

  final StorageService storageService;
  final String content;

  @override
  State<_EncryptedImportPasswordDialog> createState() =>
      _EncryptedImportPasswordDialogState();
}

class _EncryptedImportPasswordDialogState
    extends State<_EncryptedImportPasswordDialog> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final input = _controller.text;
    if (input.isEmpty) {
      setState(() => _errorText = l10n.settingsImportEncryptedErrorEmpty);
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });
    final decrypted = await widget.storageService
        .decryptExportContent(widget.content, input);
    if (!mounted) return;
    if (decrypted != null) {
      Navigator.pop(context, decrypted);
      return;
    }
    setState(() {
      _submitting = false;
      _errorText = l10n.settingsImportEncryptedErrorWrong;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.settingsImportEncryptedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsImportEncryptedSubtitle),
          const SizedBox(height: 16),
          TextField(
            key: const Key('importEncryptedInputField'),
            controller: _controller,
            obscureText: true,
            enabled: !_submitting,
            decoration: InputDecoration(
                labelText: l10n.settingsImportEncryptedInputLabel),
            onSubmitted: (_) => _submitting ? null : _submit(l10n),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorText!,
                key: const Key('importEncryptedErrorText'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        ElevatedButton(
          key: const Key('importEncryptedSubmitButton'),
          onPressed: _submitting ? null : () => _submit(l10n),
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.settingsImportEncryptedSubmitButton),
        ),
      ],
    );
  }
}
