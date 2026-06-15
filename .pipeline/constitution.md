<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

---
title: "Project Constitution -- Functional Layer (Default)"
project: "Digital Systems Engineering Pipeline"
tier: functional
created: "2025-06-13"
last_updated: "2026-06-15"
---

# Project Constitution: Digital Systems Engineering Pipeline

> This document governs specification generation and is platform-independent.
> All agents MUST read this file before beginning any pipeline execution.
> For platform-specific rules, see `.pipeline/profiles/<platform>.md`.

---

## 1. Domain Rules

### 1.1 Specification Sources

- Primary sources are normative standards documents: IETF RFCs, 3GPP Technical Specifications, IEEE standards, CAMARA APIs, ITU-T Recommendations.
- Structural schemas (YANG, OpenAPI, Protobuf, ASN.1, SysMLv2) are the authoritative machine-readable models.
- When the normative text and the schema conflict, the schema is authoritative for structural completeness; the normative text is authoritative for behavioral semantics.

### 1.2 Schema Compliance

- Every data model constraint in the schema MUST be captured in at least one Feature's acceptance criteria. Zero loss tolerance.
- Constraints include: data type, validation ranges, regex patterns, default values, mandatory fields, conditional expressions, minimum/maximum elements, and structural relationship references.
- If a schema node has no explicit constraint, document its type and note "no additional constraints specified in schema."

### 1.3 Data Model Integrity

- Every schema definition, model node, data object, property, variant, custom type, and extension defined in the input schemas MUST map to at least one Feature.
- Cross-module references (leafref, augment, uses) must be explicitly documented with source and target module names.
- Circular dependencies must be flagged and escalated -- do not silently drop them.

### 1.4 UML Metamodel & Profile Mapping Standard

To maintain rigorous, machine-readable representations, all incoming authoritative schemas MUST map strictly to UML elements according to the following profile rules:
- **YANG Schema Mappings**:
  - A YANG `module` or `submodule` maps to a **UML Component**.
  - A YANG `container`, `list`, or `grouping` maps to a **UML Class**.
  - A YANG `leaf` or `leaf-list` maps to a **UML Attribute** (with multiplicity `[0..1]` or `[0..*]` respectively).
  - A YANG `rpc` or `action` maps to a **UML Operation**.
  - Any YANG `must`, `when`, `range`, `pattern`, or `length` statement maps to a **UML Constraint** (specified in OCL or formal structured text).
- **OpenAPI Mappings**:
  - An OpenAPI document or tag group maps to a **UML Component**.
  - An OpenAPI `Schema Object` maps to a **UML Class**.
  - An OpenAPI schema property maps to a **UML Attribute** (multiplicity `[1..1]` if required, `[0..1]` otherwise).
  - An OpenAPI path operation (GET, POST, PUT, DELETE, etc.) maps to a **UML Operation**.
  - API validation keywords (`minimum`, `maximum`, `pattern`, `enum`) map to a **UML Constraint**.
- **Protobuf Mappings**:
  - A Protobuf `package` maps to a **UML Component** or package boundary.
  - A Protobuf `message` maps to a **UML Class**.
  - A Protobuf field maps to a **UML Attribute** (multiplicity `[0..*]` for `repeated` fields, `[0..1]` for optional, `[1..1]` for required/implicit).
  - A Protobuf `service` maps to a **UML Interface** or **UML Component**.
  - A Protobuf `rpc` definition maps to a **UML Operation**.
  - Protobuf validation options (e.g., `buf.validate`) map to a **UML Constraint**.

### 1.5 Universal Model Consistency Rules

To prevent semantic divergence between structural design and dynamic behavior:
- **Dynamic-to-Static Alignment**: No class, component, interface, attribute, operation, signal, or message may be used in dynamic behavior diagrams (such as UML Sequence Diagrams or State Machine Diagrams) unless it is explicitly defined in the structural UML Class Diagrams or Component Diagrams.
- **Sequence Diagram Lifelines**: Every lifeline in a sequence diagram MUST represent an instance of a defined UML Class or Component.
- **Message and Call Consistency**: Every message (synchronous, asynchronous, or return) in a sequence diagram must map to an active UML Operation or Signal defined on the target classifier's interface/class definition.
- **State Transition Events**: Every trigger, event, or action on a UML State Machine transition must be defined as a UML Operation or Signal in the class metamodel.
- **Auto-verification Failure**: Any diagram or spec that references undefined operations, classes, or signals will violate the quality gates and halt the pipeline.

### 1.6 Traceability

- Every Epic MUST reference the specification section(s) it covers.
- Every Feature MUST include a "Source References" section with verbatim specification clause numbers and schema paths.
- Every User Story MUST link to the Features it validates.
- Every Use Case MUST link to the User Stories and Features it realizes.

---

## 2. Specification Standards

### 2.1 Epic Granularity

- One Epic per major functional domain or protocol module.
- An Epic should contain 3-15 Features. Fewer than 3 means the Epic is too narrow; more than 15 means it should be split.
- Epic titles use the format: `[Module/Domain]: [Functional Area]` (e.g., "Network Topology: Node Management").

### 2.2 Feature Granularity

- A Feature represents a single, independently testable functional capability.
- A Feature should have 3-10 acceptance criteria. Fewer means it lacks specificity; more than 10 means it should be split.
- Features MUST be platform-independent. No framework names, no UI component names, no implementation technology references.
- Feature titles use the format: `[Verb] [Object] [Qualifier]` (e.g., "Display Node Attributes with Constraint Validation").

### 2.3 BDD Scenario Format

- All acceptance criteria MUST use Given-When-Then format.
- Given: establishes preconditions and system state.
- When: describes the trigger action or event.
- Then: specifies the observable outcome with measurable assertions.
- Negative scenarios (error cases, boundary violations) are MANDATORY for every constraint.
- Example:
  ```
  Given a database record with a status attribute restricted to enum values {active, suspended, inactive}
  When the system receives a value of "unknown" (not in enumeration)
  Then the system rejects the value with a constraint violation error
  ```

### 2.4 User Story Format

- User Stories follow: `As a [Actor], I want to [Action], so that [Outcome]`.
- Each User Story MUST have at least one BDD scenario (Given-When-Then).
- Stories are modeled using OOA/OOD methodology -- actors map to UML objects with defined responsibilities.
- The "Required Features Matrix" links each story to the Feature issue numbers it depends on.

### 2.5 Use Case Formality

- Use Cases follow UML formal structure: Actor, Preconditions, Main Success Scenario (numbered steps), Alternate Flows, Postconditions.
- The Realization Matrix maps each Use Case to its constituent User Stories and Features.
- Duplicate detection is mandatory before creating new Use Cases.

### 2.6 Labeling Taxonomy

- Exactly four label types: `epic`, `feature`, `user-story`, `use-case`.
- Labels are bootstrapped via `gh label create --force` to ensure idempotency.
- Each GitHub issue carries exactly one of these labels.

---

## 3. Agent Behavior Rules

### 3.1 Commit Format

- Specification commits: `docs: [action] [artifact type] -- [brief description]`
  - Example: `docs: create feature -- display node attributes with validation`
  - Example: docs: update epic -- add domain-registration features
- Implementation commits: `feat:`, `fix:`, `test:`, `refactor:`, `chore:` per Conventional Commits.

### 3.2 Branch Strategy

- Specification work: directly on the default branch (e.g. `main`/`master`) or a single `spec/<module>` branch if the change is large.
- Implementation work: `feat/<issue-number>-<short-description>` branches.

### 3.3 Documentation Standards

- All generated markdown files include YAML frontmatter.
- All generated markdown files include a "Source References" section at the bottom.
- No orphan documents -- every file must be linked from at least one GitHub issue.

### 3.4 Idempotency

- Re-running any pipeline skill MUST NOT create duplicate issues or documents.
- Duplicate detection uses normalized title matching against existing GitHub issues.
- If a duplicate is found, skip creation and log a note.

### 3.5 Error Handling

- If a validation gate fails, HALT immediately. Do not proceed to the next phase.
- Log the failure reason with the specific file/issue that caused it.
- Escalate to the human with a clear description of what failed and why.

---

## 4. Universal Quality Gates

### 4.1 Specification Validation Gates

- **Post-Worker A (Schema Extraction):** Every schema node maps to at least one Feature. Coverage = 100%.
- **Post-Worker B (User Stories):** Every User Story links to at least one Feature via the Required Features Matrix.
- **Post-Worker C (Use Cases):** Every Use Case links to at least one User Story and one Feature via the Realization Matrix.
- **Post-Worker D (Reconciliation):** All local markdown checklist states match GitHub issue states. All completed items are closed.

### 4.2 Model Coverage Verification

- `verify_model_coverage.py` MUST pass with exit code 0 before declaring specification complete.
- Coverage is binary: 100% or fail. There is no acceptable partial coverage.

### 4.3 Cross-Reference Integrity

- No broken issue links (all `#N` references must resolve to existing GitHub issues).
- No orphan Features (every Feature belongs to exactly one Epic).
- No orphan User Stories (every Story links to at least one Feature).

### 4.4 Human Approval (The Grill)

- Required before implementation begins (Step 2 of feature-driven-implementation).
- NOT required for specification generation -- spec workers operate autonomously within these constitutional bounds.
- If a spec worker encounters ambiguity in the normative text, it MUST flag it in the Feature description rather than guessing.

---

## 5. Forbidden Practices

- Do NOT read, write, or execute terminal commands targeting directories outside the active repository workspace.
- Do NOT invent requirements not present in the specification or schema.
- Do NOT add platform-specific language to Epics, Features, User Stories, or Use Cases.
- Do NOT skip negative/error scenarios -- every constraint implies at least one failure mode.
- Do NOT create Features larger than 10 acceptance criteria without splitting.
- Do NOT hardcode GitHub issue numbers in cross-references -- always query live state via `gh` CLI.
- Do NOT silently drop schema nodes that are difficult to categorize -- flag them and escalate.

---

## 6. Evolution

This constitution is a living document. To update:

1. The human proposes a change.
2. The agent reads the current constitution.
3. The agent proposes an amendment (showing before/after).
4. The human approves or rejects.
5. The agent writes the update, increments `last_updated`, and commits.

Changes to this constitution affect ALL subsequent pipeline executions. Treat amendments with the same care as code changes.
