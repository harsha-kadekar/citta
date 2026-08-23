import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/encryption_metadata.dart';
import 'package:citta/services/crypto_service.dart';

EncryptedPayload _payload(int seed) => EncryptedPayload(
      cipherText: [seed, seed + 1],
      nonce: [seed + 2],
      mac: [seed + 3],
    );

EncryptionMetadata _metadata({
  List<int>? recoverySalt,
  EncryptedPayload? wrappedMasterKeyRecovery,
}) =>
    EncryptionMetadata(
      salt: [1, 2, 3],
      kdfMemoryKiB: 19456,
      kdfIterations: 2,
      kdfParallelism: 1,
      wrappedMasterKeyPassword: _payload(1),
      recoverySalt: recoverySalt,
      wrappedMasterKeyRecovery: wrappedMasterKeyRecovery,
      masterKeyVerifier: 'verifier',
    );

void main() {
  group('EncryptionMetadata JSON round-trip', () {
    test('recoverySalt and wrappedMasterKeyRecovery survive toJson/fromJson',
        () {
      final metadata = _metadata(
        recoverySalt: [9, 8, 7],
        wrappedMasterKeyRecovery: _payload(10),
      );

      final decoded = EncryptionMetadata.fromJson(metadata.toJson());

      expect(decoded.recoverySalt, [9, 8, 7]);
      expect(decoded.wrappedMasterKeyRecovery!.cipherText, [10, 11]);
      expect(decoded.wrappedMasterKeyRecovery!.nonce, [12]);
      expect(decoded.wrappedMasterKeyRecovery!.mac, [13]);
    });

    test('recoverySalt and wrappedMasterKeyRecovery are null when unset', () {
      final metadata = _metadata();

      final decoded = EncryptionMetadata.fromJson(metadata.toJson());

      expect(decoded.recoverySalt, isNull);
      expect(decoded.wrappedMasterKeyRecovery, isNull);
    });

    test('legacy JSON written before recoverySalt existed parses as null',
        () {
      final metadata = _metadata();
      final json = metadata.toJson()..remove('recoverySalt');

      final decoded = EncryptionMetadata.fromJson(json);

      expect(decoded.recoverySalt, isNull);
      expect(decoded.wrappedMasterKeyRecovery, isNull);
    });
  });
}
