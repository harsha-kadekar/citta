#!/usr/bin/env bash
# Verify that a keystore, APK or app bundle carries Citta's release signing certificate.
# See docs/android-signing-key.md (issue #105).
#
# Usage:
#   scripts/verify-release-key.sh <keystore|apk|aab>
#
# Keystores (.jks, .keystore, .p12, .pfx): the entry checked is $KEY_ALIAS
# (default "citta", the alias Gradle signs with). The store password is read
# from $KEYSTORE_PASSWORD; when it's unset, keytool prompts only if stdin is a
# terminal.
# APKs: apksigner is looked up on PATH, then under $ANDROID_HOME (default
# ~/Android/Sdk) build-tools. The APK must have exactly one signer.
# App bundles (.aab): checked with `keytool -printcert -jarfile`.
#
# Exit status: 0 on match, 1 on mismatch, 2 on usage or tool errors.
set -euo pipefail

# SHA-256 of the release signing certificate (lowercase hex, no colons).
RELEASE_CERT_SHA256="cee3a0e0f1f4b435be8541364111270dc283f8b4742d8ca138e407336dcb6716"
# Override only for testing the script itself.
expected="${CITTA_EXPECTED_CERT_SHA256:-$RELEASE_CERT_SHA256}"

die() { echo "error: $*" >&2; exit 2; }

[[ $# -eq 1 ]] || { echo "Usage: $0 <keystore|apk|aab>" >&2; exit 2; }
file="$1"
[[ -f "$file" ]] || die "file not found: $file"

normalize() { tr -d ':[:space:]' | tr '[:upper:]' '[:lower:]'; }

find_apksigner() {
  if command -v apksigner >/dev/null 2>&1; then
    command -v apksigner
    return
  fi
  local sdk="${ANDROID_HOME:-$HOME/Android/Sdk}" latest
  latest=$(ls -d "$sdk"/build-tools/*/ 2>/dev/null | sort -V | tail -1)
  [[ -n "$latest" && -x "${latest}apksigner" ]] || return 1
  echo "${latest}apksigner"
}

require_keytool() {
  command -v keytool >/dev/null 2>&1 || die "keytool not found (install a JDK)"
}

ext=$(tr '[:upper:]' '[:lower:]' <<<"${file##*.}")
case "$ext" in
  apk)
    apksigner=$(find_apksigner) || die "apksigner not found (install Android build-tools)"
    out=$("$apksigner" verify --print-certs "$file" 2>/dev/null) \
      || die "apksigner could not verify $file"
    digests=$(sed -n 's/^Signer #[0-9]* certificate SHA-256 digest: //p' <<<"$out")
    count=$(grep -c . <<<"$digests" || true)
    [[ "$count" -eq 1 ]] || die "expected exactly one signer in $file, found $count"
    actual=$(normalize <<<"$digests")
    ;;
  aab)
    require_keytool
    out=$(keytool -printcert -jarfile "$file") \
      || die "keytool could not read the signature of $file"
    count=$(grep -c '^Signer #' <<<"$out" || true)
    [[ "$count" -eq 1 ]] || die "expected exactly one signer in $file, found $count"
    actual=$(sed -n 's/^[[:space:]]*SHA256:[[:space:]]*//p' <<<"$out" | head -1 | normalize)
    ;;
  jks|keystore|p12|pfx)
    require_keytool
    alias="${KEY_ALIAS:-citta}"
    pass_args=()
    if [[ -n "${KEYSTORE_PASSWORD:-}" ]]; then
      pass_args=(-storepass:env KEYSTORE_PASSWORD)
    elif [[ ! -t 0 ]]; then
      die "set KEYSTORE_PASSWORD (stdin is not a terminal, so keytool can't prompt)"
    fi
    out=$(keytool -list -v -keystore "$file" -alias "$alias" ${pass_args[@]+"${pass_args[@]}"}) \
      || die "keytool could not read alias '$alias' from $file (wrong password or alias?)"
    actual=$(sed -n 's/^[[:space:]]*SHA256:[[:space:]]*//p' <<<"$out" | head -1 | normalize)
    ;;
  *)
    die "unsupported file type: $file (expected .jks, .keystore, .p12, .pfx, .apk or .aab)"
    ;;
esac

[[ -n "$actual" ]] || die "no certificate SHA-256 found in $file"

if [[ "$actual" == "$expected" ]]; then
  echo "OK: $file is signed with the Citta release key ($actual)"
else
  echo "MISMATCH: $file has certificate SHA-256 $actual"
  echo "          expected                     $expected"
  exit 1
fi
