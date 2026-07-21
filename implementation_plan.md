# Implementation Plan - Issue #16: Epic Section Truncation in reconcile_backlog.py

This plan details the audit, debug, fix, and verification steps to address the Epic checklist section truncation issue.

## User Review Required

> [!IMPORTANT]
> **Plan Approval**: As required by project guidelines, this plan must be approved before executing codebase modifications or git operations.

## Proposed Changes

### Phase 1: Audit & Design
1. Inspect the slicing behavior in `reconcile_epic_checklists` inside `skills/spec-orchestrator/scripts/reconcile_backlog.py` (lines 567-595).
2. Confirm that any content (such as H3 subheadings, descriptions, or notes) between the end of the user stories checklist and the next H2 section (e.g., `## 3. Architecture`) is skipped when `idx_next != -1`.

### Phase 2: Implementation of the Fix
1. Modify `skills/spec-orchestrator/scripts/reconcile_backlog.py` inside `reconcile_epic_checklists` to compute `start_after_stories = idx_stories + 1 + len(existing_stories) if idx_stories != -1 else len(lines)`.
2. When `idx_next != -1`, correctly slice and append `lines[start_after_stories : idx_next]` to `new_lines` before appending `lines[idx_next:]`.
3. Write a unit test `test_reconcile_epic_checklist_preserves_custom_content` in `tests/test_linter_reliability.py` (or a dedicated test file) to verify that custom paragraphs and headings inside section 2 of Epics are preserved after reconciliation.

### Phase 3: Verification & Remote Sync
1. Run local linter checks: `python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only`
2. Run pytest suite: `python3 -m pytest tests/`
3. Stage, commit, and push the changes directly to `feat/58-63-linter-fixes`.
4. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
