import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../widgets/encryption_opt_in.dart';

/// Settings screen for changing the password protecting an already-encrypted
/// install. Requires and validates the current password before accepting a
/// new one — [StorageService.changePassword] re-wraps the existing master
/// key under the new password, so [sessions.json] is never touched, and the
/// recovery key (if any) keeps working unchanged.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState appState, AppLocalizations l10n) async {
    final current = _currentController.text;
    final newPassword = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty || newPassword.isEmpty) {
      setState(() => _errorText = l10n.changePasswordErrorEmpty);
      return;
    }
    if (newPassword.length < EncryptionOptIn.minPasswordLength) {
      setState(() => _errorText = l10n
          .changePasswordErrorTooShort(EncryptionOptIn.minPasswordLength));
      return;
    }
    if (newPassword != confirm) {
      setState(() => _errorText = l10n.changePasswordErrorMismatch);
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      final changed = await appState.storageService.changePassword(
        currentPassword: current,
        newPassword: newPassword,
      );
      if (!mounted) return;
      if (changed) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _errorText = l10n.changePasswordErrorWrongCurrent);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = l10n.changePasswordErrorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordScreenTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('changePasswordCurrentField'),
              controller: _currentController,
              obscureText: true,
              enabled: !_submitting,
              decoration:
                  InputDecoration(labelText: l10n.changePasswordCurrentLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('changePasswordNewField'),
              controller: _newController,
              obscureText: true,
              enabled: !_submitting,
              decoration:
                  InputDecoration(labelText: l10n.changePasswordNewLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('changePasswordConfirmField'),
              controller: _confirmController,
              obscureText: true,
              enabled: !_submitting,
              decoration:
                  InputDecoration(labelText: l10n.changePasswordConfirmLabel),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorText!,
                  key: const Key('changePasswordErrorText'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('changePasswordSubmitButton'),
              onPressed:
                  _submitting ? null : () => _submit(appState, l10n),
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.changePasswordSubmitButton),
            ),
          ],
        ),
      ),
    );
  }
}
