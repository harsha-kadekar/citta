Run Flutter static analysis on the Citta project.

## Setup: resolve paths first

Before running, detect the required paths:

1. **Flutter binary**: run `which flutter` — if not found, check `$HOME/flutter/flutter/bin/flutter`
2. **JAVA_HOME**: resolve Java 17 home in this order:
   - Run `mise where java@17` to get the exact path
   - If mise is unavailable, look for a `17.*` directory under `$HOME/.local/share/mise/installs/java/`
   - Last resort: use `$JAVA_HOME` only if it points to a Java 17 installation

## Run analysis

From the `citta/` subdirectory of the project:

```
JAVA_HOME=<resolved-java-home> \
<resolved-flutter> analyze
```

## Report results
- If there are no issues, confirm clearly
- If there are warnings or errors, list them grouped by file
- For each issue, explain what it means and suggest a fix
