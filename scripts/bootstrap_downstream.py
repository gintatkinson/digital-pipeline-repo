#!/usr/bin/env python3
"""
Bootstrap downstream baseline template files.
Surgically copies template files while preserving target's '.git', 'node_modules', '.dart_tool', and lockfiles.
"""

import argparse
import os
import shutil
import sys

def main():
    parser = argparse.ArgumentParser(description="Bootstrap downstream baseline template files.")
    parser.add_argument("platform", choices=["react", "flutter"], help="Platform to bootstrap ('react' or 'flutter')")
    parser.add_argument("destination", help="Destination path for the bootstrapped project")
    parser.add_argument("--no-domain", action="store_true", help="Skip copying domain directories/files")
    args = parser.parse_args()

    platform = args.platform
    destination = os.path.abspath(args.destination)

    # Determine template source dir relative to this script
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    if platform == "react":
        src_dir = os.path.join(repo_root, "web_react")
    else:  # flutter
        src_dir = os.path.join(repo_root, "app_flutter")

    if not os.path.exists(src_dir):
        print(f"ERROR: Source template directory '{src_dir}' does not exist.", file=sys.stderr)
        sys.exit(1)

    print(f"Bootstrapping {platform} baseline template from {src_dir} to {destination}...")

    # Set of files/folders to preserve at destination
    preserved = {".git", "node_modules", ".dart_tool", "package-lock.json", "pubspec.lock", "yarn.lock", "pnpm-lock.yaml", "build", "dist"}

    copied_count = 0
    skipped_count = 0

    # Ensure destination directory exists
    if not os.path.exists(destination):
        os.makedirs(destination, exist_ok=True)

    for root, dirs, files in os.walk(src_dir):
        # Filter directories in-place to avoid walking into preserved subdirectories
        dirs[:] = [d for d in dirs if d not in preserved]

        # Calculate destination directory structure
        rel_path = os.path.relpath(root, src_dir)
        norm_rel_path = rel_path.replace(os.sep, "/")

        if args.no_domain and platform == "flutter" and norm_rel_path == "lib":
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

            if args.no_domain and platform == "react" and norm_rel_path == "src" and file == "types.ts":
                print(f"Skipping domain file per --no-domain: {file}")
                skipped_count += 1
                continue

            src_file = os.path.join(root, file)
            shutil.copy2(src_file, target_file)
            print(f"Copied: {rel_path if rel_path != '.' else ''}/{file} -> {target_file}")
            copied_count += 1

    print(f"\nBootstrap complete for {platform}.")
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

if __name__ == "__main__":
    main()
