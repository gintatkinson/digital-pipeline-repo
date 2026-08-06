# Project-Scoped Subagent Rules: DEAP Low-Altitude UAS & Infrastructure Safety Platform

> **Scope:** `packages/DEAP-uas-infrastructure-safety`  
> **Target Engineering Domain:** `Low-Altitude UAS Infrastructure Inspection (SORA v2.5, ASTM, RTCA, ROS2, PX4)`

---

## 1. Karpathy Engineering Principles

1. **No Silent Assumptions:** Verify all regulatory standards (SORA v2.5 SAIL I-VI, ASTM F3269-17 RTA, ASTM F3411-22a Remote ID, RTCA DO-365B DAA) and codebase constraints before implementing changes. Ask clarifying questions if requirements are underspecified.
2. **No Over-Engineering:** Implement simple, robust, deterministic algorithms for geofence checking, uORB publishing, and ROS2 QoS setup. Avoid speculative abstractions.
3. **Surgical Changes:** Make targeted edits only to files within `packages/DEAP-uas-infrastructure-safety/`. Do not modify unrelated workspace components.
4. **Verifiable Success Criteria:** Define clean build, lint, unit test, and SITL simulation verification steps for all code and spec edits.

---

## 2. Strict Plan Enforcement & Authorization Lock

1. **Approved Implementation Plan Required:** Subagents and coordinators must operate strictly under an approved implementation plan. No repository source or specification edits are permitted without prior plan authorization.
2. **Direct Writing Lock:** The coordinator is strictly forbidden from directly writing or modifying target functional specifications or codebase source files; all file writes must be delegated to context-isolated subagents.
3. **Subagent Context Isolation:** Each subagent must be launched with a fresh, clean context targeting at most one discrete micro-task or specification unit.

---

## 3. SORA / ROS2 / PX4 Safety Verification Gates

1. **Bi-Directional Safety Traceability:** All C++ source files, ROS2 nodes, and PX4 modules must maintain explicit `/// Safety-Realises:` tags linking code symbols to SORA SAIL mitigations, ASTM bounds, or RTCA DO-365B requirements.
2. **Zero Dynamic Allocation Linter Gate:** Subagents modifying execution-critical ROS2 node callbacks or PX4 module loops must ensure code compiles and passes static analysis asserting zero heap memory allocations (`malloc`/`new`).
3. **QoS & uORB Standard Alignment:** All ROS2 nodes must adhere strictly to `.pipeline/profiles/ros2_cpp.md` QoS profile requirements. All PX4 autopilot modules must adhere strictly to `.pipeline/profiles/px4_module.md` lifecycle and uORB messaging rules.
4. **Remote ID & Geofence Validation:** Any changes to ASTM F3411-22a Remote ID generators or ASTM F3269-17 RTA geofence monitors must pass validation test suites verifying payload freshness ($\Delta t < 1.0\text{ s}$) and deterministic containment fallback behavior ($\le 100\text{ ms}$).

---

## 4. Forbidden Practices & Workspace Isolation

1. **No Root Workspace Edits:** Subagents must only read and write within `packages/DEAP-uas-infrastructure-safety/`.
2. **No Outside Terminal Operations:** Terminal commands targeting locations outside the repository root are strictly forbidden.
3. **No Unsafe Fallbacks:** Swallowing safety exception flags, bypassing geofence breaches, or returning dummy non-zero safe states is strictly prohibited.
