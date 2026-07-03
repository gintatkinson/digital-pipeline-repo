# Implementation Plan: One-Step Downstream Bootstrapping (Option 1)

This plan details the changes to implement the approved plan for the one-step downstream bootstrapping setup.

---

## Proposed Changes

### 1. Auto-copy pipeline skills/ and rules/ to destination root
- **File**: `scripts/bootstrap_downstream.py`
- **Action**: Append logic at the end of the `main()` function (after line 88, before `if __name__ == "__main__":`) to copy the `skills/` and `rules/` directories from `repo_root` to `destination`.
- **Snippet to insert**:
  ```python
    # Auto-copy skills/ and rules/ directories to destination root
    print("\nCopying pipeline rules and skills to destination root...")
    skills_src = os.path.join(repo_root, "skills")
    rules_src = os.path.join(repo_root, "rules")
    
    if os.path.exists(skills_src):
        skills_dest = os.path.join(destination, "skills")
        shutil.copytree(skills_src, skills_dest, dirs_exist_ok=True)
        print(f"Copied pipeline skills to {skills_dest}")
        
    if os.path.exists(rules_src):
        rules_dest = os.path.join(destination, "rules")
        shutil.copytree(rules_src, rules_dest, dirs_exist_ok=True)
        print(f"Copied pipeline rules to {rules_dest}")
  ```

### 2. Update README.md
- **File**: `README.md`
- **Action**: Add "Installation Option 1: One-Step Downstream Bootstrapping (Recommended)" as the primary option, and adjust Option 2 and Option 3. Preserve original license warnings and diagrams.

### 3. Update wiki/Configuration.md
- **File**: `wiki/Configuration.md`
- **Action**: Place the one-step bootstrapping command as the recommended Option 1.

---

## Verification Plan

### Step 1: Execute Bootstrapping script
1. Run:
   ```bash
   python3 scripts/bootstrap_downstream.py flutter /tmp/test-bootstrapped-app
   ```
2. Verify that `/tmp/test-bootstrapped-app` contains the copied application, the `skills/` folder, and the `rules/` folder.
3. Clean up `/tmp/test-bootstrapped-app`.

### Step 2: Push and Verify Git Diff
1. Commit the changes and push to origin/main.
2. Verify `git diff origin/main` is empty.
