import 'package:flutter/material.dart';
import '../theme/adaptive_colors.dart';

/// Read-only tag badge, shared by any screen that displays a session's tags.
class TagChip extends StatelessWidget {
  final String label;

  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: colorScheme.primary),
      ),
    );
  }
}

/// Toggleable tag pill, shared by any screen that lets the user pick tags
/// (filtering, or assigning tags to a session).
class SelectableTagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SelectableTagChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final adaptiveColors = context.adaptiveColors;

    return Semantics(
      label: label,
      button: true,
      selected: selected,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : adaptiveColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: selected
                      ? Border.all(color: colorScheme.primary, width: 1)
                      : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected
                        ? colorScheme.primary
                        : adaptiveColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
