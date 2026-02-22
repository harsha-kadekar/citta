Run Flutter static analysis on the Citta project.

## Setup: resolve paths first

Before running, detect the required paths:

1. **Flutter binary**: run `which flutter` — if not found, check `$HOME/flutter/flutter/bin/flutter`
2. **JAVA_HOME**: run `mise where java` — if mise is not available, fall back to the existing `$JAVA_HOME` environment variable

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
