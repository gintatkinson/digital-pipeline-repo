# Implementation Plan - Update Onboarding Instructions in Feature Skill

This plan details the changes required to update onboarding instructions by replacing stale references to `bootstrap_downstream.py` with native GitHub template instructions.

## Proposed Changes

### 1. Update Workspace Feature Skill
- **Target File**: `skills/feature-driven-implementation/SKILL.md`
- **Action**: In line 42, replace the stale instruction about `bootstrap_downstream.py` with native GitHub template onboarding instructions.
  - **Before**: `Ensure that the downstream workspace has been bootstrapped using the upstream-only \`bootstrap_downstream.py\` script. Note that this is an upstream-only tool and must be executed from the upstream repository directory (\`<upstream_workspace_path>\`) targeting the downstream workspace path BEFORE the downstream agent begins work (use the \`--no-domain\` flag with the bootstrap script if implementing a different project domain).`
  - **After**: `Ensure that the downstream workspace has been bootstrapped using the native GitHub template onboarding workflow: 'gh repo create <new_app_name> --template gintatkinson/digital-pipeline-repo --public --clone'. This creates a fresh repository on GitHub and clones it locally BEFORE the downstream agent begins work.`

### 2. Update Agent System Skill Copy
- **Target File**: `.agents/skills/feature-driven-implementation/SKILL.md`
- **Action**: In line 42, replace the stale instruction with the same native GitHub template onboarding instructions.
  - **Before**: `Ensure that the downstream workspace has been bootstrapped using the upstream-only \`bootstrap_downstream.py\` script. Note that this is an upstream-only tool and must be executed from the upstream repository directory (\`<upstream_workspace_path>\`) targeting the downstream workspace path BEFORE the downstream agent begins work (use the \`--no-domain\` flag with the bootstrap script if implementing a different project domain).`
  - **After**: `Ensure that the downstream workspace has been bootstrapped using the native GitHub template onboarding workflow: 'gh repo create <new_app_name> --template gintatkinson/digital-pipeline-repo --public --clone'. This creates a fresh repository on GitHub and clones it locally BEFORE the downstream agent begins work.`

### 3. Update Implementation Plan
- **Target File**: `implementation_plan.md`
- **Action**: Document the current implementation plan for this branch/task.

## Verification Plan

### Step 1: Git Diff Check
- Run `git diff` to verify that only the expected replacement edits are present in both `SKILL.md` files.

### Step 2: Push and Sync Check
- Commit and push the changes to origin on the active branch.
- Verify that `git diff origin/fix/stale-bootstrap-references` is empty.
