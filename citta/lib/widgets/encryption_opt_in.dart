import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../providers/app_state.dart';

/// Reusable "turn on encryption" component: a toggle that expands to a
/// password + confirmation, validates client-side, and on success calls
/// [StorageService.enableEncryption] to generate, wrap, and persist the
/// master key. Used both by the first-time setup screen and by Settings'
/// enable-later flow — this widget only handles opt-in; it does not display
/// the recovery key (that's a follow-up step the host screen triggers via
/// [onEncryptionEnabled]).
///
/// Toggling off (or never turning it on) never calls into storage — the only
/// side effect this widget can produce is a successful [onEncryptionEnabled]
/// call after the password is confirmed and submitted. The toggle is locked
/// (non-interactive) while a submission is in flight and after it succeeds,
/// so it can't be raced or resubmitted.
class EncryptionOptIn extends StatefulWidget {
  final VoidCallback? onEncryptionEnabled;

  const EncryptionOptIn({super.key, this.onEncryptionEnabled});

  static const int minPasswordLength = 8;

  @override
  State<EncryptionOptIn> createState() => _EncryptionOptInState();
}

class _EncryptionOptInState extends State<EncryptionOptIn> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _enabled = false;
  bool _submitting = false;
  bool _completed = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onToggle(bool value) {
    setState(() {
      _enabled = value;
      _errorText = null;
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  Future<void> _submit(AppState appState, AppLocalizations l10n) async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty) {
      setState(() => _errorText = l10n.encryptionErrorEmpty);
      return;
    }
    if (password.length < EncryptionOptIn.minPasswordLength) {
      setState(() => _errorText =
          l10n.encryptionErrorTooShort(EncryptionOptIn.minPasswordLength));
      return;
    }
    if (password != confirm) {
      setState(() => _errorText = l10n.encryptionErrorMismatch);
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await appState.storageService.enableEncryption(password: password);
      if (!mounted) return;
      // Encryption is now on for good — clear the plaintext password out of
      // memory and lock the form so it can't be resubmitted (a second call
      // to enableEncryption() always throws, since it's a one-time setup).
      _passwordController.clear();
      _confirmController.clear();
      setState(() => _completed = true);
      widget.onEncryptionEnabled?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = l10n.encryptionErrorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(l10n.encryptionToggleTitle),
          subtitle: Text(l10n.encryptionToggleSubtitle),
          value: _enabled,
          // Locked once submitting (an in-flight enableEncryption() call
          // must not be raced by toggling off mid-flight) or once completed
          // (encryption is on for good; there's nothing left to toggle).
          onChanged: (_submitting || _completed) ? null : _onToggle,
        ),
        if (_enabled && !_completed) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              key: const Key('encryptionPasswordField'),
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.encryptionPasswordLabel,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              key: const Key('encryptionConfirmPasswordField'),
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.encryptionConfirmPasswordLabel,
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ElevatedButton(
              key: const Key('encryptionEnableButton'),
              onPressed: _submitting ? null : () => _submit(appState, l10n),
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.encryptionEnableButton),
            ),
          ),
        ],
      ],
    );
  }
}
