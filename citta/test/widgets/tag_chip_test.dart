import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/theme/app_theme.dart';
import 'package:citta/widgets/tag_chip.dart';

Widget _app(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  group('TagChip', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(_app(const TagChip(label: 'calm')));

      expect(find.text('calm'), findsOneWidget);
    });

    testWidgets('uses the primary-tinted read-only style', (tester) async {
      await tester.pumpWidget(_app(const TagChip(label: 'calm')));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary.withValues(alpha: 0.15));

      final text = tester.widget<Text>(find.text('calm'));
      expect(text.style?.color, AppColors.primary);
    });
  });

  group('SelectableTagChip', () {
    testWidgets('renders its label and calls onTap when tapped',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(_app(SelectableTagChip(
        label: 'deep',
        selected: false,
        onTap: () => tapped = true,
      )));

      expect(find.text('deep'), findsOneWidget);
      await tester.tap(find.text('deep'));
      expect(tapped, isTrue);
    });

    testWidgets('shows a bordered, primary-tinted fill when selected',
        (tester) async {
      await tester.pumpWidget(_app(SelectableTagChip(
        label: 'deep',
        selected: true,
        onTap: () {},
      )));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary.withValues(alpha: 0.15));
      expect(decoration.border, isNotNull);
    });

    testWidgets('shows no border and a neutral fill when not selected',
        (tester) async {
      await tester.pumpWidget(_app(SelectableTagChip(
        label: 'deep',
        selected: false,
        onTap: () {},
      )));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.surfaceVariant);
      expect(decoration.border, isNull);
    });

    testWidgets('exposes button + selected semantics matching visual state',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_app(SelectableTagChip(
        label: 'deep',
        selected: true,
        onTap: () {},
      )));
      final selectedSemantics =
          tester.getSemantics(find.byType(SelectableTagChip));
      expect(selectedSemantics.label, 'deep');
      expect(selectedSemantics.flagsCollection.isButton, isTrue);
      expect(selectedSemantics.flagsCollection.isSelected, Tristate.isTrue);

      await tester.pumpWidget(_app(SelectableTagChip(
        label: 'deep',
        selected: false,
        onTap: () {},
      )));
      final unselectedSemantics =
          tester.getSemantics(find.byType(SelectableTagChip));
      expect(
          unselectedSemantics.flagsCollection.isSelected, Tristate.isFalse,
          reason:
              'unselected chips must not announce as selected to screen readers');

      handle.dispose();
    });

    testWidgets(
        'activates via keyboard Enter once focused, like FilterChip did',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(_app(SelectableTagChip(
        label: 'deep',
        selected: false,
        onTap: () => tapped = true,
      )));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(tapped, isTrue,
          reason:
              'desktop/web keyboard users must be able to select a tag without a pointer');
    });

    testWidgets('meets the minimum 48x48 touch target size', (tester) async {
      await tester.pumpWidget(_app(SelectableTagChip(
        label: 'deep',
        selected: false,
        onTap: () {},
      )));

      final size = tester.getSize(find.byType(SelectableTagChip));
      expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension),
          reason: 'a short tag label must not shrink the tap target below 48dp');
    });
  });
}
