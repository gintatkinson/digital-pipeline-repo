# Implementation Plan: Bug #185

1. **Step 1 - Reproduction Subagent**: Dispatch subagent to reproduce Bug #185 by reviewing `scripts/verify_downstream_baseline.py`.
2. **Step 2 - Hypothesis Subagent**: Dispatch subagent to hypothesize why `.dart_tool`, `.flutter-plugins`, etc., aren't removed.
3. **Step 3 - Investigation Subagent**: Dispatch subagent to investigate the `cleanup_workspace` function.
4. **Step 4 - Evidence Subagent**: Dispatch subagent to document findings.
5. **Step 5 - Root Cause Subagent**: Dispatch subagent to determine root cause.
6. **Step 6 - Fix Subagent**: Dispatch subagent to implement fix in `scripts/verify_downstream_baseline.py` to remove `.dart_tool`, `.flutter-plugins`, and `.flutter-plugins-dependencies` and run tests.
7. **Step 7 - Verification Subagent**: Dispatch subagent to verify fix with pytest, commit, push, and close the issue on GitHub.
