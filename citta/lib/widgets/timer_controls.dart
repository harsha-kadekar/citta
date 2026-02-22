import 'package:flutter/material.dart';
import '../services/timer_service.dart';
import '../theme/app_theme.dart';

class TimerControls extends StatelessWidget {
  final TimerService timerService;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const TimerControls({
    super.key,
    required this.timerService,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final state = timerService.state;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state == TimerState.running) ...[
          // Pause button
          _CircleButton(
            icon: Icons.pause_rounded,
            color: AppColors.secondary,
            onTap: onPause,
            size: 56,
          ),
          const SizedBox(width: 32),
          // Stop button
          _CircleButton(
            icon: Icons.stop_rounded,
            color: AppColors.error,
            onTap: onStop,
            size: 56,
          ),
        ] else if (state == TimerState.paused) ...[
          // Resume button
          _CircleButton(
            icon: Icons.play_arrow_rounded,
            color: AppColors.primary,
            onTap: onResume,
            size: 56,
          ),
          const SizedBox(width: 32),
          // Stop button
          _CircleButton(
            icon: Icons.stop_rounded,
            color: AppColors.error,
            onTap: onStop,
            size: 56,
          ),
        ],
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha:0.1),
          border: Border.all(color: color.withValues(alpha:0.3), width: 2),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}
