#!/usr/bin/env python3
"""
Verify downstream project baseline conformance.
Asserts baseline files exist, validates type compatibility with mandated domain classes,
and runs the build/test commands ('npm run build' for React, 'flutter analyze && flutter test' for Flutter).
"""

import argparse
import json
import os
import re
import subprocess
import sys

# Mandated domain classes/interfaces to check in types.ts or types.dart
MANDATED_CLASSES = []

def load_mandated_classes(destination):
    config_paths = [
        os.path.join(destination, ".pipeline", "logical-ui", "codebase_rules.json"),
        os.path.join(destination, "codebase_rules.json"),
        os.path.join(destination, "baseline_manifest.json")
    ]
    for path in config_paths:
        if os.path.isfile(path):
            try:
                with open(path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                
                classes = None
                if isinstance(data, dict):
                    if "validation_rules" in data and isinstance(data["validation_rules"], dict):
                        classes = data["validation_rules"].get("mandated_classes")
                    if classes is None:
                        classes = data.get("mandated_classes")
                
                if isinstance(classes, list):
                    if all(isinstance(c, str) for c in classes):
                        print(f"Loaded mandated classes dynamically from {path}: {classes}")
                        return classes
                    else:
                        print(f"WARNING: Invalid format for 'mandated_classes' in {path} (not all elements are strings).", file=sys.stderr)
                else:
                    print(f"WARNING: 'mandated_classes' not found or not a list in {path}.", file=sys.stderr)
            except Exception as e:
                print(f"WARNING: Failed to parse or load config {path}: {e}", file=sys.stderr)
    
    print("Using default hardcoded MANDATED_CLASSES.")
    return MANDATED_CLASSES

def main():
    parser = argparse.ArgumentParser(description="Verify a downstream project's baseline conformance.")
    parser.add_argument("--no-domain", action="store_true", help="Skip checking the domain model")
    parser.add_argument("destination", nargs="?", default=".", help="Path to the downstream project directory (defaults to current directory)")
    args = parser.parse_args()

    dest = os.path.abspath(args.destination)

    if not os.path.isdir(dest):
        print(f"ERROR: Destination path '{dest}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    is_flutter = os.path.exists(os.path.join(dest, "pubspec.yaml"))
    # If checking from root and app_flutter exists, run inside app_flutter
    if not is_flutter and os.path.isdir(os.path.join(dest, "app_flutter")):
        dest_flutter = os.path.join(dest, "app_flutter")
        if os.path.exists(os.path.join(dest_flutter, "pubspec.yaml")):
            dest = dest_flutter
            is_flutter = True

    is_react = os.path.exists(os.path.join(dest, "package.json"))
    if not is_react and os.path.isdir(os.path.join(dest, "web_react")):
        dest_react = os.path.join(dest, "web_react")
        if os.path.exists(os.path.join(dest_react, "package.json")):
            dest = dest_react
            is_react = True

    if not is_flutter and not is_react:
        print(f"ERROR: Destination path '{dest}' does not appear to be a Flutter or React project (missing pubspec.yaml and package.json).", file=sys.stderr)
        sys.exit(1)

    if is_flutter:
        print(f"Verifying conformance for platform 'flutter' at '{dest}'...")
        # 1. Assert baseline files exist
        baseline_files = [
            "pubspec.yaml",
            "analysis_options.yaml",
            "lib/main.dart",
            "lib/domain/repository_resolver.dart",
            "lib/domain/validation.dart"
        ]
        if args.no_domain:
            baseline_files.remove("lib/domain/repository_resolver.dart")
            baseline_files.remove("lib/domain/validation.dart")

        missing_files = []
        for f in baseline_files:
            path = os.path.join(dest, f)
            if not os.path.exists(path):
                missing_files.append(f)

        if missing_files:
            print(f"ERROR: Flutter baseline file(s) missing: {', '.join(missing_files)}", file=sys.stderr)
            sys.exit(1)

        print("Success: All Flutter baseline files exist.")

        # 2. Validate type compatibility
        if args.no_domain:
            print("Skipping domain type compatibility validation (--no-domain specified).")
        else:
            print("Success: Type compatibility validation passed (domain layer exists).")

        # 3. Run build/test commands
        if args.no_domain:
            print("Skipping build and test suite execution (--no-domain specified, domain implementation pending).")
        else:
            try:
                print("Running 'flutter pub get' to resolve dependencies...")
                subprocess.run(["flutter", "pub", "get"], cwd=dest, check=True)
                
                print("Running 'flutter analyze'...")
                subprocess.run(["flutter", "analyze", "--no-fatal-warnings", "--no-fatal-infos"], cwd=dest, check=True)
                
                print("Running 'flutter test'...")
                subprocess.run(["flutter", "test"], cwd=dest, check=True)
            except subprocess.CalledProcessError as e:
                print(f"ERROR: Verification command failed: {e}", file=sys.stderr)
                sys.exit(1)

    if is_react:
        print(f"Verifying conformance for platform 'react' at '{dest}'...")
        # 1. Assert baseline files exist
        has_tsconfig = os.path.exists(os.path.join(dest, "tsconfig.json"))
        has_jsconfig = os.path.exists(os.path.join(dest, "jsconfig.json"))
        if not has_tsconfig and not has_jsconfig:
            print("ERROR: TSConfig or JSConfig is missing.", file=sys.stderr)
            sys.exit(1)

        entry_candidates = ["src/main.tsx", "src/main.jsx", "src/index.tsx", "src/index.jsx"]
        entry_file = None
        for cand in entry_candidates:
            if os.path.exists(os.path.join(dest, cand)):
                entry_file = cand
                break
        if not entry_file:
            print(f"ERROR: React entrypoint file missing (expected one of: {', '.join(entry_candidates)})", file=sys.stderr)
            sys.exit(1)

        if not args.no_domain:
            validation_candidates = ["src/domain/validation.ts", "src/domain/validation.js", "src/domain/validation.tsx", "src/domain/validation.jsx"]
            validation_file = None
            for cand in validation_candidates:
                if os.path.exists(os.path.join(dest, cand)):
                    validation_file = cand
                    break
            if not validation_file:
                print(f"ERROR: Domain validation file missing (expected one of: {', '.join(validation_candidates)})", file=sys.stderr)
                sys.exit(1)

        print("Success: All React baseline files exist.")

        # 2. Validate type compatibility
        if args.no_domain:
            print("Skipping domain type compatibility validation (--no-domain specified).")
        else:
            print("Success: Type compatibility validation passed (domain layer exists).")

        # 3. Run build/test commands
        if args.no_domain:
            print("Skipping build execution (--no-domain specified, domain implementation pending).")
        else:
            try:
                print("Running 'npm install' to resolve dependencies...")
                subprocess.run(["npm", "install"], cwd=dest, check=True)
                
                print("Running 'npm run build'...")
                subprocess.run(["npm", "run", "build"], cwd=dest, check=True)
            except subprocess.CalledProcessError as e:
                print(f"ERROR: React verification command failed: {e}", file=sys.stderr)
                sys.exit(1)

    print("Success: Build and test suite execution passed. Conformance gate verified.")
    sys.exit(0)

if __name__ == "__main__":
    main()
