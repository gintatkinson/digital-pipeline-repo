# Implementation Plan - Unify README.md Installation Instructions

This plan outlines the changes to `README.md` to unify the installation instructions.

## Proposed Changes

### Phase 1: Codebase Modifications

1. **Update `README.md`**:
   - File: `README.md`
   - Action:
     Replace the Direct Copy Installation section (lines 125-141) with a single, unified copy block that:
     1. Deletes all pipeline folders (`skills/`, `rules/`, `.pipeline/`, `.agents/`, `scripts/`) and both application templates (`app_flutter/`, `web_react/`).
     2. Copies all pipeline folders (`skills/`, `rules/`, `.pipeline/`, `.agents/`, `scripts/`) and both application templates (`app_flutter/`, `web_react/`).
     3. Runs `python3 scripts/setup_git_hooks.py` at the end.

     The unified code block will look like this:
     ```bash
     git clone https://github.com/gintatkinson/digital-pipeline-repo.git ./.tmp-pipeline
     rm -rf ./skills ./rules ./.pipeline ./.agents ./scripts ./app_flutter ./web_react
     cp -RP ./.tmp-pipeline/skills ./
     cp -RP ./.tmp-pipeline/rules ./
     cp -RP ./.tmp-pipeline/.pipeline ./
     cp -RP ./.tmp-pipeline/.agents ./
     cp -RP ./.tmp-pipeline/scripts ./
     cp -RP ./.tmp-pipeline/app_flutter ./
     cp -RP ./.tmp-pipeline/web_react ./
     rm -rf ./.tmp-pipeline
     python3 scripts/setup_git_hooks.py
     ```

### Phase 2: Verification

1. Ensure the syntax and formatting of `README.md` remain valid.
2. Verify `git diff origin/main` contains exactly these changes.

### Phase 3: Git Operations & Synchronization

1. Stage, commit with message: "docs: unify installation instructions for react and flutter in README.md"
2. Push to `origin/main`.
