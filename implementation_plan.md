# Implementation Plan - Issue #268: Logical UI Validator Header Matching Bug Fix

This plan outlines the surgical changes to fix the `match` vs `target_match` logic bug in `logical_ui_validator.py` and prevent bypasses for unnumbered headings.

---

## 1. Proposed Code Changes

### Target File: `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/logical_ui_validator.py`

We will modify two locations in [logical_ui_validator.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/logical_ui_validator.py):

1. **Line 102 (approximate)**: Change `if not match:` to `if not target_match:`. This ensures that features containing valid unnumbered `## Logical UI & Layout Bindings` headers (which set `target_match` but leave `match` as `None`) do not trigger the incorrect linter error complaining that the section is missing.
2. **Line 236 (approximate)**: Change `if match and GEODETIC_REGEX.search(content):` to `if target_match and GEODETIC_REGEX.search(content):`. This ensures that unnumbered heading features are not bypassed for geodetic/spatial validation checks.

#### Detailed Code Diff (Proposed)

```diff
-            if not match:
+            if not target_match:
```

and

```diff
-            if match and GEODETIC_REGEX.search(content):
+            if target_match and GEODETIC_REGEX.search(content):
```

---

## 2. Proposed Test Changes

### Target File: `skills/spec-orchestrator/parity_auditor/tests/test_logical_ui_validator_issue268.py`

We will create a new test file [test_logical_ui_validator_issue268.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/tests/test_logical_ui_validator_issue268.py) to explicitly test:
1. That a feature file with an unnumbered header `## Logical UI & Layout Bindings` and valid bindings parses successfully and does not throw a "lacks the 'Logical UI & Layout Bindings' section" error.
2. That a feature file with an unnumbered header `## Logical UI & Layout Bindings` and geodetic attributes (e.g. `latitude`, `longitude`) is still validated and reports errors if it does not map to a valid spatial component, ensuring the validation bypass is plugged.

### Target File: `skills/spec-orchestrator/parity_auditor/tests/test_logical_ui_validator_issue222.py`

We will update [test_logical_ui_validator_issue222.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/tests/test_logical_ui_validator_issue222.py#L438-L480):
- Modify `test_issue217_strict_section_5_header_numbering` to assert that the unnumbered header (`feat-unnumbered.md`) does **not** trigger a missing section error now that the fallback is fully supported and validated.

---

## 3. Verification Plan

1. **Automated Unit Tests**:
   Run `.venv/bin/pytest` to ensure all tests, including the updated `test_logical_ui_validator_issue222.py` and the new tests in `test_logical_ui_validator_issue268.py`, pass cleanly.
2. **Backlog Reconciliation**:
   Run `python3 skills/spec-orchestrator/scripts/reconcile_backlog.py` to ensure local specifications and issues sync correctly.
3. **Downstream Baseline Gate Checks**:
   Verify everything conforms via the standard validation script.
4. **Git Inspection**:
   Run `git status` and `git diff` to ensure no orthogonal changes are made.
