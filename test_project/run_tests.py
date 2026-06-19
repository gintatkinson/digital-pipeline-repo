#!/usr/bin/env python3
import subprocess
import os
import sys
import re

TEST_PROJECT_DIR = os.path.dirname(os.path.abspath(__file__))
WORKSPACE_DIR = os.path.dirname(TEST_PROJECT_DIR)

LINTER_SCRIPT = os.path.join(WORKSPACE_DIR, "skills", "spec-orchestrator", "scripts", "verify_model_coverage.py")
RULES_PATH = os.path.join(TEST_PROJECT_DIR, ".pipeline", "logical-ui", "codebase_rules.json")

EPIC_FILE = os.path.join(TEST_PROJECT_DIR, "docs", "epics", "epic-01-test-location.md")
FEATURE_FILE = os.path.join(TEST_PROJECT_DIR, "docs", "features", "feat-01-reference-frame.md")

def run_linter():
    env = os.environ.copy()
    env["CODEBASE_RULES_PATH"] = RULES_PATH
    env["PYTHONPATH"] = os.path.join(WORKSPACE_DIR, "skills", "spec-orchestrator", "parity_auditor", "src")
    
    cmd = [
        sys.executable,
        LINTER_SCRIPT,
        os.path.join(TEST_PROJECT_DIR, "schema"),
        os.path.join(TEST_PROJECT_DIR, "docs", "features")
    ]
    res = subprocess.run(cmd, capture_output=True, text=True, env=env)
    return res

def test_valid_specifications():
    print("--- Test 1: Valid Specifications ---")
    res = run_linter()
    print("Exit code:", res.returncode)
    if res.returncode != 0:
        print("Stdout:", res.stdout)
        print("Stderr:", res.stderr)
        raise AssertionError("Linter failed on valid specifications.")
    print("PASS: Linter successfully accepted valid specifications.")

def test_isolated_class_detection():
    print("--- Test 2: Isolated Class Detection ---")
    with open(EPIC_FILE, "r") as f:
        content = f.read()
        
    # Introduce an isolated class by removing the connection line
    bad_content = content.replace("GeoLocation --> ReferenceFrame : referenceFrame", "%% Commented connection")
    with open(EPIC_FILE, "w") as f:
        f.write(bad_content)
        
    try:
        res = run_linter()
        print("Exit code:", res.returncode)
        print("Stdout:", res.stdout)
        
        if res.returncode == 0:
            raise AssertionError("Linter failed to detect isolated class in Epic class diagram.")
        if "contains class 'ReferenceFrame' with zero relationships" not in res.stdout and "contains class 'ReferenceFrame' with zero relationships" not in res.stderr:
            if "contains a disconnected UML Class Diagram" not in res.stdout:
                raise AssertionError(f"Linter did not report the correct isolated class error. Output: {res.stdout}")
        print("PASS: Linter successfully blocked isolated classes.")
    finally:
        # Restore file
        with open(EPIC_FILE, "w") as f:
            f.write(content)

def test_invalid_type_detection():
    print("--- Test 3: Invalid Type Detection ---")
    with open(FEATURE_FILE, "r") as f:
        content = f.read()
        
    # Introduce an invalid type
    bad_content = content.replace("+String alternateSystem", "+CustomType alternateSystem")
    with open(FEATURE_FILE, "w") as f:
        f.write(bad_content)
        
    try:
        res = run_linter()
        print("Exit code:", res.returncode)
        print("Stdout:", res.stdout)
        
        if res.returncode == 0:
            raise AssertionError("Linter failed to detect invalid type in Feature class diagram.")
        if "has invalid type 'CustomType'" not in res.stdout and "has invalid type 'CustomType'" not in res.stderr:
            raise AssertionError(f"Linter did not report the correct invalid type error. Output: {res.stdout}")
        print("PASS: Linter successfully blocked invalid primitive types.")
    finally:
        # Restore file
        with open(FEATURE_FILE, "w") as f:
            f.write(content)

def main():
    try:
        test_valid_specifications()
        test_isolated_class_detection()
        test_invalid_type_detection()
        print("\nALL TESTS PASSED SUCCESSFULLY!")
        sys.exit(0)
    except Exception as e:
        print(f"\nTEST SUITE FAILED: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
