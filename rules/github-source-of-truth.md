<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

# Rule: GitHub as Source of Truth

**ALWAYS enforce:** Use `gh` CLI commands to query GitHub for authoritative issue state. Never trust local files or checklist documentation alone.

## Hard constraints

- Before working on a feature, verify its status via `gh issue view <number>`.
- Before creating issues, check for duplicates via `gh issue list --label "<label>" --state "all" --json number,title`.
- Use `gh issue create`, `gh issue close`, and `gh issue edit` for all issue lifecycle operations.
- When referencing Issue IDs in markdown, use the live GitHub Issue number — never hard-code or assume numbers.
- When constructing links to files in GitHub issues, dynamically determine the remote URL via `git remote get-url origin`. Never use relative paths like `../features/...` — they resolve incorrectly in GitHub issue bodies.

## What local files are for

- Local markdown files (`docs/epics/`, `docs/features/`, etc.) are the specification source, but their checklist states may be stale.
- Always sync local state with GitHub state using the reconciliation script (`scripts/reconcile_backlog.py`).

## Why

Local files can be contaminated, outdated, or contain broken links. GitHub is the canonical state store. Querying it directly prevents agents from working on closed issues, creating duplicates, or referencing stale data.
