import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/intl_locale.dart';
import '../models/session_model.dart';
import '../services/stats_service.dart';
import '../theme/app_theme.dart';

class CalendarView extends StatefulWidget {
  final List<SessionModel> sessions;
  final StatsService statsService;

  const CalendarView({
    super.key,
    required this.sessions,
    StatsService? statsService,
  }) : statsService = statsService ?? const StatsService();

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _currentMonth;
  late Map<DateTime, List<SessionModel>> _sessionsByDate;
  String _localeStr = '';
  late String _monthName;
  late List<String> _weekdayHeaders;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _sessionsByDate = widget.statsService.groupByDate(widget.sessions);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = safeIntlLocale(Localizations.localeOf(context).toString());
    if (newLocale == _localeStr) return;
    _localeStr = newLocale;
    _updateMonthName();
    _buildWeekdayHeaders();
  }

  void _updateMonthName() {
    _monthName = DateFormat('MMMM y', _localeStr)
        .format(DateTime(_currentMonth.year, _currentMonth.month));
  }

  void _buildWeekdayHeaders() {
    _weekdayHeaders = List.generate(
      7,
      (i) => DateFormat('E', _localeStr).format(DateTime(2024, 1, i + 1)),
    );
  }

  @override
  void didUpdateWidget(CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.sessions, oldWidget.sessions)) {
      _sessionsByDate = widget.statsService.groupByDate(widget.sessions);
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
      );
      _updateMonthName();
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
      );
      _updateMonthName();
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstDayWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    ).weekday; // 1 = Monday

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardShadow = isDark ? DarkAppColors.cardShadow : AppColors.cardShadow;
    final textHint = isDark ? DarkAppColors.textHint : AppColors.textHint;
    final textSecondary = isDark ? DarkAppColors.textSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              Text(
                _monthName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Day headers
          Row(
            children: _weekdayHeaders
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 12,
                            color: textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ...List.generate(6, (week) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (dayOfWeek) {
                  final dayIndex =
                      week * 7 + dayOfWeek - (firstDayWeekday - 1);
                  if (dayIndex < 1 || dayIndex > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 36));
                  }

                  final date = DateTime(
                    _currentMonth.year,
                    _currentMonth.month,
                    dayIndex,
                  );
                  final hasSession = _sessionsByDate.containsKey(date);
                  final isToday = _isToday(date);

                  return Expanded(
                    child: Container(
                      height: 36,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: hasSession
                            ? colorScheme.primary.withValues(alpha: 0.2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: colorScheme.primary, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayIndex',
                          style: TextStyle(
                            fontSize: 13,
                            color: hasSession
                                ? colorScheme.primary
                                : textSecondary,
                            fontWeight: hasSession
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
