# Implementation Plan - Update README.md Feature Implementation Prompt

Update the Feature Implementation Prompt in `README.md` to include downstream baseline seeding and rules verification.

## Proposed Changes

### 1. `README.md`
- Replace the existing "Feature Implementation Prompt" block with the new one containing:
  - Step 0: Pre-Execution Seeding & Rules Verification (references `scripts/bootstrap_downstream.py`, Project Constitution `.pipeline/constitution.md`, and Zero-Mocking Live Persistence Mandate).
  - Step 7: Verification Proof via compliance engine run (`python3 scripts/verify_downstream_baseline.py`).

## Verification Plan

### Automated Verification
1. Run `git diff README.md` to verify the changes match the replacement text exactly.
2. Verify that there are no syntax errors or formatting issues in `README.md`.
