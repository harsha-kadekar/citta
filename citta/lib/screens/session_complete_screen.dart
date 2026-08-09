import 'dart:async';

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
  Timer? _autoAdvanceTimer;
  bool _hasAdvanced = false;

  @override
  void initState() {
    super.initState();
    _autoAdvanceTimer = Timer(const Duration(seconds: 3), _continue);
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _continue() {
    // Cancelling here (rather than relying on `mounted` alone) closes a race
    // where a manual tap starts the push-replacement transition but this
    // widget stays `mounted` until the transition finishes — if the
    // auto-advance timer were still pending, it could fire mid-transition
    // and push a second, duplicate NotesScreen.
    _autoAdvanceTimer?.cancel();
    // Guards against _continue() itself being re-entered a second time
    // (e.g. a double-tap on Continue) before the widget unmounts —
    // `mounted` alone doesn't catch that, since it stays true for as long
    // as this screen remains in the tree.
    if (_hasAdvanced || !mounted) return;
    _hasAdvanced = true;
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
