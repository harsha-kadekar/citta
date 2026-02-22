Build the Citta Flutter app as a release APK.

## Setup: resolve paths first

Before running, detect the required paths:

1. **Flutter binary**: run `which flutter` — if not found, check `$HOME/flutter/flutter/bin/flutter`
2. **JAVA_HOME**: run `mise where java` — if mise is not available, fall back to the existing `$JAVA_HOME` environment variable
3. **Android SDK**: use `$ANDROID_HOME` if set, otherwise default to `$HOME/Android/Sdk`

## Run build

From the `citta/` subdirectory of the project, first get dependencies then build:

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
- If successful, report the APK location: `citta/build/app/outputs/flutter-apk/app-release.apk`
- If it fails, show the error output and suggest what might be wrong
