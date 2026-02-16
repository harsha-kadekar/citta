import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/calendar_view.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final stats = appState.stats;
    final showCalendar = appState.config.calendarViewEnabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        actions: [
          IconButton(
            icon: Icon(
              showCalendar
                  ? Icons.calendar_month
                  : Icons.calendar_month_outlined,
              color:
                  showCalendar ? AppColors.primary : AppColors.textHint,
            ),
            onPressed: () {
              final newConfig = appState.config
                  .copyWith(calendarViewEnabled: !showCalendar);
              appState.updateConfig(newConfig);
            },
            tooltip: 'Toggle calendar view',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFFE8834A),
                    label: 'Current Streak',
                    value: '${stats.currentStreak}',
                    unit: stats.currentStreak == 1 ? 'day' : 'days',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    iconColor: AppColors.secondary,
                    label: 'Longest Streak',
                    value: '${stats.longestStreak}',
                    unit: stats.longestStreak == 1 ? 'day' : 'days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.self_improvement,
                    iconColor: AppColors.primary,
                    label: 'Total Sessions',
                    value: '${stats.totalSessions}',
                    unit: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.schedule,
                    iconColor: AppColors.accent,
                    label: 'Average',
                    value: _formatDuration(stats.averageDurationSeconds),
                    unit: '',
                  ),
                ),
              ],
            ),
            // Calendar
            if (showCalendar) ...[
              const SizedBox(height: 24),
              CalendarView(sessions: appState.sessions),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '0m';
    final mins = seconds ~/ 60;
    return '${mins}m';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
