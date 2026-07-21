# Implementation Plan: Epic UML Class Diagram Validation Bypass Fix (Issue #58)

This plan details the audit, reproduction, implementation, and verification steps to address the Epic UML Class Diagram validation bypass issue in the spec-orchestrator parity linter.

## User Review Required

> [!IMPORTANT]
> **Plan Approval Requirement**: As mandated by the workspace guidelines, this plan must be explicitly approved by the user before any workspace-modifying commands (e.g., checkout, file edits, git push) are executed.

## Open Questions

None.

---

## Proposed Changes

### Phase 1: Branch Checkout & Baseline Research
1. Checkout the target tracking branch `feat/58-63-linter-fixes` where the epic files reside.
2. Inspect the epic file structures and check for any existing class diagrams inside `docs/epics/`.
3. Locate the logical discrepancies in `cli.py` and `validators/uml.py` that bypass or ignore Epic class diagrams during audit.

### Phase 2: Bug Fix Implementation
1. Modify `skills/spec-orchestrator/parity_auditor/src/parity_auditor/cli.py` to ensure that:
   - The UML Diagrams Compliance Audit is not skipped if there are epic specifications present, even if feature specifications are empty.
   - The resolved `epics_dir` is correctly passed to `uml_validator.validate()`.
2. Modify `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/uml.py` to ensure epic class diagrams are validated properly and integrated with standard compliance and model coverage checks.

### Phase 3: Verification & Sync
1. Run local linter checks: `python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only`.
2. Run automated test suite: `python3 -m pytest tests/`.
3. Verify that `git diff origin/feat/58-63-linter-fixes` is empty after staging, committing, and pushing.
