# Embedded C Implementation Profile: Civil Avionics (DAL A–D)

> **Profile Identifier:** `embedded-c-avionics-dal-a-d`  
> **Target Environment:** `Civil Avionic Flight Software (RTCA DO-178C DAL A–D)`  
> **Compiler & Toolchain:** `GCC / Clang / Arm GNU Toolchain (Strict C99/C11)`  
> **Coding Standard:** `MISRA-C:2012 / RTCA DO-178C Guidelines`

---

## 1. Overview & Scope

This profile specifies code construction standards, compiler configurations, and static analysis gates for developing safety-critical C software components in civil airborne avionics under RTCA DO-178C DAL A through DAL D.

---

## 2. Mandatory Language & Verification Rules

### 2.1 MISRA-C:2012 Compliance
- All C source files (`.c`) and header files (`.h`) must strictly comply with **MISRA-C:2012** rules (including Amendments 1, 2, and 3).
- Zero violations allowed for **Mandatory** and **Required** MISRA rules. Any **Advisory** rule deviation must be documented with an approved formal Safety Justification Report.
- Automated static analyzers (e.g., Clang-Tidy, Cppcheck, PC-Lint Plus, Coverity) must execute on every build to enforce compliance.

### 2.2 Absolute Ban on Dynamic Memory Allocation (`zero malloc`)
- Functions `malloc`, `free`, `realloc`, `calloc`, `alloca`, or custom dynamic memory pool wrappers are **100% prohibited** in all DAL A, B, C, and D software modules.
- All variables, structs, buffers, ring buffers, state machine queues, and execution stacks must be statically allocated at compile time using explicit array boundaries:
  ```c
  /* MANDATORY: Static allocation pattern */
  #define MAX_TELEMETRY_BUFFERS 16U
  static TelemetryBuffer_t g_telemetry_pool[MAX_TELEMETRY_BUFFERS];
  ```

### 2.3 Strict C99/C11 Compiler Settings
- Code must compile with zero warnings under `-std=c99` or `-std=c11` strict standards.
- Enforced compiler flags:
  `-Wall -Wextra -Werror -Wpedantic -Wshadow -Wconversion -Wstrict-prototypes -Wold-style-definition -Wmissing-prototypes -fstack-protector-strong`
- Pragmas disabling warnings or masking type conversions are strictly forbidden.

### 2.4 Explicit Integer Width Declarations (`<stdint.h>`)
- Primitive non-specific types (`int`, `long`, `short`, `char`, `unsigned`) are **strictly prohibited** for numeric arithmetic or status representation.
- Developers MUST use fixed-width integer types from `<stdint.h>` and `<stdbool.h>`:
  - `uint8_t`, `uint16_t`, `uint32_t`, `uint64_t`
  - `int8_t`, `int16_t`, `int32_t`, `int64_t`
  - `bool` (`true`, `false`)
- Floating-point arithmetic must explicitly specify standard types (`float` for single-precision IEEE 754, `double` for double-precision IEEE 754) with explicit cast validations.

### 2.5 Deterministic Control Flow & Bounded Loops
- Unbounded loops (`while(1)` without timeout breaks, `for(;;)` without iteration counters) are strictly prohibited.
- All loops must specify an explicit, statically provable maximum iteration count $N_{max}$ to prevent infinite thread block or watchdog timeouts.
- Recursion (direct or indirect) is strictly banned under MISRA-C Rule 17.2.

---

## 3. Static Analyzer Verification Commands

```bash
# Compile with strict warnings treated as errors
gcc -std=c99 -Wall -Wextra -Werror -Wpedantic -Wshadow -Wconversion -I./include -c src/flight_logic.c -o build/flight_logic.o

# Run cppcheck with MISRA analysis engine
cppcheck --inline-suppr --enable=warning,style,performance,portability --addon=misra.json --error-exitcode=1 src/

# Run clang-tidy static analysis gate
clang-tidy src/*.c -- -I./include -std=c99 -Wall -Wextra -Werror
```
