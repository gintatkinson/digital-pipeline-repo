# Implementation Plan: File Correctness Bug for Scene 3D Viewport

## Proposed Changes
1. **Dispatch Subagent for Code Audit**:
   - Dispatch a subagent using `invoke_subagent` (Type: `self`, Role: `Adversarial Code Auditor`) to execute the `adversarial-code-auditor` skill.
   - The subagent will read the skill protocol and file a correctly formatted bug report for `app_flutter/lib/features/topology/scene_3d_viewport.dart:1539-1550`.
   - The subagent will use the user-provided details (5 Whys, Correctness Analysis, Proposed Correction, etc.) to construct the report.
   - The subagent will file the issue using `gh issue create --body-file /tmp/gh_body.md` with the title `[AUDIT] [scene_3d_viewport.dart]: Viewport painting overdraw and canvas bleeding`.

## Verification
- The subagent will verify the output format internally based on the skill's Step D.
- The subagent will return the created GitHub issue URL.
