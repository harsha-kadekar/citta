---
name: ship
description: Review, commit, and push all changes in the Citta project to GitHub
---

Review, commit, and push all changes in the Citta project to GitHub.

Follow these steps carefully:

## 1. Check current state
Run `git status` to see modified and untracked files.

## 2. Review untracked files
For each untracked file, decide:
- **Commit**: source code, assets, tests, config files, documentation
- **Ignore**: build artifacts, generated files, IDE/editor files, local secrets

Common files to ALWAYS ignore (add to `citta/.gitignore` if not already there):
- `/build/`, `.dart_tool/`, `.flutter-plugins`, `.flutter-plugins-dependencies`
- `.idea/`, `*.iml`, `.vscode/`
- `pubspec.lock` (already ignored)
- Platform dirs: `/ios/`, `/linux/`, `/macos/`, `/windows/`, `/web/` (note: `/android/` is tracked in this project)

The `.claude/` directory is already handled by the user's global gitignore — do not touch it.

## 3. Update .gitignore if needed
If any untracked files should be ignored, add them to `citta/.gitignore` before staging.

## 4. Stage appropriate files
Use `git add` with specific file paths — never `git add -A` or `git add .`.

## 5. Commit
- Look at `git log --oneline -5` to match the existing commit message style
- Write a concise, imperative commit message describing what changed and why
- Always append: `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`

## 6. Push
```
git push origin master
```

Report the commit hash and confirm the push succeeded.
