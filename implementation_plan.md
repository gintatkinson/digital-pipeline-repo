# Implementation Plan: Fix Tooling Bug in reconcile_backlog.py

We will update the dependency tracking checklist filter in `skills/spec-orchestrator/scripts/reconcile_backlog.py` to correctly skip plain checkboxes without issue reference prefixes and unresolved placeholder identifiers.

## Proposed Changes

### spec-orchestrator scripts

#### [MODIFY] [reconcile_backlog.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/scripts/reconcile_backlog.py)

- Locate the function `update_checklist_in_file` around line 153.
- Replace the legacy digit/prefix check:
```python
        if dep_num_str.isdigit() and not prefix:
            continue
```
- With the robust filters:
```python
        # 1. Skip plain markdown checkboxes that have no issue reference prefix
        if not prefix:
            continue

        # 2. Skip unresolved template placeholders
        if dep_num_str in ("IssueID", "EpicIssueID", "StoryIssueID", "FeatureIssueID", "UseCaseIssueID", "StoryID", "N/A"):
            continue
```

## Verification Plan

### Compilation Check
- Run the python compilation command to verify no syntax errors:
  ```bash
  python3 -m py_compile skills/spec-orchestrator/scripts/reconcile_backlog.py
  ```
