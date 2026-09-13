import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_palette.dart';

/// The list of selectable color palettes for the Settings → Appearance
/// palette picker (issue #66). Mirrors [LanguagePickerOptions]'s shape:
/// [onSelected] fires with the chosen palette and the caller decides what to
/// do next (e.g. pop the dialog).
class PalettePickerOptions extends StatelessWidget {
  final void Function(AppPalette palette) onSelected;

  const PalettePickerOptions({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final current =
        AppPaletteStorage.fromStorageString(appState.config.colorPalette);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final palette in AppPalette.values)
          SimpleDialogOption(
            onPressed: () => onSelected(palette),
            child: ListTile(
              leading: _PaletteSwatch(palette: palette),
              title: Text(palette.definition.displayName),
              trailing: palette == current
                  ? Icon(Icons.check,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// A row of small color previews representing one palette's light variant,
/// so users can distinguish palettes before selecting one.
class _PaletteSwatch extends StatelessWidget {
  final AppPalette palette;

  const _PaletteSwatch({required this.palette});

  @override
  Widget build(BuildContext context) {
    final colors = palette.definition.light;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 8, backgroundColor: colors.primary),
        const SizedBox(width: 4),
        CircleAvatar(radius: 8, backgroundColor: colors.secondary),
        const SizedBox(width: 4),
        CircleAvatar(radius: 8, backgroundColor: colors.tertiary),
      ],
    );
  }
}
