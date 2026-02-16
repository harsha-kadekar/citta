import 'package:flutter/material.dart';
import '../services/timer_service.dart';
import '../theme/app_theme.dart';

class TimerDisplay extends StatelessWidget {
  final TimerService timerService;

  const TimerDisplay({super.key, required this.timerService});

  @override
  Widget build(BuildContext context) {
    final isCountdown = timerService.mode == TimerMode.countdown;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular progress (for countdown only)
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isCountdown)
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: 1.0 - timerService.progress,
                    strokeWidth: 4,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timerService.state == TimerState.paused
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                  ),
                ),
              if (!isCountdown)
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: timerService.state == TimerState.paused
                          ? AppColors.secondary.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.3),
                      width: 4,
                    ),
                  ),
                ),
              // Time text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timerService.displayTime,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textPrimary,
                      letterSpacing: 2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (timerService.state == TimerState.paused)
                    const Text(
                      'PAUSED',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
