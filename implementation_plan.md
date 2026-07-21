# Implementation Plan - Issue #77 Git Pre-Flight Verify

This plan details the steps to audit and modify `skills/spec-orchestrator/SKILL.md` and `.agents/skills/project-constitution/SKILL.md` to enforce git repository tracking verification and remote constitution presence verification.

## Proposed Changes

### Phase 1: Codebase Modifications

1. **File**: `skills/spec-orchestrator/SKILL.md`
   - **Section "Pre-Flight Git Repository Verification"**:
     - Add a new section right before "Pre-Flight Checklist" instructing the agent to run `git ls-files` on:
       1. `.pipeline/constitution.md`
       2. `skills/`
       3. `rules/`
       4. `scripts/`
     - Halt and instruct the operator to add/commit/push them first if any check fails:
       ```bash
       git add .pipeline/ skills/ rules/ scripts/ app_flutter/
       git commit -m "chore: bootstrap pipeline infrastructure"
       git push
       ```

2. **File**: `.agents/skills/project-constitution/SKILL.md`
   - **Section "Step 6: Commit & Reference"**:
     - Add a verification step to run:
       ```bash
       gh api repos/$OWNER/$REPO/contents/.pipeline/constitution.md --jq '.name'
       ```
     - Halt and inform the user if the command fails or returns empty.

### Phase 2: Verification & Test Execution

1. Run the local linter checks:
   ```bash
   python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
   ```

### Phase 3: Git Operations

1. Stage the modified files:
   ```bash
   git add skills/spec-orchestrator/SKILL.md .agents/skills/project-constitution/SKILL.md
   ```
2. Commit with message:
   `docs: implement git pre-flight verify checklist and remote presence checks`
3. Push changes directly to the remote tracking branch `feat/58-63-linter-fixes`.
4. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
