import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/app_bootstrapper.dart';
import 'package:citta/providers/session_recovery_service.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/crypto_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/secure_key_cache.dart';
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

  group('master key auto-unlock (issue #50)', () {
    late Directory tmpDir;

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('citta_bootstrapper_autounlock_test_');
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('loads sessions without a password prompt when a master key is '
        'cached from a prior unlock — simulating an app restart', () async {
      final sharedCache = InMemoryKeyCache();
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        ),
        secureKeyCache: sharedCache,
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');
      await setupStorage.saveSessions([
        SessionModel(
          id: 's1',
          date: DateTime.utc(2024, 6, 1),
          duration: 300,
          timerMode: TimerMode.countdown,
        ),
      ]);

      final freshStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        ),
        secureKeyCache: sharedCache,
      );
      const bootstrapper =
          AppBootstrapper(sessionRecoveryService: SessionRecoveryService());

      final result = await bootstrapper.run(
        storageService: freshStorage,
        quoteService: QuoteService(freshStorage),
        audioService: _fakeAudioService(),
      );

      expect(freshStorage.isUnlocked, true);
      expect(result.sessions.map((s) => s.id), ['s1']);
    });

    test('reports needsUnlock instead of throwing when encryption is '
        'enabled but nothing is cached — the caller (AppState/AppRoot) '
        'shows UnlockScreen rather than crashing on a locked read',
        () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        ),
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');
      await setupStorage.saveSessions([
        SessionModel(
          id: 's1',
          date: DateTime.utc(2024, 6, 1),
          duration: 300,
          timerMode: TimerMode.countdown,
        ),
      ]);

      final freshStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        ),
        secureKeyCache: InMemoryKeyCache(),
      );
      const bootstrapper =
          AppBootstrapper(sessionRecoveryService: SessionRecoveryService());

      final result = await bootstrapper.run(
        storageService: freshStorage,
        quoteService: QuoteService(freshStorage),
        audioService: _fakeAudioService(),
      );

      expect(result.needsUnlock, true);
      expect(result.sessions, isEmpty,
          reason: 'encrypted sessions must not be read while locked');
      expect(freshStorage.isUnlocked, false);
    });

    test('needsUnlock is false once a cached key auto-unlocks', () async {
      final sharedCache = InMemoryKeyCache();
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        ),
        secureKeyCache: sharedCache,
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');

      final freshStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        ),
        secureKeyCache: sharedCache,
      );
      const bootstrapper =
          AppBootstrapper(sessionRecoveryService: SessionRecoveryService());

      final result = await bootstrapper.run(
        storageService: freshStorage,
        quoteService: QuoteService(freshStorage),
        audioService: _fakeAudioService(),
      );

      expect(result.needsUnlock, false);
    });

    test('needsUnlock is false when encryption was never enabled', () async {
      final storage = StorageService.withBasePath(tmpDir.path);
      const bootstrapper =
          AppBootstrapper(sessionRecoveryService: SessionRecoveryService());

      final result = await bootstrapper.run(
        storageService: storage,
        quoteService: QuoteService(storage),
        audioService: _fakeAudioService(),
      );

      expect(result.needsUnlock, false);
    });

    test('loadUnlockedSessions loads and recovers sessions once the '
        'caller has unlocked the instance', () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        ),
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');
      await setupStorage.saveSessions([
        SessionModel(
          id: 's1',
          date: DateTime.utc(2024, 6, 1),
          duration: 300,
          timerMode: TimerMode.countdown,
        ),
      ]);
      await setupStorage.saveInProgressSession(
        id: 'recovered',
        startDate: DateTime.utc(2024, 6, 2),
        elapsedSeconds: 45,
        timerMode: TimerMode.countdown.toStorageString(),
        targetDuration: 900,
      );

      final freshStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        ),
      );
      final unlocked = await freshStorage
          .unlockWithPassword('correct horse battery staple');
      expect(unlocked, true);

      const bootstrapper =
          AppBootstrapper(sessionRecoveryService: SessionRecoveryService());
      final sessions = await bootstrapper.loadUnlockedSessions(freshStorage);

      expect(sessions.map((s) => s.id), containsAll(['s1', 'recovered']));
      expect(await freshStorage.loadInProgressSession(), isNull);
    });
  });
}
