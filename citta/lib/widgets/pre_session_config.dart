import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../models/config_model.dart';
import '../services/timer_service.dart';
import '../theme/app_theme.dart';

class PreSessionConfig extends StatelessWidget {
  final ConfigModel config;
  final TimerMode? adHocMode;
  final int? adHocDuration;
  final Function(TimerMode) onModeChanged;
  final Function(int) onDurationChanged;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  const PreSessionConfig({
    super.key,
    required this.config,
    required this.adHocMode,
    required this.adHocDuration,
    required this.onModeChanged,
    required this.onDurationChanged,
    required this.onStart,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMode = adHocMode ??
        (config.timerMode == 'stopwatch'
            ? TimerMode.stopwatch
            : TimerMode.countdown);
    final effectiveDuration = adHocDuration ?? config.countdownDuration;
    final l10n = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardShadow = isDark ? DarkAppColors.cardShadow : AppColors.cardShadow;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.preSessionSetup,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          // Mode toggle
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: l10n.homeCountdown,
                  icon: Icons.timer,
                  selected: effectiveMode == TimerMode.countdown,
                  onTap: () => onModeChanged(TimerMode.countdown),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModeButton(
                  label: l10n.homeStopwatch,
                  icon: Icons.timer_off_outlined,
                  selected: effectiveMode == TimerMode.stopwatch,
                  onTap: () => onModeChanged(TimerMode.stopwatch),
                ),
              ),
            ],
          ),
          // Duration picker (countdown only)
          if (effectiveMode == TimerMode.countdown) ...[
            const SizedBox(height: 20),
            Text(
              l10n.settingsDurationMinutes(effectiveDuration ~/ 60),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Slider(
              value: effectiveDuration.toDouble(),
              min: 60,
              max: 7200,
              divisions: 119,
              activeColor: colorScheme.primary,
              onChanged: (val) => onDurationChanged(val.round()),
            ),
          ],
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: Text(l10n.actionCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onStart,
                  child: Text(l10n.actionBegin),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceVariant = isDark ? DarkAppColors.surfaceVariant : AppColors.surfaceVariant;
    final textSecondary = isDark ? DarkAppColors.textSecondary : AppColors.textSecondary;
    final textHint = isDark ? DarkAppColors.textHint : AppColors.textHint;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? colorScheme.primary : textHint,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? colorScheme.primary : textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
