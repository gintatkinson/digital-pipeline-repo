# Implementation Plan - Issue #78 Docs Scoping Commit Limit

This plan details the steps to audit and modify `skills/schema-specification-engineering/SKILL.md`, `skills/spec-user-story-engineering/SKILL.md`, and `skills/spec-usecase-engineering/SKILL.md` to mandate a pre-commit infrastructure audit before committing generated markdown files.

## Proposed Changes

### Phase 1: Codebase Modifications

1. **File**: `skills/schema-specification-engineering/SKILL.md`
   - **Section "Step 5: Local Validation & Backlog Synchronization"**:
     - **Step 5.1**: Add instruction to check for untracked pipeline infrastructure files before committing.
     - **Step 5.4**: Add sub-step 4 under "Crucial Verification & Body Synchronization" to check for untracked pipeline infrastructure files before committing.
     - **Step 5.6**: Add sub-step 4 under "Crucial Verification & Body Synchronization" to check for untracked pipeline infrastructure files before committing.
     - Include the exact command snippet in all three steps:
       ```bash
       UNTRACKED_INFRA=$(git ls-files --others --exclude-standard .pipeline/ skills/ rules/ scripts/)
       if [ -n "$UNTRACKED_INFRA" ]; then
         git add .pipeline/ skills/ rules/ scripts/
       fi
       ```

2. **File**: `skills/spec-user-story-engineering/SKILL.md`
   - **Section "Step 5: Zero-Fault Backlog Synchronization"**:
     - **Step 5.1**: Add instruction to check for untracked pipeline infrastructure files before committing.
     - Include the exact command snippet:
       ```bash
       UNTRACKED_INFRA=$(git ls-files --others --exclude-standard .pipeline/ skills/ rules/ scripts/)
       if [ -n "$UNTRACKED_INFRA" ]; then
         git add .pipeline/ skills/ rules/ scripts/
       fi
       ```

3. **File**: `skills/spec-usecase-engineering/SKILL.md`
   - **Section "Step 5: Zero-Fault Backlog Synchronization"**:
     - **Step 5.1**: Add instruction to check for untracked pipeline infrastructure files before committing.
     - Include the exact command snippet:
       ```bash
       UNTRACKED_INFRA=$(git ls-files --others --exclude-standard .pipeline/ skills/ rules/ scripts/)
       if [ -n "$UNTRACKED_INFRA" ]; then
         git add .pipeline/ skills/ rules/ scripts/
       fi
       ```

### Phase 2: Verification & Test Execution

1. Run the local linter checks:
   ```bash
   python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
   ```

### Phase 3: Git Operations

1. Stage the modified files:
   ```bash
   git add skills/schema-specification-engineering/SKILL.md skills/spec-user-story-engineering/SKILL.md skills/spec-usecase-engineering/SKILL.md
   ```
2. Commit with message:
   `docs: mandate pre-commit infrastructure audit in specification engineering skills`
3. Push changes directly to the remote tracking branch `feat/58-63-linter-fixes`.
4. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
