import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import '../models/session_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'notes_screen.dart';

class SessionCompleteScreen extends StatefulWidget {
  final SessionModel session;

  const SessionCompleteScreen({super.key, required this.session});

  @override
  State<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends State<SessionCompleteScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _continue);
  }

  void _continue() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => NotesScreen(session: widget.session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.success,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.sessionComplete,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                formatDuration(widget.session.duration),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: _continue,
                child: Text(l10n.actionContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
