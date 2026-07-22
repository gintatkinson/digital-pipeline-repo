#!/usr/bin/env python3
"""
Clean up Git hooks and whitelist pipeline infrastructure directories.
Removes pre-commit and pre-push hooks to prevent auto-triggered compiler runs.
Appends whitelist rules to .gitignore and stages pipeline directories.
"""

import os
import subprocess
import sys

INFRA_DIRS = ["/skills", "/rules", "/.pipeline", "/.agents", "/scripts"]
WHITELIST_HEADER = "\n# Pipeline infrastructure (whitelisted by setup_git_hooks.py)\n"

STAGE_DIRS = [".pipeline/", "skills/", "rules/", "scripts/", ".agents/"]


def _whitelist_infrastructure(repo_root):
    gitignore_path = os.path.join(repo_root, ".gitignore")
    if not os.path.isfile(gitignore_path):
        print(f"Warning: .gitignore not found at {gitignore_path}", file=sys.stderr)
        return

    with open(gitignore_path, "r", encoding="utf-8") as f:
        content = f.read()

    patterns = []
    for d in INFRA_DIRS:
        for suffix in ("/", "/**"):
            pattern = f"!{d}{suffix}"
            if pattern not in content:
                patterns.append(pattern)

    if not patterns:
        print("Infrastructure whitelist entries already present in .gitignore")
        return

    with open(gitignore_path, "a", encoding="utf-8") as f:
        f.write(WHITELIST_HEADER)
        for p in patterns:
            f.write(f"{p}\n")

    print(f"Appended {len(patterns)} whitelist entr{'y' if len(patterns)==1 else 'ies'} to .gitignore")

    subprocess.run(
        ["git", "add"] + STAGE_DIRS,
        capture_output=True, cwd=repo_root
    )
    print("Staged pipeline infrastructure directories")


def setup_git_hooks():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    git_dir = os.path.join(repo_root, ".git")
    
    if not os.path.isdir(git_dir):
        print(f"Error: .git directory not found at {git_dir}", file=sys.stderr)
        sys.exit(1)
        
    hooks_dir = os.path.join(git_dir, "hooks")
    pre_commit_path = os.path.join(hooks_dir, "pre-commit")
    pre_push_path = os.path.join(hooks_dir, "pre-push")
    
    for path in [pre_commit_path, pre_push_path]:
        if os.path.exists(path):
            try:
                os.remove(path)
                print(f"Successfully removed Git hook: {path}")
            except Exception as e:
                print(f"Error removing Git hook {path}: {e}", file=sys.stderr)
        else:
            print(f"Git hook not present: {path}")

    _whitelist_infrastructure(repo_root)


if __name__ == "__main__":
    setup_git_hooks()
