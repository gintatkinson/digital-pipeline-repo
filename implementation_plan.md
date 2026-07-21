# Implementation Plan - README Installer Guide Auditor

This plan outlines the changes to `README.md` to guide users on staging the copied folders and whitelisting them in `.gitignore`.

## Proposed Changes

### Phase 1: Codebase Modifications

1. **Update `README.md`**:
   - File: `README.md`
   - Action: Inspect lines 195-202. Insert the specified text block regarding Git tracking and `.gitignore` whitelisting before line 199.
   - Text to insert:
     ```markdown
     ### Stage and Track Copied Files in Git
     
     Because these files are copied directly into your existing project, they are **untracked** by default. To track them in Git and push them to GitHub, stage them manually:
     
     \`\`\`bash
     git add skills rules .pipeline .agents scripts requirements.txt app_flutter  # or web_react
     \`\`\`
     
     If your project's `.gitignore` contains rules that ignore hidden folders (e.g., `.*`) or custom scripts, Git will ignore the `.pipeline/` and `.agents/` configuration folders. To resolve this, add whitelist rules to your `.gitignore` file:
     
     \`\`\`gitignore
     !/skills/
     !/rules/
     !/.pipeline/
     !/.agents/
     !/scripts/
     \`\`\`
     ```

### Phase 2: Verification

1. Run `git diff` to ensure the exact changes are applied correctly to `README.md`.

### Phase 3: Git Operations & Synchronization

1. Stage the modified file:
   ```bash
   git add README.md
   ```
2. Commit with the conventional message:
   `docs: update README with git staging and gitignore whitelist instructions`
3. Push the changes to the remote branch `feat/58-63-linter-fixes`:
   ```bash
   git push origin feat/58-63-linter-fixes
   ```
4. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
