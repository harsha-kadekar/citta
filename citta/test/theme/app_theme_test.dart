import 'package:flutter_test/flutter_test.dart';

import 'package:citta/theme/app_theme.dart';

void main() {
  group('AppTheme — dividerColor', () {
    // Regression test (codex review, issue #63): AppTheme only set
    // dividerTheme.color, leaving ThemeData.dividerColor itself unset. Any
    // code (ours or a third party's, e.g. flutter_markdown_plus's
    // MarkdownStyleSheet.fromTheme) that reads the more idiomatic
    // Theme.of(context).dividerColor got Material 3's fallback instead —
    // opaque black in light theme, white in dark theme — rather than the
    // intended beige/gray divider.
    test('light theme dividerColor is the light divider color', () {
      expect(AppTheme.lightTheme().dividerColor, AppColors.divider);
    });

    test('dark theme dividerColor is the dark divider color', () {
      expect(AppTheme.darkTheme().dividerColor, DarkAppColors.divider);
      expect(AppTheme.darkTheme().dividerColor, isNot(AppColors.divider));
    });
  });
}
