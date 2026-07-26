# Implementation Plan: Autonomous Two-Stage Resolution of All Backlogged Issues

This plan details the technical steps for the autonomous, unattended looping and resolution of all remaining open issues in the backlog using a two-stage process: (1) **Adversarial Audit** to verify and document the defect context, and (2) **Debug Protocol** to apply the minimal fix, verify changes, commit/push, and close the issue.

---

## 1. Context & Objectives

*   **Goal**: Sequentially resolve all open issues in the backlog without human intervention, ensuring each is fully verified, committed, pushed to the remote tracking branch, and closed.
*   **Two-Stage Rule**: For each issue, I must first run the adversarial auditor against the target file to document the defect details, and then execute the debug protocol to apply the fix, verify it, and close the issue.
*   **Active Backlog**: Issues 228, 227, 226, 225, 224, 222, 221, 220, 219, 218, 217, 216, 215, 214, 213, 212, 211, 209, 208, 207.

---

## 2. Proposed Loop Workflow (Unattended Execution)

For each open issue in the backlog:

### Stage 1: Adversarial Audit
1.  **Retrieve Issue Details**: Fetch the issue context and target file:
    ```bash
    env -u GITHUB_TOKEN gh issue view <ISSUE_ID>
    ```
2.  **Run Audit**: Run an adversarial audit on the target file using the relevant correctness risk pillars (e.g. Memory Safety, Resource Lifecycle, Concurrency, Test Integrity, Semantic Traceability).
3.  **Document Finding**: Draft the audit finding using the standard 7-section layout (Context, 5 Whys, Correctness Analysis, UML Diagram, Caller Impact, Proposed Correction, and Severity). Save the finding to a markdown file under `scratch/`.

### Stage 2: Debug Protocol Execution
With the audit specification documented, execute the 8-step debugging protocol:
1.  **Step 1-5 (Reproduction & Root Cause)**: Confirm the symptom, verify the hypothesis, and locate the exact lines causing failure.
2.  **Step 6 (Fix)**: Design and apply the minimal fix to resolve the root cause.
3.  **Step 7 (Verification - RED-GREEN)**:
    *   Run pytest unit tests in `skills/spec-orchestrator/parity_auditor/` to confirm green status.
    *   Run `verify_model_coverage.py --spec-only` to ensure compliance.
    *   Log raw terminal outputs as verification proof.
4.  **Step 8 (Release & Close)**:
    *   Commit changes (`fix: resolve issue <ISSUE_ID>`).
    *   Push to `origin/main` to synchronize changes.
    *   Close the GitHub issue using `gh issue close <ISSUE_ID>`.

---

## 3. Targeted Remediation Details

### Component: Parity Auditor CLI
#### [MODIFY] [cli.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/cli.py)
*   **Issue 228**: Downgrade the GitHub API offline error to a warning and skip the check without setting `has_failed = True` or exiting with code 1.
*   **Verification**: Run `../../../.venv/bin/pytest tests/test_cli_offline.py`.

### Component: Document Generation & Hyperlink Alignment
#### [MODIFY] [generate_docs.py](file:///Users/perkunas/jail/digital-pipeline-repo/scratch/generate_docs.py) (If found/restored) / Spec Files
*   **Issue 227**: Ensure `alternate-systems` has its own dedicated feature specification file (`feat-002-alternate-systems.md`) and is not collapsed under `geo-location-container` spec.
*   **Issue 226**: Fix broken cross-document links pointing to 2-digit filenames (e.g. `feat-01-`) and align them to the standard 3-digit zero-padded format (e.g. `feat-001-`).

### Component: Environment Sanitization & Security Gates
#### [MODIFY] [reconcile_backlog.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/scripts/reconcile_backlog.py) / [bootstrap_downstream.py](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/bootstrap_downstream.py)
*   **Issue 225**: Add a validation hook to block execution if any forbidden local mock executable wrappers (such as `scratch/bin/gh`) are found.
*   **Issue 224**: Clean the dummy `GITHUB_TOKEN` environment variable globally in bootstrap/shell setup scripts so git shell operations can use the OS keyring helper.

### Component: Logical UI Validator
#### [MODIFY] [logical_ui_validator.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/logical_ui_validator.py)
*   **Issue 222**: Enforce the `TableView`-only children constraint for `TabbedContainer` nodes.
*   **Issue 221**: Fix `schema-specification-engineering` mapping template to correctly target detail grids for geodetic attributes.
*   **Issue 220**: Enforce namespace prefixes check on prefixed elements.
*   **Issue 219**: Bypassing enforcement of mapping geodetic attributes to `TopographicalView`.

---

## 4. Verification Plan

*   **Pytest Suite**: Run `../../../.venv/bin/pytest` inside the parity auditor tests directory.
*   **Linter Verification**: Run the linter check:
    ```bash
    ./skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
    ```
*   **Synchronization Check**: Verify that `git diff origin/main` is empty.
