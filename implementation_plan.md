# Implementation Plan - Issue #66 verify_downstream_baseline missing asset copy

This plan outlines the changes to resolve the template/upstream assets directory copy issue in the downstream baseline verification script.

## Proposed Changes

### Phase 1: Codebase Modifications

1. **Import `shutil` in baseline verifier**:
   - File: [verify_downstream_baseline.py](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/verify_downstream_baseline.py)
   - Action: Add `import shutil` at the top of the file.

2. **Add assets copy step in Flutter verification block**:
   - File: [verify_downstream_baseline.py](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/verify_downstream_baseline.py)
   - Action: Inside the `else` block (before executing the build/test commands), add code to:
     - Determine `repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))`.
     - Resolve the source assets directory: `src_assets = os.path.join(repo_root, "app_flutter", "assets")`.
     - Resolve the target assets directory: `dest_assets = os.path.join(dest, "assets")`.
     - Check if `src_assets` exists and `os.path.abspath(src_assets) != os.path.abspath(dest_assets)` (to prevent `shutil.SameFileError` when running verifier on the template project itself).
     - If yes:
       - Create `dest_assets` if missing using `os.makedirs(dest_assets, exist_ok=True)`.
       - Iterate over files in `src_assets` and copy each to `dest_assets` using `shutil.copy2`.
       - Print a message confirming the copy.

### Phase 2: Verification

1. Run the downstream verifier locally on `app_flutter` using the `run_command` tool (unsandboxed):
   ```bash
   python3 scripts/verify_downstream_baseline.py app_flutter
   ```
2. Run model coverage checks using the `run_command` tool (unsandboxed):
   ```bash
   python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
   ```
3. Verify that both pass successfully.

### Phase 3: Git Operations & Synchronization

1. Stage the modified file:
   ```bash
   git add scripts/verify_downstream_baseline.py
   ```
2. Commit with the conventional message:
   `fix: verify_downstream_baseline missing asset copy for downstream baseline compilation`
3. Push the changes to the remote branch `feat/58-63-linter-fixes`:
   ```bash
   git push origin feat/58-63-linter-fixes
   ```
4. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
