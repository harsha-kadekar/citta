import 'dart:convert';
import '../services/crypto_service.dart';

/// On-disk format for `encryption_meta.json`: everything needed to unwrap
/// the master key from a password or recovery key, plus the params used to
/// derive that key. The file itself is unencrypted — it is safe to store in
/// plaintext because it is useless without the password/recovery key it
/// describes.
class EncryptionMetadata {
  static const int currentVersion = 1;
  static const String algorithm = 'aes-256-gcm';
  static const String kdfAlgorithm = 'argon2id';

  final int version;
  final List<int> salt;
  final int kdfMemoryKiB;
  final int kdfIterations;
  final int kdfParallelism;

  /// The master key, wrapped under a key derived from the user's password.
  final EncryptedPayload wrappedMasterKeyPassword;

  /// The master key, wrapped under a key derived from the recovery key.
  /// Null until recovery key setup (issue #52) populates it.
  final EncryptedPayload? wrappedMasterKeyRecovery;

  /// The salt used to derive the key that wraps [wrappedMasterKeyRecovery]
  /// from the recovery key string — a separate salt from [salt] (which is
  /// scoped to the password derivation) since the two secrets must never
  /// share one. Null exactly when [wrappedMasterKeyRecovery] is null.
  final List<int>? recoverySalt;

  /// A non-secret digest of the master key's raw bytes (see
  /// `CryptoService.masterKeyVerifier`), used to confirm a candidate master
  /// key — e.g. one restored from a device's secure-storage cache — is
  /// actually the key this install was set up with, without needing the
  /// password to check. Null for metadata written before this field
  /// existed; `StorageService.unlockWithPassword` migrates such metadata to
  /// populate it the next time the user unlocks with their password.
  final String? masterKeyVerifier;

  const EncryptionMetadata({
    this.version = currentVersion,
    required this.salt,
    required this.kdfMemoryKiB,
    required this.kdfIterations,
    required this.kdfParallelism,
    required this.wrappedMasterKeyPassword,
    this.wrappedMasterKeyRecovery,
    this.recoverySalt,
    this.masterKeyVerifier,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'algorithm': algorithm,
        'kdf': {
          'algorithm': kdfAlgorithm,
          'salt': base64Encode(salt),
          'memoryKiB': kdfMemoryKiB,
          'iterations': kdfIterations,
          'parallelism': kdfParallelism,
        },
        'wrappedMasterKeyPassword': wrappedMasterKeyPassword.toJson(),
        'wrappedMasterKeyRecovery': wrappedMasterKeyRecovery?.toJson(),
        'recoverySalt':
            recoverySalt == null ? null : base64Encode(recoverySalt!),
        'masterKeyVerifier': masterKeyVerifier,
      };

  factory EncryptionMetadata.fromJson(Map<String, dynamic> json) {
    final kdf = json['kdf'] as Map<String, dynamic>;
    final recovery = json['wrappedMasterKeyRecovery'];
    final recoverySalt = json['recoverySalt'] as String?;
    return EncryptionMetadata(
      version: json['version'] as int,
      salt: base64Decode(kdf['salt'] as String),
      kdfMemoryKiB: kdf['memoryKiB'] as int,
      kdfIterations: kdf['iterations'] as int,
      kdfParallelism: kdf['parallelism'] as int,
      wrappedMasterKeyPassword: EncryptedPayload.fromJson(
        json['wrappedMasterKeyPassword'] as Map<String, dynamic>,
      ),
      wrappedMasterKeyRecovery: recovery == null
          ? null
          : EncryptedPayload.fromJson(recovery as Map<String, dynamic>),
      recoverySalt: recoverySalt == null ? null : base64Decode(recoverySalt),
      masterKeyVerifier: json['masterKeyVerifier'] as String?,
    );
  }
}
