import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// Cryptographic primitives for password-based encryption of session data.
///
/// Pure, unit-testable module: no filesystem or UI dependencies. Callers
/// (e.g. a future encrypted `StorageService`) are responsible for persisting
/// the bytes this service produces.
class CryptoService {
  /// Argon2id cost parameters. Defaults follow OWASP's password-hashing
  /// guidance (19 MiB memory, 2 iterations, parallelism 1). Callers with
  /// stricter latency budgets (e.g. tests) may override these, but should
  /// not weaken them in production code paths.
  ///
  /// The derived key is always sized to match [AesGcm.with256bits]'s
  /// required 32-byte key — it isn't caller-configurable, since a
  /// mismatched length would make the derived key unusable for [encrypt] /
  /// [wrapKey] (AES-256-GCM rejects any other key length).
  CryptoService({
    this.argon2Parallelism = 1,
    this.argon2MemoryKiB = 19456,
    this.argon2Iterations = 2,
  }) : _kdf = Argon2id(
          parallelism: argon2Parallelism,
          memory: argon2MemoryKiB,
          iterations: argon2Iterations,
          hashLength: _aesKeyLengthBytes,
        );

  static const int saltLengthBytes = 16;
  static const int _aesKeyLengthBytes = 32;

  /// The Argon2id cost params this instance was configured with — recorded
  /// alongside a derived key's salt (e.g. in encryption metadata) so a
  /// later derivation can be reproduced with the exact same params.
  final int argon2Parallelism;
  final int argon2MemoryKiB;
  final int argon2Iterations;

  final Argon2id _kdf;
  final AesGcm _cipher = AesGcm.with256bits();
  final Random _random = Random.secure();

  /// A random salt suitable for [deriveKeyFromPassword].
  List<int> generateSalt() =>
      List<int>.generate(saltLengthBytes, (_) => _random.nextInt(256));

  /// Derives a key from [password] and [salt] using Argon2id. Deterministic
  /// for the same password+salt pair; different salts produce different
  /// keys even for the same password.
  Future<SecretKey> deriveKeyFromPassword({
    required String password,
    required List<int> salt,
  }) {
    return _kdf.deriveKeyFromPassword(password: password, nonce: salt);
  }

  /// Generates a random AES-256 master key.
  Future<SecretKey> generateMasterKey() => _cipher.newSecretKey();

  /// Encrypts [plaintext] with [key] using AES-256-GCM.
  Future<EncryptedPayload> encrypt({
    required List<int> plaintext,
    required SecretKey key,
  }) async {
    final secretBox = await _cipher.encrypt(plaintext, secretKey: key);
    return EncryptedPayload(
      cipherText: secretBox.cipherText,
      nonce: secretBox.nonce,
      mac: secretBox.mac.bytes,
    );
  }

  /// Decrypts [payload] with [key], verifying the GCM authentication tag.
  ///
  /// Throws [CryptoAuthenticationException] if [payload] was tampered with
  /// (or [key] is wrong) rather than returning corrupted plaintext.
  Future<List<int>> decrypt({
    required EncryptedPayload payload,
    required SecretKey key,
  }) async {
    final secretBox = SecretBox(
      payload.cipherText,
      nonce: payload.nonce,
      mac: Mac(payload.mac),
    );
    try {
      return await _cipher.decrypt(secretBox, secretKey: key);
    } on SecretBoxAuthenticationError catch (e) {
      throw CryptoAuthenticationException(e.toString());
    }
  }

  /// Wraps (encrypts) [keyToWrap] under [wrappingKey], so the wrapped bytes
  /// can be stored without exposing the raw key material.
  Future<EncryptedPayload> wrapKey({
    required SecretKey keyToWrap,
    required SecretKey wrappingKey,
  }) async {
    final rawBytes = await keyToWrap.extractBytes();
    return encrypt(plaintext: rawBytes, key: wrappingKey);
  }

  /// Unwraps (decrypts) a key previously produced by [wrapKey].
  ///
  /// Throws [CryptoAuthenticationException] if [wrapped] was tampered with
  /// or [wrappingKey] is wrong.
  Future<SecretKey> unwrapKey({
    required EncryptedPayload wrapped,
    required SecretKey wrappingKey,
  }) async {
    final rawBytes = await decrypt(payload: wrapped, key: wrappingKey);
    return SecretKey(rawBytes);
  }
}

/// The output of [CryptoService.encrypt] / input to [CryptoService.decrypt]:
/// an AES-256-GCM ciphertext with its nonce and authentication tag.
class EncryptedPayload {
  final List<int> cipherText;
  final List<int> nonce;
  final List<int> mac;

  const EncryptedPayload({
    required this.cipherText,
    required this.nonce,
    required this.mac,
  });

  /// Serializes to base64-encoded fields, suitable for embedding in a JSON
  /// document (e.g. an encrypted file envelope or encryption metadata).
  Map<String, dynamic> toJson() => {
        'cipherText': base64Encode(cipherText),
        'nonce': base64Encode(nonce),
        'mac': base64Encode(mac),
      };

  factory EncryptedPayload.fromJson(Map<String, dynamic> json) =>
      EncryptedPayload(
        cipherText: base64Decode(json['cipherText'] as String),
        nonce: base64Decode(json['nonce'] as String),
        mac: base64Decode(json['mac'] as String),
      );
}

/// Thrown by [CryptoService.decrypt] / [CryptoService.unwrapKey] when the
/// GCM authentication tag doesn't match — the ciphertext was tampered with,
/// or the wrong key was used. Wraps the underlying `cryptography` package's
/// error so callers don't depend on that package's exception type directly.
class CryptoAuthenticationException implements Exception {
  final String message;

  const CryptoAuthenticationException(this.message);

  @override
  String toString() => 'CryptoAuthenticationException: $message';
}
