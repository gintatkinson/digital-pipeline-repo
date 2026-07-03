# Implementation Plan: GitHub-First Downstream Bootstrapping

This plan details the changes to implement the GitHub-first bootstrapping workflow in `scripts/bootstrap_downstream.py`.

---

## Proposed Changes

### 1. Import subprocess and re in bootstrapping script
- **File**: `scripts/bootstrap_downstream.py`
- **Action**: Import `subprocess` and `re` at the top.
- **Target Content**:
  ```python
  import argparse
  import os
  import shutil
  import sys
  ```
- **Replacement Content**:
  ```python
  import argparse
  import os
  import shutil
  import sys
  import subprocess
  import re
  ```

### 2. Update bootstrap setup to create and clone GitHub repo first
- **File**: `scripts/bootstrap_downstream.py`
- **Action**: Replace the destination folder exists check/creation with the `gh` repository creation and cloning sequence.
- **Target Content**:
  ```python
      # Ensure destination directory exists
      if not os.path.exists(destination):
          os.makedirs(destination, exist_ok=True)
  ```
- **Replacement Content**:
  ```python
      # Check if gh CLI is available
      if not shutil.which("gh"):
          print("ERROR: GitHub CLI ('gh') is not installed or not in PATH.", file=sys.stderr)
          sys.exit(1)

      repo_name = os.path.basename(destination)

      # 1. Create the repository on GitHub
      print(f"Creating GitHub repository '{repo_name}' as the single source of truth...")
      try:
          create_res = subprocess.run(
              ["gh", "repo", "create", repo_name, "--public"],
              capture_output=True,
              text=True,
              check=True
          )
          output = create_res.stdout.strip() + "\n" + create_res.stderr.strip()
      except subprocess.CalledProcessError as e:
          print(f"ERROR: Failed to create repository on GitHub: {e.stderr}", file=sys.stderr)
          sys.exit(1)

      # 2. Extract the clone URL dynamically
      clone_url = None
      urls = re.findall(r'https://github\.com/[^\s]+', output)
      if urls:
          clone_url = urls[0].replace(".git", "") + ".git"
      
      if not clone_url:
          # Fallback dynamic resolution
          user_res = subprocess.run(["gh", "api", "user", "-q", ".login"], capture_output=True, text=True)
          username = user_res.stdout.strip()
          if not username:
              print("ERROR: Failed to resolve authenticated GitHub user.", file=sys.stderr)
              sys.exit(1)
          clone_url = f"https://github.com/{username}/{repo_name}.git"

      print(f"Dynamically resolved clone URL: {clone_url}")

      # Clean up destination if a partial directory exists (excluding git metadata if cloning fails)
      if os.path.exists(destination):
          shutil.rmtree(destination)

      # 3. Clone the empty GitHub repository locally
      print(f"Cloning empty repository to {destination}...")
      try:
          subprocess.run(["git", "clone", clone_url, destination], check=True)
      except subprocess.CalledProcessError as e:
          print(f"ERROR: Failed to clone repository: {e}", file=sys.stderr)
          sys.exit(1)
  ```

### 3. Add automated commit and push to remote
- **File**: `scripts/bootstrap_downstream.py`
- **Action**: Add Git automation logic at the end of the `main()` function.
- **Target Content**:
  ```python
      if os.path.exists(rules_src):
          rules_dest = os.path.join(destination, "rules")
          shutil.copytree(rules_src, rules_dest, dirs_exist_ok=True)
          print(f"Copied pipeline rules to {rules_dest}")
  ```
- **Replacement Content**:
  ```python
      if os.path.exists(rules_src):
          rules_dest = os.path.join(destination, "rules")
          shutil.copytree(rules_src, rules_dest, dirs_exist_ok=True)
          print(f"Copied pipeline rules to {rules_dest}")

      # 4. Automate Initial Commit and Push to remote
      print("\nStaging, committing, and pushing initial template code to GitHub...")
      try:
          subprocess.run(["git", "add", "-A"], cwd=destination, check=True)
          subprocess.run(
              ["git", "commit", "-m", "chore: bootstrap project from pipeline templates"],
              cwd=destination,
              check=True
          )
          # Rename branch to main if needed
          subprocess.run(["git", "branch", "-M", "main"], cwd=destination, check=True)
          subprocess.run(["git", "push", "-u", "origin", "main"], cwd=destination, check=True)
          print("\nSUCCESS: Downstream project successfully bootstrapped and synced to GitHub remote!")
      except subprocess.CalledProcessError as e:
          print(f"\nERROR during Git push operations: {e}", file=sys.stderr)
          sys.exit(1)
  ```

### 4. Update README.md with generic onboarding Option 1 and placeholders
- **File**: `README.md`
- **Action**: Modify Option 1 block to use generic structure and path (`~/projects`), ensure Option 2 and Option 3 use generic placeholders, and replace absolute local paths (`/Users/perkunas/digital-pipeline-repo`) with `/path/to/digital-pipeline-repo`.
- **Target Content**:
  Option 1, 2, 3 block and other local paths.

### 5. Update wiki/Configuration.md with generic onboarding Option 1 and placeholders
- **File**: `wiki/Configuration.md`
- **Action**: Restructure Option 1 setup guide to match the README format exactly using `~/projects` as the workspace path.
- **Target Content**:
  Option 1 setup guide block.

---

## Verification Plan

### Step 1: Verify README.md Changes
1. Inspect `README.md` changes.
2. Check that Option 1 matches the exact format specified in the prompt.
3. Check that Option 2 and Option 3, as well as general text, contain no personal usernames or local jail paths.

### Step 2: Verify wiki/Configuration.md Changes
1. Inspect `wiki/Configuration.md` changes.
2. Check that Option 1 matches the README.md version exactly.

### Step 3: Git Check and Push
1. Commit the changes.
2. Push to `origin/main`.
3. Verify that `git diff origin/main` is empty.



