# SPARK Ada Implementation Profile: Civil Avionics (DAL A–C)

> **Profile Identifier:** `spark-ada-avionics-dal-a-c`  
> **Target Environment:** `Civil Avionic Flight Safety Systems (RTCA DO-178C DAL A–C)`  
> **Compiler & Formal Toolchain:** `GNAT Pro / SPARK 2014+ (gnatprove)`  
> **Language Standard:** `Ada 2012 / SPARK 2014`

---

## 1. Overview & Scope

This profile defines the engineering rules, formal verification standards, and compiler settings for developing civil airborne flight software using **SPARK Ada** under RTCA DO-178C DAL A, B, and C assurance levels. SPARK Ada enables formal mathematical proof of software correctness, guaranteeing the complete absence of run-time errors (AoRTE) and enforcing rigorous interface contracts.

---

## 2. Core Profile Rules & Directives

### 2.1 Enforcement of SPARK_Mode
- Every Ada spec (`.ads`) and body (`.adb`) file in safety-critical packages MUST declare `pragma SPARK_Mode (On);` at the unit header level.
- Unsound constructs or non-SPARK code blocks are strictly forbidden in DAL A/B modules. If a third-party legacy interface requires `SPARK_Mode => Off`, it must be strictly isolated inside a dedicated wrapper and verified via manual code review.

### 2.2 Formal Contract Annotations
All subprograms must specify explicit formal contracts using SPARK aspect annotations:
- **`Pre` (Preconditions):** States all required input states, parameter ranges, and system invariants prior to subprogram entry.
- **`Post` (Postconditions):** Formally defines the exact output guarantees, state changes, and return values upon subprogram exit.
- **`Global` Aspect:** Explicitly lists all global state variables accessed or modified (`Input`, `Output`, `In_Out`, `Proof_In`). Implicit global state access is prohibited.
- **`Depends` Aspect:** Defines exact data-flow dependency matrices between input inputs/globals and output outputs/globals.

Example:
```ada
package Flight_Controller
  with SPARK_Mode => On
is
   type Elevator_Angle is range -30 .. 30;
   
   procedure Set_Elevator (Target_Angle : in Elevator_Angle)
     with
       Global  => (In_Out => Current_Surface_State),
       Depends => (Current_Surface_State =>+ Target_Angle),
       Pre     => System_Initialized and then Airspeed_Valid,
       Post    => Current_Surface_State.Elevator = Target_Angle;
end Flight_Controller;
```

### 2.3 Formal Proof Levels (`gnatprove`)
- **DAL A Verification:** Must pass `gnatprove --level=gold --proof=progressive --checks-as-errors` verifying 100% absence of run-time errors (AoRTE) and contract satisfaction.
- **DAL B Verification:** Must pass `gnatprove --level=silver --checks-as-errors`.
- **DAL C Verification:** Must pass `gnatprove --level=stone` or `check_all`.
- **Zero Unproven Checks:** Pull requests containing unproven checks (`VCs`) or unverified assertions will be rejected by CI verification gates.

### 2.4 Zero Runtime Exception Handling
- Software designs must prove freedom from run-time exceptions (e.g., division by zero, array index out of bounds, range overflow, discriminant mismatch) mathematically using `gnatprove`.
- Pragma `Suppress (All_Checks);` may only be enabled in production binaries after formal proof has demonstrated that no checks can fail, ensuring zero exception overhead and zero unhandled exception paths.

### 2.5 Static Memory & Stack Allocation
- Dynamic heap allocation (`Ada.Unchecked_Deallocation`, `allocators`, `access` types pointing to heap) is **100% banned**.
- All data types, fixed arrays, static queues, and records must have fixed, statically known sizes at compile time.
- Task stacks and global storage must be pre-allocated statically. GNAT stack analysis (`-fstack-usage`) must verify maximum call stack depth.

---

## 3. Compliance Verification Commands

```bash
# Run GNAT static analysis and syntax checks
gnatmake -gnat2012 -gnatwa -gnatwe -gnatVa -Pflight_safety.gpr

# Execute SPARK formal proof engine (DAL A Gold Level)
gnatprove -Pflight_safety.gpr --level=gold --report=all --checks-as-errors
```
