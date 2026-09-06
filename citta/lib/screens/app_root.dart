import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'first_time_setup_screen.dart';
import 'language_selection_screen.dart';
import 'splash_screen.dart';
import 'main_shell.dart';
import 'unlock_screen.dart';

/// Root screen shown once [AppState] has been provided. Owns the app's
/// startup sequence: a loading spinner while [AppState] bootstraps, a
/// one-time first-launch language picker, the unlock screen (if encryption
/// is enabled and locked), a one-time combined first-time setup screen
/// (name, theme, encryption opt-in — issue #59), the splash screen, and
/// finally the main app shell. Every step but the splash dismissal is
/// purely reactive to [AppState.config] — there are no imperative startup
/// side effects here.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;

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

    if (!appState.config.hasCompletedLanguageSelection) {
      return const LanguageSelectionScreen();
    }

    if (appState.needsUnlock) {
      return const UnlockScreen();
    }

    if (!appState.config.hasCompletedFirstTimeSetup) {
      return const FirstTimeSetupScreen();
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
}
