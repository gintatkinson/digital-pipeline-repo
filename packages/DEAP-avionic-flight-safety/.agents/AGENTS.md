# Project-Scoped Subagent Rules: DEAP Civil Avionic Flight Safety Platform

> **Scope:** `packages/DEAP-avionic-flight-safety`  
> **Target Engineering Domain:** `Civil Avionic Flight Safety Systems (DO-178C, DO-254, ARP4754A, ARP4761, SPARK Ada, MISRA-C)`

---

## 1. Karpathy Engineering Framework

1. **No Silent Assumptions:** Verify all civil aviation regulatory mandates (RTCA DO-178C DAL A–E, RTCA DO-254, SAE ARP4754A, SAE ARP4761) and codebase constraints before implementing changes. Ask clarifying questions if requirements are underspecified.
2. **No Over-Engineering:** Implement minimal, deterministic, provably correct algorithms for flight software, safety filters, and state logic. Avoid speculative design patterns or unnecessary dynamic abstractions.
3. **Surgical Changes:** Make targeted edits only to files within `packages/DEAP-avionic-flight-safety/`. Do not modify unrelated workspace components or root files without authorization.
4. **Verifiable Success Criteria:** Define clean build, static analysis, formal proof (`gnatprove`), MISRA lint, unit test, and 100% MC/DC coverage verification steps for all code and spec edits.

---

## 2. Strict Plan Enforcement & Authorization Lock

1. **Approved Implementation Plan Required:** Subagents and coordinators must operate strictly under an approved implementation plan. No repository source or specification edits are permitted without prior plan authorization.
2. **Direct Writing Lock:** The coordinator is strictly forbidden from directly writing or modifying target functional specifications or codebase source files; all file writes must be delegated to context-isolated subagents.
3. **Subagent Context Isolation:** Each subagent must be launched with a fresh, clean context targeting at most one discrete micro-task or specification unit.

---

## 3. DO-178C / DO-254 Verification Gates & Safety Rules

1. **Bi-Directional Safety Traceability:** All SPARK Ada, Embedded C, VHDL/RTL source files, and test suites must maintain explicit `/// Safety-Realises:` tags linking code symbols to DO-178C SRD requirements, DO-254 hardware specs, or ARP4761 hazard mitigations.
2. **Zero Dynamic Memory Allocation Gate:** Subagents modifying flight software or real-time callbacks must ensure code strictly uses static stack/global pre-allocations and passes static AST analysis asserting zero `malloc`/`free`/`new`/`delete` calls.
3. **100% MC/DC Coverage Gate:** Any changes to DAL A software modules must be verified against 100% Modified Condition/Decision Coverage test suites before merging.
4. **Language Profile Compliance:** All SPARK Ada code must adhere to `.pipeline/profiles/spark_ada.md` (`pragma SPARK_Mode (On)`, formal contracts, `gnatprove` proof). All Embedded C code must adhere to `.pipeline/profiles/embedded_c.md` (MISRA-C:2012 compliance, C99/C11 strict mode, explicit `<stdint.h>` types).

---

## 4. Forbidden Practices & Workspace Isolation

1. **No Root Workspace Edits:** Subagents must only read and write within `packages/DEAP-avionic-flight-safety/`.
2. **No Outside Terminal Operations:** Terminal commands targeting locations outside the repository root are strictly forbidden.
3. **No Unsafe Fallbacks:** Swallowing safety exceptions, suppressing compiler warnings without formal justification, or bypassing static verification gates is strictly prohibited.
