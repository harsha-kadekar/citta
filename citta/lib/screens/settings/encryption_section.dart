import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../change_password_screen.dart';
import '../enable_encryption_screen.dart';
import 'settings_widgets.dart';

/// Settings row for turning encryption on later (for users who skipped it at
/// first launch) or off again (reverting to plaintext storage). Reflects the
/// on-disk status ([StorageService.isEncryptionEnabled]) rather than tracking
/// it independently, so an enable flow abandoned partway through (encryption
/// opt-in submitted, recovery key screen dismissed without continuing) still
/// shows correctly once control returns here.
class EncryptionSection extends StatefulWidget {
  const EncryptionSection({super.key});

  @override
  State<EncryptionSection> createState() => _EncryptionSectionState();
}

class _EncryptionSectionState extends State<EncryptionSection> {
  bool? _enabled;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final enabled =
        await context.read<AppState>().storageService.isEncryptionEnabled;
    if (mounted) setState(() => _enabled = enabled);
  }

  Future<void> _onToggle(bool value) async {
    if (value) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EnableEncryptionScreen()),
      );
      await _refreshStatus();
      return;
    }
    await _confirmAndDisable();
  }

  Future<void> _confirmAndDisable() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsEncryptionDisableConfirmTitle),
        content: Text(l10n.settingsEncryptionDisableConfirmMessage),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            key: const Key('encryptionDisableCancelButton'),
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            key: const Key('encryptionDisableConfirmButton'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.settingsEncryptionDisableConfirmButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final appState = context.read<AppState>();
    setState(() => _busy = true);
    try {
      await appState.storageService.disableEncryption();
      if (!mounted) return;
      setState(() {
        _enabled = false;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsEncryptionDisableError)),
      );
    }
  }

  Future<void> _openChangePassword() async {
    final l10n = AppLocalizations.of(context)!;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.changePasswordSuccess)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = _enabled ?? false;
    return Column(
      children: [
        SwitchListTile(
          key: const Key('encryptionSectionSwitch'),
          title: Text(l10n.settingsEncryptionTitle),
          subtitle: Text(enabled
              ? l10n.settingsEncryptionSubtitleEnabled
              : l10n.settingsEncryptionSubtitleDisabled),
          value: enabled,
          onChanged: (_enabled == null || _busy) ? null : _onToggle,
        ),
        if (enabled)
          SettingsTile(
            key: const Key('settingsChangePasswordTile'),
            title: l10n.settingsChangePasswordTitle,
            subtitle: l10n.settingsChangePasswordSubtitle,
            onTap: _openChangePassword,
          ),
      ],
    );
  }
}
