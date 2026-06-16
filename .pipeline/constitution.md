<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

---
title: "Project Constitution -- Functional Layer (Default)"
project: "Digital Systems Engineering Pipeline"
tier: functional
version: "1.0.0"
created: "2025-06-13"
created_time: "2025-06-13T00:00:00+00:00"
last_updated: "2026-06-17"
last_updated_time: "2026-06-17T01:00:02+08:00"
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
- Cross-module or external schema references (e.g., leafref/augment/uses in YANG, $ref in OpenAPI, imports in Protobuf/ASN.1) must be explicitly documented with source and target module names.
- Circular dependencies must be flagged and escalated -- do not silently drop them.

### 1.4 UML Metamodel & Profile Mapping Standard

To maintain rigorous, machine-readable representations, all incoming authoritative schemas (regardless of format: e.g., YANG, OpenAPI, Protobuf, ASN.1, XML Schema, ROS messages, or SysMLv2) MUST map strictly to UML elements according to the following universal profile rules:

- **Namespace & Boundary Constructs**: Top-level schema modules, packages, namespaces, or tag groups map to a **UML Component** or **UML Package**.
- **Structural Entity & Type Definitions**: Message schemas, container types, lists, structural groupings, and objects map to a **UML Class**.
- **Data Properties & Leaf Nodes**: Individual fields, properties, elements, attributes, or variables map to a **UML Property** (or owned attribute of a class) with appropriate visibility, type, and multiplicity (e.g. `[0..1]`, `[1..1]`, or `[0..*]`).
- **Interfaces & Operations**: Services, RPC methods, actions, or operational paths map to a **UML Operation** defined on the target classifier.
- **Rules & Validation Logic**: Any syntax constraints, range checks, pattern validations, conditional dependencies, or length constraints map to a **UML Constraint** (specified in OCL or formal structured text).

### 1.5 Universal Model Consistency Rules

To prevent semantic divergence between structural design and dynamic behavior:
- **Dynamic-to-Static Alignment**: No class, component, interface, attribute, operation, signal, or message may be used in dynamic behavior diagrams (such as UML Sequence Diagrams or State Machine Diagrams) unless it is explicitly defined in the structural UML Class Diagrams or Component Diagrams.
- **Sequence Diagram Lifelines**: Every lifeline in a sequence diagram MUST represent an instance of a defined UML Class or Component.
- **Message and Call Consistency**: Every message (synchronous, asynchronous, or return) in a sequence diagram must map to an active UML Operation or Signal defined on the target classifier's interface/class definition. Note that return/reply messages (represented by dashed lines) are excluded from this operation mapping requirement, as they represent the return of control and output values from an already active operation.
- **State Transition Events**: Every trigger, event, or action on a UML State Machine transition must be defined as a UML Operation or Signal in the class metamodel. Note that transition effects represent UML Behaviors (such as OpaqueBehavior or Activity) which can invoke operations or send signals, but the effects themselves are not directly defined as operations in the class definition.
- **Auto-verification Failure**: Any diagram or spec that references undefined operations, classes, or signals will violate the quality gates and halt the pipeline.

### 1.6 Traceability

- Every Epic MUST reference the specification section(s) it covers.
- Every Feature MUST include a "Source References" section with verbatim specification clause numbers and schema paths.
- Every User Story MUST link to the Features it validates.
- Every Use Case MUST link to the User Stories and Features it realizes.

### 1.7 Standard & Platform Parameter Isolation

To ensure that specifications remain reusable and the codebase stays modular, a strict 3-tier boundary architecture MUST be maintained:

1. **Tier 1: Functional Layer (Abstract Specification)**:
   - Includes: Epics, Features, User Stories, Use Cases, and Logical UI specifications.
   - Constraints: Must be platform-independent and standard-agnostic. Absolutely no framework keywords (e.g., React, Flutter, BLoC, Context), specific standards designations (e.g., ITU-T X.733, 3GPP TS), or hardcoded visual values (e.g., hex colors, fonts, pixel dimensions) are allowed. Refer to these variables abstractly (e.g., "the active alarm severity state" or "the configured color token").
   
2. **Tier 2: Runtime Configuration Parameters (Dynamic Context)**:
   - Includes: `design-tokens.json`, dynamic mapping configurations, translation files.
   - Constraints: This layer is the single source of truth for standard-specific definitions and visual attributes. Standard states and their physical mappings are declared here, to be read dynamically by implementation layers.
   
3. **Tier 3: Platform Implementation Profiles (Technical Execution)**:
   - Includes: `.pipeline/profiles/<platform>.md` and codebase implementations.
   - Constraints: Must govern build mechanics, performance patterns (e.g., Web Workers, Dart Isolates), and dependencies. Profiles and implementation source code MUST NOT hardcode standard-specific attributes or colors. They must define the mechanism to dynamically resolve Tier 2 assets (e.g., binding to CSS variables or deserializing runtime JSON).

### 1.8 Unique Backlog Identifiers

To prevent backlog reconciliation matching failures due to title drift, all local specification files MUST include a permanent unique identifier (`issue_id: <int>`) in their YAML frontmatter, mapped directly to their remote issue number. Matching by title normalization is prohibited as a primary selector.


---

## 2. Specification Standards

### 2.1 Epic Granularity

- One Epic per major functional domain or protocol module.
- An Epic should contain 3-15 Features. Fewer than 3 means the Epic is too narrow; more than 15 means it should be split.
- Epic titles use the format: `[Module/Domain]: [Functional Area]` (e.g., "Network Topology: Node Management").

### 2.2 Feature Granularity

- A Feature represents a single, independently testable functional capability.
- A Feature should have 3-10 acceptance criteria. Fewer means it lacks specificity; more than 10 means it should be split.
- Features MUST be platform-independent and standard-agnostic. No framework names, UI component names, specific standard designations (e.g., "ITU-T X.733"), or hardcoded standard parameters may appear in Epics, Features, User Stories, or acceptance criteria.
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
  - Example: `docs: update epic -- add domain-registration features`
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
- If you suspect the failure is due to a pipeline tooling bug or schema limitation, automatically submit a GitHub issue to the upstream repository:
  ```bash
  gh issue create --repo gintatkinson/digital-pipeline-repo --title "Tooling Bug: [Brief description]" --body "Context: [Error details, stack traces, and schema file references]"
  ```
- Escalate to the human with a clear description of what failed and why.

### 3.6 User Authorization Lock & Compliance Check

- **Authorization Lock**: The agent is strictly forbidden from invoking any file-writing tools (`write_to_file`, `replace_file_content`, `multi_replace_file_content`) or terminal execution tools (`run_command`) in interactive developer sessions unless the user's latest message contains the word `PROCEED` (case-insensitive). This lock is bypassed during automated, non-interactive evaluation runner scenarios to allow validation suites to execute.
- **Mandatory Compliance Check**: Every agent thought block must begin with the 3-point Karpathy Compliance Check:
  * Is the user's message a question/inquiry or a direct command?
  * Has the user explicitly approved a file-write/command execution for this turn? (Yes/No)
  * Am I making any silent assumptions about the user's intent?

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
- Do NOT edit or patch pipeline tooling scripts (such as linter, reconciler, or verify scripts) inside downstream target repositories. Any tooling bugs or feature requests must be escalated and fixed upstream in the pipeline repository.
- Do NOT hardcode standard-specific properties, names, or visual style attributes (e.g., hex colors like `#d50000`) inside platform implementation profiles or functional specifications.
- Do NOT mix platform-specific implementation mechanisms (such as React Context or Flutter Keys) inside logical UI component specifications.
- Do NOT bypass dynamic design token resolution; all colors, typography, and spacing must map back to variables loaded dynamically from Tier 2 configuration files.

---

## 6. Evolution

This constitution is a living document. To update:

1. The human proposes a change.
2. The agent reads the current constitution.
3. The agent proposes an amendment (showing before/after).
4. The human approves or rejects.
5. The agent writes the update, increments `last_updated`, and commits.

Changes to this constitution affect ALL subsequent pipeline executions. Treat amendments with the same care as code changes.
