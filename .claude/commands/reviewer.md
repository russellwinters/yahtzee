---
name: reviewer
description: Review all changes on the current branch by diffing against a target branch and providing a structured code review.
argument-hint: [branch] (optional: branch to diff against; defaults to main)
---

Use the `branch-diff` skill to get the diff, then perform a structured code review.

## Step 1: Determine the target branch

- If `$ARGUMENTS` is provided, use it as the target branch.
- If `$ARGUMENTS` is empty, determine the default branch:
  ```bash
  git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
  ```
  If that fails or there is no remote, fall back to `main`.

## Step 2: Get the diff

Use the `branch-diff` skill to get the diff between the current branch and the target branch determined above. Follow the skill's workflow exactly to produce the diff.

## Step 3: Code Review

Analyze the diff and produce a structured code review with the following sections:

### Summary

A 2–4 sentence overview of what this branch does, based on the changes observed.

### Changes by File

For each changed file, one line describing what changed and why it matters (skip trivial changes like formatting-only edits unless they are the entire diff).

### Observations

Flag any of the following if present:

- **Bugs or logic errors** — incorrect conditions, off-by-one errors, unhandled edge cases
- **Security concerns** — injection risks, exposed secrets, missing auth checks, unsafe inputs
- **Performance issues** — unnecessary loops, missing indexes, N+1 queries, large allocations
- **Missing error handling** — uncaught exceptions, unhandled promise rejections, missing null checks
- **Test coverage gaps** — changed logic with no corresponding test changes

### Suggestions

Concrete, actionable improvements. Each suggestion should reference the file and line if possible. Skip this section if there is nothing meaningful to suggest.

### Verdict

One of:

- **Looks good** — No significant issues found.
- **Minor issues** — Small improvements recommended but not blocking.
- **Needs changes** — Issues that should be addressed before merging.

## Step 4: Save the Review

Write the complete review output to `docs/review.md`. Create the file if it does not exist. Overwrite any existing content.

## Notes

- If the diff is empty (branches are identical or target does not exist), report that and stop.
- If the diff is very large (>500 lines), focus the review on the highest-risk changes and note that the review is summarized.
- Be direct and specific. Avoid generic praise. Only flag real issues.
