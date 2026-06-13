---
name: project-constitution
title: "Project Constitution (Persistent Principles & Governance)"
description: "Establishes and maintains a project's governing principles, coding standards, testing mandates, and domain rules as persistent agent memory."
category: "governance"
risk: low
source: custom
version: "1.0"
---

# Project Constitution (Persistent Principles & Governance)

Use this skill to establish or update a project's foundational constitution — a persistent memory file that all other skills and agents reference when making decisions. The constitution captures what is non-negotiable for the project and survives across sessions, agents, and runtime environments.

> [!TIP]
> Inspired by Spec Kit's `/speckit.constitution` concept. This skill provides the same persistent principles memory but integrated natively into the Digital Pipeline without external dependencies.

## When to Invoke

- **New project setup:** Before running any other pipeline skill, establish the constitution first.
- **Major architectural changes:** When the team adopts new standards, frameworks, or constraints.
- **Agent onboarding:** When a new agent session begins and needs to understand project rules.

## Core Mandates

1. **Single Source of Truth:** Every project MUST have exactly one constitution file. It lives at `.pipeline/constitution.md` in the project repository root (or `docs/constitution.md` if `.pipeline/` is not used).
2. **Cumulative, Never Destructive:** When updating the constitution, read the existing file first. Append or refine — never delete established principles without explicit human approval.
3. **Human Authored, Agent Enforced:** The constitution is written by the human (with agent assistance for structure). Agents MUST NOT modify it autonomously. They read it, follow it, and reference it in decisions.
4. **Universal Reference:** Every other skill in this pipeline (`spec-orchestrator`, `schema-specification-engineering`, `feature-driven-implementation`, etc.) MUST read the constitution before beginning execution and adhere to its mandates.

---

## Step-by-Step Workflow

### Step 1: Initialize Constitution

If no constitution file exists, create one from the template below:

```bash
mkdir -p .pipeline
touch .pipeline/constitution.md
```

### Step 2: Interactive Principles Gathering

Prompt the human with these categories (adapt to project domain):

1. **Platform & Stack Constraints**
   - Target platform(s): (e.g., React, Flutter, .NET)
   - Language version requirements
   - Forbidden dependencies or patterns

2. **Coding Standards**
   - Type strictness level (e.g., no `any` in TypeScript)
   - Naming conventions (domain-driven, kebab-case files, etc.)
   - Module/component architecture pattern

3. **Testing Mandates**
   - Required test types (unit, integration, E2E, property-based)
   - Coverage thresholds
   - TDD enforcement level (mandatory per micro-task, or per feature)
   - Test framework(s)

4. **Domain Rules**
   - Specification sources (e.g., IETF RFC, 3GPP TS)
   - Schema compliance requirements
   - Data model constraints

5. **Agent Behavior Rules**
   - Drill-down navigation mandate
   - UI verification method (manual vs Playwright)
   - Commit message format
   - Branch naming convention
   - Documentation standards

6. **Quality Gates**
   - Linting: must pass before commit? (yes/no)
   - Build: must pass before PR? (yes/no)
   - Review: required before merge? (yes/no)
   - Human approval gates (The Grill, acceptance testing)

7. **Operational Context**
   - Deployment environment
   - CI/CD pipeline requirements
   - Security constraints (API keys, auth, CORS)

### Step 3: Generate Constitution Document

Write the gathered principles into `.pipeline/constitution.md` using this format:

```markdown
---
title: "Project Constitution"
project: "[Project Name]"
created: "[ISO Date]"
last_updated: "[ISO Date]"
---

# Project Constitution: [Project Name]

## Platform & Stack
- [Captured constraints]

## Coding Standards
- [Captured standards]

## Testing Mandates
- [Captured mandates]

## Domain Rules
- [Captured rules]

## Agent Behavior
- [Captured rules]

## Quality Gates
- [Captured gates]

## Operational Context
- [Captured context]

---

> This file is the single source of truth for project governance.
> All agents MUST read this file before beginning any pipeline execution.
> Human approval is required to modify this document.
```

### Step 4: Commit & Reference

1. Commit the constitution:
   ```bash
   git add .pipeline/constitution.md
   git commit -m "docs: establish project constitution"
   ```

2. Ensure the project's `AGENTS.md` (or equivalent) references the constitution:
   ```markdown
   **CRITICAL: Read `.pipeline/constitution.md` before any task execution.**
   ```

### Step 5: Ongoing Governance

- **Before every feature:** The agent reads the constitution and confirms adherence.
- **On conflict:** If a proposed change conflicts with the constitution, the agent halts and escalates to the human.
- **On evolution:** The human requests a constitution update. The agent reads the existing file, proposes amendments, and waits for approval before writing.

---

## Integration with Other Skills

| Skill | How It Uses the Constitution |
|---|---|
| `spec-orchestrator` | Reads platform constraints before triggering Workers |
| `schema-specification-engineering` | Reads platform target to scope Features correctly |
| `feature-driven-implementation` | Reads testing mandates, coding standards, and quality gates to enforce during TDD |
| `spec-user-story-engineering` | Reads domain rules to model BDD scenarios accurately |
| `spec-usecase-engineering` | Reads operational context for Use Case preconditions |
