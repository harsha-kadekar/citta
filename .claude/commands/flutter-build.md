Build the Citta Flutter app as a release APK.

First run `flutter pub get` to ensure dependencies are up to date, then build:

```
JAVA_HOME=/home/harsha/.local/share/mise/installs/java/17.0.2 \
ANDROID_HOME=/home/harsha/Android/Sdk \
ANDROID_SDK_ROOT=/home/harsha/Android/Sdk \
/home/harsha/flutter/flutter/bin/flutter pub get

JAVA_HOME=/home/harsha/.local/share/mise/installs/java/17.0.2 \
ANDROID_HOME=/home/harsha/Android/Sdk \
ANDROID_SDK_ROOT=/home/harsha/Android/Sdk \
/home/harsha/flutter/flutter/bin/flutter build apk --release
```

Run both commands from the `citta/` subdirectory (`/home/harsha/workspace/Citta/citta`).

After the build:
- If successful, report the APK location: `citta/build/app/outputs/flutter-apk/app-release.apk`
- If it fails, show the error output and suggest what might be wrong
