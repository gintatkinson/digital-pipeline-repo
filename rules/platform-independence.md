<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

# Rule: Platform Independence in Specifications

**ALWAYS enforce:** Epics, Features, User Stories, and Use Cases must be purely functional and platform-independent.

## Hard constraints

- Specification documents MUST describe *what* the system does, never *how* it is built.
- Feature specs MUST NOT contain framework-specific component names (e.g., no `<Drawer>`, no `showModalBottomSheet`).
- Feature specs MUST NOT contain a `platform` field in their YAML frontmatter.
- Acceptance criteria MUST be platform-independent (e.g., "the detail view displays the address" — not "the React Drawer component renders the address").
- The `Interface Requirements` section describes data, payloads, layout, or protocols logically, without referencing specific frameworks or transport libraries.
- Every Mermaid diagram or code block MUST be strictly and explicitly closed using matching closing fences (e.g. ```` ``` ```` on a new line) to prevent layout/parser leakage.
- **Mermaid Class Diagram Syntax Rules**: Colons are strictly prohibited inside Mermaid class member strings (e.g., do not use `+methodName() : ReturnType` or `+methodName(arg : Type)`), as secondary colons confuse the parser and break rendering. Use standard spacing instead (e.g., `+ReturnType methodName(Type arg)`).
- **Mermaid Class Naming Rules**: Double quotes MUST NOT be used in class names. Colons are explicitly forbidden in unbackticked class names; any class names containing colons must be enclosed in backticks (e.g., `` class `Nw:network` ``). Use backticks (e.g., `class `My Class` {`) or label brackets if names contain special characters or spaces.
- **Mermaid Note Rules**: Colons are strictly prohibited inside Mermaid class diagram note strings (e.g., do not use `note "Status: Active"` or `note for ClassA : "Status: Active"`), as colons in notes confuse the parser and break rendering.
- **Mermaid Relationship Rules**: Double angle brackets, stereotypes, or HTML entities representing stereotypes (e.g., `<<`, `>>`, `&lt;&lt;`, `&gt;&gt;`, `«`, `»`) are strictly prohibited on class diagram relationship lines. Relationship labels must be plain strings without stereotypes (e.g., use `-->` with a label like `references` instead of `<<references>>`).



## Where platform-specific details belong

- Implementation profiles: `.pipeline/profiles/<platform>.md`
- Implementation plans: `implementation_plan.md` created during The Grill (Step 2 of feature-driven-implementation)
- Solution walkthroughs: paths defined by design and implementation guidelines (e.g. `<walkthrough_dir>/feat-<N>-solution.md` or as configured)

## Why

A single set of functional specs can drive implementations on React, Flutter, .NET, or any other platform. Contaminating specs with platform details forces re-specification when targeting a new platform and violates the two-tier constitution architecture.
