import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/app_state.dart';
import 'package:citta/services/audio_service.dart';
import 'package:citta/services/crypto_service.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/secure_key_cache.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';
import 'package:just_audio/just_audio.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Argon2id cost params for tests only: fast, not secure.
CryptoService _testCryptoService() => CryptoService(
      argon2Parallelism: 1,
      argon2MemoryKiB: 8,
      argon2Iterations: 1,
    );

// IMPORTANT: call only from setUp(), never inside test() — real async I/O
// does not complete under fakeAsync.
Future<AppState> _makeAndInit(
  String basePath, {
  SecureKeyCache? secureKeyCache,
}) async {
  final storage = StorageService.withBasePath(
    basePath,
    cryptoService: _testCryptoService(),
    secureKeyCache: secureKeyCache,
  );
  final appState = AppState(
    storageService: storage,
    quoteService: QuoteService(storage),
    audioService: AudioService.withPlayers(
      bellPlayer: _FakeAudioPlayer(),
      musicPlayer: _FakeAudioPlayer(),
      sessionFactory: () async => _FakeAudioSession(),
    ),
    statsService: const StatsService(),
  );
  await appState.initialize();
  return appState;
}

const _kTestPassword = 'correct horse battery staple';

SessionModel _session(String id) => SessionModel(
      id: id,
      date: DateTime.utc(2024, 6, 1),
      duration: 300,
      timerMode: TimerMode.countdown,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppState.needsUnlock / unlock (issue #53)', () {
    late Directory tmpDir;

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('citta_unlock_test_');
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('needsUnlock is false when encryption was never enabled', () async {
      final appState = await _makeAndInit(tmpDir.path);
      expect(appState.needsUnlock, isFalse);
    });

    test('needsUnlock is true after startup when encryption is enabled and '
        'nothing is cached', () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');
      await setupStorage.saveSessions([_session('s1')]);

      final appState = await _makeAndInit(tmpDir.path);

      expect(appState.needsUnlock, isTrue);
      expect(appState.sessions, isEmpty,
          reason: 'encrypted sessions must not be exposed while locked');
    });

    test('unlockWithPassword("correct password") clears needsUnlock and '
        'loads the previously-inaccessible sessions', () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');
      await setupStorage.saveSessions([_session('s1')]);

      final appState = await _makeAndInit(tmpDir.path);
      expect(appState.needsUnlock, isTrue);

      final result =
          await appState.unlockWithPassword('correct horse battery staple');

      expect(result, isTrue);
      expect(appState.needsUnlock, isFalse);
      expect(appState.sessions.map((s) => s.id), ['s1']);
    });

    test('unlockWithPassword with the wrong password returns false and '
        'leaves needsUnlock set', () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');

      final appState = await _makeAndInit(tmpDir.path);
      final result = await appState.unlockWithPassword('wrong password');

      expect(result, isFalse);
      expect(appState.needsUnlock, isTrue);
      expect(appState.sessions, isEmpty);
    });

    test('unlockWithRecoveryKey with the correct recovery key clears '
        'needsUnlock and loads sessions', () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');
      final pending = await setupStorage.prepareRecoveryKey();
      await setupStorage.commitRecoveryKey(pending);
      await setupStorage.saveSessions([_session('s1')]);

      final appState = await _makeAndInit(tmpDir.path);
      final result =
          await appState.unlockWithRecoveryKey(pending.recoveryKey);

      expect(result, isTrue);
      expect(appState.needsUnlock, isFalse);
      expect(appState.sessions.map((s) => s.id), ['s1']);
    });

    test('unlockWithRecoveryKey with the wrong recovery key returns false '
        'and leaves needsUnlock set', () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: 'correct horse battery staple');
      final pending = await setupStorage.prepareRecoveryKey();
      await setupStorage.commitRecoveryKey(pending);

      final appState = await _makeAndInit(tmpDir.path);
      final result = await appState
          .unlockWithRecoveryKey('WRNG-WRNG-WRNG-WRNG-WRNG-WRNG-WRNG-WRNG');

      expect(result, isFalse);
      expect(appState.needsUnlock, isTrue);
    });
  });

  group('AppState.unlockWithPasswordOrRecoveryKey (issue #53 review)',
      () {
    late Directory tmpDir;

    setUp(() {
      tmpDir =
          Directory.systemTemp.createTempSync('citta_unlock_either_test_');
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('the correct password unlocks', () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: _kTestPassword);
      await setupStorage.saveSessions([_session('s1')]);

      final appState = await _makeAndInit(tmpDir.path);
      final result =
          await appState.unlockWithPasswordOrRecoveryKey(_kTestPassword);

      expect(result, isTrue);
      expect(appState.needsUnlock, isFalse);
      expect(appState.sessions.map((s) => s.id), ['s1']);
    });

    test(
        'a recovery key typed in lowercase with stray whitespace still '
        'unlocks, even though the password attempt tried it first and '
        'failed', () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: _kTestPassword);
      final pending = await setupStorage.prepareRecoveryKey();
      await setupStorage.commitRecoveryKey(pending);
      await setupStorage.saveSessions([_session('s1')]);

      final appState = await _makeAndInit(tmpDir.path);
      final mistyped = '  ${pending.recoveryKey.toLowerCase()}  ';
      final result = await appState.unlockWithPasswordOrRecoveryKey(mistyped);

      expect(result, isTrue,
          reason: 'the recovery-key attempt must normalize case and '
              'whitespace before deriving, since the key was generated in '
              'an all-uppercase alphabet specifically for manual '
              'transcription');
      expect(appState.needsUnlock, isFalse);
      expect(appState.sessions.map((s) => s.id), ['s1']);
    });

    test('a password is tried exactly as typed — whitespace is not '
        'stripped from the password attempt', () async {
      const spacedPassword = ' correct horse battery staple ';
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: spacedPassword);

      final appState = await _makeAndInit(tmpDir.path);

      expect(
        await appState.unlockWithPasswordOrRecoveryKey(spacedPassword.trim()),
        isFalse,
        reason: 'trimming the password attempt would incorrectly accept a '
            'password that differs from the one actually set',
      );
      expect(
        await appState.unlockWithPasswordOrRecoveryKey(spacedPassword),
        isTrue,
      );
    });

    test('neither a wrong password nor a wrong recovery key unlocks',
        () async {
      final setupStorage = StorageService.withBasePath(
        tmpDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupStorage.enableEncryption(password: _kTestPassword);

      final appState = await _makeAndInit(tmpDir.path);
      final result =
          await appState.unlockWithPasswordOrRecoveryKey('nope nope nope');

      expect(result, isFalse);
      expect(appState.needsUnlock, isTrue);
    });
  });
}
