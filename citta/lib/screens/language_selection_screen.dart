import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import 'settings/language_picker.dart';

/// Shown once, as the very first thing on a fresh install, before any other
/// first-run UI (issue #57) — the chosen language affects the text of
/// everything shown after it. Disappears on its own once
/// [AppState.setLanguage] marks `hasCompletedLanguageSelection`, since
/// [AppRoot] rebuilds and stops returning this screen.
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                l10n.settingsLanguage,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            LanguagePickerOptions(
              onSelected: (language) => appState.setLanguage(language),
            ),
          ],
        ),
      ),
    );
  }
}
