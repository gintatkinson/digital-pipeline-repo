# Implementation Plan - Debug Protocol Issues

## User Request
Run the 8-Step Recursive Debugging Protocol on the open bug issues in the repository backlog:
1. Issue #206: [AUDIT] [SKILL.md]: Missing --title extraction from YAML frontmatter title field
2. Issue #207: [AUDIT] [reconcile_backlog.py]: Placeholder-to-checklist backfill fails for epic child artifacts
3. Issue #208: [AUDIT] [reconcile_backlog.py]: No duplicate section detection allows dual Source References in epics
4. Issue #209: [AUDIT] [SKILL.md]: Realization Matrix cross-reference Issue IDs all default to single value

## Proposed Changes
For each issue (#206, #207, #208, #209), I will dispatch the following subagents in sequence:
1. **Step 1 — Reproduction**: Gather symptom info, reproduce the bug consistently, and check scope.
2. **Step 2 — Hypothesis**: Generate multiple ranked hypotheses for the cause.
3. **Step 3 — Investigation**: Trace data flow, binary-search the problem space, and gather observations.
4. **Step 4 — Evidence**: Document all evidence, logs, and trace data.
5. **Step 5 — Root Cause**: Identify the root cause with file:line references.
6. **Step 6 — Fix**: Apply the minimal fix, stage, commit, and push. Update the issue.
7. **Step 7 — Verification**: Confirm the fix, run test suites, check git diff, and close the issue.

## Verification Plan
For each issue, the fix will be validated using tests, `git status`/`git diff`, and verified by checking the issue state before closing.
