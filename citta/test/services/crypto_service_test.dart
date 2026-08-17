import 'package:flutter_test/flutter_test.dart';
import 'package:citta/services/crypto_service.dart';

/// Argon2id cost params for tests only: fast, not secure. Production code
/// must use [CryptoService]'s default (OWASP-recommended) params.
CryptoService _testCryptoService() => CryptoService(
      argon2Parallelism: 1,
      argon2MemoryKiB: 8,
      argon2Iterations: 1,
    );

void main() {
  late CryptoService cryptoService;

  setUp(() {
    cryptoService = _testCryptoService();
  });

  group('deriveKeyFromPassword', () {
    test('same password and salt produce identical key bytes', () async {
      final salt = cryptoService.generateSalt();

      final key1 = await cryptoService.deriveKeyFromPassword(
        password: 'correct horse battery staple',
        salt: salt,
      );
      final key2 = await cryptoService.deriveKeyFromPassword(
        password: 'correct horse battery staple',
        salt: salt,
      );

      expect(await key1.extractBytes(), await key2.extractBytes());
    });

    test('different salts produce different key bytes', () async {
      final saltA = cryptoService.generateSalt();
      final saltB = cryptoService.generateSalt();

      final keyA = await cryptoService.deriveKeyFromPassword(
        password: 'same password',
        salt: saltA,
      );
      final keyB = await cryptoService.deriveKeyFromPassword(
        password: 'same password',
        salt: saltB,
      );

      expect(await keyA.extractBytes(), isNot(await keyB.extractBytes()));
    });

    test('generateSalt returns non-empty, non-repeating salts', () {
      final saltA = cryptoService.generateSalt();
      final saltB = cryptoService.generateSalt();

      expect(saltA, isNotEmpty);
      expect(saltA, isNot(saltB));
    });
  });

  group('generateMasterKey', () {
    test('produces a 32-byte AES-256 key', () async {
      final key = await cryptoService.generateMasterKey();
      expect((await key.extractBytes()).length, 32);
    });

    test('produces different keys on each call', () async {
      final keyA = await cryptoService.generateMasterKey();
      final keyB = await cryptoService.generateMasterKey();
      expect(await keyA.extractBytes(), isNot(await keyB.extractBytes()));
    });
  });

  group('encrypt / decrypt', () {
    test('round-trips an arbitrary byte payload', () async {
      final key = await cryptoService.generateMasterKey();
      final plaintext = List<int>.generate(64, (i) => i % 256);

      final payload = await cryptoService.encrypt(
        plaintext: plaintext,
        key: key,
      );
      final decrypted = await cryptoService.decrypt(
        payload: payload,
        key: key,
      );

      expect(decrypted, plaintext);
    });

    test('round-trips an empty payload', () async {
      final key = await cryptoService.generateMasterKey();

      final payload = await cryptoService.encrypt(plaintext: [], key: key);
      final decrypted = await cryptoService.decrypt(payload: payload, key: key);

      expect(decrypted, isEmpty);
    });

    test('tampered ciphertext fails authentication', () async {
      final key = await cryptoService.generateMasterKey();
      final plaintext = 'top secret meditation notes'.codeUnits;

      final payload = await cryptoService.encrypt(
        plaintext: plaintext,
        key: key,
      );
      final tamperedCipherText = List<int>.from(payload.cipherText);
      tamperedCipherText[0] ^= 0xFF;
      final tamperedPayload = EncryptedPayload(
        cipherText: tamperedCipherText,
        nonce: payload.nonce,
        mac: payload.mac,
      );

      expect(
        () => cryptoService.decrypt(payload: tamperedPayload, key: key),
        throwsA(isA<CryptoAuthenticationException>()),
      );
    });

    test('tampered MAC fails authentication', () async {
      final key = await cryptoService.generateMasterKey();
      final plaintext = 'top secret meditation notes'.codeUnits;

      final payload = await cryptoService.encrypt(
        plaintext: plaintext,
        key: key,
      );
      final tamperedMac = List<int>.from(payload.mac);
      tamperedMac[0] ^= 0xFF;
      final tamperedPayload = EncryptedPayload(
        cipherText: payload.cipherText,
        nonce: payload.nonce,
        mac: tamperedMac,
      );

      expect(
        () => cryptoService.decrypt(payload: tamperedPayload, key: key),
        throwsA(isA<CryptoAuthenticationException>()),
      );
    });
  });

  group('wrapKey / unwrapKey', () {
    test('round-trips a generated master key', () async {
      final wrappingKey = await cryptoService.generateMasterKey();
      final masterKey = await cryptoService.generateMasterKey();

      final wrapped = await cryptoService.wrapKey(
        keyToWrap: masterKey,
        wrappingKey: wrappingKey,
      );
      final unwrapped = await cryptoService.unwrapKey(
        wrapped: wrapped,
        wrappingKey: wrappingKey,
      );

      expect(await unwrapped.extractBytes(), await masterKey.extractBytes());
    });

    test('a password-derived key can wrap and unwrap a master key', () async {
      // This is the actual intended use case (see issue #48): a key derived
      // from the user's password wraps a randomly-generated master key.
      final salt = cryptoService.generateSalt();
      final derivedKey = await cryptoService.deriveKeyFromPassword(
        password: 'correct horse battery staple',
        salt: salt,
      );
      final masterKey = await cryptoService.generateMasterKey();

      final wrapped = await cryptoService.wrapKey(
        keyToWrap: masterKey,
        wrappingKey: derivedKey,
      );
      final unwrapped = await cryptoService.unwrapKey(
        wrapped: wrapped,
        wrappingKey: derivedKey,
      );

      expect(await unwrapped.extractBytes(), await masterKey.extractBytes());
    });

    test('unwrap fails authentication with the wrong wrapping key', () async {
      final wrappingKey = await cryptoService.generateMasterKey();
      final wrongKey = await cryptoService.generateMasterKey();
      final masterKey = await cryptoService.generateMasterKey();

      final wrapped = await cryptoService.wrapKey(
        keyToWrap: masterKey,
        wrappingKey: wrappingKey,
      );

      expect(
        () => cryptoService.unwrapKey(wrapped: wrapped, wrappingKey: wrongKey),
        throwsA(isA<CryptoAuthenticationException>()),
      );
    });
  });

  group('masterKeyVerifier', () {
    test('is deterministic for the same key bytes', () async {
      final key = await cryptoService.generateMasterKey();

      final verifierA = await cryptoService.masterKeyVerifier(key);
      final verifierB = await cryptoService.masterKeyVerifier(key);

      expect(verifierA, verifierB);
    });

    test('differs for different keys', () async {
      final keyA = await cryptoService.generateMasterKey();
      final keyB = await cryptoService.generateMasterKey();

      final verifierA = await cryptoService.masterKeyVerifier(keyA);
      final verifierB = await cryptoService.masterKeyVerifier(keyB);

      expect(verifierA, isNot(verifierB));
    });

    test('does not reveal the raw key bytes', () async {
      final key = await cryptoService.generateMasterKey();

      final verifier = await cryptoService.masterKeyVerifier(key);

      expect(verifier, isNot(contains(String.fromCharCodes(await key.extractBytes()))));
    });
  });
}
