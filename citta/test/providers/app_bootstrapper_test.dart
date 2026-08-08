import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/app_bootstrapper.dart';
import 'package:citta/providers/session_recovery_service.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/storage_service.dart';
import 'package:just_audio/just_audio.dart';

class _FakeAudioPlayer implements AudioPlayerBase {
  @override Future<void> setAsset(String path) async {}
  @override Future<void> setFilePath(String path) async {}
  @override Future<void> setLoopMode(LoopMode mode) async {}
  @override Future<void> setVolume(double volume) async {}
  @override Future<void> seek(Duration position) async {}
  @override Future<void> play() async {}
  @override Future<void> pause() async {}
  @override Future<void> stop() async {}
  @override Future<void> dispose() async {}
}

class _FakeAudioSession implements AudioSessionBase {
  @override Future<void> configure(AudioSessionConfiguration _) async {}
  @override Stream<AudioInterruptionEvent> get interruptionEventStream =>
      const Stream.empty();
}

AudioService _fakeAudioService() => AudioService.withPlayers(
      bellPlayer: _FakeAudioPlayer(),
      musicPlayer: _FakeAudioPlayer(),
      sessionFactory: () async => _FakeAudioSession(),
    );

class _RecordingRecoveryService implements SessionRecoveryService {
  List<SessionModel>? seenExisting;
  final List<SessionModel> Function(List<SessionModel> existing)? onRecover;
  final Object? throwing;

  _RecordingRecoveryService({this.onRecover, this.throwing});

  @override
  Future<List<SessionModel>> recover(
    StorageService storageService,
    List<SessionModel> existingSessions,
  ) async {
    seenExisting = existingSessions;
    if (throwing != null) throw throwing!;
    return onRecover?.call(existingSessions) ?? existingSessions;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppBootstrapper', () {
    late Directory tmpDir;
    late StorageService storage;

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('citta_bootstrapper_test_');
      storage = StorageService.withBasePath(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('loads config and sessions from storage', () async {
      await storage.saveConfig(ConfigModel(userName: 'harsha'));
      await storage.saveSessions([
        SessionModel(
          id: 's1',
          date: DateTime.utc(2024, 6, 1),
          duration: 300,
          timerMode: TimerMode.countdown,
        ),
      ]);
      const bootstrapper =
          AppBootstrapper(sessionRecoveryService: SessionRecoveryService());

      final result = await bootstrapper.run(
        storageService: storage,
        quoteService: QuoteService(storage),
        audioService: _fakeAudioService(),
      );

      expect(result.config.userName, 'harsha');
      expect(result.sessions.map((s) => s.id), ['s1']);
    });

    test('delegates recovery to the session recovery service with the loaded sessions',
        () async {
      await storage.saveSessions([
        SessionModel(
          id: 's1',
          date: DateTime.utc(2024, 6, 1),
          duration: 300,
          timerMode: TimerMode.countdown,
        ),
      ]);
      final recovered = SessionModel(
        id: 'recovered',
        date: DateTime.utc(2024, 6, 2),
        duration: 60,
        timerMode: TimerMode.countdown,
        completedFully: false,
      );
      final recovery = _RecordingRecoveryService(
        onRecover: (existing) => [...existing, recovered],
      );
      final bootstrapper = AppBootstrapper(sessionRecoveryService: recovery);

      final result = await bootstrapper.run(
        storageService: storage,
        quoteService: QuoteService(storage),
        audioService: _fakeAudioService(),
      );

      expect(recovery.seenExisting?.map((s) => s.id), ['s1']);
      expect(result.sessions.map((s) => s.id), ['s1', 'recovered']);
    });

    test('a recovery failure is swallowed and clears the in-progress marker as a fallback',
        () async {
      await storage.saveInProgressSession(
        id: 'stuck',
        startDate: DateTime.utc(2024, 6, 1),
        elapsedSeconds: 30,
        timerMode: TimerMode.countdown.toStorageString(),
        targetDuration: 900,
      );
      final recovery = _RecordingRecoveryService(throwing: Exception('boom'));
      final bootstrapper = AppBootstrapper(sessionRecoveryService: recovery);

      final result = await bootstrapper.run(
        storageService: storage,
        quoteService: QuoteService(storage),
        audioService: _fakeAudioService(),
      );

      expect(result.sessions, isEmpty,
          reason: 'a failed recovery must not throw out of run()');
      expect(await storage.loadInProgressSession(), isNull,
          reason: 'the fallback cleanup must still clear the stuck marker');
    });
  });
}
