Run Flutter static analysis on the Citta project.

Use the following command (exact paths required due to local setup):

```
JAVA_HOME=/home/harsha/.local/share/mise/installs/java/17.0.2 \
/home/harsha/flutter/flutter/bin/flutter analyze
```

Run it from the `citta/` subdirectory (`/home/harsha/workspace/Citta/citta`).

After analysis completes:
- If there are no issues, confirm clearly
- If there are warnings or errors, list them grouped by file
- For each issue, explain what it means and suggest a fix
