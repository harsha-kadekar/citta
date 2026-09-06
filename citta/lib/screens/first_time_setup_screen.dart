import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../models/app_theme_mode.dart';
import '../providers/app_state.dart';
import '../widgets/encryption_opt_in.dart';
import 'recovery_key_screen.dart';
import 'settings/appearance_section.dart' show themeDisplayName;

/// Combined first-time setup screen (issue #59): collects a name, a theme
/// choice, and an encryption opt-in in a single screen shown once, right
/// after the language picker — replacing the old standalone name-prompt
/// dialog.
///
/// Name and theme are persisted as soon as Continue is tapped, *before* any
/// recovery-key step, so killing the app mid-setup never loses them.
/// [AppState.config.hasCompletedFirstTimeSetup] is the only thing gating
/// whether this screen shows again, and it is set last — only after the
/// recovery key (if encryption was turned on) has actually been committed —
/// so a resumed setup always finishes the flow it interrupted rather than
/// dropping into an inconsistent state.
class FirstTimeSetupScreen extends StatefulWidget {
  const FirstTimeSetupScreen({super.key});

  @override
  State<FirstTimeSetupScreen> createState() => _FirstTimeSetupScreenState();
}

class _FirstTimeSetupScreenState extends State<FirstTimeSetupScreen> {
  late final TextEditingController _nameController;
  late AppThemeMode _themeMode;

  // Null while the initial on-disk check is in flight. Checked (rather than
  // tracked purely in local state) so a setup resumed after encryption was
  // already enabled — but the app was killed before this screen's Continue
  // was reached — shows the "already enabled" notice instead of asking for
  // a password again.
  bool? _encryptionEnabled;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final config = context.read<AppState>().config;
    _nameController = TextEditingController(text: config.userName ?? '');
    _themeMode = config.themeMode;
    _refreshEncryptionStatus();
  }

  Future<void> _refreshEncryptionStatus() async {
    final enabled =
        await context.read<AppState>().storageService.isEncryptionEnabled;
    if (mounted) setState(() => _encryptionEnabled = enabled);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final appState = context.read<AppState>();
    final name = _nameController.text.trim();
    await appState.mutateConfig(
      (current) => current.copyWith(
        userName: name.isEmpty ? null : name,
        themeMode: _themeMode,
      ),
    );

    final storageService = appState.storageService;
    final encryptionEnabled = await storageService.isEncryptionEnabled;
    final hasRecoveryKey =
        encryptionEnabled && await storageService.hasRecoveryKey;

    if (!mounted) return;

    if (encryptionEnabled && !hasRecoveryKey) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecoveryKeyScreen(
            onContinue: () async {
              await appState.mutateConfig(
                (current) => current.copyWith(hasCompletedFirstTimeSetup: true),
              );
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ),
      );
      if (mounted) setState(() => _submitting = false);
      return;
    }

    await appState.mutateConfig(
      (current) => current.copyWith(hasCompletedFirstTimeSetup: true),
    );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final encryptionEnabled = _encryptionEnabled;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(l10n.firstTimeSetupSubtitle),
              const SizedBox(height: 24),
              TextField(
                key: const Key('firstTimeSetupNameField'),
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: l10n.welcomeNameHint),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.firstTimeSetupThemeSectionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              RadioGroup<AppThemeMode>(
                groupValue: _themeMode,
                onChanged: (value) => setState(() => _themeMode = value!),
                child: Column(
                  children: [
                    for (final mode in AppThemeMode.values)
                      RadioListTile<AppThemeMode>(
                        key: Key('firstTimeSetupTheme_${mode.name}'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(themeDisplayName(mode, l10n)),
                        value: mode,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (encryptionEnabled == true)
                Padding(
                  key: const Key('firstTimeSetupEncryptionEnabledNotice'),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child:
                      Text(l10n.firstTimeSetupEncryptionAlreadyEnabledNotice),
                )
              else if (encryptionEnabled == false)
                EncryptionOptIn(
                  onEncryptionEnabled: () =>
                      setState(() => _encryptionEnabled = true),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('firstTimeSetupContinueButton'),
                  onPressed: _submitting ? null : _onContinue,
                  child: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.firstTimeSetupContinueButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
