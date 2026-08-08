import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'splash_screen.dart';
import 'main_shell.dart';

/// Root screen shown once [AppState] has been provided. Owns the app's
/// startup sequence: a loading spinner while [AppState] bootstraps, a
/// one-time first-launch name prompt, the splash screen, and finally the
/// main app shell.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;

  // Guards the first-launch name prompt so it fires at most once per launch.
  // Mutated only from [_maybeTriggerNamePrompt], never from build().
  bool _namePromptTriggered = false;

  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = context.read<AppState>();
    _appState.addListener(_onAppStateChanged);
    _maybeTriggerNamePrompt();
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() => _maybeTriggerNamePrompt();

  /// Decides, from the current [AppState], whether the first-launch name
  /// prompt should be shown, and schedules it if so. This is the app's
  /// only startup side effect and it never runs from build().
  void _maybeTriggerNamePrompt() {
    if (_namePromptTriggered) return;
    if (_appState.isLoading) return;
    if (_appState.config.userName != null) return;

    _namePromptTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showNamePrompt(context, _appState, AppLocalizations.of(context)!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showSplash) {
      return SplashScreen(
        quote: appState.quoteService.todayQuote,
        userName: appState.config.userName,
        onDismiss: () => setState(() => _showSplash = false),
      );
    }

    return const MainShell();
  }

  void _showNamePrompt(BuildContext context, AppState appState, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.welcomeTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.welcomeNameHint,
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionSkip),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                appState.mutateConfig(
                  (current) => current.copyWith(userName: name),
                );
              }
              Navigator.pop(context);
            },
            child: Text(l10n.actionContinue),
          ),
        ],
      ),
    );
  }
}
