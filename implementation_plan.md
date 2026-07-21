# Implementation Plan - Issue #76 Single-Point Backlog Reconciliation State

This plan details the steps to audit and modify `skills/spec-orchestrator/SKILL.md` to ensure all specification issues are registered with their full body contents during creation in Phases 1, 2, and 3, and to clarify the role of Phase 4 backlog reconciliation.

## User Review Required

> [!IMPORTANT]
> **Plan Approval**: As required by project rules, this plan must be approved before executing codebase modifications, running scripts, or executing git operations.

## Proposed Changes

### Phase 1: Codebase Modifications

1. **File**: `skills/spec-orchestrator/SKILL.md`
   - **Section "Item-Level Subagent Context Isolation" (under Step 4: Registration)**:
     - Clarify that the worker agent must register issues with their full body contents at creation time:
       `4. **Registration**: The worker agent aggregates the outputs, links them, and registers them sequentially in the issue tracker. All spec issues (Epics, Features, User Stories, Use Cases) MUST be created with their full body contents using `gh issue create --body-file <local-md-file>` at the time of creation during Phases 1, 2, and 3. An immediate post-creation verification check must be run (e.g. validating that the tracker body is not a stub and contains 'Source References' or 'References') to ensure the tracker is fully populated.`
   - **Section "Phase 1: Structural Extraction (Worker A)" (Step 2: Execution)**:
     - Clarify feature/epic issue creation using `--body-file` and immediate post-creation verification.
   - **Section "Phase 2: Behavioral Extraction - User Stories (Worker B)" (Step 2: Execution)**:
     - Clarify user story issue creation using `--body-file` and immediate post-creation verification.
   - **Section "Phase 3: System Interaction Extraction - UML Use Cases (Worker C)" (Step 2: Execution)**:
     - Clarify use case issue creation using `--body-file` and immediate post-creation verification.
   - **Section "Phase 4: Reconciliation & Automated Verification"**:
     - Clarify that Phase 4 backlog reconciliation is a secondary verification gate (syncing checkbox lists, cross-links, and closing completed items), rather than a deferred publisher of primary issue bodies.
     - Mandate that the tracker is the canonical source of truth and must remain fully populated at all times during the specification lifecycle.

### Phase 2: Verification

1. Run the local linter checks:
   ```bash
   python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
   ```

### Phase 3: Remote Synchronization

1. Stage and commit changes with message:
   `docs: update spec-orchestrator instructions to enforce immediate issue body creation and verify Phase 4 gate`
2. Push changes directly to branch `feat/58-63-linter-fixes`.
3. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
