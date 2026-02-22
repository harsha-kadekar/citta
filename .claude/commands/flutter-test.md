Run all Flutter tests for the Citta project.

Use the following command (exact paths required due to local setup):

```
JAVA_HOME=/home/harsha/.local/share/mise/installs/java/17.0.2 \
ANDROID_HOME=/home/harsha/Android/Sdk \
ANDROID_SDK_ROOT=/home/harsha/Android/Sdk \
/home/harsha/flutter/flutter/bin/flutter test
```

Run it from the `citta/` subdirectory (`/home/harsha/workspace/Citta/citta`).

After the tests complete:
- Report how many tests passed, failed, or were skipped
- If any tests fail, show the failure output and suggest what might be wrong
- If all tests pass, confirm clearly
