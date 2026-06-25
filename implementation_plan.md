# Implementation Plan - Issue #65 Baseline Verification Customizations

This plan details the implementation of baseline verification customizations and the `--no-domain` option during bootstrapping and compliance checks.

## Proposed Changes

### 1. `scripts/bootstrap_downstream.py`
- Add `--no-domain` command-line argument.
- Adjust directory/file walking loop to:
  - If `platform == "flutter"` and `--no-domain` is active, skip entering and copying the `lib/domain` directory.
  - If `platform == "react"` and `--no-domain` is active, skip copying the `src/types.ts` file.

### 2. `scripts/verify_downstream_baseline.py`
- Look up the list of mandated classes dynamically from:
  1. `<destination>/.pipeline/logical-ui/codebase_rules.json`
  2. `<destination>/codebase_rules.json`
  3. `<destination>/baseline_manifest.json`
- Parse `"mandated_classes"` from under `"validation_rules"`, or at the root level of the JSON config file.
- Fall back to the default hardcoded `MANDATED_CLASSES` list if none of the configuration files exist or are valid.

### 3. `README.md`
- Document the `--no-domain` flag around lines 296 and 323-336.
- Update description of the compliance verification script to document dynamic validation checks.

### 4. `.pipeline/constitution.md`
- Amend Section 4.5 to specify that domain baseline verification is dynamically parameterized via project-specific configuration rules.

### 5. `.agents/skills/feature-driven-implementation/SKILL.md`
- Update instructions to mention that the `--no-domain` flag should be used during bootstrapping if implementing a different project domain.

## Verification Plan

### Automated/Manual Verification Steps
1. Run `bootstrap_downstream.py` with `--no-domain` to a temporary directory in the workspace (`tmp/test-no-domain-react` and `tmp/test-no-domain-flutter`) and verify that:
   - For React, the file `src/types.ts` is NOT copied.
   - For Flutter, the folder `lib/domain` is NOT created/copied.
2. Run `verify_downstream_baseline.py` with custom configurations containing a subset of classes to verify they parse and pass compliance checks when only that subset is defined.
3. Verify that `git diff origin/master` contains all changes, compilation/tests pass, and the walkthrough is completed.
