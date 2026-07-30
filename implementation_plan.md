# Implementation Plan - Issue #267: Fix Silent Exceptions in Logical UI Validator

This plan details the systematic steps using the `debug-protocol` 8-step recursive debugging loop to address silent exceptions caught at lines 108-114 in `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/logical_ui_validator.py`.

---

## 1. Objectives
- Ensure that exceptions caught during frontmatter parsing (yaml parsing) in `logical_ui_validator.py` are either reported to the user or appended to the validation errors, rather than silently ignored.

---

## 2. Execution Steps (8-Step Debugging Loop)

### Step 0: Confirmed as a Bug
- A bug has been identified where exceptions are silently ignored, preventing diagnosis of frontmatter parsing failures.

### Step 1: Reproduction Subagent
- Dispatch a subagent to:
  - Create/simulate a reproduction case (e.g. malformed frontmatter in a feature markdown file).
  - Observe that the exception is caught silently and not reported or added to validation errors.

### Step 2: Hypothesis Subagent
- Dispatch a subagent to generate and rank hypotheses on why exceptions are silent and what options exist for logging or error accumulation (e.g., adding to `errors` list, logging).

### Step 3: Investigation Subagent
- Dispatch a subagent to verify error flow. Trace how the `errors` parameter is passed to `validate` in `logical_ui_validator.py` and inspect how other errors are recorded.

### Step 4: Evidence Subagent
- Dispatch a subagent to assemble the dossier of observations, behavior under malformed YAML, and current handling of Exceptions.

### Step 5: Root Cause Subagent
- Dispatch a subagent to pinpoint the exact line, file, and conditions causing the silent exception.

### Step 6: Fix Subagent
- Dispatch a subagent to implement the minimal fix:
  - Update `logical_ui_validator.py` catch block to either append the exception/error details to the `errors` list, print them, or both, as specified.
  - Stage, commit, and push changes to the remote repository.
  - Run backlog reconciliation or other validation scripts if required.

### Step 7: Verification Subagent
- Dispatch a subagent to:
  - Confirm that malformed frontmatter now results in reported validation errors.
  - Run the full test suite using `.venv/bin/pytest`.
  - Validate with `git diff`.

### Step 8: Loop Decision
- Terminate spawned subagents. Close the loop.

---

## 3. Verification Criteria
1. Malformed frontmatter yaml parsing exceptions are successfully appended to the `errors` validation list.
2. Codebase compiling and `pytest` runs cleanly without errors.
3. Conventional commit and push.
