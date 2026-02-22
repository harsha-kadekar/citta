Run all Flutter tests for the Citta project.

## Setup: resolve paths first

Before running, detect the required paths:

1. **Flutter binary**: run `which flutter` — if not found, check `$HOME/flutter/flutter/bin/flutter`
2. **JAVA_HOME**: resolve Java 17 home in this order:
   - Run `mise where java@17` to get the exact path
   - If mise is unavailable, look for a `17.*` directory under `$HOME/.local/share/mise/installs/java/`
   - Last resort: use `$JAVA_HOME` only if it points to a Java 17 installation
3. **Android SDK**: use `$ANDROID_HOME` if set, otherwise default to `$HOME/Android/Sdk`

## Run tests

From the `citta/` subdirectory of the project:

```
JAVA_HOME=<resolved-java-home> \
ANDROID_HOME=<resolved-android-sdk> \
ANDROID_SDK_ROOT=<resolved-android-sdk> \
<resolved-flutter> test
```

## Report results
- Report how many tests passed, failed, or were skipped
- If any tests fail, show the failure output and suggest what might be wrong
- If all tests pass, confirm clearly
