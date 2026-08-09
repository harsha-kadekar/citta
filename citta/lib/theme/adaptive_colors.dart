import 'package:flutter/material.dart';
import 'app_theme.dart';

/// The subset of [AppColors]/[DarkAppColors] that has no equivalent in
/// [ColorScheme] and would otherwise need manual brightness branching at
/// every call site.
class AdaptiveColors {
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color cardShadow;
  final Color accent;

  const AdaptiveColors({
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.cardShadow,
    required this.accent,
  });

  static const light = AdaptiveColors(
    surfaceVariant: AppColors.surfaceVariant,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textHint: AppColors.textHint,
    cardShadow: AppColors.cardShadow,
    accent: AppColors.accent,
  );

  static const dark = AdaptiveColors(
    surfaceVariant: DarkAppColors.surfaceVariant,
    textPrimary: DarkAppColors.textPrimary,
    textSecondary: DarkAppColors.textSecondary,
    textHint: DarkAppColors.textHint,
    cardShadow: DarkAppColors.cardShadow,
    accent: DarkAppColors.accent,
  );
}

extension AdaptiveColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  AdaptiveColors get adaptiveColors =>
      isDarkMode ? AdaptiveColors.dark : AdaptiveColors.light;
}
