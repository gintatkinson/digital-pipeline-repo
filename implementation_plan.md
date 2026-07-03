# Implementation Plan: Robust Bootstrapping Fallback Implementation

This plan details the changes to `scripts/bootstrap_downstream.py` to catch "already exists" errors during repository creation on GitHub and gracefully fallback to cloning the existing repository.

---

## Proposed Changes

### 1. Update try/except block for `gh repo create` in bootstrapping script
- **File**: `scripts/bootstrap_downstream.py`
- **Action**: Modify the try/except block for `gh repo create` (lines 53-63) to check if the error message contains "already exists" or "name already exists", print a warning, and proceed rather than failing.
- **Target Content**:
```python
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
```
- **Replacement Content**:
```python
    # 1. Create the repository on GitHub
    print(f"Creating GitHub repository '{repo_name}' as the single source of truth...")
    output = ""
    try:
        create_res = subprocess.run(
            ["gh", "repo", "create", repo_name, "--public"],
            capture_output=True,
            text=True,
            check=True
        )
        output = create_res.stdout.strip() + "\n" + create_res.stderr.strip()
    except subprocess.CalledProcessError as e:
        err_msg = (e.stdout or "") + "\n" + (e.stderr or "")
        if "already exists" in err_msg.lower() or "name already exists" in err_msg.lower():
            print(f"WARNING: Repository '{repo_name}' already exists on GitHub. Proceeding to clone existing repository...")
            output = err_msg
        else:
            print(f"ERROR: Failed to create repository on GitHub: {err_msg}", file=sys.stderr)
            sys.exit(1)
```

---

## Verification Plan

### Step 1: Run bootstrap with existing repository name
Run a test run using the pre-existing repository name:
`python3 scripts/bootstrap_downstream.py flutter scratch/unreal-spatial-project-test`

Verify that:
1. It prints the warning: `WARNING: Repository 'unreal-spatial-project-test' already exists on GitHub. Proceeding to clone existing repository...`
2. It clones, populates, and pushes successfully.
3. Clean up the directory `/Users/perkunas/jail/digital-pipeline-repo/scratch/unreal-spatial-project-test`.

### Step 2: Push changes and verify git diff
1. Commit the changes to `scripts/bootstrap_downstream.py` and `implementation_plan.md`.
2. Push to `origin/main`.
3. Verify `git diff origin/main` is empty.
