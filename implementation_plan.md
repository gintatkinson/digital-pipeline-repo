# Implementation Plan - Update Project Rules for Context Isolation

This plan details the changes required to append strict context isolation and skill fidelity rules to the project-scoped rules document.

## Proposed Changes

### 1. Update Project-Scoped Rules
- **Target File**: `.agents/AGENTS.md`
- **Action**: Append the new rule block at the end of the file.
- **Content to Append**:
  ```markdown
  
  ## Strict Context Isolation & Skill Fidelity (No Cross-Talk)
  - **No Cross-Talk / Memory Leakage**: You are strictly forbidden from reading, scanning, or referencing logs, transcripts, artifacts, or files belonging to other projects, folders, or conversation IDs (such as `3dgs-ion`, `3dgs-phoenix`, or other network models) stored under the App Data Directory (`~/.gemini/antigravity/brain/`). You must execute tasks strictly based on the inputs and schema files present in the *active* workspace.
  - **Literal Skill Execution (No Summarization)**: When adopting a skill, you must read the skill's instructions in full and adhere to them literally. You are strictly forbidden from summarizing, truncating, or using abbreviated interpretations of instructions.
  ```

### 2. Update Implementation Plan
- **Target File**: `implementation_plan.md`
- **Action**: Overwrite this file with the active implementation plan for this branch.

## Verification Plan

### Step 1: Git Diff Check
- Run `git diff` to verify that only the expected replacement edits are present in `.agents/AGENTS.md` and `implementation_plan.md`.

### Step 2: Push and Sync Check
- Commit and push the changes to origin on the active branch.
- Verify that `git diff origin/fix/strict-context-isolation-rules` is empty.
