# Implementation Plan - CMM Level 3 / Scrum Issue Lifecycle Constitution Update

This plan adds a formal process section to the Project Constitution to align our issue lifecycle with CMM Level 3 (Separation of Verification & Validation) executed in Scrum style (with the Product Owner/customer controlling final validation acceptance).

## 1. Context & Goal
To prevent issues from being closed prematurely without explicit user approval, we will codify a CMM Level 3 / Scrum issue state flow:
1.  **Verification (Done by Developer / Linter)**: The issue is marked as `Fixed / Resolved` (not `Closed`) once the fix is merged and automated tests pass.
2.  **Validation (Done by Product Owner / Customer)**: The issue is transitioned to `Closed` ONLY upon explicit verification and sign-off by the PO/customer in the chat.

## 2. Proposed Changes

### [MODIFY] [constitution.md](file:///Users/perkunas/jail/digital-pipeline-repo/.pipeline/constitution.md)
Append a new section `## CMMI Level 3 & Scrum Issue Lifecycle Rules` at the end of the file:
*   Define the separate states: `New`, `Active`, `In Progress`, `Verifying`, `Fixed / Resolved`, and `Closed`.
*   Establish that the `Fixed / Resolved` state is the final state for the implementation loop.
*   Enforce that transitioning to `Closed` requires explicit PO/Customer validation approval.

## 3. Verification Plan
*   **Linter verification**: Run `./skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only` to ensure the updated constitution file complies with formatting rules.
*   **Git check**: Verify that the diff matches our intent and has zero trailing modifications.
