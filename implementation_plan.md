# Implementation Plan - Issue #71 Auditor and Debugger

This plan outlines the changes to `AGENTS.md` to mandate that coordinator prompts explicitly instruct subagents to read their corresponding `SKILL.md` file using `view_file`.

## Proposed Changes

### Phase 1: Codebase Modifications

1. **Update `AGENTS.md`**:
   - File: `.agents/AGENTS.md`
   - Action: Under the section `## Mandatory Subagent Dispatch for Research, Specification & Implementation Loops`, add the following bullet to the list of instructions for step 2 (Invoke Subagent):
     `- **Mandatory Skill-Reading Instruction**: When launching a subagent, the coordinator's prompt MUST explicitly instruct the subagent to read the relevant \`SKILL.md\` file (e.g. using \`view_file\` on \`.agents/skills/debug-protocol/SKILL.md\`) as its very first step, and to strictly follow its formatting templates and instruction guidelines.`

### Phase 2: Verification

1. Run `git diff` to ensure the exact changes are applied correctly to `.agents/AGENTS.md`.

### Phase 3: Git Operations & Synchronization

1. Stage the modified file:
   ```bash
   git add .agents/AGENTS.md
   ```
2. Commit with the conventional message:
   `docs: mandate subagent explicit skill reading in AGENTS.md`
3. Push the changes to the remote branch `feat/58-63-linter-fixes`:
   ```bash
   git push origin feat/58-63-linter-fixes
   ```
4. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
