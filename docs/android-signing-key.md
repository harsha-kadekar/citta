# Android release signing key

- **Issue:** #105 — Back up the release keystore and document key management
- **Last verified:** 2026-11-26, against the v0.3.0 GitHub release APK

The release signing key is Citta's identity on Android. Android, F-Droid and
Google Play only install an update when it's signed with the same key as the
installed app. **If this key is lost, no existing user can ever receive another
update.** If it leaks, anyone can ship an "update" that installs over Citta and
reads its data.

This file records only public information. The keystore and its passwords
must **never** be committed. The root `.gitignore` and
`citta/android/.gitignore` exclude `key.properties`, `*.jks`, `*.keystore`,
`*.p12` and `*.pfx` anywhere in the repository, and
`citta/test/platform/release_signing_test.dart` checks with
`git check-ignore` that those rules stay in place.

## Certificate

| Field | Value |
| --- | --- |
| Certificate SHA-256 | `cee3a0e0f1f4b435be8541364111270dc283f8b4742d8ca138e407336dcb6716` |
| Certificate SHA-256 (colon form) | `CE:E3:A0:E0:F1:F4:B4:35:BE:85:41:36:41:11:27:0D:C2:83:F8:B4:74:2D:8C:A1:38:E4:07:33:6D:CB:67:16` |
| Certificate SHA-1 | `e100b880aa3777c080cfc86ecd40a20217e6bc4f` |
| Public key SHA-256 | `e7c98ef1190fc6bccccf56741dd33748aa222e706e6824a88aec621ffaf26b11` |
| Subject / issuer DN | `CN=Harsha Kadekar, OU=Unknown, O=Unknown, L=Redmond, ST=WA, C=US` (self-signed) |
| Serial number | `299255817aa114d7` |
| Key | RSA 2048, signature algorithm SHA384withRSA |
| Valid | 2026-06-09 → 2053-10-25 |
| Keystore | PKCS12, file name `citta-release.jks`, key alias `citta` |
| APK signature schemes | v2 only, as produced by the current Gradle build (v1 and v3 not present in v0.3.0) |

`scripts/verify-release-key.sh` pins the same SHA-256, and the guard test
fails if the doc and the script ever disagree. The script accepts a keystore
(`.jks`, `.keystore`, `.p12`, `.pfx`; it checks the `citta` alias, or
`$KEY_ALIAS`), a release APK, or an app bundle (`.aab`), and it refuses any
APK or bundle with more than one signer. The tag-triggered `release` job in
`.github/workflows/ci.yml` runs it on `app-release.apk` before creating the
GitHub Release, so a wrongly configured `ANDROID_KEYSTORE_BASE64` secret
fails the release instead of publishing an APK that can't upgrade anyone.

### Release history

v0.3.0 is the first release signed with this key. v0.1.0–v0.2.1 were signed
with throwaway debug keys, each one different, and they also used the old
`com.example.citta` applicationId (see `android-application-id.md`). Users of
those builds already have to reinstall, so no earlier key needs to be kept.

## Where the key is used

| Location | What it holds | Is it a backup? |
| --- | --- | --- |
| `~/citta-release.jks` on the maintainer's workstation | The keystore | Working copy only: one disk is not a backup |
| `citta/android/key.properties` (local, gitignored) | Path, alias and passwords for local release builds | No |
| GitHub Actions secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | Base64 keystore and credentials for the tag-triggered `release` job in `.github/workflows/ci.yml` | **No.** GitHub secrets are write-only and can't be read back out |

## Backups

Keep the keystore file **and** both passwords (store and key) together in at
least two independent offsite locations. A keystore without its password is
as useless as no keystore.

| # | Location | Contents | Last restore test |
| --- | --- | --- | --- |
| 1 | Password manager: a secure note or item with the `.jks` attached | Keystore, store password, key password, alias, this SHA-256 | _not yet tested_ |
| 2 | Encrypted offline copy (for example an `age`/GPG-encrypted file on a USB drive or in cloud storage, with its passphrase kept somewhere other than the file) | Keystore plus passwords | _not yet tested_ |

Rules:

- Don't keep both copies with the same provider or on the same device.
- Record the date in the table above after each restore test. Re-test at
  least once a year, and after any change to the backups.
- Never email, chat-paste or commit the keystore or its passwords.

## Restore

To recover the keystore on a new machine, or to rebuild CI secrets:

1. Copy the keystore out of one backup to a path outside the repository, for
   example `~/citta-release.jks`, with `chmod 600`.
2. Verify that it's the real release key:

   ```sh
   KEYSTORE_PASSWORD='<store password>' scripts/verify-release-key.sh ~/citta-release.jks
   ```

   It checks the `citta` alias, the one Gradle signs with. It must print
   `OK`. `MISMATCH` means this is the wrong keystore: don't
   build or publish with it.
3. Recreate `citta/android/key.properties` from
   `citta/android/key.properties.example`, using that path, alias `citta` and
   the passwords.
4. Build and check a signed APK:

   ```sh
   cd citta && flutter build apk --release
   ../scripts/verify-release-key.sh build/app/outputs/flutter-apk/app-release.apk
   ```

5. To restore CI, set the four secrets again, for example
   `base64 -w0 ~/citta-release.jks | gh secret set ANDROID_KEYSTORE_BASE64`.
   The next tagged release verifies the signer before publishing.

### Restore test

A restore test is steps 1–4 run from a **backup** copy, ideally on a different
machine or in a fresh directory, without looking at the working copy. Record
the date in the Backups table once it passes.

## Store-specific notes

### F-Droid

- F-Droid reproducible builds publish the developer-signed APK only when the
  APK it builds matches it. The build metadata (`fdroiddata`) pins the signer
  with `AllowedAPKSigningKeys:` set to the certificate SHA-256 in lowercase
  with no colons:
  `cee3a0e0f1f4b435be8541364111270dc283f8b4742d8ca138e407336dcb6716`.
- If F-Droid signs with its own key instead, F-Droid users get a different
  signature and can't upgrade to or from GitHub release APKs without
  reinstalling.

### Google Play

- Enroll in **Play App Signing**. Google then holds the app signing key, and
  this keystore can serve as the upload key. A lost upload key can be reset
  through Play Console support. A lost app signing key can't be reset.
- If this key is uploaded to Play as the app signing key, which keeps Play
  and GitHub/F-Droid APKs signature-compatible, it must still stay backed up
  here. F-Droid and GitHub releases depend on it either way.
- Play Console shows the app signing and upload certificate SHA-256 values.
  Check them against the table above after setup.

## If the key is lost or compromised

- **Lost, with no backup:** no update can reach existing installs. The only
  way forward is a new key, which (because of signature pinning) means a new
  `applicationId` and new store listings, with every user reinstalling and
  losing on-device data unless they export it first.
- **Compromised:** rotate right away. Android's APK Signature Scheme v3.1
  supports key rotation with a proof-of-rotation lineage
  (`apksigner rotate`), and Play App Signing supports an upload key reset or
  app signing key upgrade. Update this doc, the script constant and the
  F-Droid metadata to the new fingerprint, and keep the old key in the
  lineage.
