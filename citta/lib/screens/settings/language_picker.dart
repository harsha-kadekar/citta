import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../theme/adaptive_colors.dart';
import '../../models/app_language.dart';

/// The list of selectable languages, shared between the Settings language
/// picker dialog and the first-launch language selection screen (issue #57).
/// [onSelected] fires with the chosen language; the caller decides what to
/// do next (e.g. pop a dialog).
class LanguagePickerOptions extends StatelessWidget {
  final void Function(AppLanguage language) onSelected;

  const LanguagePickerOptions({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final language in AppLanguage.values)
          SimpleDialogOption(
            onPressed: () => onSelected(language),
            child: ListTile(
              leading: Icon(
                  language == AppLanguage.system
                      ? Icons.language
                      : Icons.translate,
                  color: appState.config.language == language
                      ? Theme.of(context).colorScheme.primary
                      : null),
              title: Text(language == AppLanguage.system
                  ? l10n.settingsLanguageSystem
                  : language.nativeName),
              // Matches the picker's historical subtitle rule, which is
              // narrower than isLatinScript (only these three codes
              // suppress the English-name subtitle here).
              subtitle: {
                AppLanguage.system,
                AppLanguage.english,
                AppLanguage.french,
                AppLanguage.german,
              }.contains(language)
                  ? null
                  : Text(language.englishName,
                      style: TextStyle(
                          fontSize: 12, color: context.adaptiveColors.textHint)),
            ),
          ),
      ],
    );
  }
}
