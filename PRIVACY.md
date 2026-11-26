# Citta Privacy Policy

**Effective date:** 26 November 2026

Citta is a local-first meditation tracking app. This policy explains what
happens to your information when you use it. The short version: **Citta does
not collect, transmit, or share any of your data.** Everything you record stays
on your device unless you choose to move it.

## Information we collect

None. The developer of Citta does not collect, receive, or have access to any
personal information or usage data. There are no user accounts, no sign-up,
and no identifiers sent anywhere.

## No analytics, advertising, or tracking

Citta contains no analytics, advertising, crash-reporting, or tracking
libraries or SDKs, and does not build any profile of you.

## No network use

Citta works entirely offline. The release build does not request Android's
`INTERNET` permission, so the app cannot connect to the internet or send data
anywhere. (For example, if a note contains a Markdown link to an online image,
the image is not loaded.)

The app does declare `ACCESS_NETWORK_STATE`. This permission is added
automatically by the audio playback library Citta uses (AndroidX Media3) and
only allows checking whether a network connection exists; it cannot send or
receive data, and Citta does not use it.

## Data stored on your device

Citta stores the following as JSON files in the app's private storage on your
device, which other apps cannot read:

- your meditation session history (date, duration, timer mode, notes, tags);
- a snapshot of a session in progress (start time, elapsed time, timer mode,
  target duration), so an interrupted session can be resumed;
- quotes you add yourself;
- your app settings;
- if you enable encryption, the encryption settings needed to unlock your
  data (salts and encrypted keys — never your password).

Uninstalling Citta deletes this on-device data. It does not delete copies you
have exported, or any Android system backup (see below), which may restore
your data if you reinstall.

## Optional encryption

You can choose to encrypt your stored data with a password. When encryption is
enabled:

- Your session history — including your notes and tags — is encrypted with
  AES-256-GCM, using a key protected by your
  password (via the Argon2id key-derivation function) and by a recovery key
  that Citta gives you when you set up encryption.
- To avoid asking for your password on every launch, the decryption key is
  cached in your device's secure storage (backed by the Android Keystore).
  Turning encryption off removes it.
- Encryption does **not** cover your app settings, quotes you have added, or
  the in-progress session snapshot; these remain stored unencrypted.
- Your password and recovery key never leave your device and are not known to
  the developer. **If you lose both, your encrypted data cannot be recovered.**

## Export and import

You can export your data from Settings. Export uses your device's standard
share sheet, and **you** choose where the file goes (for example, a file
manager, email, or a cloud drive). Once exported, the file is handled by
whichever app or service you send it to, under that service's own privacy
policy. If encryption is enabled, you can choose an encrypted export protected
by your password.

Import reads only the file you pick with your device's file picker.

## Files you choose

If you select your own audio file for a bell or background music, Citta reads
it from your device through the system file picker to play it. The file is not
uploaded or shared.

## Android system backup

Citta does not back up your data anywhere itself. However, Android's built-in
backup feature may include the app's data in your device backup (for example,
to your Google account) if backup is enabled in your device settings. This is
controlled by you and by Android, and is subject to Google's privacy policy.
If you use Citta's encryption, your session history remains encrypted in such
a backup; your settings, added quotes, and any in-progress session snapshot
are backed up unencrypted.

## Children's privacy

Citta does not collect personal information from anyone, including children.

## Changes to this policy

If this policy changes — for example, if a future version adds a feature that
uses the network — the updated policy will be published at this same address
with a new effective date, and the change will be noted in the release notes.
The full history of this document is available in the
[repository](https://github.com/harsha-kadekar/citta/commits/master/PRIVACY.md).

## Contact

Questions about this policy can be raised by opening an issue at
<https://github.com/harsha-kadekar/citta/issues>.
