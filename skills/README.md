# Digital Systems Engineering Pipeline (Builders Project)

Welcome to the Digital Systems Engineering Pipeline. This repository contains a suite of autonomous AI Agent "Skills" designed to completely reverse-engineer protocol standards (IETF, 3GPP, CAMARA, IEEE) into deterministic, behavior-driven Agile tracking matrices in GitHub.

By feeding these agents a Structural Schema (e.g., YANG, OpenAPI, Protobuf) and its associated Normative Specification Document (e.g., an RFC or Technical Specification), the agents will automatically build your Epics, Features, User Stories, and UML Use Cases, ensuring a 100% mathematically bounded requirements pipeline mapped via UML OOA/OOD methodologies.

---

## 🏗️ The Agent Architecture

This toolchain operates on a **Master-Worker architecture** requiring five distinct components:

### 1. `spec-orchestrator` (The Master)
The overarching command-and-control skill. You assign this skill to your primary AI agent. It is responsible for triggering the worker skills in sequence and enforcing strict validation gates (verifying GitHub issues actually exist before proceeding).

### 2. `schema-specification-engineering` (Worker A: Structure)
This agent parses the raw schemas (e.g., `*.yang`, `*.yaml`). It breaks down the structural models into **Epics** and **Features**, extracts the programmatic constraints (e.g., ranges, enums, defaults), translates them into Given-When-Then criteria, and pushes them to GitHub.

### 3. `spec-user-story-engineering` (Worker B: Behavior)
This agent parses the operational/deployment chapters of the specification document. It extracts Behavior-Driven Development (BDD) **User Stories** modeled upon UML OOA/OOD principles. It then queries GitHub for the Features created by Worker A and builds a "Cross-Cutting Matrix" tasklist linking the scenarios to the technical requirements.

### 4. `spec-usecase-engineering` (Worker C: System Interaction)
This agent extracts formal **UML System Use Cases** (identifying Primary/Secondary Actors, Preconditions, Main Success Scenarios, Alternate Flows, and Postconditions) and explicitly maps them to the underlying User Stories (from Worker B) and Features (from Worker A) in a Realization Matrix.

### 5. `feature-driven-implementation` (Feature Delivery Workflow)
Enforces a strict serial, platform-specific implementation workflow. It guides feature delivery through a full vertical slice (Unified Database Test Data, Logic/Parser hooks, and UI view rendering) and mandates isolated, multi-agent validation to audit database record integrity and walkthrough links before closure.

### 6. Pipeline Utilities (Worker D & Coverage Check)
* **`reconcile_backlog.py` (Reconciliation & Audit)**: An automated Python utility executed by the Orchestrator to ensure zero-trust consistency of the Agile board. It queries GitHub, updates checkbox states inside local markdown specs when issue states change, syncs checklists back to GitHub, and closes completed issues.
* **`verify_model_coverage.py` (Model Coverage Check)**: An automated Python utility that parses YANG schemas and checks generated feature specifications to mathematically verify 100% model coverage.


---

## 🚀 How to Run the Pipeline

To execute this pipeline, you must be using an AI agent framework capable of reading standard `.md` skill files and executing CLI commands (e.g., `gh` CLI, `git`). 

1. Ensure your AI agent has access to this `/skills/` directory.
2. Provide your agent with the following prompt:

> **Execution Prompt Template:**
> 
> "Adopt the `spec-orchestrator` skill. I want to reverse-engineer [Protocol Standard, e.g., RFC 8345]. 
> 
> 1. The structural schemas are located at `[Path to file OR directory containing schemas]`.
> 2. The normative specification documents are located at `[Path to file OR directory containing specs]`.
> 
> Execute the full digital engineering pipeline."

---

## 🛠️ How to Implement a Feature

To implement a feature from the backlog, instruct your AI agent with the following prompt:

> **Feature Implementation Prompt Template:**
> 
> "Adopt the `feature-driven-implementation` skill. I want to implement Feature [Feature Number / Issue Number, e.g. Feature 12] targeting platform [react OR flutter]. 
> 
> Execute the feature delivery workflow:
> 1. Verify the target platform in the feature specification.
> 2. Draft an implementation plan covering the full vertical slice (Database Layer - Unified test data, Logic & Parser Layer, UI & Presentation Layer).
> 3. Implement the feature.
> 4. Provide step-by-step human manual testing instructions for the UI in the verification plan.
> 5. Deliver the solution walkthrough and close the issue upon human approval."

---

## 📊 Expected Outputs

If successful, the orchestrator will generate a perfectly synchronized taxonomy on your live GitHub board:

1. **Epics (`epic`)**: High-level structural containers.
2. **Features (`feature`)**: Granular technical building blocks with injected verbatim spec text and dependency links.
3. **User Stories (`user-story`)**: Object-oriented BDD scenarios mapped to required structural Features.
4. **Use Cases (`use-case`)**: High-level formal UML system interactions mapping the entire flow down to User Stories and Features.

*Note: The skills will automatically attempt to bootstrap the repository labels (`epic`, `feature`, `user-story`, `use-case`) if they do not already exist using the `gh label create` command.*
