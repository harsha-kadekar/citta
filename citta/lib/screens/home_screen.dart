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
import '../models/audio_source.dart';

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
  // How often (in elapsed seconds) an active session is checkpointed to
  // disk, so a crash mid-session loses at most this much progress without
  // needing the app to be backgrounded first.
  static const _checkpointIntervalSeconds = 30;

  late TimerService _timerService;
  bool _showPreSessionConfig = false;
  // Ad-hoc overrides (null means use config default)
  TimerMode? _adHocMode;
  int? _adHocDuration;
  // Set when a session starts; used to write the in-progress marker.
  String? _sessionId;
  DateTime? _sessionStartDate;
  // Serializes marker file saves/clears so overlapping fire-and-forget calls
  // (start, pause, resume, background, periodic checkpoint) can't interleave
  // their multi-step atomic writes on the same file and let a stale write
  // clobber a fresher one.
  Future<void> _markerOpChain = Future.value();
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
      if (mounted) unawaited(_onSessionComplete(completedFully: true));
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
    _timerService.onTick = () {
      if (_timerService.elapsedSeconds % _checkpointIntervalSeconds == 0) {
        unawaited(_saveInProgressMarker());
      }
    };
  }

  Future<void> _playBell(AudioSource bellId) async {
    final appState = context.read<AppState>();
    await appState.audioService.playBell(bellId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_timerService.state == TimerState.running) {
        _timerService.pause();
      }
      // Fire-and-forget real disk I/O — a test asserting on its completion
      // must poll the marker file (see _waitForMarker in home_screen_test.dart)
      // rather than relying on tester.pump(), which can't drive real I/O.
      unawaited(_saveInProgressMarker());
    }
  }

  void _startSession() {
    final appState = context.read<AppState>();
    final config = appState.config;

    final mode = _adHocMode ?? config.timerMode;
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

    // Fire-and-forget real disk I/O — a test asserting on its completion
    // must poll the marker file (see _waitForMarker in home_screen_test.dart)
    // rather than relying on tester.pump(), which can't drive real I/O.
    unawaited(_saveInProgressMarker());
  }

  Future<void> _saveInProgressMarker() {
    if (_sessionId == null || !mounted) return Future.value();
    try {
      // Snapshot state now, not when the queued write eventually runs, so a
      // save enqueued at pause-time can't pick up seconds ticked after it.
      final appState = context.read<AppState>();
      final id = _sessionId!;
      final startDate = _sessionStartDate!;
      final elapsedSeconds = _timerService.elapsedSeconds;
      final timerMode = _timerService.mode;
      final targetDuration = _timerService.targetDuration;
      return _enqueueMarkerOp(() async {
        try {
          await appState.saveInProgressSession(
            id: id,
            startDate: startDate,
            elapsedSeconds: elapsedSeconds,
            timerMode: timerMode,
            targetDuration: targetDuration,
          );
        } catch (_) {
          // clearInProgressSession handles any partial writes from a failed save
        }
      });
    } catch (_) {
      return Future.value();
    }
  }

  Future<void> _enqueueMarkerOp(Future<void> Function() op) {
    final chained = _markerOpChain.then((_) => op());
    // Reset regardless of success/failure so one failing op (e.g. a clear
    // that throws) can't permanently poison every later enqueue — mirrors
    // AudioService._queueBellOp's handling of the same hazard.
    _markerOpChain = chained.then((_) {}, onError: (_) {});
    return chained;
  }

  Future<void> _onSessionComplete({required bool completedFully}) async {
    // Guard against reentrancy (e.g. natural completion and a manual stop
    // firing close together): the second call becomes a no-op instead of a
    // null-check throw, which — now that this method is async and invoked
    // via unawaited() — would otherwise surface as an unhandled Future
    // rejection rather than a loud synchronous crash.
    if (_sessionId == null) return;

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

    final session = SessionModel(
      id: sessionId,
      date: DateTime.now(),
      duration: _timerService.elapsedSeconds,
      timerMode: _timerService.mode,
      completedFully: completedFully,
    );

    // Push immediately so the UI transition isn't delayed by the marker
    // clear below; only the clear itself needs to be awaited so it can't
    // outlive this method as a dangling, unobservable write.
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SessionCompleteScreen(session: session),
        ),
      ).then((_) {
        _timerService.reset();
        _adHocMode = null;
        _adHocDuration = null;
        setState(() {});
      }),
    );

    try {
      // Routed through the same marker-op chain as saves, so a checkpoint
      // enqueued just before completion can't run after the clear and
      // resurrect the marker for a session that's already been recorded.
      await _enqueueMarkerOp(appState.clearInProgressSession);
    } catch (_) {
      // Best-effort: StorageService.recoverIfNeeded does NOT repair a marker
      // left behind by a failed delete here (it only repairs a missing main
      // file via a dangling .tmp/.bak). The real protection against a stale
      // marker resurrecting a duplicate session on next launch is the id-dedup
      // check in AppState._recoverInterruptedSession.
    }
  }

  void _pauseSession() {
    _timerService.pause();
    HapticFeedback.lightImpact();
    // Pausing is a meaningful transition worth checkpointing immediately,
    // rather than waiting for the periodic on-tick cadence (which doesn't
    // fire while paused) or the app being backgrounded.
    unawaited(_saveInProgressMarker());
  }

  void _resumeSession() {
    _timerService.resume();
    HapticFeedback.lightImpact();
    unawaited(_saveInProgressMarker());
  }

  void _stopSession() {
    _timerService.stop();
    HapticFeedback.mediumImpact();
    // Stopwatch sessions are always complete (no fixed target to miss).
    // Countdown sessions stopped early are incomplete.
    unawaited(_onSessionComplete(
      completedFully: _timerService.mode == TimerMode.stopwatch,
    ));
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
        context.select<AppState, TimerMode>((s) => s.config.timerMode);
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
                      onPause: _pauseSession,
                      onResume: _resumeSession,
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
      TimerMode timerMode, int countdownDuration, AppLocalizations l10n) {
    final mode = timerMode == TimerMode.stopwatch
        ? l10n.homeStopwatch
        : l10n.homeCountdown;
    if (timerMode == TimerMode.stopwatch) return mode;
    final mins = countdownDuration ~/ 60;
    return '$mode \u00b7 $mins ${l10n.homeMin}';
  }
}
