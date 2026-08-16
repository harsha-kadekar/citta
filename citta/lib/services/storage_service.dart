import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/config_model.dart';
import '../models/encryption_metadata.dart';
import '../models/session_model.dart';
import '../models/quote_model.dart';
import 'crypto_service.dart';

class StorageService {
  Future<String>? _basePathFuture;
  final _writeLock = _AsyncLock();
  final CryptoService _cryptoService;

  /// The unwrapped master key, held only in memory. Set by [enableEncryption]
  /// or a successful [unlockWithPassword]; cleared by [lock]. Never null once
  /// set for the lifetime of this instance unless explicitly locked.
  SecretKey? _masterKey;

  StorageService({CryptoService? cryptoService})
      : _cryptoService = cryptoService ?? CryptoService();

  @visibleForTesting
  StorageService.withBasePath(String basePath, {CryptoService? cryptoService})
      : _basePathFuture = Future.value(basePath),
        _cryptoService = cryptoService ?? CryptoService();

  Future<String> get basePath => _basePathFuture ??= _resolveBasePath();

  Future<String> _resolveBasePath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } catch (e) {
      _basePathFuture = null;
      rethrow;
    }
  }

  /// Runs [action] exclusively with respect to every other call made
  /// through this method and every import (see [importData] /
  /// [importValidated]), which use the same lock internally. Callers that
  /// mutate config, sessions, or user quotes outside of an import (e.g.
  /// `AppState.updateConfig`, `AppState.addSession`, `QuoteService`) must
  /// route those saves through here so they can never interleave with an
  /// in-flight import's snapshot-then-write sequence — otherwise a stale
  /// import snapshot could roll back over a concurrent edit, or a
  /// concurrent edit could be silently dropped by an import's write.
  Future<T> runExclusive<T>(Future<T> Function() action) =>
      _writeLock.run(action);

  // --- Atomic Write ---

  /// Writes data atomically: write to .tmp, rename original to .bak, rename .tmp to target.
  Future<void> _atomicWrite(String filePath, String content) async {
    final file = File(filePath);
    final tmpFile = File('$filePath.tmp');
    final bakFile = File('$filePath.bak');

    // Step 1: Write to .tmp
    await tmpFile.writeAsString(content, flush: true);

    // Step 2: Rename original to .bak (if exists)
    if (await file.exists()) {
      if (await bakFile.exists()) {
        await bakFile.delete();
      }
      await file.rename(bakFile.path);
    }

    // Step 3: Rename .tmp to target. This is the commit point — once it
    // succeeds, the new content is live, so nothing after this may cause
    // the write to be (mis)reported as failed.
    await tmpFile.rename(filePath);

    // Step 4: Best-effort cleanup of the now-redundant .bak file. A failure
    // here must not make an already-committed write look like it failed —
    // a lingering .bak is already handled safely by recoverIfNeeded() on
    // the next load.
    try {
      if (await bakFile.exists()) {
        await bakFile.delete();
      }
    } catch (_) {}
  }

  /// On startup, recover from interrupted writes.
  ///
  /// Recovery is best-effort: if something obstructs it (e.g. a directory
  /// sitting at the target path after a botched write), the failure is
  /// swallowed here rather than propagated, since callers already treat a
  /// missing or corrupt main file as a safe, handled case.
  Future<void> recoverIfNeeded(String filePath) async {
    try {
      final file = File(filePath);
      final tmpFile = File('$filePath.tmp');
      final bakFile = File('$filePath.bak');

      if (await file.exists()) {
        // Main file is fine; clean up leftover tmp/bak
        if (await tmpFile.exists()) await tmpFile.delete();
        if (await bakFile.exists()) await bakFile.delete();
        return;
      }

      // Main file missing — try to recover
      if (await tmpFile.exists()) {
        // .tmp exists but main doesn't: the rename from .tmp to main failed
        await tmpFile.rename(filePath);
        if (await bakFile.exists()) await bakFile.delete();
      } else if (await bakFile.exists()) {
        // .bak exists but main and .tmp don't: restore from backup
        await bakFile.rename(filePath);
      }
    } catch (_) {}
  }

  // --- Corrupt file handling ---

  /// Renames a corrupt file to `<path>.bak_corrupt` for manual recovery,
  /// deleting any previously saved corrupt backup first.
  Future<void> _saveCorrupt(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;
    final corruptFile = File('$filePath.bak_corrupt');
    if (await corruptFile.exists()) await corruptFile.delete();
    await file.rename(corruptFile.path);
  }

  // --- Config ---

  Future<String> get _configPath async => '${await basePath}/config.json';

  Future<ConfigModel> loadConfig() async {
    final path = await _configPath;
    await recoverIfNeeded(path);
    final file = File(path);
    if (!await file.exists()) {
      return ConfigModel();
    }
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return ConfigModel.fromJson(json);
    } catch (_) {
      await _saveCorrupt(path);
      return ConfigModel();
    }
  }

  Future<void> saveConfig(ConfigModel config) async {
    final path = await _configPath;
    final content = const JsonEncoder.withIndent('  ').convert(config.toJson());
    await _atomicWrite(path, content);
  }

  // --- Encryption ---

  Future<String> get _encryptionMetaPath async =>
      '${await basePath}/encryption_meta.json';

  /// Whether encryption has been set up on this device (metadata file
  /// exists), independent of whether this instance currently holds the
  /// unwrapped master key — see [isUnlocked] for that.
  Future<bool> get isEncryptionEnabled async =>
      File(await _encryptionMetaPath).exists();

  /// Whether this instance currently holds the unwrapped master key in
  /// memory, i.e. [saveSessions] will write ciphertext and [loadSessions]
  /// can read it back.
  bool get isUnlocked => _masterKey != null;

  /// Clears the in-memory master key. Subsequent saves revert to plaintext
  /// and reads of already-encrypted files will throw [StorageLockedException]
  /// until unlocked again.
  void lock() => _masterKey = null;

  /// Generates a new master key, wraps it under a key derived from
  /// [password], and persists the result to `encryption_meta.json`. Any
  /// sessions already on disk are migrated to the encrypted envelope format
  /// immediately, so "enabled" always means "protected on disk right now",
  /// not just "future saves will be protected". Sets the in-memory master
  /// key so subsequent saves are encrypted immediately.
  ///
  /// Runs under the same lock as [runExclusive] so it can never interleave
  /// with a concurrent save or import.
  ///
  /// Throws [StateError] if encryption is already enabled on this device —
  /// re-running setup would silently discard the previous master key (and
  /// permanently strand any data already encrypted under it).
  Future<void> enableEncryption({required String password}) {
    return _writeLock.run(() async {
      if (await isEncryptionEnabled) {
        throw StateError('encryption is already enabled');
      }

      final existingSessions = await loadSessions();

      final salt = _cryptoService.generateSalt();
      final passwordKey = await _cryptoService.deriveKeyFromPassword(
        password: password,
        salt: salt,
      );
      final masterKey = await _cryptoService.generateMasterKey();
      final wrapped = await _cryptoService.wrapKey(
        keyToWrap: masterKey,
        wrappingKey: passwordKey,
      );

      final metadata = EncryptionMetadata(
        salt: salt,
        kdfMemoryKiB: _cryptoService.argon2MemoryKiB,
        kdfIterations: _cryptoService.argon2Iterations,
        kdfParallelism: _cryptoService.argon2Parallelism,
        wrappedMasterKeyPassword: wrapped,
      );
      final path = await _encryptionMetaPath;
      final content =
          const JsonEncoder.withIndent('  ').convert(metadata.toJson());
      await _atomicWrite(path, content);

      _masterKey = masterKey;
      await saveSessions(existingSessions);
    });
  }

  /// Attempts to unwrap the master key using [password] against the stored
  /// metadata. On success, sets the in-memory master key and returns true.
  /// Returns false — without altering any existing in-memory key — if the
  /// metadata file is missing or [password] is wrong. A corrupt/malformed
  /// metadata file is a distinct failure from a wrong password, so it is
  /// not swallowed here — it propagates rather than being reported
  /// indistinguishably as "wrong password".
  ///
  /// Runs under the same lock as [runExclusive] so it can never interleave
  /// with a concurrent save or import.
  Future<bool> unlockWithPassword(String password) {
    return _writeLock.run(() async {
      final path = await _encryptionMetaPath;
      final file = File(path);
      if (!await file.exists()) return false;

      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final metadata = EncryptionMetadata.fromJson(json);
      // Derive with the KDF params recorded in the metadata, not this
      // instance's configured params: the two only coincide today because
      // there has only ever been one set of defaults. Recording them per
      // install is what lets a future change to those defaults happen
      // without breaking installs encrypted under the old ones. AES-GCM
      // itself (via _cryptoService below) has no such per-install params.
      final unlockKdf = CryptoService(
        argon2MemoryKiB: metadata.kdfMemoryKiB,
        argon2Iterations: metadata.kdfIterations,
        argon2Parallelism: metadata.kdfParallelism,
      );
      final passwordKey = await unlockKdf.deriveKeyFromPassword(
        password: password,
        salt: metadata.salt,
      );
      try {
        final masterKey = await _cryptoService.unwrapKey(
          wrapped: metadata.wrappedMasterKeyPassword,
          wrappingKey: passwordKey,
        );
        _masterKey = masterKey;
        return true;
      } on CryptoAuthenticationException {
        return false;
      }
    });
  }

  // --- Sessions ---

  Future<String> get _sessionsPath async => '${await basePath}/sessions.json';

  /// Marker key on the on-disk envelope written by [_encodeSessionsContent]
  /// when a master key is in memory at save time.
  static const _encryptedMarkerKey = 'encrypted';

  /// Reads and, if necessary, decrypts the on-disk sessions content.
  ///
  /// Distinguishes a *locked* file (encrypted, but no master key available)
  /// from a *corrupt* one: the former throws [StorageLockedException] so
  /// [loadSessions] can let it propagate instead of treating it as
  /// corruption and renaming it away via `_saveCorrupt`. Genuine corruption
  /// (malformed JSON, failed GCM authentication) is left for the caller's
  /// existing try/catch to handle.
  Future<String> _readSessionsContent(File file) async {
    final raw = await file.readAsString();
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return raw;
    }
    if (decoded is! Map<String, dynamic> || decoded[_encryptedMarkerKey] != true) {
      return raw;
    }
    final masterKey = _masterKey;
    if (masterKey == null) {
      throw const StorageLockedException(
        'sessions.json is encrypted but no master key is available',
      );
    }
    final payload =
        EncryptedPayload.fromJson(decoded['payload'] as Map<String, dynamic>);
    final plaintext =
        await _cryptoService.decrypt(payload: payload, key: masterKey);
    return utf8.decode(plaintext);
  }

  /// Encrypts [content] into the on-disk envelope format when a master key
  /// is in memory; returns it unchanged when encryption has never been
  /// enabled (today's plaintext behavior). Throws [StorageLockedException]
  /// if encryption is enabled but this instance hasn't been unlocked —
  /// otherwise a save made in that state would silently downgrade
  /// previously-encrypted data back to plaintext with no error.
  Future<String> _encodeSessionsContent(String content) async {
    final masterKey = _masterKey;
    if (masterKey == null) {
      if (await isEncryptionEnabled) {
        throw const StorageLockedException(
          'encryption is enabled but no master key is available; '
          'cannot save sessions.json',
        );
      }
      return content;
    }
    final payload = await _cryptoService.encrypt(
      plaintext: utf8.encode(content),
      key: masterKey,
    );
    final envelope = {
      _encryptedMarkerKey: true,
      'payload': payload.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  Future<List<SessionModel>> loadSessions() async {
    final path = await _sessionsPath;
    await recoverIfNeeded(path);
    final file = File(path);
    if (!await file.exists()) {
      return [];
    }
    try {
      final content = await _readSessionsContent(file);
      final json = jsonDecode(content) as Map<String, dynamic>;
      final sessions = (json['sessions'] as List<dynamic>?)
              ?.map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return sessions;
    } on StorageLockedException {
      rethrow;
    } catch (_) {
      await _saveCorrupt(path);
      return [];
    }
  }

  Future<void> saveSessions(List<SessionModel> sessions) async {
    final path = await _sessionsPath;
    final json = {
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };
    final content = const JsonEncoder.withIndent('  ').convert(json);
    await _atomicWrite(path, await _encodeSessionsContent(content));
  }

  // --- In-Progress Session ---

  Future<String> get _inProgressPath async =>
      '${await basePath}/in_progress_session.json';

  Future<void> saveInProgressSession({
    required String id,
    required DateTime startDate,
    required int elapsedSeconds,
    required String timerMode,
    required int targetDuration,
  }) async {
    final path = await _inProgressPath;
    final json = {
      'id': id,
      'startDate': startDate.toUtc().toIso8601String(),
      'elapsedSeconds': elapsedSeconds,
      'timerMode': timerMode,
      'targetDuration': targetDuration,
    };
    final content = const JsonEncoder.withIndent('  ').convert(json);
    await _atomicWrite(path, content);
  }

  Future<Map<String, dynamic>?> loadInProgressSession() async {
    final path = await _inProgressPath;
    await recoverIfNeeded(path);
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      await _saveCorrupt(path);
      return null;
    }
  }

  Future<void> clearInProgressSession() async {
    final path = await _inProgressPath;
    final file = File(path);
    if (await file.exists()) await file.delete();
    final tmp = File('$path.tmp');
    final bak = File('$path.bak');
    if (await tmp.exists()) await tmp.delete();
    if (await bak.exists()) await bak.delete();
  }

  // --- User Quotes ---

  Future<String> get _userQuotesPath async =>
      '${await basePath}/user_quotes.json';

  Future<List<QuoteModel>> loadUserQuotes() async {
    final path = await _userQuotesPath;
    await recoverIfNeeded(path);
    final file = File(path);
    if (!await file.exists()) {
      return [];
    }
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final quotes = (json['quotes'] as List<dynamic>?)
              ?.map((e) => QuoteModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return quotes;
    } catch (_) {
      await _saveCorrupt(path);
      return [];
    }
  }

  Future<void> saveUserQuotes(List<QuoteModel> quotes) async {
    final path = await _userQuotesPath;
    final json = {
      'quotes': quotes.map((q) => q.toJson()).toList(),
    };
    final content = const JsonEncoder.withIndent('  ').convert(json);
    await _atomicWrite(path, content);
  }

  // --- Export / Import ---

  /// Import schema versions this build knows how to read.
  static const Set<int> supportedImportVersions = {1};

  Future<String> exportAllData() async {
    final config = await loadConfig();
    final sessions = await loadSessions();
    final userQuotes = await loadUserQuotes();

    final exportData = {
      'version': 1,
      'exportDate': DateTime.now().toUtc().toIso8601String(),
      'config': config.toJson(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'userQuotes': userQuotes.map((q) => q.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Parses `version` from decoded JSON, accepting both an int (`1`) and a
  /// whole-number double (`1.0`, which is what `jsonDecode` produces for any
  /// JSON numeral written with a decimal point).
  int? _asVersionInt(dynamic value) {
    if (value is int) return value;
    if (value is double && value == value.truncateToDouble()) return value.toInt();
    return null;
  }

  /// Parses [value] as a list of [T] via [fromJson], or returns null if
  /// [value] isn't a list, contains a non-object entry, or any entry fails
  /// to parse. Validation and parsing happen in the same pass so callers
  /// never need to decode a list twice.
  List<T>? _parseValidList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) return null;
    try {
      return value.map((e) {
        if (e is! Map<String, dynamic>) {
          throw const FormatException('list entry is not an object');
        }
        return fromJson(e);
      }).toList();
    } catch (_) {
      return null;
    }
  }

  /// Merges [imported] into [original], skipping any entry whose id (per
  /// [idOf]) already exists in [original].
  List<T> _mergeById<T>(
    List<T> original,
    List<T> imported,
    Object Function(T item) idOf,
  ) {
    final merged = List<T>.from(original);
    final seenIds = original.map(idOf).toSet();
    for (final item in imported) {
      if (seenIds.add(idOf(item))) {
        merged.add(item);
      }
    }
    return merged;
  }

  Map<String, dynamic>? _decodeJsonObject(String content) {
    try {
      final decoded = jsonDecode(content);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  // The exact field shape of ConfigModel.toJson() for import schema version
  // 1. ConfigModel.fromJson() itself defaults missing/absent fields (for
  // backward-compatible loading of the app's own possibly-older config.json
  // on disk), so it cannot be relied on to reject a sparse or truncated
  // import payload — that must be checked explicitly first.
  static const _v1ConfigStringFields = [
    'timerMode', 'bellStart', 'bellEnd', 'bellInterval', 'themeMode', 'language',
  ];
  static const _v1ConfigIntFields = ['countdownDuration', 'intervalDuration'];
  static const _v1ConfigBoolFields = ['intervalEnabled', 'calendarViewEnabled'];
  static const _v1ConfigListFields = ['tags', 'quoteSources'];
  static const _v1ConfigNullableStringFields = ['backgroundMusic', 'userName'];

  bool _isValidV1ConfigJson(Map<String, dynamic> json) {
    for (final key in _v1ConfigStringFields) {
      if (json[key] is! String) return false;
    }
    for (final key in _v1ConfigIntFields) {
      if (json[key] is! int) return false;
    }
    for (final key in _v1ConfigBoolFields) {
      if (json[key] is! bool) return false;
    }
    for (final key in _v1ConfigListFields) {
      final value = json[key];
      if (value is! List || value.any((e) => e is! String)) return false;
    }
    for (final key in _v1ConfigNullableStringFields) {
      if (!json.containsKey(key)) return false;
      final value = json[key];
      if (value != null && value is! String) return false;
    }
    return true;
  }

  /// Parses and validates a decoded export payload: a supported `version`,
  /// a `config` object, a `sessions` list, and — if present — a `userQuotes`
  /// list, all of which must parse into their respective models. Returns
  /// null if any part is invalid.
  _ParsedImport? _parseImportJson(Map<String, dynamic> json) {
    final version = _asVersionInt(json['version']);
    if (version == null || !supportedImportVersions.contains(version)) {
      return null;
    }

    final configJson = json['config'];
    if (configJson is! Map<String, dynamic>) return null;
    if (!_isValidV1ConfigJson(configJson)) return null;
    final ConfigModel config;
    try {
      config = ConfigModel.fromJson(configJson);
    } catch (_) {
      return null;
    }

    final sessions = _parseValidList<SessionModel>(
      json['sessions'],
      SessionModel.fromJson,
    );
    if (sessions == null) return null;

    List<QuoteModel>? quotes;
    if (json.containsKey('userQuotes')) {
      quotes = _parseValidList<QuoteModel>(
        json['userQuotes'],
        QuoteModel.fromJson,
      );
      if (quotes == null) return null;
    }

    return _ParsedImport(config: config, sessions: sessions, quotes: quotes);
  }

  /// Validates that [content] is a well-formed, versioned export payload:
  /// the declared `version` is one this build supports, `config` and every
  /// `sessions` entry parse into their respective models, and — if present —
  /// every `userQuotes` entry does too. Returns the decoded JSON only when
  /// every part is valid, so that [importData] can never fail partway
  /// through because of malformed *data* (only real I/O errors remain
  /// possible there).
  Future<Map<String, dynamic>?> validateImportData(String content) async {
    final json = _decodeJsonObject(content);
    if (json == null) return null;
    return _parseImportJson(json) == null ? null : json;
  }

  /// Writes config, sessions, and (if present) user quotes as a single
  /// logical unit: the pre-import state of each is snapshotted first, and
  /// each write is staged as an [_ImportStep]. If any step fails partway
  /// through (e.g. an I/O error), every step that already succeeded is
  /// rolled back to its snapshot, in reverse order, before the error is
  /// rethrown — so a failed import never leaves a mix of old and new state.
  /// If a rollback step itself fails, that failure is not swallowed: it is
  /// reported via [ImportRollbackIncompleteException] so callers can tell a
  /// clean failure apart from one that may have left mixed state on disk.
  ///
  /// The entire snapshot-then-write sequence runs under the same lock as
  /// [runExclusive], so it can never interleave with another import or
  /// with a normal config/session/quote save made through that method — a
  /// second concurrent call (import or otherwise) simply waits its turn
  /// rather than racing the snapshot or the write.
  Future<void> _writeImport({
    required ConfigModel config,
    required List<SessionModel> sessions,
    required List<QuoteModel>? quotes,
    required bool replaceAll,
  }) {
    return _writeLock.run(() async {
      final hasQuotes = quotes != null;
      final originalConfig = await loadConfig();
      final originalSessions = await loadSessions();
      final originalQuotes =
          hasQuotes ? await loadUserQuotes() : const <QuoteModel>[];

      final finalSessions = replaceAll
          ? sessions
          : _mergeById<SessionModel>(originalSessions, sessions, (s) => s.id);

      List<QuoteModel>? finalQuotes;
      if (hasQuotes) {
        finalQuotes = replaceAll
            ? quotes
            : _mergeById<QuoteModel>(originalQuotes, quotes, (q) => q.id);
      }

      final steps = <_ImportStep>[
        _ImportStep(
          write: () => saveConfig(config),
          rollback: () => saveConfig(originalConfig),
        ),
        _ImportStep(
          write: () => saveSessions(finalSessions),
          rollback: () => saveSessions(originalSessions),
        ),
        if (hasQuotes)
          _ImportStep(
            write: () => saveUserQuotes(finalQuotes!),
            rollback: () => saveUserQuotes(originalQuotes),
          ),
      ];

      final completed = <_ImportStep>[];
      _ImportStep? inFlight;
      try {
        for (final step in steps) {
          inFlight = step;
          await step.write();
          completed.add(step);
          inFlight = null;
        }
      } catch (e) {
        // Roll back the step that threw too, not just the previously
        // completed ones: the underlying atomic write's rename can commit
        // the new content (or relocate the previous content to a backup
        // file) before a later filesystem operation in that same write
        // throws, so the failing step's own file cannot be assumed to
        // still hold its pre-import value.
        final toRollback = [
          if (inFlight != null) inFlight,
          ...completed.reversed,
        ];
        final rollbackErrors = <Object>[];
        for (final step in toRollback) {
          try {
            await step.rollback();
          } catch (rollbackError) {
            rollbackErrors.add(rollbackError);
          }
        }
        if (rollbackErrors.isNotEmpty) {
          throw ImportRollbackIncompleteException(e, rollbackErrors);
        }
        rethrow;
      }
    });
  }

  /// Applies a previously-[validateImportData]-checked payload. Does not
  /// itself check `version` — callers are expected to have validated the
  /// payload first (see [importValidated] for a single-pass alternative).
  Future<void> importData(
    Map<String, dynamic> data, {
    bool replaceAll = true,
  }) async {
    final config = ConfigModel
        .fromJson(data['config'] as Map<String, dynamic>)
        .sanitizeForDevice();

    final sessions = (data['sessions'] as List<dynamic>)
        .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final quotes = data.containsKey('userQuotes')
        ? (data['userQuotes'] as List<dynamic>)
            .map((e) => QuoteModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : null;

    await _writeImport(
      config: config,
      sessions: sessions,
      quotes: quotes,
      replaceAll: replaceAll,
    );
  }

  /// Validates and imports [content] in one pass, parsing the payload only
  /// once (unlike calling [validateImportData] followed by [importData],
  /// which each parse it independently). Returns false if the payload fails
  /// validation or the write fails for any reason (including a failed or
  /// incomplete rollback); never throws.
  Future<bool> importValidated(String content, {bool replaceAll = true}) async {
    final json = _decodeJsonObject(content);
    if (json == null) return false;
    final parsed = _parseImportJson(json);
    if (parsed == null) return false;
    try {
      await _writeImport(
        config: parsed.config.sanitizeForDevice(),
        sessions: parsed.sessions,
        quotes: parsed.quotes,
        replaceAll: replaceAll,
      );
    } on StorageLockedException {
      rethrow;
    } catch (_) {
      return false;
    }
    return true;
  }

  /// Returns the path to the export file written to a temp directory.
  Future<String> writeExportFile() async {
    final content = await exportAllData();
    final now = DateTime.now();
    final fileName =
        'citta_export_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.json';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }
}

/// Thrown by [StorageService.loadSessions] and [StorageService.saveSessions]
/// when encryption is enabled but no master key is available in memory (not
/// yet unlocked). On load, this is distinct from a corrupt-file failure: the
/// underlying file is left untouched, so callers can prompt for unlock and
/// retry rather than losing data to `_saveCorrupt`. On save, it prevents a
/// write from silently downgrading already-encrypted data back to
/// plaintext.
class StorageLockedException implements Exception {
  final String message;

  const StorageLockedException(this.message);

  @override
  String toString() => 'StorageLockedException: $message';
}

/// A minimal FIFO async mutex. Queued actions run one at a time, in the
/// order they were submitted, regardless of whether an earlier action
/// succeeded or threw — so a failure never blocks the ones queued behind it.
class _AsyncLock {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() action) {
    final previous = _tail;
    final completer = Completer<void>();
    _tail = completer.future;
    return previous.then((_) => action()).whenComplete(completer.complete);
  }
}

/// A successfully parsed and schema-validated export payload, ready to hand
/// to [StorageService]'s internal write step.
class _ParsedImport {
  final ConfigModel config;
  final List<SessionModel> sessions;
  final List<QuoteModel>? quotes;

  const _ParsedImport({
    required this.config,
    required this.sessions,
    required this.quotes,
  });
}

/// One persisted entity's write and its corresponding rollback, used by
/// [StorageService]'s import transaction so a new persisted entity can be
/// added to the import flow by appending a step rather than hand-copying a
/// snapshot flag and a rollback branch.
class _ImportStep {
  final Future<void> Function() write;
  final Future<void> Function() rollback;

  const _ImportStep({required this.write, required this.rollback});
}

/// Thrown when an import fails and the automatic rollback could not fully
/// restore the pre-import state — meaning the files on disk may now hold a
/// mix of old and new data. This is strictly worse than a clean failed
/// import, so it is reported as a distinct type rather than silently
/// swallowed alongside the original failure.
class ImportRollbackIncompleteException implements Exception {
  final Object importError;
  final List<Object> rollbackErrors;

  ImportRollbackIncompleteException(this.importError, this.rollbackErrors);

  @override
  String toString() =>
      'ImportRollbackIncompleteException: import failed ($importError) and '
      'rollback did not fully complete ($rollbackErrors)';
}
