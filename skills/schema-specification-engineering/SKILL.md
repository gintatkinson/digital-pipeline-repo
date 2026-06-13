---
name: schema-specification-engineering
title: "Schema Specification Engineering (Structural Extraction)"
description: Reverse-engineer structural schemas (e.g., YANG, OpenAPI, Protobuf) and their associated normative specification documents into deterministic, behavior-driven Agile feature specifications.
risk: medium
source: custom
version: "1.1"
---

# Schema Specification Engineering

Use this as the single canonical workflow for translating structural schemas and their normative specification documents into highly rigorous, implementation-ready Agile specifications for sub-agents. 

> [!TIP]
> This skill operates in the spirit of the `andrej-karpathy` methodology: focus deeply on the fundamentals, enforce exhaustive structural rigor, leave absolutely zero ambiguity in the acceptance criteria, and instrument the outputs flawlessly into project tracking systems.

> [!IMPORTANT]
> **EXHAUSTIVE SEMANTIC MODELING MANDATE**
> Do NOT blindly map every isolated leaf node (e.g., `x`, `y`, `z`) to a separate Feature. You MUST semantically model the schema by grouping cohesive properties into a single logical Feature (e.g., "Cartesian Coordinates"). However, "zero abstraction" still applies: within that grouped Feature, you MUST exhaustively document EVERY underlying leaf node, capturing its exact data type, mathematical constraints (fraction-digits, units), defaults, and verbatim RFC text. No constraint detail may be lost or summarized away.

## Step 1: Forensic Audit & Module Decomposition

1. **Parse the Schema:** Read the primary structural schema file (e.g., `*.yang`, `*.yaml`, `*.proto`) and its imports.
2. **Identify Top-Level Trees:** Decompose the high-level structural containers (e.g., `/globals`, `/tunnels`, `/lsps`, `/rpcs`) into discrete logical groupings.
3. **Establish Epics:** Map these high-level structures directly into Agile "Epics". Do not create the Epic GitHub issue yet. First, document it locally as a markdown file (e.g., `docs/epics/epic-01-name.md`).

## Step 2: Exhaustive Feature Extraction & Platform Scoping

1. **Semantic Feature Breakdown:** Analyze the child containers, choices, or elements. Identify cohesive functional groups (e.g., a "Velocity Vector" containing `v-north`, `v-east`, and `v-up`) and map them to a distinct "Feature".
2. **Platform Scoping:** Every Feature specification MUST target **exactly one implementation platform at a time** (either `react` or `flutter`). Do not create cross-platform features.
3. **Exhaustive Constraint Parsing:** For EVERY leaf node within the grouped feature, analyze and record all structural constraints:
   - `when` and `must` clauses
   - `type` definitions (fraction-digits, string patterns, identityrefs)
   - `units` and `default` values
   - `config false` (operational vs configuration state)
4. **Client Integration & UI Rendering Design:** Every feature spec MUST explicitly include a `## Client Integration and UI Rendering` section detailing:
   - The target unified database and test data records that must contain sample records.
   - The state loaders or parsing functions that must run the validation code.
   - The detailed UI view component, list, table, or card where the data must be visually presented to the user.
5. **Acceptance Criteria Translation:** Transform these programmatic constraints and UI rendering designs into exhaustive Given-When-Then Logical Acceptance Criteria. Always include an E2E visual criterion (e.g., "Given the unified database contains location records... When the user inspects the node... Then the UI must render the physical address").
6. **Draft the Feature Specs:** Write each Feature as a local markdown file (e.g., `docs/features/feat-01-name.md`).

## Step 3: Specification Context Injection (Verbatim)

1. **Locate Normative Text:** Find the canonical normative text document (e.g., IETF RFC, 3GPP TS) associated with the schema.
2. **Extract Line-by-Line Context:** Identify the exact paragraphs and sections that explain the behavioral logic of the specific structural container.
3. **Embed Context:** Inject this verbatim text directly into the feature specification under a `## Specification Context (Verbatim)` section. This guarantees that implementing sub-agents have ground-truth knowledge and are not hallucinating implementation details.

## Step 4: Output Formatting & Strict GitHub Instrumentation

> [!WARNING]
> You must strictly follow the operational sequencing below to ensure the `#IssueID` linkages are perfectly resolved.

1. **YAML Frontmatter:** Prepend strict YAML metadata to every `.md` file, including the target implementation platform:
   ```yaml
   ---
   title: "[Title]"
   epic: "[Parent Epic]"
   type: "feature"
   platform: "react"  # or "flutter"
   labels: ["feature", "<protocol-name>"]
   ---
   ```

2. **Source References Block (CRITICAL):**
   - At the bottom of every feature markdown file, you MUST append a `## 4. Source References` section formatted exactly like this:
   ```markdown
   ## 4. Source References
   YANG Schema: [ietf-geo-location@2022-02-11.yang](https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang)
   Normative Specification: [RFC 9179 Geographic Location](https://datatracker.ietf.org/doc/rfc9179/)
   ```
   - Inject the exact absolute URLs pointing to the authoritative structural schema and normative text document provided by the user. Do not omit this.

2. **GitHub Label Bootstrapping:** Run `gh label create "epic" --force` and `gh label create "feature" --force`.

3. **Feature Generation FIRST:**
   - Execute `gh issue create` for EVERY Feature markdown file first.
   - Example: `gh issue create --title "Feature Title" --body-file docs/features/feat-01.md --label "feature"`
   - **CRITICAL:** Capture the returned GitHub Issue URL/ID from standard output.

4. **Epic Markdown Assembly:**
   - Now that you possess the actual live Issue IDs for all extracted features, inject them into the Epic's Markdown file.
   - Ensure the body of the Epic explicitly lists its child features as a Markdown tasklist referencing the GitHub Issue ID and the absolute GitHub URL of the feature document (relative links like `../features/...` resolve incorrectly on GitHub issues and cause 404 errors). You MUST dynamically determine the remote repository URL by running `git remote get-url origin` and construct the absolute link pointing to the file on the current branch (e.g., `https://github.com/owner/repo/blob/branch_name/docs/features/feat-01.md`):
     `- [ ] #[IssueID] - [Feature Title](https://github.com/owner/repo/blob/branch_name/docs/features/feat-01.md)`

5. **Epic Generation LAST:**
   - Finally, execute `gh issue create` for the Epic markdown file containing the fully resolved tasklist.
