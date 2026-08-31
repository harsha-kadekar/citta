import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'recovery_key_screen.dart';
import '../widgets/encryption_opt_in.dart';

/// Full-page host for Settings' "enable encryption later" flow: shows
/// [EncryptionOptIn] to collect and confirm a password, then — once that
/// succeeds — pushes [RecoveryKeyScreen] on top of itself. [RecoveryKeyScreen]
/// pops both routes on Continue, returning the caller straight to Settings.
class EnableEncryptionScreen extends StatelessWidget {
  const EnableEncryptionScreen({super.key});

  void _showRecoveryKey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecoveryKeyScreen(
          onContinue: () => Navigator.of(context)
            ..pop()
            ..pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.enableEncryptionScreenTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EncryptionOptIn(
          onEncryptionEnabled: () => _showRecoveryKey(context),
        ),
      ),
    );
  }
}
