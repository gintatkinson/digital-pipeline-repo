# Implementation Plan - Fix Bug #191

## User Request
Execute the 7-step debug-protocol for Bug #191: "Tooling Bug: Installation instructions in README.md miss copying .gitignore".
Task: Gather complete symptom info, reproduce the bug consistently, determine scope (isolated or systemic), and check environment (version, platform). Return reproduction steps and scope report.

## Proposed Changes
1. **Dispatch Step 2 Hypothesis Subagent**: Generate hypotheses.
2. **Dispatch Step 3 Investigation Subagent**: Trace and investigate the issue.
3. **Dispatch Step 4 Evidence Subagent**: Document evidence.
4. **Dispatch Step 5 Root Cause Subagent**: Find root cause.
5. **Dispatch Step 6 Fix Subagent**: Apply fix in README.md, commit, and push.
6. **Dispatch Step 7 Verification Subagent**: Validate the fix and close issue.

## Verification Plan
1. Ensure the fix code is applied.
2. Confirm tests pass and `git diff` is empty.
