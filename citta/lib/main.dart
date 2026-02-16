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
      child: MaterialApp(
        title: 'Citta',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppRoot(),
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
        onDismiss: () => setState(() => _showSplash = false),
      );
    }

    return const MainShell();
  }
}
