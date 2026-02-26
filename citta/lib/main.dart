import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:citta/l10n/fallback_localizations_delegate.dart';
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
            locale: appState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              FallbackMaterialLocalizationsDelegate(),
              GlobalWidgetsLocalizations.delegate,
              FallbackCupertinoLocalizationsDelegate(),
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('kn'),
              Locale('sa'),
              Locale('te'),
              Locale('ta'),
              Locale('ml'),
              Locale('fr'),
              Locale('de'),
              Locale('ja'),
              Locale('he'),
              Locale('zh'),
              Locale('mr'),
              Locale('gu'),
              Locale('or'),
              Locale('bn'),
              Locale('tcy'),
              Locale('kok'),
              Locale('ur'),
              Locale('it'),
              Locale('es'),
              Locale('ar'),
              Locale('ru'),
              Locale('pt'),
              Locale('mai'),
              Locale('as'),
              Locale('pa'),
            ],
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
    final l10n = AppLocalizations.of(context)!;

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
        _showNamePrompt(context, appState, l10n);
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
                appState.updateConfig(
                  appState.config.copyWith(userName: name),
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
