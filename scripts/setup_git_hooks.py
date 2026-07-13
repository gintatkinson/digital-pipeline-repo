#!/usr/bin/env python3
# Copyright Gint Atkinson, gint.atkinson@gmail.com
"""
Setup Git hooks for Digital Systems Engineering Pipeline.
Creates pre-commit and pre-push hooks to enforce constraints.
"""

import os
import sys

def setup_git_hooks():
    # Identify the repository root and .git/hooks directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    git_dir = os.path.join(repo_root, ".git")
    
    if not os.path.isdir(git_dir):
        print(f"Error: .git directory not found at {git_dir}", file=sys.stderr)
        sys.exit(1)
        
    hooks_dir = os.path.join(git_dir, "hooks")
    os.makedirs(hooks_dir, exist_ok=True)
    
    # Pre-commit hook runs model coverage verification
    pre_commit_content = """#!/bin/sh
echo "Warning: Model coverage verification is being run..."
python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only
if [ $? -ne 0 ]; then
    echo "Error: Model coverage verification failed. Commit aborted."
    exit 1
fi
"""
    
    # Pre-push hook runs downstream baseline verifier check
    pre_push_content = """#!/bin/sh
echo "Warning: Downstream baseline compilation verifier check is being run..."
python3 scripts/verify_downstream_baseline.py app_flutter
if [ $? -ne 0 ]; then
    echo "Error: Downstream baseline verifier check failed. Push aborted."
    exit 1
fi
"""
    
    pre_commit_path = os.path.join(hooks_dir, "pre-commit")
    pre_push_path = os.path.join(hooks_dir, "pre-push")
    
    # Write pre-commit hook
    with open(pre_commit_path, "w", encoding="utf-8") as f:
        f.write(pre_commit_content)
    # Make executable
    os.chmod(pre_commit_path, 0o755)
    print(f"Successfully installed and configured pre-commit hook at {pre_commit_path}")
    
    # Write pre-push hook
    with open(pre_push_path, "w", encoding="utf-8") as f:
        f.write(pre_push_content)
    # Make executable
    os.chmod(pre_push_path, 0o755)
    print(f"Successfully installed and configured pre-push hook at {pre_push_path}")

if __name__ == "__main__":
    setup_git_hooks()
