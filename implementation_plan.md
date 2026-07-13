# Implement Automated Git Hooks Enforcement

## Goal Description
To transition project rules from "soft constraints" to "hard blockers," we will implement a Git hook installer. This will force agents to pass the linter and compilation verifications before they are allowed to commit or push changes.

We will create a script `scripts/setup_git_hooks.py` that writes a pre-commit hook (running `verify_model_coverage.py --spec-only`) and a pre-push hook (running `verify_downstream_baseline.py`). We will update the project's quick setup commands in `README.md` to mandate running this hook installer.

## Proposed Changes

### [scripts]

#### [NEW] [setup_git_hooks.py](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/setup_git_hooks.py)
* Create a script that writes executable Git hook scripts to `.git/hooks/pre-commit` and `.git/hooks/pre-push` inside the repository.

### [docs/operations]

#### [MODIFY] [README.md](file:///Users/perkunas/jail/digital-pipeline-repo/README.md)
* Update the quick setup instruction blocks to include `python3 scripts/setup_git_hooks.py` immediately after copying the files.

---

## Verification Plan

### Automated Checks
1. Execute the git hook installer script locally:
   ```bash
   python3 scripts/setup_git_hooks.py
   ```
2. Verify that the `.git/hooks/pre-commit` and `.git/hooks/pre-push` files are created and marked as executable.
3. Test downstream verification:
   ```bash
   python3 scripts/verify_downstream_baseline.py app_flutter
   ```
4. Verify `git diff origin/main` is clean after committing and pushing.
