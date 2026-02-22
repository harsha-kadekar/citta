import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'services/storage_service.dart';
import 'services/quote_service.dart';
import 'services/audio_service.dart';
import 'services/stats_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CittaApp());
}

class CittaApp extends StatelessWidget {
  const CittaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final quoteService = QuoteService(storageService);
    final audioService = AudioService();
    final statsService = StatsService();

    return ChangeNotifierProvider(
      create: (_) => AppState(
        storageService: storageService,
        quoteService: quoteService,
        audioService: audioService,
        statsService: statsService,
      )..initialize(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Citta',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: AppTheme.themeMode(appState.config.themeMode),
            home: const _AppRoot(),
          );
        },
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _showSplash = true;
  bool _hasPromptedName = false;

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

    // Prompt for name on first launch
    if (!_hasPromptedName && appState.config.userName == null) {
      _hasPromptedName = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNamePrompt(context, appState);
      });
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

  void _showNamePrompt(BuildContext context, AppState appState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to Citta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                appState.updateConfig(
                  appState.config.copyWith(userName: name),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
