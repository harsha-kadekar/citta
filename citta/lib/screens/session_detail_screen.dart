import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/session_model.dart';
import '../theme/app_theme.dart';

class SessionDetailScreen extends StatelessWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final date = session.date.toLocal();
    final dateStr =
        '${_monthName(date.month)} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session'),
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
                color: AppColors.surfaceVariant,
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
                            ? 'Countdown'
                            : 'Stopwatch',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (session.completedFully) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle,
                            size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.success,
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
                          backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                          ),
                        ))
                    .toList(),
              ),
            ],
            // Notes
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: MarkdownBody(
                  data: session.notes!,
                  styleSheet: MarkdownStyleSheet(
                    p: Theme.of(context).textTheme.bodyLarge,
                    h1: Theme.of(context).textTheme.headlineMedium,
                    h2: Theme.of(context).textTheme.headlineSmall,
                    blockquoteDecoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
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
                  'No notes for this session',
                  style: TextStyle(
                    color: AppColors.textHint,
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

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
