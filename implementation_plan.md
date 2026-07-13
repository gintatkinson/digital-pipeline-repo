# Implementation Plan: Add --spec-only Flag and Warning for Specification Phases

Modify files to add the `--spec-only` flag to model coverage verification commands during specification phases, and add a warning explaining its mandatory nature.

## Proposed Changes

### Skill Instructions

#### [MODIFY] [skills/spec-orchestrator/SKILL.md](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/SKILL.md)
- Modify the command around line 94 to:
  ```bash
  ./skills/spec-orchestrator/scripts/verify_model_coverage.py [schema_dir] [features_dir] --spec-only
  ```
- Add a warning block explaining that the `--spec-only` flag is mandatory for specification phases to prevent checking implementation coverage.

### Wiki Documentation

#### [MODIFY] [wiki/Pipeline-1-Specification-Engineering.md](file:///Users/perkunas/jail/digital-pipeline-repo/wiki/Pipeline-1-Specification-Engineering.md)
- Modify the command around line 87 to:
  ```bash
  ./skills/spec-orchestrator/scripts/verify_model_coverage.py [schema_dir] [features_dir] --spec-only
  ```

#### [MODIFY] [wiki/Workflows.md](file:///Users/perkunas/jail/digital-pipeline-repo/wiki/Workflows.md)
- Modify the command at lines 60 and 137 to:
  ```bash
  ./skills/spec-orchestrator/scripts/verify_model_coverage.py [schema_dir] [features_dir] --spec-only
  ```

## Verification Plan

### Automated Downstream Verification
- Run downstream verifier check:
  ```bash
  python3 scripts/verify_downstream_baseline.py app_flutter
  ```
