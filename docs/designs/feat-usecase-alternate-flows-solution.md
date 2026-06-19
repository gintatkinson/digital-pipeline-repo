# Design: Isolated Subagent Lifecycles & Constraint-Driven Alternate Flows

This document details the design and implementation of context-isolated subagent execution in the specification engineering pipeline, alongside constraint-driven validation rules for Use Case alternate/exception flows.

---

## 1. Context-Isolated Subagent Execution

To prevent context leakage and guarantee that each specification item (Epic, Feature, User Story, and Use Case) is engineered with zero residual state from prior steps, we have restructured the specification pipeline's dispatch mechanisms to use isolated subagents.

### Target Skill Configurations
* **[spec-orchestrator/SKILL.md](../../skills/spec-orchestrator/SKILL.md)**: Updated coordinator orchestration rules to mandate isolated subagent dispatch loops. The coordinator serves strictly as an orchestrator, invoking a fresh worker subagent for each target file.
* **[schema-specification-engineering/SKILL.md](../../skills/schema-specification-engineering/SKILL.md)**: Standardized isolated worker dispatches for Epic and Feature decomposition. 
* **[spec-user-story-engineering/SKILL.md](../../skills/spec-user-story-engineering/SKILL.md)**: Enforced isolated dispatches for generating OOA/OOD User Stories and UML sequence diagrams.
* **[spec-usecase-engineering/SKILL.md](../../skills/spec-usecase-engineering/SKILL.md)**: Mandated that each Use Case is processed by its own fresh, isolated subagent context.

### Conceptual Workflow

```mermaid
graph TD
    Coord[Coordinator Agent] -->|Loop: For Each Item| Dispatch{Spawn Subagent}
    Dispatch -->|Fresh Context / Isolated Scope| Worker[Worker Subagent]
    Worker -->|Analyze Schemas / Generate Spec| Output[Local Markdown Spec]
    Output -->|Return Control| Coord
```

---

## 2. Constraint-Driven Use Case Alternate Flows Validation

Previously, the linter only verified a static floor (typically 2) for Alternate/Exception flows within a Use Case. This resulted in false positives, verifying 100% coverage even when a schema model defined many more validation rules than there were Alternate/Exception flows.

We have redesigned the linter to verify that the number of Alternate/Exception flows in a Use Case matches or exceeds the number of schema validation constraints defined in its referenced features.

### Linter Enhancements
* **Target File**: [uml.py](../../skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/uml.py)
* **Changes**:
  1. **Flow Parsing with Bullet Lookahead**: Modified the alternate flow splitter regex to support both `-` and `*` bullet list styles and parse the entire flow body (including numbered steps) by performing a lookahead for the next flow marker or the end of the block.
  2. **Schema Constraint Counting**: For each Use Case, the linter parses the realization matrix to locate all referenced feature files. It then scans those features' `### Validation & Constraints` (or `### 2. Validation & Constraints`) sections to count the defined validation constraints.
  3. **Constraint-Flow Parity Assertion**: Asserts that the Use Case defines at least `max(flow_limit, total_constraints)` Alternate/Exception flows. If the number of flows is fewer than the total count of validation constraints, the linter reports a compliance violation.

---

## 3. Verification

We verified the linter implementation using the project's test suite:
* **Command**: `python3 test_project/run_tests.py`
* **Result**: **ALL TESTS PASSED SUCCESSFULLY!**
  * Verifies correct parsing of alternate flows and numbered steps.
  * Verifies that isolated class detection in class diagrams blocks invalid connections.
  * Verifies that invalid primitive types in feature class diagrams are correctly flagged.
