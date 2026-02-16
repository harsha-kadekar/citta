import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/session_model.dart';
import '../theme/app_theme.dart';
import 'session_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Set<String> _selectedFilterTags = {};

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allTags = appState.config.tags;
    final sessions = _selectedFilterTags.isEmpty
        ? appState.sortedSessions
        : appState.filterByTags(_selectedFilterTags.toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Column(
        children: [
          // Tag filter
          if (allTags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', _selectedFilterTags.isEmpty, () {
                      setState(() => _selectedFilterTags.clear());
                    }),
                    const SizedBox(width: 8),
                    ...allTags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            tag,
                            _selectedFilterTags.contains(tag),
                            () {
                              setState(() {
                                if (_selectedFilterTags.contains(tag)) {
                                  _selectedFilterTags.remove(tag);
                                } else {
                                  _selectedFilterTags.add(tag);
                                }
                              });
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),
          // Session list
          Expanded(
            child: sessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      return _buildSessionCard(context, sessions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: AppColors.primary, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, SessionModel session) {
    final date = session.date.toLocal();
    final dateStr =
        '${_monthName(date.month)} ${date.day}, ${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final duration = _formatDuration(session.duration);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  SessionDetailScreen(session: session),
            ),
          );
        },
        title: Row(
          children: [
            Text(
              dateStr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Text(
              timeStr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(duration,
                    style: Theme.of(context).textTheme.bodyMedium),
                if (session.completedFully) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle,
                      size: 14, color: AppColors.success),
                ],
              ],
            ),
            if (session.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: session.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing:
            Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.self_improvement,
              size: 64, color: AppColors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first dhyana session\nto see it here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
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
