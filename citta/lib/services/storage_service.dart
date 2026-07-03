import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/config_model.dart';
import '../models/session_model.dart';
import '../models/quote_model.dart';

class StorageService {
  String? _basePath;

  StorageService();

  @visibleForTesting
  StorageService.withBasePath(String basePath) : _basePath = basePath;

  Future<String> get basePath async {
    if (_basePath != null) return _basePath!;
    final dir = await getApplicationDocumentsDirectory();
    _basePath = dir.path;
    return _basePath!;
  }

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

    // Step 3: Rename .tmp to target
    await tmpFile.rename(filePath);

    // Step 4: Clean up .bak on success
    if (await bakFile.exists()) {
      await bakFile.delete();
    }
  }

  /// On startup, recover from interrupted writes.
  Future<void> recoverIfNeeded(String filePath) async {
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

  // --- Sessions ---

  Future<String> get _sessionsPath async => '${await basePath}/sessions.json';

  Future<List<SessionModel>> loadSessions() async {
    final path = await _sessionsPath;
    await recoverIfNeeded(path);
    final file = File(path);
    if (!await file.exists()) {
      return [];
    }
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final sessions = (json['sessions'] as List<dynamic>?)
              ?.map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return sessions;
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
    await _atomicWrite(path, content);
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

  Future<Map<String, dynamic>?> validateImportData(String content) async {
    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      if (!json.containsKey('config') || !json.containsKey('sessions')) {
        return null;
      }
      return json;
    } catch (_) {
      return null;
    }
  }

  Future<void> importData(
    Map<String, dynamic> data, {
    bool replaceAll = true,
  }) async {
    final importedConfig = ConfigModel
        .fromJson(data['config'] as Map<String, dynamic>)
        .sanitizeForDevice();

    final importedSessions = (data['sessions'] as List<dynamic>)
        .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (replaceAll) {
      await saveConfig(importedConfig);
      await saveSessions(importedSessions);
    } else {
      // Merge: keep existing sessions, add new ones by ID
      final existing = await loadSessions();
      final existingIds = existing.map((s) => s.id).toSet();
      for (final session in importedSessions) {
        if (!existingIds.contains(session.id)) {
          existing.add(session);
        }
      }
      await saveSessions(existing);
      await saveConfig(importedConfig);
    }

    // Import user quotes
    if (data.containsKey('userQuotes')) {
      final importedQuotes = (data['userQuotes'] as List<dynamic>)
          .map((e) => QuoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (replaceAll) {
        await saveUserQuotes(importedQuotes);
      } else {
        final existing = await loadUserQuotes();
        final existingIds = existing.map((q) => q.id).toSet();
        for (final quote in importedQuotes) {
          if (!existingIds.contains(quote.id)) {
            existing.add(quote);
          }
        }
        await saveUserQuotes(existing);
      }
    }
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
