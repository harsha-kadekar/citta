import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/quote_model.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/app_state.dart';
import '../services/timer_service.dart';
import '../models/session_model.dart';
import '../theme/app_theme.dart';
import '../widgets/quote_card.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_controls.dart';
import '../widgets/pre_session_config.dart';
import 'session_complete_screen.dart';
import 'package:uuid/uuid.dart';

const _cittaTitles = [
  'Citta',       // English
  'चित्त',       // Sanskrit / Hindi
  'ಚಿತ್ತ',       // Kannada
  'சித்த',       // Tamil
  'చిత్త',       // Telugu
  'ചിത്ത',       // Malayalam
];

class HomeScreen extends StatefulWidget {
  final int visitCount;
  const HomeScreen({super.key, this.visitCount = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late TimerService _timerService;
  bool _showPreSessionConfig = false;
  // Ad-hoc overrides (null means use config default)
  TimerMode? _adHocMode;
  int? _adHocDuration;
  // Set when a session starts; used to write the in-progress marker.
  String? _sessionId;
  DateTime? _sessionStartDate;
  String get _title => _cittaTitles[widget.visitCount % _cittaTitles.length];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timerService = TimerService();
    _setupTimerCallbacks();
  }

  void _setupTimerCallbacks() {
    final appState = context.read<AppState>();
    _timerService.onComplete = () {
      HapticFeedback.heavyImpact();
      if (mounted) _onSessionComplete(completedFully: true);
    };
    _timerService.onIntervalBell = () {
      _playBell(appState.config.bellInterval);
    };
    _timerService.onStart = () {
      _playBell(appState.config.bellStart);
      if (appState.config.backgroundMusic != null) {
        appState.audioService
            .startBackgroundMusic(appState.config.backgroundMusic!);
      }
    };
  }

  Future<void> _playBell(String bellId) async {
    final appState = context.read<AppState>();
    await appState.audioService.playBell(bellId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_timerService.state == TimerState.running) {
        _timerService.pause();
      }
      unawaited(_saveInProgressMarker());
    }
  }

  void _startSession() {
    final appState = context.read<AppState>();
    final config = appState.config;

    final mode = _adHocMode ??
        (config.timerMode == 'stopwatch'
            ? TimerMode.stopwatch
            : TimerMode.countdown);
    final duration = _adHocDuration ?? config.countdownDuration;

    _timerService.configure(
      mode: mode,
      targetDuration: duration,
      intervalDuration: config.intervalDuration,
      intervalEnabled: config.intervalEnabled,
    );

    _sessionId = const Uuid().v4();
    _sessionStartDate = DateTime.now();

    _setupTimerCallbacks();
    _timerService.start();
    WakelockPlus.enable().catchError(
      (Object _) {},
      test: (e) => e is PlatformException,
    );
    HapticFeedback.mediumImpact();
    setState(() {
      _showPreSessionConfig = false;
    });

    unawaited(_saveInProgressMarker());
  }

  Future<void> _saveInProgressMarker() async {
    if (_sessionId == null || !mounted) return;
    try {
      await context.read<AppState>().saveInProgressSession(
        id: _sessionId!,
        startDate: _sessionStartDate!,
        elapsedSeconds: _timerService.elapsedSeconds,
        timerMode: _timerService.mode == TimerMode.countdown
            ? 'countdown'
            : 'stopwatch',
        targetDuration: _timerService.targetDuration,
      );
    } catch (_) {
      // clearInProgressSession handles any partial writes from a failed save
    }
  }

  void _onSessionComplete({required bool completedFully}) {
    // Capture and null immediately so no new marker saves start after this point.
    final sessionId = _sessionId!;
    _sessionId = null;
    _sessionStartDate = null;

    WakelockPlus.disable().catchError(
      (Object _) {},
      test: (e) => e is PlatformException,
    );
    final appState = context.read<AppState>();
    appState.audioService.stopBackgroundMusic();
    _playBell(appState.config.bellEnd);
    appState.clearInProgressSession();

    final session = SessionModel(
      id: sessionId,
      date: DateTime.now(),
      duration: _timerService.elapsedSeconds,
      timerMode: _timerService.mode == TimerMode.countdown
          ? 'countdown'
          : 'stopwatch',
      completedFully: completedFully,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SessionCompleteScreen(session: session),
      ),
    ).then((_) {
      _timerService.reset();
      _adHocMode = null;
      _adHocDuration = null;
      setState(() {});
    });
  }

  void _stopSession() {
    _timerService.stop();
    HapticFeedback.mediumImpact();
    // Stopwatch sessions are always complete (no fixed target to miss).
    // Countdown sessions stopped early are incomplete.
    _onSessionComplete(
      completedFully: _timerService.mode == TimerMode.stopwatch,
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable().catchError(
      (Object _) {},
      test: (e) => e is PlatformException,
    );
    WidgetsBinding.instance.removeObserver(this);
    _timerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quote =
        context.select<AppState, QuoteModel?>((s) => s.quoteService.todayQuote);
    final timerMode =
        context.select<AppState, String>((s) => s.config.timerMode);
    final countdownDuration =
        context.select<AppState, int>((s) => s.config.countdownDuration);
    final isSessionActive = _timerService.state == TimerState.running ||
        _timerService.state == TimerState.paused;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _timerService,
        builder: (context, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Quote card (hidden during session), aligned to the bottom
                  // of the top flex section. SingleChildScrollView clips the
                  // card on narrow-height viewports without a layout error.
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      physics: const NeverScrollableScrollPhysics(),
                      child: !isSessionActive && quote != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 16),
                              child: QuoteCard(quote: quote),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  // Timer display
                  if (isSessionActive ||
                      _timerService.state == TimerState.completed) ...[
                    TimerDisplay(timerService: _timerService),
                    const SizedBox(height: 40),
                    TimerControls(
                      timerService: _timerService,
                      onPause: () {
                        _timerService.pause();
                        HapticFeedback.lightImpact();
                      },
                      onResume: () {
                        _timerService.resume();
                        HapticFeedback.lightImpact();
                      },
                      onStop: _stopSession,
                    ),
                  ] else ...[
                    // Idle state — show start button
                    if (_showPreSessionConfig)
                      PreSessionConfig(
                        // PreSessionConfig is only visible after setState, so
                        // reading a snapshot here is always fresh enough.
                        config: context.read<AppState>().config,
                        adHocMode: _adHocMode,
                        adHocDuration: _adHocDuration,
                        onModeChanged: (mode) =>
                            setState(() => _adHocMode = mode),
                        onDurationChanged: (dur) =>
                            setState(() => _adHocDuration = dur),
                        onStart: _startSession,
                        onCancel: () =>
                            setState(() => _showPreSessionConfig = false),
                      )
                    else ...[
                      _buildStartButton(l10n),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showPreSessionConfig = true),
                        icon: const Icon(
                          Icons.tune,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        label: Text(
                          _getConfigSummary(timerMode, countdownDuration, l10n),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _startSession,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            l10n.homeBegin,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  String _getConfigSummary(
      String timerMode, int countdownDuration, AppLocalizations l10n) {
    final mode =
        timerMode == 'stopwatch' ? l10n.homeStopwatch : l10n.homeCountdown;
    if (timerMode == 'stopwatch') return mode;
    final mins = countdownDuration ~/ 60;
    return '$mode \u00b7 $mins ${l10n.homeMin}';
  }
}
