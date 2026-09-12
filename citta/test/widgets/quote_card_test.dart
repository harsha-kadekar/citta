import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/models/quote_model.dart';
import 'package:citta/theme/app_theme.dart';
import 'package:citta/widgets/quote_card.dart';

const _quote = QuoteModel(
  id: 'q1',
  source: 'Gita',
  reference: '2.47',
  originalText: 'karmanye vadhikaraste',
  translation: 'You have a right to action alone',
);

Widget _app(ThemeData theme) => MaterialApp(
      theme: theme,
      home: const Scaffold(body: QuoteCard(quote: _quote)),
    );

/// The card's own surface [Container] — distinct from the smaller divider
/// [Container] nested inside it, which has no [BoxDecoration.boxShadow].
Finder _cardContainer() => find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          (widget.decoration as BoxDecoration?)?.boxShadow != null,
    );

/// The thin divider line between the original text and its translation,
/// built with `Container(color: ...)` rather than a [BoxDecoration].
Finder _dividerContainer() => find.byWidgetPredicate(
      (widget) => widget is Container && widget.color != null,
    );

void main() {
  group('QuoteCard — light theme colors', () {
    testWidgets('card surface and shadow use the light theme colors',
        (tester) async {
      await tester.pumpWidget(_app(AppTheme.lightTheme));

      final container = tester.widget<Container>(_cardContainer());
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColors.surface,
          reason: 'card background must come from colorScheme.surface');
      expect(decoration.boxShadow!.single.color, AppColors.cardShadow,
          reason: 'card shadow must come from adaptiveColors.cardShadow');
    });

    testWidgets('text styles use the light theme colors', (tester) async {
      await tester.pumpWidget(_app(AppTheme.lightTheme));

      final original = tester.widget<Text>(find.text(_quote.originalText));
      expect(original.style?.color, AppColors.textPrimary);

      final translation = tester.widget<Text>(find.text(_quote.translation));
      expect(translation.style?.color, AppColors.textSecondary);

      final reference = tester.widget<Text>(find.text('— ${_quote.reference}'));
      expect(reference.style?.color, AppColors.textHint);
    });

    testWidgets('divider uses the light theme divider color', (tester) async {
      await tester.pumpWidget(_app(AppTheme.lightTheme));

      final divider = tester.widget<Container>(_dividerContainer());
      expect(divider.color, AppColors.divider);
    });
  });

  group('QuoteCard — dark theme colors', () {
    testWidgets('card surface and shadow adapt to the dark theme',
        (tester) async {
      await tester.pumpWidget(_app(AppTheme.darkTheme));

      final container = tester.widget<Container>(_cardContainer());
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, DarkAppColors.surface);
      expect(decoration.boxShadow!.single.color, DarkAppColors.cardShadow);
      expect(decoration.color, isNot(AppColors.surface),
          reason: 'card must not stay pinned to the light-theme literal '
              'under dark theme');
    });

    testWidgets('text styles adapt to the dark theme', (tester) async {
      await tester.pumpWidget(_app(AppTheme.darkTheme));

      final original = tester.widget<Text>(find.text(_quote.originalText));
      expect(original.style?.color, DarkAppColors.textPrimary);

      final translation = tester.widget<Text>(find.text(_quote.translation));
      expect(translation.style?.color, DarkAppColors.textSecondary);

      final reference = tester.widget<Text>(find.text('— ${_quote.reference}'));
      expect(reference.style?.color, DarkAppColors.textHint);
      expect(reference.style?.color, isNot(AppColors.textHint),
          reason: 'reference text must not stay pinned to the light-theme '
              'literal under dark theme');
    });

    testWidgets('divider adapts to the dark theme divider color',
        (tester) async {
      await tester.pumpWidget(_app(AppTheme.darkTheme));

      final divider = tester.widget<Container>(_dividerContainer());
      expect(divider.color, DarkAppColors.divider);
      expect(divider.color, isNot(AppColors.divider),
          reason: 'divider must not stay pinned to the light-theme literal '
              'under dark theme');
    });
  });
}
