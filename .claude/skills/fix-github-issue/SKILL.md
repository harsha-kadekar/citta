---
name: fix-github-issue
description: Research, plan, and fix a GitHub issue for the Citta project using TDD, then iterate on code-review findings until clean
---

Fix a GitHub issue end to end: understand it, plan it, implement it test-first, and
work through review feedback — without skipping steps or committing anything
without being asked.

The argument passed to this skill is the issue number or URL. If none is given, ask
for one before proceeding.

This operationalizes the workflow already mandated by this repo's `CLAUDE.md` —
follow that file's wording if the two ever disagree.

## 1. Research & understand — no code yet

- `gh issue view <number> --repo harsha-kadekar/citta --json title,body,labels,comments`
- Read the referenced files and explore the current design (use the Explore agent for
  anything broader than a couple of targeted lookups).
- Identify the acceptance criteria verbatim from the issue body — the plan and the
  final tests must map back to these, not to a paraphrase of them.
- Do not write or edit any code during this step.

## 2. Plan — and stop for confirmation

Write a short plan covering:
- What will change and why, file by file.
- Risks or behavior changes (e.g. "this makes X mandatory, which rejects previously-
  accepted Y").
- The concrete test cases you intend to add, phrased as behaviors, not implementation
  details.

Present the plan and use `AskUserQuestion` to get explicit sign-off before touching
any code. If you believe a case genuinely doesn't need a test, say so and get
explicit confirmation ("I AUTHORIZE SKIPPING TESTS") rather than quietly skipping it.

## 3. Tests first (RED)

- Write failing tests that describe the desired behavior from the plan.
- Run them via the `flutter-test` skill and confirm they fail for the *right* reason
  (missing behavior, not a typo or compile error).
- Do not write the implementation yet.

## 4. Implement (GREEN)

- Write the minimal code to make the new tests pass.
- Run `flutter-test` again and confirm everything is green, including the existing
  suite — a fix that breaks unrelated tests isn't done.

## 5. Analyze

- Run the `flutter-analyze` skill. Zero issues is the bar — not "just warnings."
- Fix everything it reports before moving on.

## 6. Refactor

- Clean up the implementation (naming, duplication, dead branches) while keeping
  tests green.
- Re-run `flutter-test` and `flutter-analyze` after each meaningful change, not just
  once at the end.

## 7. Work through code-review findings — repeat until clean

A review may arrive two ways: the user runs `/code-review` or an external tool and
asks you to check it, or asks you to read a review artifact (e.g. `docs/codex-review`
or `docs/codex-review.md` — check both, since either may be the active one for a
given repo). For each finding:

1. **Understand the exact failure scenario** the finding describes before touching
   code — don't pattern-match on the summary alone.
2. **Fix it**, and add a regression test that encodes the scenario.
3. **Verify the test actually catches the bug**: temporarily revert just the fix (not
   the test), run the new test and confirm it fails for the reason the finding
   describes, then restore the fix and confirm it passes. Skip this only when the
   fix is a mechanical, obviously-correct change (e.g. deduplication) with no
   behavioral claim to verify.
4. **Run the full suite + analyze** — a fix for one finding must not reintroduce or
   mask another.
5. If a finding's proposed remediation would require a much larger refactor than its
   severity justifies (e.g. touching every call site across the UI for a rare race),
   say so explicitly, do the smallest correct fix, and document the remaining gap
   in your summary rather than silently scoping it down.

If asked to "check for new findings," re-read the review artifact for content added
*since your last pass* (compare line counts or timestamps) rather than reprocessing
the whole file — these logs are append-only across rounds. Repeat step 7 until a
fresh review pass reports no findings, then stop; don't go looking for more once the
review is clean.

## 8. Do not commit or open a PR unless asked

Report what changed and that tests/analyze are clean, then stop. When the user
explicitly asks to commit and/or open a PR:
- Create a feature branch — never commit or push directly to `master`. Follow this
  repo's existing convention: `<type>/issue-<N>-<slug>` (see `git branch -a` for
  examples), where `<type>` is a Conventional Commits type (`feat`, `fix`, `refactor`,
  ...).
- Stage only the files relevant to this issue by name — never `git add -A`.
- Commit with a Conventional Commits message and the `Co-Authored-By` trailer.
- Push and `gh pr create` with a summary and a test plan checklist; return the PR URL.
