import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/theme/adaptive_colors.dart';
import 'package:citta/theme/app_theme.dart';

void main() {
  group('AdaptiveColors', () {
    testWidgets('resolves to light AppColors under the light theme',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      expect(capturedContext.isDarkMode, isFalse);
      final colors = capturedContext.adaptiveColors;
      expect(colors.surfaceVariant, AppColors.surfaceVariant);
      expect(colors.textSecondary, AppColors.textSecondary);
      expect(colors.textHint, AppColors.textHint);
      expect(colors.textPrimary, AppColors.textPrimary);
      expect(colors.cardShadow, AppColors.cardShadow);
      expect(colors.accent, AppColors.accent);
    });

    testWidgets('resolves to DarkAppColors under the dark theme',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ));

      expect(capturedContext.isDarkMode, isTrue);
      final colors = capturedContext.adaptiveColors;
      expect(colors.surfaceVariant, DarkAppColors.surfaceVariant);
      expect(colors.textSecondary, DarkAppColors.textSecondary);
      expect(colors.textHint, DarkAppColors.textHint);
      expect(colors.textPrimary, DarkAppColors.textPrimary);
      expect(colors.cardShadow, DarkAppColors.cardShadow);
      expect(colors.accent, DarkAppColors.accent);
    });
  });
}
