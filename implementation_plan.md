# Implementation Plan - Issue: Parent Epic Fallback in Backlog Reconciler

This plan outlines the surgical changes to support parsing parent epics from the text body of features, user stories, and use cases, and supporting reverse lookup of issue IDs to normalized epic titles in `reconcile_backlog.py`.

---

## 1. Proposed Code Changes

### Target File: `skills/spec-orchestrator/scripts/reconcile_backlog.py`

We will modify `reconcile_backlog.py` in the following locations:

1. **Top-Level Helper Function**: Implement `extract_epic_from_body(body_content)` after `extract_title` (around line 121) to parse parent epics using links (local/remote) or explicit patterns like `## Parent Epic` and issue IDs.
2. **Reverse Issue ID Lookup**: Inside the main execution flow, before defining `resolve_epic_norm(epic_ref)` (around line 1084), populate `epic_id_to_norm` mapping `issue_id` to its normalized title.
3. **Update `resolve_epic_norm`**: Support matching string/int issue IDs (with or without `#` prefix) using the new `epic_id_to_norm` mapping.
4. **Fallback in Scanning Loops**: Under `Dynamic relationship scanning` (around line 1098), for features, user stories, and use cases, when `meta.get("epic")` is missing or empty, read the file body and extract the parent epic using `extract_epic_from_body(body_content)`.

---

## 2. Proposed Test Changes

### Target File: `skills/spec-orchestrator/parity_auditor/tests/test_reconcile_backlog_epic_fallback.py`

We will create a new test file [test_reconcile_backlog_epic_fallback.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/tests/test_reconcile_backlog_epic_fallback.py) to verify:
1. `extract_epic_from_body` correctly extracts parent epics from markdown links (e.g. `[Epic Title](../epics/epic-01-geo-location.md)`) and `## Parent Epic` sections with issue IDs.
2. `resolve_epic_norm` resolves integer IDs, string IDs, and prefixed IDs (e.g. `123`, `"123"`, `"#123"`) to normalized epic titles via the reverse lookup map.
3. The relationship scanning loops successfully associate features, user stories, and use cases with parent epics via body content extraction fallback.

---

## 3. Verification Plan

1. **Automated Unit Tests**:
   Run `.venv/bin/pytest skills/spec-orchestrator/parity_auditor/tests/test_reconcile_backlog_epic_fallback.py` to check the new features.
   Run `.venv/bin/pytest skills/spec-orchestrator/parity_auditor/tests/` to check all tests.
2. **Backlog Reconciliation Verification**:
   Run `python3 skills/spec-orchestrator/scripts/reconcile_backlog.py` using `--help` or dry-run configuration rules to ensure no syntax errors.
3. **Git Status & Diff Verification**:
   Check `git diff` to ensure no orthogonal changes are made.
