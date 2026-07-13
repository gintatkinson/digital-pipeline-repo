# Implementation Plan: Role Boundary Lock Rule

We will create the new rule file `rules/role-boundary-lock.md`, append it to `.agents/AGENTS.md`, and add it to `README.md`.

## Proposed Changes

### Rules and Agent Configurations

#### [CREATE] [rules/role-boundary-lock.md](file:///Users/perkunas/jail/digital-pipeline-repo/rules/role-boundary-lock.md)
- Create a new rule file containing strict role-based tool locking rules for specification and implementation phases.

#### [MODIFY] [.agents/AGENTS.md](file:///Users/perkunas/jail/digital-pipeline-repo/.agents/AGENTS.md)
- Append a new section `## Role Boundary Lock` at the end of the file.

#### [MODIFY] [README.md](file:///Users/perkunas/jail/digital-pipeline-repo/README.md)
- Add a row for `role-boundary-lock` in the "Always-Loaded Governance Rules" table.

## Verification Plan

### Downstream Verifier
- Run:
  ```bash
  python3 scripts/verify_downstream_baseline.py app_flutter
  ```
