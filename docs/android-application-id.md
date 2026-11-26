# Decision: Android applicationId

- **Status:** Accepted
- **Date:** 2026-11-26
- **Issue:** #103 — Finalize the Android applicationId before first store release

## Decision

Citta keeps **`com.hkadekar.citta`** as its permanent Android `applicationId`
for F-Droid, Google Play and GitHub release APKs.

## Context

The `applicationId` identifies the app on a device and in every store. Once the
app is published to F-Droid or Google Play, it can't change. A different ID
counts as a different app: existing users get no update, and their on-device
data stays with the old install.

## Rationale

- **It has already shipped.** The `app-release.apk` attached to the GitHub
  v0.3.0 release uses `com.hkadekar.citta`, introduced in commit 80bc637.
  Changing the ID now would break in-place upgrades for everyone who installed
  that APK.
- **The earlier ID can't be published anyway.** v0.1.0 through v0.2.1 shipped
  with Flutter's placeholder `com.example.citta`, which Google Play rejects.
  That rename has already happened, so users of those builds already need to
  reinstall to get v0.3.0 or later. A second rename would add another break
  and fix nothing.
- **No store requires domain ownership.** Google Play only needs the ID to be
  globally unique. F-Droid has no ownership rule. A reverse-domain ID is a
  naming convention, not something either store checks.
- **It's a stable author handle.** `hkadekar` isn't tied to an employer, a
  hosting provider or a domain that could lapse.
- **It's already consistent.** The Gradle `namespace`, the `applicationId` and
  the Kotlin package of `MainActivity.kt` already match.

## Alternatives considered

| Option | Why it was rejected |
| --- | --- |
| `io.github.harsha_kadekar.citta` | Ties the ID to the GitHub namespace, but needs an awkward `_` (GitHub's `-` isn't valid in a package name), and it breaks upgrades from the v0.3.0 release APK. |
| A domain-based ID (`com.<domain>.citta`) | No domain is used for the project, and switching breaks upgrades from the v0.3.0 release APK. |
| Revert to `com.example.citta` (the v0.1.0–v0.2.1 ID) | Google Play rejects `com.example.*` package names. |

## Places that must stay in sync

All of these must equal `com.hkadekar.citta`:

1. `citta/android/app/build.gradle.kts`: `defaultConfig.applicationId`
2. `citta/android/app/build.gradle.kts`: `android.namespace`
3. `citta/android/app/src/main/kotlin/com/hkadekar/citta/MainActivity.kt`: the
   `package` line and the directory path

`citta/test/platform/application_id_test.dart` enforces all three, so an
accidental rename fails CI.

## Other platforms

`citta/linux/` is gitignored and isn't part of the repository, so it's out of
scope here and not covered by the guard test. Any locally generated Linux
scaffold sets its GTK `APPLICATION_ID` in `linux/CMakeLists.txt`. If a Linux
build is ever tracked or published (for example on Flathub), that value
should also be `com.hkadekar.citta`.
