# Citta — Senior Android Engineer Code Review

**Reviewed:** 2026-05-09
**Version:** 0.2.1+3
**Scope:** Full codebase review — Android release readiness, lifecycle correctness, audio, state management, data integrity, and Flutter code quality.

---

## Executive Summary

The app is architecturally coherent and production-like in its overall structure. The service layer, storage strategy, and localization support are all well above average for an app at this stage. However, there are several issues that would block a production Android release or cause user-visible bugs at moderate scale. The most critical problems are:

- Release APK is built with debug signing and a template application ID — not shippable.
- Manual session stops are incorrectly recorded as fully-completed sessions, corrupting history data.
- No Android audio focus management, meaning bells and background music won't pause for phone calls or other audio apps.
- `AppState.stats` and `AppState.sortedSessions` recompute from scratch on every access with no caching, and all screens watch the full provider.
- `ConfigModel` allows direct in-place mutation of its `tags` list, bypassing the `copyWith` contract.

The recommended fix order is listed at the end of this document.

---

## Priority 1 — Blockers

### 1. Android release config is not production-ready

**Files:** `android/app/build.gradle.kts:9, 24, 37`

The `namespace` and `applicationId` are both `com.example.citta` — the Flutter template default. Publishing to the Play Store with this ID is impossible (Google blocks `com.example.*` namespaces). The release build type also uses the debug signing config:

```kotlin
release {
    // TODO: Add your own signing config for the release build.
    signingConfig = signingConfigs.getByName("debug")
}
```

A release APK signed with debug keys cannot be installed over a debug build, cannot be uploaded to the Play Store, and will lose all user data on first real-world upgrade if the package name is changed after initial release.

**Fix:**
- Choose a stable, real application ID (e.g., `com.hkadekar.citta`) and set it in `defaultConfig.applicationId`.
- Set the same value for `namespace`.
- Create a proper `release` signing config reading keystore path, alias, and passwords from `~/.gradle/gradle.properties` or environment variables — never committed to source.
- Remove both TODO comments once done.
- Also add a `minifyEnabled = true` + `shrinkResources = true` block to the release build type, and supply a `proguard-rules.pro` for just_audio and file_picker if needed.

---

### 2. Manual stop records a false "fully completed" session

**Files:** `lib/services/timer_service.dart:98`, `lib/screens/home_screen.dart:107–139`

`TimerService.stop()` unconditionally sets `_state = TimerState.completed`. When the user taps the stop button, `_stopSession()` calls `stop()`, then immediately calls `_onSessionComplete()`, which computes:

```dart
completedFully: _timerService.state == TimerState.completed,
```

Because `stop()` always sets `completed`, both natural timer expiry and user-initiated interruptions are persisted with `completedFully: true`. The completion checkmark on the history and detail screens is therefore meaningless — every session shows as complete.

**Fix:**
Add a `SessionEndReason` enum (`completed`, `stopped`) and pass it explicitly into `_onSessionComplete(SessionEndReason reason)`. Set `completedFully = (reason == SessionEndReason.completed)`. Do not infer completion from `TimerState`.

---

## Priority 2 — Significant Issues

### 3. No Android audio focus management

**Files:** `lib/services/audio_service.dart`

The app plays bell sounds and background music via `just_audio` without requesting or managing Android AudioFocus. This means:

- A phone call arrives mid-session → bell sound and background music continue playing over the ringtone.
- The user presses play in Spotify → bells overlap with Spotify; neither pauses.
- The OS can kill audio arbitrarily, leaving `_isMusicPlaying = true` out of sync with reality.

`just_audio` exposes AudioFocus configuration via `AudioPlayer.setAudioAttributes()` with a `AudioAttributesBuilder`. For a meditation app, the correct configuration is `AudioFocus.gain` with usage `AudioUsage.media` and content type `AudioContentType.music`.

**Fix:**
Configure audio attributes on both `_bellPlayer` and `_musicPlayer` after creation. Listen to the `AudioPlayer.playerStateStream` to detect unexpected stops (e.g., audio focus loss) and sync `_isMusicPlaying` accordingly. Also pause the `TimerService` when audio focus is lost transiently (duck or pause).

---

### 4. `AppState.stats` and sorted/filtered sessions have no caching

**Files:** `lib/providers/app_state.dart:29, 66, 72, 83`

```dart
StatsResult get stats => statsService.calculateStats(_sessions);

List<SessionModel> get sortedSessions {
  final sorted = List<SessionModel>.from(_sessions);
  sorted.sort((a, b) => b.date.compareTo(a.date));
  return sorted;
}

List<SessionModel> filterByTag(String tag) {
  return _sessions.where((s) => s.tags.contains(tag)).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}
```

Every access to `stats`, `sortedSessions`, or `filterByTag` runs a full O(n log n) sort and/or O(n) stats calculation over `_sessions`. Every screen uses `context.watch<AppState>()` which rebuilds the entire widget tree on any `notifyListeners()` call — including for config changes like toggling the calendar or changing the theme. The result is that switching theme triggers a full session list sort and stats recalculation.

**Fix:**
- Cache `_sortedSessions`, `_cachedStats`, and optionally `_sessionsByDate` as private fields in `AppState`.
- Recompute only inside `initialize()`, `addSession()`, `deleteSessions()`, and `importData()`.
- Replace `context.watch<AppState>()` in `StatsScreen`, `HistoryScreen`, and `HomeScreen` with `context.select()` or `Selector` widgets that only subscribe to the specific field they need (e.g., `Selector<AppState, StatsResult>` for the stats grid, `Selector<AppState, ConfigModel>` for theme/language).

---

### 5. `ConfigModel` is nominally immutable but directly mutated

**Files:** `lib/providers/app_state.dart:93–105`, `lib/services/storage_service.dart:228–237`, `lib/models/config_model.dart:31–32`

`ConfigModel` has `var` (mutable) fields. The `tags` and `quoteSources` fields are exposed as mutable `List<String>`. `AppState.addTag()` and `removeTag()` mutate `_config.tags` in place and then call `saveConfig(_config)` — bypassing `copyWith` entirely:

```dart
Future<void> addTag(String tag) async {
  if (!_config.tags.contains(tag)) {
    _config.tags.add(tag);   // direct mutation
    await storageService.saveConfig(_config);
    notifyListeners();
  }
}
```

`StorageService.importData()` also directly mutates a freshly-deserialized config:

```dart
importedConfig.bellStart = ConfigModel.defaultBellStart; // direct mutation
```

This is inconsistent with `copyWith` usage elsewhere and makes state transitions harder to reason about, especially as more settings are added.

**Fix:**
- Make all `ConfigModel` fields `final`.
- Change `tags` and `quoteSources` to `List<String>` that are copies in the constructor and `copyWith`.
- Rewrite `addTag`/`removeTag` to use `updateConfig(_config.copyWith(tags: [..._config.tags, tag]))`.
- Rewrite the import mutation to build a new config via a chained `copyWith`.

---

### 6. `CalendarView` creates a new `StatsService` instance and regroups unconditionally

**Files:** `lib/widgets/calendar_view.dart:25–31, 67–73`

```dart
void initState() {
  _sessionsByDate = StatsService().groupByDate(widget.sessions);
}

void didUpdateWidget(CalendarView oldWidget) {
  super.didUpdateWidget(oldWidget);
  _sessionsByDate = StatsService().groupByDate(widget.sessions);  // always runs
}
```

`didUpdateWidget` runs on every parent rebuild — toggling the calendar, changing theme, any config update. A new `StatsService()` is instantiated and `groupByDate` loops over all sessions every time, even when `widget.sessions` has not changed.

The `build` method also recreates `DateFormat` instances and the seven weekday header strings on every frame.

**Fix:**
- Guard the regroup: `if (widget.sessions != oldWidget.sessions) { ... }`. Since `AppState.sessions` returns a new `List.unmodifiable` wrapper every call (line 27 of `app_state.dart`), also cache the grouped data using the session count + last-modified marker, or pass in already-grouped data from `AppState`.
- Extract `_monthFormatter` and `_weekdayHeaders` as lazily-initialized state fields rather than rebuilding in `build`.
- Remove the `StatsService()` instantiation entirely — pass in grouped data or inject the service.

---

### 7. App lifecycle: only pause handled, not resume

**Files:** `lib/screens/home_screen.dart:74–79`

```dart
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused &&
      _timerService.state == TimerState.running) {
    _timerService.pause();
  }
}
```

The app correctly pauses the timer when backgrounded, but never resumes it when the user returns to foreground (`AppLifecycleState.resumed`). The user must manually tap Resume after returning. For a meditation app this is probably intentional, but it should be documented clearly — if it is intentional, add a code comment; if unintentional, add a resume handler.

A more significant gap: there is no handling for `AppLifecycleState.detached`. If the OS kills the app mid-session (OOM killer, force-stop), the in-progress session is lost with no partial record saved. For a meditation tracker, this is a data-integrity risk.

**Fix (optional, but recommended):**
On `AppLifecycleState.paused`, save a lightweight "in-progress session" marker to storage. On `initialize()`, check for and clear this marker — optionally surfacing a "recover incomplete session?" prompt. This is a relatively small addition given that `StorageService` already exists.

---

## Priority 3 — Code Quality and Maintainability

### 8. Background music path uses a different storage convention than bell sounds

**Files:** `lib/screens/settings_screen.dart:597–600`, `lib/services/audio_service.dart:146–148`

Bell sounds use `bundled:<name>` or `custom:<absolute-path>` prefixes consistently. Background music stores the raw file path with no prefix:

```dart
// Settings screen:
appState.updateConfig(appState.config.copyWith(backgroundMusic: result.files.single.path));

// AudioService:
if (path.startsWith('custom:')) {
  await _musicPlayer.setFilePath(path.substring(7));
} else {
  await _musicPlayer.setFilePath(path);  // treats raw path as file path
}
```

This inconsistency means the `custom:` prefix check in `AudioService.startBackgroundMusic` is dead code for the current implementation (it will never be reached from the settings screen). It also makes it harder to later add bundled background music tracks.

**Fix:** Store background music with the `custom:` prefix, consistent with bell sounds. Update `startBackgroundMusic` to require the prefix, and update the settings picker accordingly.

---

### 9. `StorageService.addSession()` is dead code

**Files:** `lib/services/storage_service.dart:149–153`

```dart
Future<void> addSession(SessionModel session) async {
  final sessions = await loadSessions();
  sessions.add(session);
  await saveSessions(sessions);
}
```

This method re-reads all sessions from disk before adding one, then saves. It is never called — `AppState.addSession()` calls `storageService.saveSessions(_sessions)` directly. The method also has a read-modify-write race condition: if two calls happen concurrently (unlikely but possible), one will overwrite the other's session. Delete this method or replace it with a note explaining why `AppState` owns the list.

---

### 10. Duration formatting is duplicated across five screens

**Files:**
- `lib/screens/history_screen.dart:327`
- `lib/screens/stats_screen.dart:102`
- `lib/screens/session_complete_screen.dart` (implicit in duration display)
- `lib/screens/session_detail_screen.dart`
- `lib/screens/notes_screen.dart`

Each screen has its own `_formatDuration(int seconds)` with slightly different logic (some include seconds, some only minutes). This is a localization landmine — if the app ever needs locale-aware duration formatting, it will need to be fixed in five places.

**Fix:** Extract a shared `lib/utils/formatters.dart` with named variants — `formatDurationCompact(int seconds)` for stat cards, `formatDurationFull(int seconds)` for session detail — and replace all inline implementations.

---

### 11. Date/time formatting is inline and repeated across screens

**Files:**
- `lib/screens/history_screen.dart:192–196`
- `lib/screens/session_detail_screen.dart:17`
- `lib/widgets/calendar_view.dart:67–73`

Date and time formatting is embedded directly in widget build methods with no shared helper. `HistoryScreen` constructs date strings via `DateFormat('MMM d, y', localeStr)` and manually builds a time string with `padLeft`:

```dart
final dateStr = DateFormat('MMM d, y', localeStr).format(date);
final timeStr =
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
```

`CalendarView` independently uses `DateFormat('MMMM y', localeStr)` for the month header and `DateFormat('E', localeStr)` for weekday headers. `SessionDetailScreen` formats dates and times by yet another inline approach.

The manual `padLeft` time construction is also 24-hour only — there is no 12h/AM-PM support, and adding it later would require finding all the construction sites.

**Fix:** Extend `lib/utils/formatters.dart` (to be created per finding #10) with shared helpers — `formatSessionDate(DateTime, Locale)`, `formatSessionTime(DateTime)`, and `formatMonthYear(DateTime, Locale)`. Centralise the 24h/12h policy decision in one place.

---

### 12. `_RealAudioPlayer` creates a new `AudioPlayer` on every source change

**Files:** `lib/services/audio_service.dart:19–48`

```dart
Future<void> setAsset(String path) async {
  await _player.dispose();
  _player = AudioPlayer();
  await _player.setAsset(path);
}
```

The comment documents this as a workaround for ExoPlayer stale format state on some Android versions. While valid as a workaround, disposing and recreating the ExoPlayer instance on every bell play (each session start, each interval bell, each session end) is expensive. On older devices with slower disk and slower class loading, this can add 100–400 ms of latency before the bell plays.

A better approach is to use a single `AudioPlayer` instance per bell slot and handle the format-state issue by calling `seek(Duration.zero)` before `play()` (which the code already does with `seek(Duration(milliseconds: 1))`). If the stale-format issue persists, use `AudioPlayer.setAudioSource()` with `preload: false` as the less-destructive reset path.

---

### 13. Missing ProGuard/R8 rules for release builds

**Files:** `android/app/` — no `proguard-rules.pro` customization present

Release builds with minification enabled (which should be added per finding #1) require ProGuard rules for:
- `just_audio` and ExoPlayer reflection-based codec selection
- `file_picker` and `share_plus` intent-related classes
- Any JSON deserialization code that uses reflection

Without these rules, release builds can crash with `ClassNotFoundException` or `NoSuchMethodException` that are not caught by debug testing.

**Fix:** Add `android/app/proguard-rules.pro` with at minimum:
```
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn com.google.android.exoplayer2.**
```
Check each plugin's own ProGuard instructions and consolidate them here.

---

### 14. `AppState.sessions` returns a new unmodifiable wrapper on every access

**Files:** `lib/providers/app_state.dart:27`

```dart
List<SessionModel> get sessions => List.unmodifiable(_sessions);
```

Every call to `appState.sessions` allocates a new `List` wrapper. This is called from `CalendarView` in `StatsScreen`, which already has the grouping issue noted above. Cache the unmodifiable view and rebuild it only when `_sessions` is mutated.

---

### 15. `_basePath` initialization is not concurrency-safe

**Files:** `lib/services/storage_service.dart:17–22`

```dart
Future<String> get basePath async {
  if (_basePath != null) return _basePath!;
  final dir = await getApplicationDocumentsDirectory();
  _basePath = dir.path;
  return _basePath!;
}
```

If two callers hit `basePath` before the first one completes (e.g., `loadConfig()` and `loadSessions()` called in parallel during `initialize()`), two `getApplicationDocumentsDirectory()` calls will be made and `_basePath` will be set twice. This is harmless in practice (same path), but it can be made truly safe by storing the `Future<String>` itself instead of the resolved value:

```dart
late final Future<String> _basePathFuture = _resolveBasePath();

Future<String> _resolveBasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<String> get basePath => _basePathFuture;
```

---

### 16. `SettingsScreen` is a single 750-line file with too many concerns

**Files:** `lib/screens/settings_screen.dart`

The screen owns section rendering, eight different dialog/picker builders, file picking, share integration, and config mutation — all in one stateless widget with private helper methods. It is readable now but expensive to change — any modification to a single section requires loading the full mental model of the file.

**Recommendation:** Extract section-level widgets (`_ProfileSection`, `_BellSoundsSection`, `_DataSection`) as separate private widget classes or separate files. Move picker dialogs into a `_SettingsDialogs` helper. This is low-urgency but will pay off before the screen gains more settings.

---

## Dependency and Build Observations

| Item | Observation |
|------|-------------|
| AGP `8.11.1` | Very recent. Verify compatibility with all Flutter plugins before releasing. |
| Kotlin `2.2.20` | Very recent. Monitor for plugin build breakage. |
| `just_audio ^0.9.36` | Locks to major 0.x — breaking changes are possible on minor bumps. Pin to an exact version for release. |
| `file_picker ^8.0.0` | Major version 8. Review changelog for Android scoped storage behavior. |
| `flutter_lints ^3.0.1` | Good. Ensure CI fails on lint warnings. |
| `minSdk` | Deferred to `flutter.minSdkVersion` — document the effective value (Flutter default is 21). `just_audio` requires 21+. |
| ProGuard | No rules file. Required once `minifyEnabled = true` is added. |
| Font assets | Noto Sans fonts are commented out in `pubspec.yaml`. For 27 supported locales (including Devanagari, Tamil, Kannada, etc.), system font fallback may render poorly on devices without those fonts. Uncomment the font section and bundle the fonts. |

---

## What Is Working Well

These are genuinely strong implementation choices that should be preserved:

- **Atomic storage writes** with `.tmp`/`.bak` recovery and corrupt-file quarantine (`lib/services/storage_service.dart`) — this is production-grade I/O handling rarely seen in small apps.
- **`AudioPlayerBase` abstraction** with `FakeAudioPlayer` for testing — makes the audio layer cleanly testable without Android hardware.
- **`StorageService.withBasePath()` test constructor** — dependency injection done right.
- **`TimerService` as a `ChangeNotifier`** consumed by `ListenableBuilder` in `HomeScreen` — correctly isolates timer rebuilds from the broader `AppState` rebuild scope.
- **Fallback localization delegates** for Sanskrit and other languages Flutter does not natively support — thoughtful and correct.
- **Import/export with merge strategy** and automatic reset of device-specific paths on import — good data portability design.
- **Interval bell suppression at countdown end** (`timer_service.dart:122–124`) — the edge case is explicitly handled.
- **100+ unit tests** covering storage, audio, timer, stats, and localization with edge cases — above average for this project size.

---

## Recommended Fix Order

1. **Android release config** — package ID, signing, minification (`build.gradle.kts`). Blocks any real release.
2. **Session completion bug** — `TimerService.stop()` → `SessionEndReason` enum → `_onSessionComplete()`. Corrupts persisted data.
3. **Audio focus management** — configure `AudioAttributes` in `AudioService`. Required for real-device correctness.
4. **`AppState` derived-state caching** — cache stats, sorted sessions, and the unmodifiable sessions view. Recompute only on mutation. Use `Selector` in screens.
5. **`ConfigModel` immutability** — make fields `final`, route all mutations through `copyWith`.
6. **`CalendarView` recomputation guard** — check `widget.sessions != oldWidget.sessions` in `didUpdateWidget`, cache formatters.
7. **Background music path convention** — align with `custom:` prefix used by bell sounds.
8. **Dead code removal** — `StorageService.addSession()`.
9. **Shared formatter utility** — `lib/utils/formatters.dart` covering both duration formatting (finding #10) and date/time formatting (finding #11).
10. **ProGuard rules** — once minification is enabled.
11. **`_RealAudioPlayer` — investigate** whether the dispose-recreate workaround can be replaced with a lighter reset strategy.
12. **Noto Sans fonts** — uncomment and bundle for the 27 supported locales.
