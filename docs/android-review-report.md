# Citta Android/Mobile Code Review Report

## Scope

This review covers the Flutter app in `citta/` from a senior Android/mobile engineering perspective, with emphasis on:

- runtime performance and rebuild behavior
- maintainability and duplicated logic
- Android release readiness

Test coverage was intentionally skipped per request.

## Executive Summary

The codebase is small and understandable, with a clean service split and mostly straightforward UI flow. The biggest immediate problems are:

- an incorrect session completion flag that records manually stopped sessions as fully completed
- Android release configuration that is still using template values and debug signing
- missing Android audio focus handling for bells/background audio
- repeated derived-state work in `AppState` and screen builds that will become more expensive as session history grows
- mutable configuration/state patterns that make the app harder to reason about and easier to regress
- repeated formatting and screen-level helper logic that should be centralized

## Priority Findings

### 1. Manual stop is recorded as a fully completed session

Severity: High

Files:

- `citta/lib/screens/home_screen.dart:107`
- `citta/lib/screens/home_screen.dart:120`
- `citta/lib/screens/home_screen.dart:135`

Problem:

`_stopSession()` calls `TimerService.stop()`, which sets the timer state to `completed`. `_onSessionComplete()` then builds the `SessionModel` with:

- `completedFully: _timerService.state == TimerState.completed`

That means both natural timer completion and manual interruption are persisted as fully completed sessions. This corrupts session history, affects stats quality, and makes the completion badge unreliable across `HistoryScreen`, `NotesScreen`, and `SessionDetailScreen`.

Recommended fix:

- distinguish `stoppedByUser` from `completedNaturally`
- pass an explicit completion reason into `_onSessionComplete()`
- persist `completedFully = true` only when countdown actually reaches the target or stopwatch flow is intentionally considered complete by product definition

Suggested implementation:

- add a local boolean or enum such as `SessionEndReason.completed` / `SessionEndReason.stopped`
- set it from timer callbacks and stop actions instead of inferring from `TimerState`
- update dependent UI to rely on the corrected persisted value only

Acceptance criteria:

- manually stopped sessions do not show as completed in history/detail screens
- naturally completed sessions still do

### 2. Android release config is not production-ready

Severity: High

Files:

- `citta/android/app/build.gradle.kts:23`
- `citta/android/app/build.gradle.kts:24`
- `citta/android/app/build.gradle.kts:35`
- `citta/android/app/build.gradle.kts:37`

Problem:

The app still uses the template application ID `com.example.citta`, and release builds are signed with the debug signing config. This is not acceptable for shipping and creates upgrade/signing risk on Android.

Recommended fix:

- replace `applicationId` with the real package name
- configure a proper release signing config from Gradle properties or environment variables
- keep debug signing only for debug builds

Acceptance criteria:

- release builds no longer use debug signing
- package name is stable and intentional
- the TODO markers are removed

### 3. Audio playback does not manage Android audio focus

Severity: High

Files:

- `citta/lib/services/audio_service.dart:50`
- `citta/lib/screens/home_screen.dart:59`

Problem:

The app plays bells and optional looping background music through `just_audio`, but the audio layer does not request or react to Android audio focus. In practice that means the app has no explicit policy for interruptions such as phone calls, another media app starting playback, or transient focus loss.

This is less about code style and more about real-device correctness. A meditation app should behave predictably when the OS or another app interrupts audio.

Recommended fix:

- configure Android audio attributes/focus behavior for both bell and background playback
- make interruption behavior explicit: pause, duck, or stop as appropriate
- ensure internal playback state stays aligned with actual player state after interruptions or failures

Acceptance criteria:

- playback behavior is defined and tested for interruption scenarios
- background music state does not remain "playing" after unexpected stop/focus loss

### 4. Derived state is recomputed repeatedly across rebuilds

Severity: Medium

Files:

- `citta/lib/providers/app_state.dart:27`
- `citta/lib/providers/app_state.dart:29`
- `citta/lib/providers/app_state.dart:66`
- `citta/lib/providers/app_state.dart:83`
- `citta/lib/screens/stats_screen.dart:13`
- `citta/lib/screens/stats_screen.dart:15`
- `citta/lib/screens/stats_screen.dart:94`

Problem:

`AppState` computes several derived values on demand:

- `sessions` creates a new unmodifiable wrapper every access
- `stats` recalculates from the full session list every access
- `sortedSessions` sorts a copied list every access
- `filterByTags()` filters and sorts every call

These are then consumed from screens using broad `context.watch<AppState>()`, which means unrelated config updates can trigger avoidable work. This is fine at small scale, but the history and stats screens will become progressively more expensive as session volume grows.

Recommended fix:

- cache derived session data in `AppState` and recompute only when `_sessions` changes
- expose stable read-only collections instead of recreating wrappers each access
- replace broad `context.watch<AppState>()` with `Selector`/`context.select()` where only one field is needed

Suggested implementation:

- maintain `_sortedSessions`, `_stats`, and optionally a grouped/tag index alongside `_sessions`
- recompute these only inside `initialize()`, `addSession()`, `deleteSessions()`, and `importData()`
- split stats/config consumption so toggling calendar/theme does not force unnecessary list-derived work

Acceptance criteria:

- `HistoryScreen` and `StatsScreen` stop sorting/recomputing from scratch on unrelated config changes
- UI behavior remains unchanged

### 5. `CalendarView` does unnecessary recomputation and object churn

Severity: Medium

Files:

- `citta/lib/widgets/calendar_view.dart:25`
- `citta/lib/widgets/calendar_view.dart:31`
- `citta/lib/widgets/calendar_view.dart:67`
- `citta/lib/widgets/calendar_view.dart:70`

Problem:

`CalendarView` rebuilds grouped session data in both `initState()` and every `didUpdateWidget()` without checking whether the sessions actually changed. It also recreates date formatters and weekday headers inside `build()`.

On its own this is not catastrophic, but it compounds the broader derived-state issue and creates avoidable work during stats/config changes.

Recommended fix:

- move grouping responsibility out of the widget and pass in already-grouped data
- or, at minimum, only regroup when the input sessions actually change
- cache month and weekday formatters per locale instead of rebuilding them on every frame

Acceptance criteria:

- month navigation only rebuilds presentation state
- session regrouping happens only when the underlying session data changes

### 6. `ConfigModel` and `AppState` mix immutable and mutable state patterns

Severity: Medium

Files:

- `citta/lib/models/config_model.dart:18`
- `citta/lib/models/config_model.dart:27`
- `citta/lib/models/config_model.dart:45`
- `citta/lib/providers/app_state.dart:93`
- `citta/lib/providers/app_state.dart:101`

Problem:

The code uses `copyWith()` in some places, but also mutates model internals directly:

- `ConfigModel.tags` and `quoteSources` are mutable lists
- `AppState.addTag()` and `removeTag()` mutate `_config.tags` in place

This makes state transitions inconsistent. Over time it becomes harder to guarantee that persistence, rebuilds, and business rules all stay in sync, especially once more settings or background work are added.

Recommended fix:

- make `ConfigModel` effectively immutable
- store unmodifiable list fields or defensively copy on read
- update tags and other collections via `copyWith()` only

Acceptance criteria:

- no screen or provider mutates `ConfigModel` internals directly
- all config changes flow through one update path

### 7. Session lifecycle handling stops at pause and does not protect in-progress data

Severity: Medium

Files:

- `citta/lib/screens/home_screen.dart:74`
- `citta/lib/providers/app_state.dart:34`
- `citta/lib/services/storage_service.dart:9`

Problem:

`HomeScreen.didChangeAppLifecycleState()` pauses an active timer when the app is backgrounded, but there is no persistence of in-progress session state. If the process is later killed while a session is paused or running, the session disappears entirely.

For a meditation tracker this is a data-integrity/product-behavior gap more than a crash bug, but it is worth defining before release.

Recommended fix:

- decide whether interrupted sessions should be discarded or recoverable
- if recoverable, persist a lightweight in-progress session marker on pause/background
- clear or reconcile that marker on next launch

Acceptance criteria:

- interrupted-session behavior is explicit
- app restart after process death does not silently lose state if recovery is intended

## Duplication and Maintainability Opportunities

### 8. Duration formatting logic is duplicated in multiple screens

Files:

- `citta/lib/screens/history_screen.dart:327`
- `citta/lib/screens/notes_screen.dart:61`
- `citta/lib/screens/session_complete_screen.dart:32`
- `citta/lib/screens/session_detail_screen.dart:151`
- `citta/lib/screens/stats_screen.dart:102`

Problem:

There are multiple slightly different `_formatDuration()` implementations scattered across screens. Some include seconds, some only minutes, and the formatting rules are embedded in UI classes.

Recommendation:

- extract a shared formatter utility or `Duration`/`int` extension
- define named variants if product wants different display modes, for example compact stats vs session detail

Expected benefit:

- consistent UI output
- less duplication
- easier localization later

### 9. Date/time formatting is inline and repeated in presentation code

Files:

- `citta/lib/screens/history_screen.dart:192`
- `citta/lib/screens/session_detail_screen.dart:17`
- `citta/lib/widgets/calendar_view.dart:67`

Problem:

Date formatting rules are repeated in screen widgets, along with manual time string construction. This is manageable today, but it is exactly the kind of duplication that becomes painful when localization requirements change.

Recommendation:

- extract shared localized date/time helpers
- centralize 12h/24h policy and locale fallback behavior

### 10. Background music path handling is inconsistent with bell sound IDs

Files:

- `citta/lib/screens/settings_screen.dart:592`
- `citta/lib/services/audio_service.dart:144`

Problem:

Bell sounds consistently use prefixed identifiers like `bundled:...` and `custom:...`, while background music is currently stored as a raw file path. `AudioService.startBackgroundMusic()` supports both formats, so this is not broken today, but it does create an inconsistent config shape and makes future extension to bundled music options less clean.

Recommendation:

- choose one storage convention for audio selections
- if bells are the model to follow, store background music as `custom:<path>` as well
- keep `AudioService` tolerant during migration so existing saved configs still work

Expected benefit:

- more consistent config data
- simpler future expansion of background music sources

### 11. `StorageService.addSession()` appears unused and duplicates persistence flow

Files:

- `citta/lib/services/storage_service.dart:149`
- `citta/lib/providers/app_state.dart:60`

Problem:

`StorageService.addSession()` loads sessions from disk, appends one, and writes the full list back, but `AppState.addSession()` already owns the in-memory list and persists it directly. If `StorageService.addSession()` is truly unused, it adds maintenance cost and suggests a second persistence path that the app does not actually follow.

Recommendation:

- remove the method if it is dead
- otherwise document when it should be used versus `AppState.addSession()`

Expected benefit:

- clearer ownership of session persistence
- less chance of future divergence between two write paths

### 12. `_basePath` lazy initialization is harmless but not fully synchronized

Files:

- `citta/lib/services/storage_service.dart:17`

Problem:

`StorageService.basePath` memoizes the resolved path after the first async call, but concurrent first callers can race and resolve the same directory more than once before `_basePath` is set.

This is not a correctness bug in the current implementation because the resulting path should be identical, but it is a small cleanup opportunity in a foundational service.

Recommendation:

- store the in-flight `Future<String>` instead of only the resolved string if this service is refactored further
- treat this as low-priority cleanup, not urgent product work

### 13. Settings screen is doing too much in one file

Primary file:

- `citta/lib/screens/settings_screen.dart`

Problem:

`SettingsScreen` contains section rendering, dialog orchestration, picker behavior, and persistence triggers in one large file. It is readable now, but future changes will be slower and riskier because the screen owns too many concerns.

Recommendation:

- split into section widgets such as profile, timer, bells, tags, data
- move picker/dialog builders into dedicated helpers or reusable bottom-sheet/dialog components
- centralize config mutation calls so the screen is declarative

Expected benefit:

- lower cognitive load
- easier review and targeted refactors
- simpler future widget testing if added later

## Claude Code Execution Plan

Recommended order:

1. Fix session completion semantics in `HomeScreen` and verify all completed indicators use the corrected persisted field.
2. Clean up Android release config in `android/app/build.gradle.kts`.
3. Define Android audio focus/interruption behavior for bells and background music.
4. Refactor `AppState` to cache derived values and reduce broad rebuilds with `Selector`/`context.select()`.
5. Move calendar grouping out of `CalendarView` or guard recomputation properly.
6. Make `ConfigModel` immutable and remove in-place list mutation from `AppState`.
7. Decide interrupted-session recovery behavior and persist minimal in-progress state if needed.
8. Extract shared formatting utilities for duration and date/time output.
9. Normalize background music path conventions and remove dead persistence helpers.
10. Break up `SettingsScreen` into smaller widgets/helpers.

## Suggested Refactor Targets

- create `lib/utils/formatters.dart` for duration/date helpers
- create a small derived-state refresh method in `AppState`, for example `_recomputeDerivedState()`
- consider a lightweight view-model object for history/stats if the provider starts growing further
- define a single config/data convention for all audio asset selections
- keep Android release constants out of source where possible and load signing values from Gradle properties

## Final Assessment

The app is in a workable state, but it still has a few template-level Android issues and some early-stage state management shortcuts that will become more expensive as the data set and feature count grow. The best next move is not a broad rewrite. It is a focused pass on session correctness, release readiness, derived-state caching, and shared formatting/utilities.

## Atomic Task List For Claude Code

The tasks below are intentionally small and independently executable. Each task should be completed with code changes, any necessary tests, and a short validation note.

### Task 1. Fix manual-stop completion semantics

Files:

- `citta/lib/screens/home_screen.dart`
- `citta/lib/services/timer_service.dart`
- any affected session presentation screens/tests

Deliverable:

- introduce an explicit session end reason for natural completion vs user stop
- persist `completedFully` from that explicit reason instead of inferring from `TimerState.completed`

Done when:

- manually stopped sessions persist as incomplete
- naturally completed sessions persist as complete

### Task 2. Add regression tests for session completion semantics

Files:

- existing timer/home/session tests as appropriate

Deliverable:

- add tests covering manual stop and natural completion flows

Done when:

- tests fail before the fix and pass after it

### Task 3. Make Android release config production-ready

Files:

- `citta/android/app/build.gradle.kts`
- Android signing/property files if needed

Deliverable:

- replace template package values with the real application ID/namespace
- remove debug signing from release builds
- wire release signing from Gradle properties or environment variables

Done when:

- release config no longer depends on debug signing
- template TODOs related to package/signing are removed

### Task 4. Define and implement Android audio focus behavior

Files:

- `citta/lib/services/audio_service.dart`
- any Android/plugin integration points required

Deliverable:

- configure interruption/focus behavior for bells and background music
- keep internal playback state aligned with actual player state after interruptions

Done when:

- expected behavior for interruption scenarios is implemented and documented in code/tests

### Task 5. Add tests for audio interruption/state synchronization

Files:

- `citta/test/services/audio_service_test.dart`

Deliverable:

- add or extend tests covering focus-loss/interruption-related state transitions where feasible with current abstractions

Done when:

- audio state behavior is asserted instead of implied

### Task 6. Cache derived session state in `AppState`

Files:

- `citta/lib/providers/app_state.dart`

Deliverable:

- add cached derived fields for stats/sorted sessions and refresh them only when `_sessions` changes

Done when:

- `stats` and sorted-session access stop recalculating from scratch on unrelated config updates

### Task 7. Reduce broad `AppState` watches in screens

Files:

- `citta/lib/screens/home_screen.dart`
- `citta/lib/screens/history_screen.dart`
- `citta/lib/screens/stats_screen.dart`

Deliverable:

- replace broad `context.watch<AppState>()` usage with narrower `Selector` or `context.select()` reads where appropriate

Done when:

- unrelated config changes no longer force avoidable derived-session work in those screens

### Task 8. Fix `CalendarView` recomputation behavior

Files:

- `citta/lib/widgets/calendar_view.dart`
- optionally `citta/lib/providers/app_state.dart`

Deliverable:

- stop unconditional regrouping in `didUpdateWidget()`
- avoid recreating date-formatting helpers on every build where practical

Done when:

- regrouping only occurs when relevant session input changes

### Task 9. Make `ConfigModel` updates immutable

Files:

- `citta/lib/models/config_model.dart`
- `citta/lib/providers/app_state.dart`
- `citta/lib/services/storage_service.dart`

Deliverable:

- remove direct in-place config/list mutation
- route config changes through `copyWith()`/single update paths

Done when:

- `ConfigModel` internals are not mutated directly by providers/services

### Task 10. Decide and implement interrupted-session recovery behavior

Files:

- `citta/lib/screens/home_screen.dart`
- `citta/lib/providers/app_state.dart`
- `citta/lib/services/storage_service.dart`

Deliverable:

- define product behavior for in-progress sessions when the app is backgrounded or killed
- implement minimal persistence/recovery only if the chosen behavior requires it

Done when:

- interrupted-session behavior is explicit in code and no longer accidental

### Task 11. Extract shared duration/date formatter utilities

Files:

- create `citta/lib/utils/formatters.dart`
- update affected screens

Deliverable:

- centralize duplicated duration formatting
- centralize repeated date/time formatting helpers

Done when:

- screen-local duplicate formatting helpers are removed or substantially reduced

### Task 12. Normalize background music config format

Files:

- `citta/lib/screens/settings_screen.dart`
- `citta/lib/services/audio_service.dart`
- `citta/lib/models/config_model.dart`

Deliverable:

- choose one persisted format for background music selection
- keep backward compatibility for already-saved raw-path configs if needed

Done when:

- background music storage follows one documented convention

### Task 13. Remove or document `StorageService.addSession()`

Files:

- `citta/lib/services/storage_service.dart`

Deliverable:

- delete the method if unused, or document why it exists and when it should be used

Done when:

- there is only one clearly-owned session persistence path

### Task 14. Clean up `StorageService.basePath` initialization

Files:

- `citta/lib/services/storage_service.dart`

Deliverable:

- optionally replace string memoization with in-flight future memoization

Done when:

- base path initialization is clearly single-flight or intentionally documented as-is

### Task 15. Split `SettingsScreen` into smaller units

Files:

- `citta/lib/screens/settings_screen.dart`
- any extracted widget/helper files

Deliverable:

- extract section widgets and/or dialog helpers so the screen stops owning all concerns in one file

Done when:

- the main settings screen file is materially smaller and responsibilities are clearer

### Suggested execution order

1. Task 1
2. Task 2
3. Task 3
4. Task 4
5. Task 5
6. Task 6
7. Task 7
8. Task 8
9. Task 9
10. Task 10
11. Task 11
12. Task 12
13. Task 13
14. Task 14
15. Task 15

## GitHub Issues

| Task | Title | Severity | Issue |
|------|-------|----------|-------|
| Task 1 | Fix manual-stop completion semantics | High | [#5](https://github.com/harsha-kadekar/citta/issues/5) |
| Task 2 | Add regression tests for session completion semantics | Medium | [#6](https://github.com/harsha-kadekar/citta/issues/6) |
| Task 3 | Make Android release config production-ready | High | [#7](https://github.com/harsha-kadekar/citta/issues/7) |
| Task 4 | Define and implement Android audio focus behavior | High | [#8](https://github.com/harsha-kadekar/citta/issues/8) |
| Task 5 | Add tests for audio interruption and state synchronization | Medium | [#9](https://github.com/harsha-kadekar/citta/issues/9) |
| Task 6 | Cache derived session state in AppState | Medium | [#10](https://github.com/harsha-kadekar/citta/issues/10) |
| Task 7 | Reduce broad AppState watches with Selector/context.select() | Medium | [#11](https://github.com/harsha-kadekar/citta/issues/11) |
| Task 8 | Fix CalendarView unnecessary recomputation and object churn | Medium | [#12](https://github.com/harsha-kadekar/citta/issues/12) |
| Task 9 | Make ConfigModel updates immutable | Medium | [#13](https://github.com/harsha-kadekar/citta/issues/13) |
| Task 10 | Decide and implement interrupted-session recovery behavior | Medium | [#14](https://github.com/harsha-kadekar/citta/issues/14) |
| Task 11 | Extract shared duration and date formatter utilities | Low | [#15](https://github.com/harsha-kadekar/citta/issues/15) |
| Task 12 | Normalize background music config storage format | Low | [#16](https://github.com/harsha-kadekar/citta/issues/16) |
| Task 13 | Remove or document StorageService.addSession() dead code | Low | [#17](https://github.com/harsha-kadekar/citta/issues/17) |
| Task 14 | Clean up StorageService.basePath lazy initialization | Low | [#18](https://github.com/harsha-kadekar/citta/issues/18) |
| Task 15 | Split SettingsScreen into smaller focused widgets | Low | [#19](https://github.com/harsha-kadekar/citta/issues/19) |
