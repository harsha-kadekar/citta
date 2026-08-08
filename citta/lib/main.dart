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
import 'screens/app_root.dart';

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
    const statsService = StatsService();

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
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppRoot(),
          );
        },
      ),
    );
  }
}
