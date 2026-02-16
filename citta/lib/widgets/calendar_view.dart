import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/stats_service.dart';
import '../theme/app_theme.dart';

class CalendarView extends StatefulWidget {
  final List<SessionModel> sessions;

  const CalendarView({super.key, required this.sessions});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _currentMonth;
  late Map<DateTime, List<SessionModel>> _sessionsByDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _sessionsByDate = StatsService().groupByDate(widget.sessions);
  }

  @override
  void didUpdateWidget(CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sessionsByDate = StatsService().groupByDate(widget.sessions);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
      );
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

    return Container(
      padding: const EdgeInsets.all(16),
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
                '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
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
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
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
                            ? AppColors.primary.withOpacity(0.2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(
                                color: AppColors.primary, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayIndex',
                          style: TextStyle(
                            fontSize: 13,
                            color: hasSession
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
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

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }
}
