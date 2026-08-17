import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the unwrapped master key across app launches so a user who has
/// already unlocked once on this device isn't re-prompted for their
/// password on every access. Implementations are the only place the raw
/// key bytes are allowed to leave memory for storage — never into
/// `config.json`, `sessions.json`, or any other file [StorageService]
/// manages.
abstract class SecureKeyCache {
  /// Persists [key] so a later [read] call (e.g. on the next app launch)
  /// can restore it without a password prompt. Overwrites any previously
  /// cached key.
  Future<void> save(SecretKey key);

  /// Returns the previously [save]d key, or null if none is cached (never
  /// saved, or [clear] was called since).
  Future<SecretKey?> read();

  /// Removes any cached key. Idempotent — safe to call when nothing is
  /// cached.
  Future<void> clear();
}

/// [SecureKeyCache] backed by the OS secure keystore (Android Keystore /
/// iOS Keychain / etc) via `flutter_secure_storage`.
class SecureStorageKeyCache implements SecureKeyCache {
  SecureStorageKeyCache({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _masterKeyStorageKey = 'citta_master_key';

  @override
  Future<void> save(SecretKey key) async {
    final bytes = await key.extractBytes();
    await _storage.write(
      key: _masterKeyStorageKey,
      value: base64Encode(bytes),
    );
  }

  @override
  Future<SecretKey?> read() async {
    final value = await _storage.read(key: _masterKeyStorageKey);
    if (value == null) return null;
    return SecretKey(base64Decode(value));
  }

  @override
  Future<void> clear() => _storage.delete(key: _masterKeyStorageKey);
}

/// An in-memory [SecureKeyCache] that never touches a platform channel.
/// Used as [StorageService.withBasePath]'s default so unit tests exercise
/// caching behavior without needing a mocked secure-storage channel;
/// production code (via [StorageService]'s default constructor) always
/// uses [SecureStorageKeyCache].
class InMemoryKeyCache implements SecureKeyCache {
  SecretKey? _key;

  @override
  Future<void> save(SecretKey key) async => _key = key;

  @override
  Future<SecretKey?> read() async => _key;

  @override
  Future<void> clear() async => _key = null;
}
