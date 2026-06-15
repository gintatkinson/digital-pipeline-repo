<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

---
name: spec-user-story-engineering
description: "Extracts BDD User Stories from normative specification documents using OOA/OOD modeling. Use when you need to derive behavioral scenarios (Given-When-Then) from protocol specs and matrix them against existing GitHub Feature issues."
compatibility: "Requires gh CLI and git. Works with Claude Code, Gemini CLI, Cursor, Copilot, Cascade."
metadata:
  title: "Specification User Story Engineering (Behavioral Extraction)"
  category: architecture
  risk: low
  source: custom
  version: "2.0"
---

# Specification User Story Engineering (Behavioral Extraction)

This skill enables a sub-agent to autonomously read a normative specification document (e.g., IETF RFC, 3GPP TS, CAMARA API Doc) and extract its behavioral deployment scenarios into pure Behavior-Driven Development (BDD) User Stories modeled according to Object-Oriented Analysis and Design (OOA/OOD) principles, linking them dynamically to structural features already defined in the GitHub repository.

## Execution Trigger
You should invoke this skill ONLY after the structural Features have been extracted using the `schema-specification-engineering` skill.

### Algorithmic & Calculation Story Extraction Trigger
In addition to standard deployment scenarios, you MUST scan the specification and schema for any derived, computed, or calculated values (e.g. deriving speed or heading from a velocity vector, or performing unit conversions, coordinate transformations, validation ranges, or elapsed time checks). For every calculated or derived value identified, you MUST extract a dedicated User Story that details the calculations, formulas, or algorithmic transformations required, ensuring that these dynamic behaviors are fully captured.

## Step 1: Context Ingestion (Operational Text & Schemas)
1. Ingest the target normative specification document AND the target structural schemas (e.g., YANG, OpenAPI, Protobuf).
2. **Scan the structural schema definitions** (specifically node descriptions, comments, type restrictions, and validation constraints) to identify:
   - Any derived, calculated, or computed data fields (e.g., speed and heading derived from a velocity vector).
   - Any mathematical formulas, equations, unit conversions, or derivations.
   - Any temporal attributes or state lifecycles.
3. Target and analyze the following operational chapters of the normative specification:
   - **Introduction & Applicability**
   - **Deployment Scenarios**
   - **Operational Considerations**
   - **Security Considerations**
   - **Algorithmic, Calculation, or Derivation clauses**

## Step 2: Behavioral Modeling (OOA/OOD User Story Extraction)
For every distinct deployment scenario and behavioral trigger found, model it as a formal User Story integrated with OOA/OOD principles.

### Behavioral Extraction Triggers (Mandatory User Stories)
An agent MUST extract a separate, dedicated User Story if the normative text or structural schema meets any of the following triggers:
- **Algorithmic/Calculation Trigger**: If the specification or schema defines any mathematical formula, equation, conversion, or derivation, it MUST have a dedicated User Story mapping the calculation behavior.
  - BDD scenarios must cover edge cases, rounding, division by zero, and invalid inputs.
- **Temporal/State Lifecycle Trigger**: If the schema defines temporal attributes (`timestamp`, `valid-until`) or implies state-decay lifecycles, it MUST have a dedicated User Story detailing the transition to expired/stale state and postconditions for stale data access.

1. Identify the Actor/Role (the object or entity initiating the action).
2. Formulate the core scenario using strict BDD syntax mapped to object interactions:
   - `Given` (Precondition object state)
   - `When` (Triggering message or event)
   - `Then` (Postcondition object state)
   - Or standard format: `As a [Actor], I want to [Action/Message] so that [Outcome/State Change].`
3. Map the story to specific Domain Objects (the structural schema entities affected).
4. **UML Sequence Diagram:** Every User Story MUST include a **UML Sequence Diagram** (using Mermaid `sequenceDiagram`) illustrating the dynamic interaction between the Actor and specific Domain Objects (e.g., `[DomainRegistry]`, `[EntityValidator]`), showing method signatures with camelCase parameters (matching the structural schema leaves) and return types/statuses. Naming actor participants as `Actor` is prohibited; use descriptive names (e.g., `[ClientActor]`).
   - **Mandated Sequence Elements:** The diagram MUST model:
     - **Validation Loops/Conditional Blocks:** Use Mermaid `alt` or `loop` blocks to explicitly illustrate input validation loops (e.g., bounds checking on input fields or parameter limits).
     - **Typed Parameters & Return Values:** All method calls and returns MUST be fully typed (e.g., `operationName(attributeName: DataType): status_code`).
     - **Helper/Calculator Object Delegation:** Do not model the main container handling complex computations directly; instead, illustrate delegation to specialized helper or utility objects (e.g., delegating computations to a `[BusinessLogicService]` utility class).


## Step 3: The Cross-Cutting Matrix (Feature Linking)
A User Story requires technical building blocks (Domain Objects/Features) to function. You must find the blocks that have already been built.
1. Execute `gh issue list --label "feature" --state "all" --json number,title,body` to pull the existing structural inventory.
2. **Perform Semantic Analysis**: Inspect both titles and content bodies of features to perform mapping rather than simple title-only matching.
3. Determine exactly which of those `#IssueID`s are prerequisites for your extracted User Story.
4. Construct a `## Required Features` matrix in your document containing a markdown tasklist of these intersecting links referencing BOTH the Issue ID and the absolute GitHub URL of the feature document. You MUST dynamically determine the remote repository URL by running `git remote get-url origin` and construct the absolute link pointing to the file on the current branch (e.g., `- [ ] #41 - [Feature 01 Title](https://github.com/owner/repo/blob/branch_name/docs/features/feat-01.md)`). **Every checklist item in the matrix MUST include a concise parenthetical justification explaining the semantic linkage (e.g. `(provides coordinates schema)`).**

## Step 4: Markdown Generation
Create a new file in `docs/user-stories/us-[XX]-[name].md` (zero-padded, dash-separated, e.g., `us-01-register-entity.md`). Format strictly:

```markdown
---
title: "[User Story Title]"
type: "user-story"
spec_source: "[Spec Reference]"
---

# User Story: [Title]

## Domain Object Mapping
- **Primary Domain Objects:** [List affected structural schema entities]
- **Actor/Role:** [The object/entity initiating the action]

## BDD Scenario (OOA/OOD Realization)
**Given** [Initial system/object state]
**When** [Triggering action/event/message]
**Then** [Resulting system/object state]

*(Alternatively)*
**As a** [Actor]
**I want to** [Action]
**So that** [Outcome/State Change]

## UML Sequence Diagram
```mermaid
sequenceDiagram
    autonumber
    actor ClientActor
    participant DomainRegistry
    participant BusinessLogicService

    ClientActor->>DomainRegistry: operationName(attributeName: DataType)
    alt is valid payload
        DomainRegistry->>BusinessLogicService: validateBounds(attributeName: DataType)
        BusinessLogicService-->>DomainRegistry: validationResult(isValid: boolean)
        alt isValid == true
            Note over DomainRegistry: Store value
            DomainRegistry-->>ClientActor: status(status: SUCCESS)
        else isValid == false
            DomainRegistry-->>ClientActor: status(status: INVALID_DATA)
        end
    else missing mandatory fields
        DomainRegistry-->>ClientActor: status(status: MISSING_FIELDS)
    end
```

## Operational Context
[Verbatim operational constraints or deployment scenarios quoted from the specification]

## Required Features Matrix
- [ ] #[IssueID] - [Feature Title](https://github.com/owner/repo/blob/branch_name/docs/features/feat-XX-name.md) (semantic linkage justification)
- [ ] #[IssueID] - [Feature Title](https://github.com/owner/repo/blob/branch_name/docs/features/feat-XX-name.md) (semantic linkage justification)

## Source References
Structural Schema: [Target Schema File](link-to-schema)
Normative Specification: [Normative Specification](link-to-specification)
```

## Step 5: Zero-Fault GitHub Synchronization
1. Commit and push the Markdown files to the remote repository.
2. You MUST verify the `user-story` label exists in the repository. Run `gh label create "user-story" --force`. Do not bypass this.
3. **Duplicate Detection:** Before creating, run `gh issue list --label "user-story" --state "all" --json number,title` and check if an issue with an identical or semantically equivalent title already exists. If found, skip creation and reuse the existing Issue ID.
4. Create the issue natively in GitHub. You MUST explicitly bind the label:
   `gh issue create --title "[User Story Title]" --body-file [path/to/markdown.md] --label "user-story"`
5. Verify the creation and return the generated GitHub URLs to the Orchestrator or User.
