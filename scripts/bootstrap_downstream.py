#!/usr/bin/env python3
"""
Bootstrap downstream baseline template files.
Surgically copies template files while preserving target's '.git', 'node_modules', '.dart_tool', and lockfiles.
"""

import argparse
import os
import shutil
import sys
import subprocess
import re

def main():
    parser = argparse.ArgumentParser(description="Bootstrap downstream baseline template files.")
    parser.add_argument("destination", help="Destination path for the bootstrapped project")
    parser.add_argument("--no-domain", action="store_true", help="Skip copying domain directories/files")
    args = parser.parse_args()

    destination = os.path.abspath(args.destination)

    # Determine template source dir relative to this script
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    src_dir = os.path.join(repo_root, "app_flutter")

    if not os.path.exists(src_dir):
        print(f"ERROR: Source template directory '{src_dir}' does not exist.", file=sys.stderr)
        sys.exit(1)

    print(f"Bootstrapping flutter baseline template from {src_dir} to {destination}...")

    # Set of files/folders to preserve at destination
    preserved = {".git", ".dart_tool", "pubspec.lock", "build", "dist"}

    copied_count = 0
    skipped_count = 0

    # Check if gh CLI is available
    if not shutil.which("gh"):
        print("ERROR: GitHub CLI ('gh') is not installed or not in PATH.", file=sys.stderr)
        sys.exit(1)

    repo_name = os.path.basename(destination)

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

    for root, dirs, files in os.walk(src_dir):
        # Filter directories in-place to avoid walking into preserved subdirectories
        dirs[:] = [d for d in dirs if d not in preserved]

        # Calculate destination directory structure
        rel_path = os.path.relpath(root, src_dir)
        norm_rel_path = rel_path.replace(os.sep, "/")

        if args.no_domain and norm_rel_path == "lib":
            if "domain" in dirs:
                dirs.remove("domain")

        if rel_path == ".":
            target_dir = destination
        else:
            target_dir = os.path.join(destination, rel_path)

        if not os.path.exists(target_dir):
            os.makedirs(target_dir, exist_ok=True)

        for file in files:
            target_file = os.path.join(target_dir, file)

            # Check if file name itself is a preserved item and already exists in target
            if file in preserved and os.path.exists(target_file):
                print(f"Preserving existing: {target_file}")
                skipped_count += 1
                continue

            src_file = os.path.join(root, file)
            shutil.copy2(src_file, target_file)
            print(f"Copied: {rel_path if rel_path != '.' else ''}/{file} -> {target_file}")
            copied_count += 1

    print(f"\nBootstrap complete for flutter.")
    print(f"Copied: {copied_count} files.")
    print(f"Skipped/Preserved: {skipped_count} files.")

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

if __name__ == "__main__":
    main()
