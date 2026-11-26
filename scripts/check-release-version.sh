#!/usr/bin/env bash
# Check that a release tag matches the version in citta/pubspec.yaml at the
# tagged commit, and that its build number (the Android versionCode) is higher
# than at every earlier release tag and not used by any other. See docs/RELEASING.md (issue #107).
#
# Usage:
#   scripts/check-release-version.sh <tag>     # e.g. v0.4.0
#
# Run it from anywhere inside the repository. All v* tags must be fetched
# (in CI: actions/checkout with fetch-depth: 0) or the build number check only
# sees the tags that are present.
#
# Exit status: 0 when the tag is valid, 1 when it isn't, 2 on usage or git errors.
set -euo pipefail

PUBSPEC=citta/pubspec.yaml

die() { echo "error: $*" >&2; exit 2; }
fail() { echo "FAIL: $*"; exit 1; }

[[ $# -eq 1 ]] || { echo "Usage: $0 <tag>" >&2; exit 2; }
tag="$1"

git rev-parse --verify --quiet "refs/tags/$tag" >/dev/null \
  || die "tag not found: $tag"

# Prints the `version:` value of the pubspec at <ref> without surrounding
# quotes, or nothing when <ref> has no pubspec.
version_at() {
  { git show "$1:$PUBSPEC" 2>/dev/null || true; } \
    | sed -n 's/^version:[[:space:]]*["'"'"']\{0,1\}\([^"'"'"'[:space:]#]*\).*/\1/p' | head -1
}

version=$(version_at "$tag")
[[ -n "$version" ]] || fail "no version in $PUBSPEC at $tag"

name="${version%%+*}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+([1-9][0-9]*)$ ]] \
  || fail "$PUBSPEC version '$version' at $tag must be X.Y.Z+N with a positive build number N"
build="${BASH_REMATCH[1]}"

[[ "$tag" == "v$name" ]] \
  || fail "tag $tag does not match $PUBSPEC version $name (expected tag v$name)"

# Prints the build number at <ref>, or nothing.
build_at() {
  local v
  v=$(version_at "$1")
  [[ "$v" =~ \+([0-9]+)$ ]] && echo "$((10#${BASH_REMATCH[1]}))"
  return 0
}

# Earlier releases (v* tags reachable from this one) must have a lower build
# number. Later tags on the same history are ignored, so an old tag can still
# be re-checked.
while read -r other; do
  [[ -n "$other" && "$other" != "$tag" ]] || continue
  other_build=$(build_at "$other")
  [[ -n "$other_build" ]] || continue
  if (( other_build >= build )); then
    fail "build number $build at $tag is not higher than $other_build at $other; bump +N in $PUBSPEC"
  fi
done < <(git tag --list 'v*' --merged "$tag")

# No other release anywhere may use the same build number: stores reject a
# reused versionCode even when the two tags are on different branches.
while read -r other; do
  [[ -n "$other" && "$other" != "$tag" ]] || continue
  if [[ "$(build_at "$other")" == "$build" ]]; then
    fail "build number $build at $tag is already used by $other; bump +N in $PUBSPEC"
  fi
done < <(git tag --list 'v*')

echo "OK: $tag matches $PUBSPEC version $version"
