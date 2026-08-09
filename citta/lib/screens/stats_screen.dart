import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/session_model.dart';
import '../providers/app_state.dart';
import '../services/stats_service.dart';
import '../theme/adaptive_colors.dart';
import '../utils/formatters.dart';
import '../widgets/calendar_view.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = context.select<AppState, StatsResult>((s) => s.stats);
    final showCalendar =
        context.select<AppState, bool>((s) => s.config.calendarViewEnabled);
    final sessions = context
        .select<AppState, List<SessionModel>>((s) => s.sessions);
    final colorScheme = Theme.of(context).colorScheme;
    final adaptiveColors = context.adaptiveColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsTitle),
        actions: [
          IconButton(
            icon: Icon(
              showCalendar
                  ? Icons.calendar_month
                  : Icons.calendar_month_outlined,
              color: showCalendar
                  ? colorScheme.primary
                  : adaptiveColors.textHint,
            ),
            onPressed: () {
              final appState = context.read<AppState>();
              appState.mutateConfig(
                (current) => current.copyWith(
                  calendarViewEnabled: !current.calendarViewEnabled,
                ),
              );
            },
            tooltip: l10n.statsToggleCalendar,
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
                    label: l10n.statsCurrentStreak,
                    value: '${stats.currentStreak}',
                    unit: l10n.statsDays(stats.currentStreak),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    iconColor: colorScheme.secondary,
                    label: l10n.statsLongestStreak,
                    value: '${stats.longestStreak}',
                    unit: l10n.statsDays(stats.longestStreak),
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
                    iconColor: colorScheme.primary,
                    label: l10n.statsTotalSessions,
                    value: '${stats.totalSessions}',
                    unit: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.schedule,
                    iconColor: adaptiveColors.accent,
                    label: l10n.statsAverage,
                    value: formatDuration(stats.averageDurationSeconds,
                        style: DurationDisplayStyle.compact),
                    unit: '',
                  ),
                ),
              ],
            ),
            // Calendar
            if (showCalendar) ...[
              const SizedBox(height: 24),
              CalendarView(sessions: sessions),
            ],
          ],
        ),
      ),
    );
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
    final colorScheme = Theme.of(context).colorScheme;
    final adaptiveColors = context.adaptiveColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: adaptiveColors.cardShadow,
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: adaptiveColors.textPrimary,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 13,
                    color: adaptiveColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: adaptiveColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
