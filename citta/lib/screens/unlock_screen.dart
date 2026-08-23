import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../providers/app_state.dart';

/// Full-screen, non-dismissible gate shown when [AppState.needsUnlock] is
/// true: encryption is enabled but this run couldn't restore the master key
/// from the secure-storage cache (fresh reinstall, new device, or a cleared
/// cache — see issue #53). Accepts either the password or the recovery key
/// in a single field and tries both against [AppState], so a wrong entry's
/// error message never reveals which form was attempted or which of the two
/// unlock paths failed. There is no skip/back affordance — the only way past
/// this screen is a successful unlock.
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState appState, AppLocalizations l10n) async {
    final input = _controller.text;
    if (input.isEmpty) {
      setState(() => _errorText = l10n.unlockErrorEmpty);
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      // AppState tries password then recovery key internally so neither
      // this screen nor any future caller has to re-implement that
      // ordering (or risk revealing which form was attempted).
      final unlocked = await appState.unlockWithPasswordOrRecoveryKey(input);
      if (!mounted) return;
      if (unlocked) {
        _controller.clear();
      } else {
        setState(() => _errorText = l10n.unlockErrorGeneric);
      }
    } catch (_) {
      // Reaching here (rather than a plain `false` above) means
      // encryption_meta.json itself is unreadable or malformed — a
      // distinct failure from "wrong credential" that a generic
      // wrong-password message would misrepresent as retryable.
      if (!mounted) return;
      setState(() => _errorText = l10n.unlockErrorCorrupted);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.unlockTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.unlockSubtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  key: const Key('unlockInputField'),
                  controller: _controller,
                  obscureText: true,
                  enabled: !_submitting,
                  decoration: InputDecoration(labelText: l10n.unlockInputLabel),
                  onSubmitted: (_) =>
                      _submitting ? null : _submit(appState, l10n),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorText!,
                      key: const Key('unlockErrorText'),
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('unlockSubmitButton'),
                  onPressed: _submitting ? null : () => _submit(appState, l10n),
                  child: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.unlockSubmitButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
