import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/services/secure_key_cache.dart';

/// An in-memory fake of the `flutter_secure_storage` platform channel, so
/// [SecureStorageKeyCache] can be exercised without a real OS keystore.
class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> store = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    store[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async =>
      store[key];

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async =>
      store.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async =>
      Map.of(store);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    store.clear();
  }
}

void main() {
  late _FakeSecureStoragePlatform fakePlatform;
  late SecureStorageKeyCache cache;

  setUp(() {
    fakePlatform = _FakeSecureStoragePlatform();
    FlutterSecureStoragePlatform.instance = fakePlatform;
    cache = SecureStorageKeyCache();
  });

  group('SecureStorageKeyCache', () {
    test('read returns null when nothing has been saved', () async {
      expect(await cache.read(), isNull);
    });

    test('save then read round-trips the same key bytes', () async {
      final key = SecretKey(List<int>.generate(32, (i) => i));

      await cache.save(key);
      final restored = await cache.read();

      expect(restored, isNotNull);
      expect(await restored!.extractBytes(), await key.extractBytes());
    });

    test('save never writes the raw key bytes in plaintext — only the '
        'base64 encoding reaches the platform store', () async {
      final key = SecretKey(List<int>.generate(32, (i) => i));

      await cache.save(key);

      final stored = fakePlatform.store.values.single;
      expect(stored, isNot(contains(String.fromCharCodes(await key.extractBytes()))));
    });

    test('save overwrites a previously cached key', () async {
      final first = SecretKey(List<int>.generate(32, (_) => 1));
      final second = SecretKey(List<int>.generate(32, (_) => 2));

      await cache.save(first);
      await cache.save(second);
      final restored = await cache.read();

      expect(await restored!.extractBytes(), await second.extractBytes());
    });

    test('clear removes a cached key, so a later read misses', () async {
      final key = SecretKey(List<int>.generate(32, (i) => i));
      await cache.save(key);

      await cache.clear();

      expect(await cache.read(), isNull);
    });

    test('clear is idempotent when nothing is cached', () async {
      await cache.clear();
      expect(await cache.read(), isNull);
    });
  });
}
