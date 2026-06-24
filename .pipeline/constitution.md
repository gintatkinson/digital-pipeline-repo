<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

---
title: "Project Constitution -- Functional Layer (Default)"
project: "Digital Systems Engineering Pipeline"
tier: functional
version: "1.1.0"
created: "2025-06-13"
created_time: "2025-06-13T00:00:00+00:00"
last_updated: "2026-06-24"
last_updated_time: "2026-06-24T14:42:23+08:00"
---

# Project Constitution: Digital Systems Engineering Pipeline

> This document governs specification generation and is platform-independent.
> All agents MUST read this file before beginning any pipeline execution.
> For platform-specific rules, see `.pipeline/profiles/<platform>.md`.

---

## 1. Domain Rules

### 1.1 Specification Sources

- Primary sources are normative technical specifications and standards documents.
- Structural schemas and interface definitions are the authoritative machine-readable models.
- When the normative text and the schema conflict, the schema is authoritative for structural completeness; the normative text is authoritative for behavioral semantics.

### 1.2 Schema Compliance

- Every data model constraint in the schema MUST be captured in at least one Feature's acceptance criteria. Zero loss tolerance.
- Constraints include: data type, validation ranges, regex patterns, default values, mandatory fields, conditional expressions, minimum/maximum elements, and structural relationship references.
- If a schema node has no explicit constraint, document its type and note "no additional constraints specified in schema."

### 1.3 Data Model Integrity

- Every schema definition, model node, data object, property, variant, custom type, and extension defined in the input schemas MUST map to at least one Feature.
- Cross-module or external schema references must be explicitly documented with source and target module names.
- Circular dependencies must be flagged and escalated -- do not silently drop them.

### 1.4 UML Metamodel & Profile Mapping Standard

To maintain rigorous, machine-readable representations, all incoming authoritative schemas (regardless of format) MUST map strictly to UML elements according to the following universal profile rules:

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
   - Constraints: Must be platform-independent and standard-agnostic. Absolutely no framework keywords (e.g., React, Flutter, BLoC, Context), specific standards designations (e.g., legacy network standards, telecom specifications), or hardcoded visual values (e.g., hex colors, fonts, pixel dimensions) are allowed. Refer to these variables abstractly (e.g., "the active alarm severity state" or "the configured color token").
   
2. **Tier 2: Runtime Configuration Parameters (Dynamic Context)**:
   - Includes: `design-tokens.json`, dynamic mapping configurations, translation files.
   - Constraints: This layer is the single source of truth for standard-specific definitions and visual attributes. Standard states and their physical mappings are declared here, to be read dynamically by implementation layers.
   
3. **Tier 3: Platform Implementation Profiles (Technical Execution)**:
   - Includes: `.pipeline/profiles/<platform>.md` and codebase implementations.
   - Constraints: Must govern build mechanics, performance patterns (e.g., Web Workers, Dart Isolates), and dependencies. Profiles and implementation source code MUST NOT hardcode standard-specific attributes or colors. They must define the mechanism to dynamically resolve Tier 2 assets (e.g., binding to CSS variables or deserializing runtime JSON).

### 1.8 Unique Backlog Identifiers

To prevent backlog reconciliation matching failures due to title drift, all local specification files MUST include a permanent unique identifier (`issue_id: <int>`) in their YAML frontmatter, mapped directly to their remote issue number. Matching by title normalization is prohibited as a primary selector.

### 1.9 Zero-Mocking Live Persistence Mandate
- All client-side application targets (e.g., React, Flutter) MUST connect to a live, persistent database, emulator, or local register map at runtime.
- The use of in-memory UI mocks, stubs, or hardcoded local variables in place of a live database/transport layer is strictly prohibited in active application builds.
- The presentation layer must depend strictly on abstract repository interfaces resolved dynamically at application bootstrap, keeping UI components completely decoupled from specific database/API SDK dependencies (such as Firestore or RPC wrappers).
- Transport concrete adapters must serialize/deserialize network payloads and translate them to and from platform-internal clean domain models, shielding presentation logic from external format changes.
- All integration and end-to-end (E2E) testing suites must compile and execute against a live database instance or emulator (in-memory stubs are prohibited for these tiers).

### 1.10 Logical UI Layout Engine Compliance & High-Density Console Standards
- Client-side platforms MUST implement a layout engine that dynamically parses and renders the component workspace hierarchy declared in `logical-layout.json` (such as resizable split workspaces, bottom-docked tabbed panels, and multidimensional viewports).
- Resizable splitters must preserve sub-component states (focus, playback, frame context) during layout orientation changes (e.g., swapping axes) by utilizing persistent virtual DOM structures and CSS Flexbox/Grid variables rather than conditional JSX/widget unmounting.
- Split workspace containers must isolate layout reflows using CSS Container Queries (`@container`) and CSS layout/paint containment to optimize rendering performance during active user resizing.
- To ensure professional high-density console aesthetics, layouts must align to an 8px grid system and enforce:
  - Roboto/Inter base typography scale (12px–13px text).
  - Outlined-only SVG vector graphic viewports (16px limit) with thin stroke weights (1.0px–1.2px) and maximum 2px bounding padding.
  - Reactive-compliant table row sizing utilizing a minimum constraint (`min-height: 32px`) and compact vertical cell padding (4px top/bottom) rather than hardcoded heights, allowing scaling during zoom or text-wrapping.

---

## 2. Specification Standards

### 2.1 Epic Granularity

- One Epic per major functional domain or protocol module.
- An Epic should contain 3-15 Features. Fewer than 3 means the Epic is too narrow; more than 15 means it should be split.
- Epic titles use the format: `[Module/Domain]: [Functional Area]` (e.g., "Network Topology: Node Management").

### 2.2 Feature Granularity

- A Feature represents a single, independently testable functional capability.
- A Feature should have 3-10 acceptance criteria. Fewer means it lacks specificity; more than 10 means it should be split.
- Features MUST be platform-independent and standard-agnostic. No framework names, UI component names, specific standard designations (e.g., legacy standards), or hardcoded standard parameters may appear in Epics, Features, User Stories, or acceptance criteria.
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

- Exactly four label types: `epic`, `feature`, `user-story`, `use-case`, or as defined by the issue tracker configuration.
- Labels are bootstrapped via the configured label bootstrap command (e.g., using the tracker CLI interface) to ensure idempotency.
- Each tracker issue carries exactly one of these labels.

---

## 3. Agent Behavior Rules

### 3.1 Commit Format

Commit formats are configured via workflow parameters. By default:
- Specification commits: `docs: [action] [artifact type] -- [brief description]`
  - Example: `docs: create feature -- display node attributes with validation`
  - Example: `docs: update epic -- add domain-registration features`
- Implementation commits: `feat:`, `fix:`, `test:`, `refactor:`, `chore:` per Conventional Commits, or as overridden by project repository settings.

### 3.2 Branch Strategy

Branching strategies are configured via workflow parameters. By default:
- Specification work: directly on the default branch (e.g. `main`/`master`) or a single `spec/<module>` branch if the change is large.
- Implementation work: `feat/<issue-number>-<short-description>` branches, or as configured by the workflow configuration.

### 3.3 Documentation Standards

- All generated markdown files include YAML frontmatter.
- All generated markdown files include a "Source References" section at the bottom.
- No orphan documents -- every file must be linked from at least one tracker issue.

### 3.4 Idempotency

- Re-running any pipeline skill MUST NOT create duplicate issues or documents.
- Duplicate detection uses normalized title matching against existing tracker issues.
- If a duplicate is found, skip creation and log a note.

### 3.5 Error Handling

- If a validation gate fails, HALT immediately. Do not proceed to the next phase.
- Log the failure reason with the specific file/issue that caused it.
- If you suspect the failure is due to a pipeline tooling bug or schema limitation, report it as an issue to the upstream repository.
- Escalate with a clear description of what failed and why.

### 3.6 Traceability and Verification Compliance

- All modifications and executions must strictly align with the approved backlog and verification plans.
- Ensure that every change is verifiable and matches the target specification.

### 3.7 Strict Planning Mode Gate (Insurmountable Approval Gate)

> [!CAUTION]
> **INSURMOUNTABLE CODE MODIFICATION BLOCK**
> * Under NO circumstances may the agent invoke any file-writing, file-modifying, or command-running tools that alter the codebase/repository files unless the user has explicitly typed "Proceed", "Approved", or "Approve plan" in the conversation history of the current turn sequence.
> * If a plan (`implementation_plan.md`) is written, the agent MUST immediately terminate its turn and stop calling tools to wait for approval. Bypassing this gate, making silent assumptions, or executing modifications prior to user confirmation is a direct violation of the constitution.
> * This rule is absolute, overrides all other instructions, and has zero exceptions.

---

## 4. Universal Quality Gates

### 4.1 Specification Validation Gates

- **Post-Worker A (Schema Extraction):** Every schema node maps to at least one Feature. Coverage = 100%.
- **Post-Worker B (User Stories):** Every User Story links to at least one Feature via the Required Features Matrix.
- **Post-Worker C (Use Cases):** Every Use Case links to at least one User Story and one Feature via the Realization Matrix.
- **Post-Worker D (Reconciliation):** All local markdown checklist states match tracker issue states. All completed items are closed.

### 4.2 Model Coverage Verification

- `verify_model_coverage.py` MUST pass with exit code 0 before declaring specification complete.
- Coverage is binary: 100% or fail. There is no acceptable partial coverage.

### 4.3 Cross-Reference Integrity

- No broken issue links (all `#N` references must resolve to existing tracker issues).
- No orphan Features (every Feature belongs to exactly one Epic).
- No orphan User Stories (every Story links to at least one Feature).

### 4.4 Human Approval (The Grill)

- Required before implementation begins (Step 2 of feature-driven-implementation).
- NOT required for specification generation -- spec workers operate autonomously within these constitutional bounds.
- If a spec worker encounters ambiguity in the normative text, it MUST flag it in the Feature description rather than guessing.

### 4.5 Downstream Conformance Gates

- Prior to integrating any downstream application implementation, the project MUST be bootstrapped and verified.
- The downstream project must be initialized using the `bootstrap_downstream.py` script.
- The baseline conformance must be verified using the `verify_downstream_baseline.py` script, which asserts that all baseline files are present, validates type compatibility with the mandated domain classes, and compiles/tests the project with a clean exit code.

---

## 5. Forbidden Practices

- Do NOT read, write, or execute terminal commands targeting directories outside the active repository workspace.
- Do NOT invent requirements not present in the specification or schema.
- Do NOT add platform-specific language to Epics, Features, User Stories, or Use Cases.
- Do NOT skip negative/error scenarios -- every constraint implies at least one failure mode.
- Do NOT create Features larger than 10 acceptance criteria without splitting.
- Do NOT hardcode issue numbers in cross-references -- always query live state via the tracking system.
- Do NOT silently drop schema nodes that are difficult to categorize -- flag them and escalate.
- Do NOT edit or patch pipeline tooling scripts (such as linter, reconciler, or verify scripts) inside downstream target repositories. Any tooling bugs or feature requests must be escalated and fixed upstream.
- Do NOT hardcode standard-specific properties, names, or visual style attributes (e.g., hex colors like `#d50000`) inside platform implementation profiles or functional specifications.
- Do NOT mix platform-specific implementation mechanisms (such as React Context or Flutter Keys) inside logical UI component specifications.
- Do NOT bypass dynamic design token resolution; all colors, typography, and spacing must map back to variables loaded dynamically from Tier 2 configuration files.
- Do NOT allow documentation drift. All interdependent documents (including README.md, platform profiles, and metadata rules) must be updated in sync with any configuration or rule changes.
- Do NOT delete, disable, or modify baseline files, layout splitters, playback timelines, or focus-loss validation forms in downstream projects, as they form the core compliance and verification framework.

---

## 6. Evolution

This constitution is a living document. To update:

1. The human proposes a change.
2. The agent reads the current constitution.
3. The agent proposes an amendment (showing before/after).
4. The human approves or rejects.
5. The agent writes the update, increments `last_updated`, and commits.

Changes to this constitution affect ALL subsequent pipeline executions. Treat amendments with the same care as code changes.
