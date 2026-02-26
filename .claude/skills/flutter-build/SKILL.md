---
name: flutter-build
description: Build the Citta Flutter app as a release APK
---

Build the Citta Flutter app as a release APK.

## Setup: resolve paths first

1. **Flutter binary**: check `$HOME/flutter/flutter/bin/flutter` first (flutter is not on $PATH on this machine); fall back to `which flutter` if that path does not exist
2. **JAVA_HOME**: resolve Java 17 home in this order:
   - Run `mise where java@17` to get the exact path
   - If mise is unavailable, look for a `17.*` directory under `$HOME/.local/share/mise/installs/java/`
   - Last resort: use `$JAVA_HOME` only if it points to a Java 17 installation
3. **Android SDK**: use `$ANDROID_HOME` if set, otherwise default to `$HOME/Android/Sdk`

## Run build

From `$HOME/workspace/Citta/citta/`, first get dependencies then build:

```
JAVA_HOME=<resolved-java-home> \
ANDROID_HOME=<resolved-android-sdk> \
ANDROID_SDK_ROOT=<resolved-android-sdk> \
<resolved-flutter> pub get

JAVA_HOME=<resolved-java-home> \
ANDROID_HOME=<resolved-android-sdk> \
ANDROID_SDK_ROOT=<resolved-android-sdk> \
<resolved-flutter> build apk --release
```

## Report results
- If successful, report the APK location and file size
- If it fails, show the full error output
