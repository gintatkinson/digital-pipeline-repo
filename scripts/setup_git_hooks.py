#!/usr/bin/env python3
"""
Clean up Git hooks for Digital Systems Engineering Pipeline.
Removes pre-commit and pre-push hooks to prevent auto-triggered compiler runs.
"""

import os
import sys

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

if __name__ == "__main__":
    setup_git_hooks()
