# Implementation Plan: Fix Clone URLs in README Installation Guide

This plan outlines the surgical changes required to correct the clone URL placeholders in the README installation instructions.

## Proposed Changes

### 1. Update README Installation Instructions
- **Target File**: `README.md`
- **Action**: Replace the placeholder `<owner>/<template-repo>` in lines 146 and 158 with `gintatkinson/digital-pipeline-repo`.
  - **Before (Line 146)**: `git clone https://github.com/<owner>/<template-repo>.git ./.tmp-pipeline`
  - **After (Line 146)**: `git clone https://github.com/gintatkinson/digital-pipeline-repo.git ./.tmp-pipeline`
  - **Before (Line 158)**: `git clone -b refactor https://github.com/<owner>/<template-repo>.git ./.tmp-pipeline`
  - **After (Line 158)**: `git clone -b refactor https://github.com/gintatkinson/digital-pipeline-repo.git ./.tmp-pipeline`

### 2. Update Implementation Plan
- **Target File**: `implementation_plan.md`
- **Action**: Document the current implementation plan for this branch/task.

## Verification Plan

### Step 1: Git Diff Check
- Run `git diff README.md` to verify that only the expected replacement edits were performed.

### Step 2: Push and Sync Check
- Commit and push to origin on the branch `fix/installation-instructions-readme`.
- Verify that `git diff origin/fix/installation-instructions-readme` is empty.
