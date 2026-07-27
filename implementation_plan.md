# Implementation Plan - UML Intermediate Container validation

This plan implements a validation check in the specification auditor to prevent hierarchy collapse or missing intermediate containers in UML class diagrams relative to frontmatter `schema_containers` paths.

## 1. Context & Goal
Issue #49 in the downstream project identifies that `feat-07-locations-container.md` has a direct `Locations *-- Rack` relationship, but fails to model the intermediate `Racks` container class. This collapses the schema hierarchy.
To prevent this in the pipeline, we will add a validation rule to `UmlValidator` in `uml.py` that verifies:
1.  Every segment in a `schema_containers` path has a corresponding class node in the class diagram (allowing CamelCase conversion).
2.  Adjacent segments in a `schema_containers` path have an explicit relationship between their corresponding classes in the class diagram.

## 2. Proposed Changes

### [MODIFY] [uml.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/uml.py)
Extend `_validate_class_diagram` to:
- Parse `schema_containers` from the frontmatter.
- For each path, extract segments (removing module prefix).
- Verify segment CamelCase classes are present in the diagram classes.
- Verify adjacent segment classes have a defined relationship in the diagram.

### [NEW] [test_uml_hierarchy_validation.py](file:///Users/perkunas/jail/digital-pipeline-repo/skills/spec-orchestrator/parity_auditor/tests/test_uml_hierarchy_validation.py)
Add a test suite verifying:
- **RED Phase**: A feature file with `Locations *-- Rack` but missing `Racks` (and missing relationship) correctly flags errors.
- **GREEN Phase**: A feature file with complete `Locations *-- Racks` and `Racks *-- Rack` chain passes.

## 3. Verification Plan
- **Step 1 (RED)**: Run pytest on the new test file before applying the fix. Assert it fails.
- **Step 2 (GREEN)**: Apply the fix. Run pytest on all tests. Assert all 88 tests pass.
- **Step 3 (Remote Sync)**: Push changes and verify `git diff origin/main` is empty.
