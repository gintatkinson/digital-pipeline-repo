# Implementation Plan: Schema Linter Gate Integration for Backlog Reconciliation (Issue #75)

This plan details the implementation of a programmatic gate that stops backlog reconciliation if schema linter/UML violations are present in local specifications.

## User Review Required

> [!IMPORTANT]
> **Plan Approval**: As required by project guidelines, this plan must be approved before executing any codebase modification or Git push commands.

## Proposed Changes

### Phase 1: Audit & Design
1. Analyze the codebase to confirm how backlog reconciliation currently bypasses the schema linter.
2. Confirm the exact command to run: `verify_model_coverage.py --spec-only --allow-missing-specs`.
3. Design a subprocess execution check inside the main execution flow of `skills/spec-orchestrator/scripts/reconcile_backlog.py`.

### Phase 2: Implementation of the Programmatic Gate
1. Modify `skills/spec-orchestrator/scripts/reconcile_backlog.py` at the beginning of `main()` to run the linter script using `sys.executable`.
2. Capture the return code. If it is non-zero, print a detailed `[FATAL]` error message and call `sys.exit(1)`.
3. Ensure no issue fetching or file writes occur if the linter check fails.

### Phase 3: Verification & Remote Sync
1. Run local linter checks to verify that the linter passes without errors:
   `python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only`
2. Run backlog reconciliation to verify the gate checks correctly:
   `python3 skills/spec-orchestrator/scripts/reconcile_backlog.py`
3. Stage, commit, and push changes to the remote branch `feat/58-63-linter-fixes`.
4. Validate that `git diff origin/feat/58-63-linter-fixes` is empty.
