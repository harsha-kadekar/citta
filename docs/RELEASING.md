# Releasing Citta

- **Issue:** #107 — Define release versioning and tagging rules

F-Droid and Google Play reject an upload whose `versionCode` has already been
used, and F-Droid's auto-update finds new releases by matching git tags
against the version in `citta/pubspec.yaml`. A release that breaks either rule
can't be shipped to a store without cutting another one, so each release
follows the rules and the checklist below.

## Versioning rules

The single source of truth is the `version:` line in `citta/pubspec.yaml`:

```yaml
version: 0.3.0+4
#        ^^^^^ ^
#        |     +-- build number N → Android versionCode
#        +-------- X.Y.Z         → Android versionName
```

Gradle reads both through `flutter.versionName` and `flutter.versionCode`
(`citta/android/app/build.gradle.kts`). Don't set them anywhere else.

1. **Every release bumps the `+N` build number.** It must be higher than the
   build number of every earlier release, and it's never reused, not even for
   a release that was pulled or never reached a store. Increase it by 1 per
   release.
2. **`X.Y.Z` follows semantic versioning.** Bump the patch for fixes only, the
   minor for new features, and the major for breaking changes to stored data
   or behavior. While the app is `0.y.z`, a breaking change may bump the
   minor instead.
3. **Tag `vX.Y.Z` on the commit that sets that version.** The tag name is
   `v` followed by exactly the `X.Y.Z` part of `version:`, with no build
   number. The tag goes on the version-bump commit as it was merged to
   `master`. Use an annotated tag (`git tag -a`). Nothing checks this, and
   `v0.1.0`–`v0.3.0` are lightweight tags from before these rules.
4. **Tags are immutable.** Never move, delete or re-push a published tag. If a
   release is broken, fix it in a new release with a new version and a higher
   build number.

`scripts/check-release-version.sh <tag>` enforces rules 1 and 3. It reads
`citta/pubspec.yaml` at the tagged commit, and it fails when:

- the tag isn't `v<X.Y.Z>`
- the version has no `+N`
- `N` isn't higher than the build number at every earlier `v*` tag reachable
  from it
- any other `v*` tag, on any branch, already uses build number `N`

The tag-triggered `release` job in `.github/workflows/ci.yml` runs it first,
before it builds or publishes anything. A bad tag therefore fails the release
instead of publishing an APK that a store will reject.

Hotfixes are released from `master` like any other release. Avoid releasing
from a side branch. The check still catches a reused build number there, but a
side-branch release can end up with a lower build number than a newer
`master` release, and then it can't be installed as an update to it.

## Release checklist

Copy this into the release PR description and tick each item.

**Prepare**

- [ ] `master` is green in CI, and every change for this release is merged.
- [ ] Pick the new version `X.Y.Z` (see rule 2), and set `N` to the previous
      release's build number + 1.
- [ ] On a branch `chore/release-vX.Y.Z`, update `version:` in
      `citta/pubspec.yaml` to `X.Y.Z+N`.
- [ ] Add a row for `vX.Y.Z` to the [release history](#release-history)
      below. Change nothing else in this commit.
- [ ] Commit as `chore(release): bump version to X.Y.Z+N`.
- [ ] Open a PR, wait for CI to pass, and merge it to `master`.

**Tag**

- [ ] Update a local `master` and confirm `HEAD` is the merged bump commit:
      `git pull && git log -1 --oneline`.
- [ ] Check the version locally before tagging:

      ```sh
      git tag -a vX.Y.Z -m "chore(release): bump version to X.Y.Z+N"
      scripts/check-release-version.sh vX.Y.Z
      ```

      It must print `OK`. If it doesn't, delete the **unpushed** tag
      (`git tag -d vX.Y.Z`), fix the version in a new PR, and start again.
- [ ] Push the tag: `git push origin vX.Y.Z`.

**Publish**

- [ ] Watch the `release` job (`gh run watch`). It verifies the tag, the
      privacy manifest and the signing key, then creates the GitHub Release
      with `app-debug.apk` and `app-release.apk`.
- [ ] Download `app-release.apk` from the release and confirm the signer:
      `scripts/verify-release-key.sh app-release.apk` prints `OK`
      (see [android-signing-key.md](android-signing-key.md)).
- [ ] Add release notes to the GitHub Release.
- [ ] **F-Droid** (once Citta is listed): nothing to do for a normal
      release. F-Droid picks up the new tag through auto-update. Check that
      the build shows up on F-Droid within a few days.
- [ ] **Google Play** (once Citta is listed): build an app bundle from the tag
      (`flutter build appbundle --release`), upload it to the Play Console,
      and roll it out.
- [ ] If the release changes what data the app stores or which permissions it
      requests, confirm that [PRIVACY.md](../PRIVACY.md) is still accurate.

## Release history

| Tag | `pubspec.yaml` version | Notes |
| --- | --- | --- |
| `v0.1.0` | `1.0.0+1` | Predates these rules: the tag doesn't match the version, and the check rejects it. Debug-signed, old `com.example.citta` applicationId. |
| `v0.2.0` | `0.2.0+2` | Debug-signed, old applicationId. |
| `v0.2.1` | `0.2.1+3` | Debug-signed, old applicationId. |
| `v0.3.0` | `0.3.0+4` | First release signed with the release key. |

The next release's build number is the last row's `N` + 1.
