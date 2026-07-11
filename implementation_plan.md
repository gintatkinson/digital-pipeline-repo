# Implementation Plan: Add --no-domain flag to verify_downstream_baseline.py

This plan details the changes required to add a `--no-domain` option to `scripts/verify_downstream_baseline.py` to allow skipping domain type compatibility checks and excluding domain baseline files from verification.

---

## Proposed Changes

### 1. Parse `--no-domain` argument
- **File**: `scripts/verify_downstream_baseline.py`
- **Action**: Add `--no-domain` as a boolean option (using `action="store_true"`) to the argument parser.

### 2. Handle `--no-domain` flag
- **File**: `scripts/verify_downstream_baseline.py`
- **Action**:
  - If `--no-domain` is specified, exclude `"src/types.ts"` (for React) or `"lib/domain/types.dart"` (for Flutter) from `baseline_files`.
  - Skip the type compatibility check (checking if mandated classes exist in `types_file`) entirely and print a message: `Skipping domain type compatibility validation (--no-domain specified).`
  - Maintain the exit logic, exiting with code 0 on success.

### 3. Update README.md to document the `--no-domain` option
- **File**: `README.md`
- **Action**: Update the section "Running Compliance Verification Gates" to document the usage of the `--no-domain` flag.

---

## Verification Plan

### Step 1: Run verification commands locally
- Create a test branch `feat/add-no-domain-flag`.
- Run `python3 scripts/verify_downstream_baseline.py --help` to confirm the new flag is listed.
- Verify React downstream conformance with `--no-domain`:
  `python3 scripts/verify_downstream_baseline.py --no-domain react web_react`
- Verify Flutter downstream conformance with `--no-domain`:
  `python3 scripts/verify_downstream_baseline.py --no-domain flutter app_flutter`
- Verify normal behavior still functions correctly when `--no-domain` is not provided.

### Step 2: Commit and push changes
- Commit the changes.
- Push to origin tracking branch.
- Verify `git diff origin/<branch>` is empty.
