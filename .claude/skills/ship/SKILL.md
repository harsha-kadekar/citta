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

## 4. Run code review
Invoke `/code-review` and work through every finding before proceeding:
- For each CONFIRMED or PLAUSIBLE finding, apply the fix.
- Re-run `flutter analyze` and `flutter test` after fixes to confirm nothing broke.
- Only move on when the review returns no actionable findings.

## 5. Run Codex review
Ask the user to run the Codex review:
> "Please run the Codex review now (e.g. via your Codex CLI or UI) and let me know when it's done."

Wait for the user to confirm completion, then read `docs/codex-review.md`:
- If it reports findings, apply fixes and re-run `flutter analyze` and `flutter test`.
- Repeat until `docs/codex-review.md` reports no findings.
- Only move on when the file confirms a clean review.

## 6. Stage appropriate files
Use `git add` with specific file paths — never `git add -A` or `git add .`.

## 7. Commit
- Use the Conventional Commits format: https://www.conventionalcommits.org/en/v1.0.0/
- Format: `<type>(<scope>): <description>` where type is one of:
  `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`, `style`, `perf`
- Example: `feat(audio): pre-initialize player on app start`
- Always append: `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`

## 8. Push
```
git push origin master
```

Report the commit hash and confirm the push succeeded.
