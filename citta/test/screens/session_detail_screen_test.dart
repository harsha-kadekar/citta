import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/screens/session_detail_screen.dart';
import 'package:citta/theme/app_theme.dart';
import 'package:citta/widgets/tag_chip.dart';

Widget _app(SessionModel session, {ThemeData? theme}) => MaterialApp(
      theme: theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: SessionDetailScreen(session: session),
    );

SessionModel _sessionWithNotes(String notes) => SessionModel(
      id: 's-notes',
      date: DateTime.utc(2024, 6, 1, 8),
      duration: 600,
      timerMode: TimerMode.countdown,
      notes: notes,
      completedFully: true,
    );

/// The notes container is the only [Container] on screen with both a
/// [BoxDecoration.color] and a border, distinguishing it from any other
/// bordered/colored container the screen might add.
Finder _notesContainer() => find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          (widget.decoration as BoxDecoration?)?.border != null &&
          (widget.decoration as BoxDecoration?)?.color != null,
    );

// Regression test (codex review, issue #63): flutter_markdown_plus's
// MarkdownStyleSheet.fromTheme derives its horizontal-rule color from
// Theme.of(context).dividerColor directly, not from anything this screen
// sets explicitly. It exposed the same underlying bug the notes box border
// had — AppTheme never set ThemeData.dividerColor itself — one layer
// deeper, inside third-party rendering this diff doesn't otherwise touch.
Finder _horizontalRule() => find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          (widget.decoration as BoxDecoration?)?.border?.top.width == 5.0,
    );

void main() {
  testWidgets('session tags render via the shared TagChip widget',
      (tester) async {
    final session = SessionModel(
      id: 's1',
      date: DateTime.utc(2024, 6, 1, 8),
      duration: 600,
      timerMode: TimerMode.countdown,
      tags: const ['calm', 'deep'],
      completedFully: true,
    );

    await tester.pumpWidget(_app(session));
    await tester.pump();

    expect(find.byType(TagChip), findsNWidgets(2));
    expect(find.text('calm'), findsOneWidget);
    expect(find.text('deep'), findsOneWidget);
  });

  testWidgets('notes box border uses the light theme divider color',
      (tester) async {
    await tester.pumpWidget(
      _app(_sessionWithNotes('some notes'), theme: AppTheme.lightTheme()),
    );
    await tester.pump();

    final decoration = tester.widget<Container>(_notesContainer()).decoration
        as BoxDecoration;
    expect(decoration.border!.top.color, AppColors.divider);
  });

  testWidgets('notes box border adapts to the dark theme divider color',
      (tester) async {
    await tester.pumpWidget(
      _app(_sessionWithNotes('some notes'), theme: AppTheme.darkTheme()),
    );
    await tester.pump();

    final decoration = tester.widget<Container>(_notesContainer()).decoration
        as BoxDecoration;
    expect(decoration.border!.top.color, DarkAppColors.divider);
    expect(decoration.border!.top.color, isNot(AppColors.divider),
        reason: 'the notes box border must not stay pinned to the '
            'light-theme literal under dark theme');
  });

  testWidgets(
      'a markdown horizontal rule in notes uses the light theme divider '
      'color', (tester) async {
    await tester.pumpWidget(
      _app(_sessionWithNotes('---'), theme: AppTheme.lightTheme()),
    );
    await tester.pump();

    final decoration =
        tester.widget<Container>(_horizontalRule()).decoration as BoxDecoration;
    expect(decoration.border!.top.color, AppColors.divider);
  });

  testWidgets(
      'a markdown horizontal rule in notes adapts to the dark theme divider '
      'color', (tester) async {
    await tester.pumpWidget(
      _app(_sessionWithNotes('---'), theme: AppTheme.darkTheme()),
    );
    await tester.pump();

    final decoration =
        tester.widget<Container>(_horizontalRule()).decoration as BoxDecoration;
    expect(decoration.border!.top.color, DarkAppColors.divider);
    expect(decoration.border!.top.color, isNot(AppColors.divider),
        reason: 'the markdown horizontal rule must not stay pinned to the '
            'light-theme literal under dark theme');
  });
}
