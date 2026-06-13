import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class TagsSection extends StatelessWidget {
  const TagsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...appState.config.tags.map((tag) => Chip(
                label: Text(tag),
                onDeleted: () => appState.removeTag(tag),
                deleteIconColor: AppColors.textHint,
              )),
          ActionChip(
            label: Text(l10n.settingsAddTag),
            onPressed: () => _showAddTagDialog(context, appState, l10n),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog(
      BuildContext context, AppState appState, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsAddTagTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.settingsAddTagHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = controller.text.trim().toLowerCase();
              if (tag.isNotEmpty) appState.addTag(tag);
              Navigator.pop(context);
            },
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
  }
}
