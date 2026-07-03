# Implementation Plan: Fix Bootstrapper build folder copy bug

This plan details the changes to prevent the downstream bootstrapping script from walking into `build/` and `dist/` directories.

---

## Proposed Changes

### 1. Update preserved set in bootstrapping script
- **File**: `scripts/bootstrap_downstream.py`
- **Action**: Update the `preserved` set to include `"build"` and `"dist"`.
- **Target Content**:
  ```python
      # Set of files/folders to preserve at destination
      preserved = {".git", "node_modules", ".dart_tool", "package-lock.json", "pubspec.lock", "yarn.lock", "pnpm-lock.yaml"}
  ```
- **Replacement Content**:
  ```python
      # Set of files/folders to preserve at destination
      preserved = {".git", "node_modules", ".dart_tool", "package-lock.json", "pubspec.lock", "yarn.lock", "pnpm-lock.yaml", "build", "dist"}
  ```

---

## Verification Plan

### Step 1: Execute Bootstrapping script
1. Run:
   ```bash
   python3 scripts/bootstrap_downstream.py flutter scratch/test-bootstrapped-app
   ```
2. Verify that the command executes and completes successfully with exit code 0.
3. Verify that `scratch/test-bootstrapped-app` contains the correct application templates, rules, and skills folders.

### Step 2: Clean up
1. Run:
   ```bash
   rm -rf scratch/test-bootstrapped-app
   ```

### Step 3: Git Operations
1. Commit the changes and push to origin/main.
2. Verify `git diff origin/main` is empty.

