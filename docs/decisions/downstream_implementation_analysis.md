# Technical Analysis Paper: Downstream Agent Feature Implementation Deficits

This paper documents the root cause analysis, symptoms, and structural loopholes causing downstream implementation agents to build no feature support for specifications in the `digital-pipeline-repo` workspace.

---

## 1. Problem Statement & Context
Downstream implementation agents are issue-driven, TDD-disciplined workers. When triggered to implement a functional specification, they are expected to build the corresponding domain models, validators, and user interface elements in the target platform folder (e.g., [`/Users/perkunas/jail/digital-pipeline-repo/app_flutter/`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/) or [`/Users/perkunas/jail/digital-pipeline-repo/web_react/`](file:///Users/perkunas/jail/digital-pipeline-repo/web_react/)).

However, during execution, downstream agents terminate successfully while leaving the codebase devoid of the actual functional classes defined in the specifications (such as `RateOfChange` or `TemporalContext`).

---

## 2. Detailed Symptoms

### Symptom A: Type Validation is Silently Skipped
When the conformance gate runs during validation, it executes:
`python3 scripts/verify_downstream_baseline.py`

Instead of checking that the classes defined in the UML diagrams of the specifications exist, the script outputs the following log:
```
No mandated classes configured — skipping type validation.
```
Consequently, it reports a successful verification status (`Success: Build and test suite execution passed. Conformance gate verified.`), even when the codebase contains no feature logic.

### Symptom B: Empty Fallback in Verification Tooling
In [`/Users/perkunas/jail/digital-pipeline-repo/scripts/verify_downstream_baseline.py`](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/verify_downstream_baseline.py#L77):
```python
MANDATED_CLASSES = []
```
The script loads the classes dynamically by searching for the key `mandated_classes` inside [`/Users/perkunas/jail/digital-pipeline-repo/.pipeline/logical-ui/codebase_rules.json`](file:///Users/perkunas/jail/digital-pipeline-repo/.pipeline/logical-ui/codebase_rules.json). However, no such key is defined in the configuration, forcing the script to fall back to the empty list `[]`.

---

## 3. Root Cause Analysis

### Root Cause 1: Lack of Specification-to-Code Mapping in the Linter
The linter checks specifications for mathematical coverage (verifying that all schema nodes are described in features) and structural correctness (verifying Mermaid blocks and Cockburn headings). It does **not** perform any verification connecting the specification's UML elements to the actual source code.

### Root Cause 2: Decoupled Conformance Gate Loophole
To prevent validation failures when domain code is removed during workspace decontamination, a previous refactor cleaned the fallback `MANDATED_CLASSES` list:
- Commit `2c78d94` / Decision: `feat-domain-decoupling-solution.md` cleared the hardcoded list of default classes.
- Without a corresponding mechanism to dynamically populate `mandated_classes` in `codebase_rules.json` from the active specifications at runtime, the verification gate became completely blind.

---

## 4. Proposed Remediation

To close this loophole, we must enforce type validation by dynamically or statically defining the expected feature classes:

1.  **Static Configuration (Immediate Patch)**:
    Append the required specification classes (e.g., `RateOfChange`, `TemporalContext`) to the `validation_rules.mandated_classes` block inside [`/Users/perkunas/jail/digital-pipeline-repo/.pipeline/logical-ui/codebase_rules.json`](file:///Users/perkunas/jail/digital-pipeline-repo/.pipeline/logical-ui/codebase_rules.json).

2.  **Dynamic Verification (Long-Term Fix)**:
    Update [`/Users/perkunas/jail/digital-pipeline-repo/scripts/verify_downstream_baseline.py`](file:///Users/perkunas/jail/digital-pipeline-repo/scripts/verify_downstream_baseline.py) to dynamically extract the classes defined in the UML class diagrams under [`/Users/perkunas/jail/digital-pipeline-repo/docs/features/`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/features/) at runtime, ensuring that any specification being implemented is automatically checked against the codebase.
