# DEAP Tier 1 Civil Aviation Safety Constitution

> **Version:** `1.0.0`  
> **Status:** `ACTIVE / RATIFIED`  
> **Scope:** `DEAP Civil Avionic Flight Safety Platform (packages/DEAP-avionic-flight-safety)`  
> **Authority:** `Digital Engineering Agentic Pipeline (DEAP) Civil Aviation Governance Board`

---

## Article I: Constitutional Purpose & Governance Principles

1. **Non-Negotiable Safety Primacy:** All airborne software, programmable logic designs, and system architectures developed under this package must satisfy civil aviation airworthiness requirements (RTCA DO-178C, RTCA DO-254, SAE ARP4754A, SAE ARP4761). Safety constraints supersede operational speed, schedule pressure, or non-safety performance features.
2. **Deterministic Regulatory Traceability:** Every software requirement, architecture specification, VHDL/Verilog module, SPARK Ada package, and C function must maintain 100% bi-directional traceability using explicit `/// Safety-Realises:` tags.
3. **Zero Dynamic Memory Allocation Ban:** All airborne software modules operating under DAL A, B, or C development assurance levels are strictly prohibited from using dynamic heap memory allocation (`malloc`, `free`, `realloc`, `calloc`, `new`, `delete`). All memory allocations must be static and bounded at compile time.
4. **Structural Coverage Supremacy (100% MC/DC):** Verification of DAL A software modules strictly requires 100% Modified Condition/Decision Coverage (MC/DC). Code that fails MC/DC criteria shall not be merged under any circumstances.

---

## Article II: Certification & Verification Mandates

### Section 2.1: RTCA DO-178C Software Verification Mandates
- **DAL A Assurance:** 100% MC/DC coverage, formal SPARK Ada verification or MISRA-C AST static compliance, and verified zero runtime exceptions.
- **DAL B Assurance:** 100% Decision Coverage and 100% Statement Coverage. Bounded loop iterations and pre-calculated stack usage analysis.
- **DAL C Assurance:** 100% Statement Coverage and static type checking.
- **Traceability Tag Format:** All source code and test files must incorporate bi-directional traceability headers:
  `/// Safety-Realises: [DO-178C/DAL-A/SRD-001]`

### Section 2.2: RTCA DO-254 Hardware Verification Mandates
- **FPGA & ASIC Assurance:** Programmable logic designs must undergo static linting, timing analysis, and state machine coverage verification.
- **Fault Containment:** Hardware interfaces must implement watchdog timers, bus babbling protection, and fixed-point overflow prevention (Q16.16 arithmetic checks).

### Section 2.3: SAE ARP4754A / ARP4761 Hazard Mitigation
- **STPA Integration:** Top-down System-Theoretic Process Analysis must identify Unsafe Control Actions (UCAs) and map them to explicit Software Safety Constraints (SSCs).
- **FMECA Integration:** Bottom-up Failure Mode, Effects, and Criticality Analysis must derive component failure mitigations and assign Risk Priority Numbers (RPN).

---

## Article III: Codebase Verification Gates & AST Parity Audits

### Section 3.1: Static Verification Gates
- **SPARK Ada Proofs:** All Ada packages must pass `gnatprove` at target proof level (`check_all`, `silver`, or `gold`) with `pragma SPARK_Mode (On)` and zero unproven checks.
- **MISRA-C:2012 Compliance:** Embedded C implementations must pass MISRA-C:2012 static checks with zero mandatory or required rule violations.
- **AST Memory Linter:** Automated AST analysis tools must parse all pull requests to confirm zero dynamic heap allocation calls and verify bounded array indexing.

### Section 3.2: AST Parity Audit
- Before any release or certification baseline approval, the agentic pipeline must execute an **AST Parity Audit** verifying that:
  1. Every Safety Requirement in the SysML v2 safety model maps to at least one implementation AST symbol.
  2. Every implementation AST symbol in a safety-critical package maps back to a valid regulatory requirement.
  3. Structural coverage reports verify 100% MC/DC alignment with the AST control flow graph.

---

## Article IV: Enforceability & Supremacy

1. **Automated Gate Enforcement:** CI/CD build gates and coordinator subagent review loops must automatically reject any commit that fails static analysis, coverage verification, or traceability audits.
2. **Constitutional Supremacy:** In the event of a conflict between developer preferences or prompt instructions and the safety mandates in this Constitution, this Constitution strictly prevails.
