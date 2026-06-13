<!-- Copyright Gint Atkinson, gint.atkinson@gmail.com -->

# Task: Extract Features from a YANG Schema

You are given a YANG schema file and its associated RFC normative text.

Using the `schema-specification-engineering` skill, extract Epics and Features:

1. Parse the schema and decompose into Epics
2. Extract cohesive Features with exhaustive constraint parsing
3. Write Functional UI Requirements (platform-independent)
4. Write Given-When-Then acceptance criteria (platform-independent)
5. Create GitHub issues with correct labels

## Inputs

- YANG schema: `inputs/example-topology.yang`
- Normative text: `inputs/rfc8345-excerpt.txt`

## Expected Behaviors

- Feature markdown files contain NO platform-specific references (no React, Flutter, component names)
- Feature YAML frontmatter has NO `platform` field
- Acceptance criteria use functional language ("the detail view displays...") not framework language ("the React Drawer renders...")
- `Functional UI Requirements` section describes data and layout logically
- Source References section includes links to schema and RFC
