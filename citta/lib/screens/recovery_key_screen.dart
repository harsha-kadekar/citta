import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../services/storage_service.dart';

/// Full-page step shown immediately after encryption setup: generates a
/// recovery key via [StorageService.prepareRecoveryKey] (held only in
/// memory), displays it once with copy/share affordances, and persists it
/// via [StorageService.commitRecoveryKey] only once the user has explicitly
/// acknowledged saving it and tapped Continue — the recovery key is the sole
/// way to recover data if the password is later forgotten, and it is never
/// shown again after this screen.
///
/// Generation is deliberately kept separate from persistence: if this screen
/// is disposed (navigated away from, or the app is killed) before the user
/// acknowledges and continues, nothing is written to disk, so a later visit
/// simply generates a fresh candidate rather than being permanently stuck on
/// an already-persisted wrap whose plaintext key no longer exists anywhere.
///
/// Unlike the password-entry step before it, though, encryption is already
/// committed by the time this screen is showing — so backing out of it isn't
/// a harmless cancellation, it stops the recovery key from ever being saved.
/// There is deliberately no back/skip affordance here, the same way
/// [UnlockScreen] has none: the only way past this screen is Continue.
class RecoveryKeyScreen extends StatefulWidget {
  final VoidCallback? onContinue;

  /// Overridable for tests; defaults to [Share.share] in production.
  final void Function(String recoveryKey)? onShare;

  const RecoveryKeyScreen({super.key, this.onContinue, this.onShare});

  @override
  State<RecoveryKeyScreen> createState() => _RecoveryKeyScreenState();
}

class _RecoveryKeyScreenState extends State<RecoveryKeyScreen> {
  late final Future<PendingRecoveryKey> _pendingFuture;
  bool _acknowledged = false;
  bool _committing = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _pendingFuture =
        context.read<AppState>().storageService.prepareRecoveryKey();
  }

  void _share(String recoveryKey) {
    final onShare = widget.onShare;
    if (onShare != null) {
      onShare(recoveryKey);
    } else {
      Share.share(recoveryKey);
    }
  }

  Future<void> _continue(
    AppState appState,
    AppLocalizations l10n,
    PendingRecoveryKey pending,
  ) async {
    setState(() {
      _committing = true;
      _errorText = null;
    });
    try {
      await appState.storageService.commitRecoveryKey(pending);
      if (!mounted) return;
      widget.onContinue?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorText = l10n.recoveryKeyErrorGeneric);
    } finally {
      if (mounted) setState(() => _committing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.recoveryKeyScreenTitle),
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder<PendingRecoveryKey>(
          future: _pendingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.recoveryKeyErrorGeneric,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              );
            }

            final pending = snapshot.data!;
            final recoveryKey = pending.recoveryKey;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recoveryKeyWarning,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    key: const Key('recoveryKeyText'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      recoveryKey,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        key: const Key('recoveryKeyCopyButton'),
                        onPressed: () => Clipboard.setData(
                          ClipboardData(text: recoveryKey),
                        ),
                        icon: const Icon(Icons.copy),
                        label: Text(l10n.recoveryKeyCopyButton),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        key: const Key('recoveryKeyShareButton'),
                        onPressed: () => _share(recoveryKey),
                        icon: const Icon(Icons.share),
                        label: Text(l10n.recoveryKeyShareButton),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    key: const Key('recoveryKeyAckCheckbox'),
                    value: _acknowledged,
                    // Locked once committing (an in-flight commit must not be
                    // raced by toggling off mid-flight).
                    onChanged: _committing
                        ? null
                        : (value) =>
                            setState(() => _acknowledged = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.recoveryKeyAckLabel),
                  ),
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorText!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('recoveryKeyContinueButton'),
                      onPressed: (_acknowledged && !_committing)
                          ? () => _continue(appState, l10n, pending)
                          : null,
                      child: _committing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.recoveryKeyContinueButton),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
