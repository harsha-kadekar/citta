import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/l10n/intl_locale.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import '../theme/app_theme.dart';

class SessionDetailScreen extends StatelessWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeStr = safeIntlLocale(Localizations.localeOf(context).toString());
    final date = session.date.toLocal();
    final dateStr =
        '${DateFormat('MMM d, y', localeStr).format(date)} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceVariant = isDark ? DarkAppColors.surfaceVariant : AppColors.surfaceVariant;
    final textHint = isDark ? DarkAppColors.textHint : AppColors.textHint;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & time
            Text(
              dateStr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Duration card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _formatDuration(session.duration),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        session.timerMode == 'countdown'
                            ? l10n.sessionCountdown
                            : l10n.sessionStopwatch,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (session.completedFully) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle,
                            size: 16, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          l10n.sessionCompleted,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Tags
            if (session.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: session.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor:
                              colorScheme.primary.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                          ),
                        ))
                    .toList(),
              ),
            ],
            // Notes
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                l10n.sessionNotes,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: MarkdownBody(
                  data: session.notes!,
                  styleSheet: MarkdownStyleSheet(
                    p: Theme.of(context).textTheme.bodyLarge,
                    h1: Theme.of(context).textTheme.headlineMedium,
                    h2: Theme.of(context).textTheme.headlineSmall,
                    blockquoteDecoration: BoxDecoration(
                      color: surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
            if (session.notes == null || session.notes!.isEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: Text(
                  l10n.sessionNoNotes,
                  style: TextStyle(
                    color: textHint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    if (mins == 0) return '${secs}s';
    return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
  }
}
