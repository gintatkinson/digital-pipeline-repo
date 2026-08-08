---
title: "Hardware-Decoupled Persistence & Bus-Mapped Register Architecture (VHDL/FPGA Platform Profile)"
type: "design"
issue_id: 373
platform: vhdl-fpga
---

# Design Document: Hardware-Decoupled Persistence & Bus-Mapped Register Architecture (VHDL/FPGA Platform Profile)

## 1. Context & Architectural Goals
This document details the hardware design for implementing the decoupled, agnostic persistence specification as a synthesized digital system in **VHDL** on a **Xilinx FPGA** platform.

The core objectives are:
1. **Contract Decoupling in Silicon:** Isolating the core digital signal processing (DSP) or control logic from the physical IO transport protocol (e.g. SPI, I2C, UART, AXI-Lite, or PCIe).
2. **Memory-Mapped Register Abstraction:** Abstracting the geodetic database tables into a hardware **Register Map** utilizing fixed-point arithmetic representations.
3. **Heterogeneous Interface Mapping:** Supporting dynamic configuration of the transport wrapper (the adapter) to swap between serial testbenches (simulation) and physical bus synthesis (production hardware) without modifying the internal computation cores.

---

## 2. Decoupled Hardware Architecture
At the hardware description level, we implement the software adapter/repository pattern using **Bus-Wrappers** and **Finite State Machines (FSMs)**:

```mermaid
flowchart LR
    subgraph "Core Logic (Agnostic Domain)"
        DSP_Core["DSP / Logic Processing Core"]
        Reg_Map["Internal Register Map BRAM/Registers"]
    end

    subgraph "Heterogeneous Bus-Wrappers (Adapters)"
        AXI_Lite["AXI-Lite Adapter Wrapper"]
        SPI_Wrap["SPI Serial Interface Wrapper"]
        PCIe_Wrap["PCIe DMA Interface Wrapper"]
    end

    subgraph "Local Simulation / Testbench"
        TB_Stim["Testbench Stimulus Vector File"]
    end

    DSP_Core ---|"Reads/Writes via Local Addresses"| Reg_Map
    Reg_Map ---|"Shared Register Access"| Interface_Wrappers
    TB_Stim -->|"Feeds Signals"| SPI_Wrap
    AXI_Lite ---|"AXI4 Bus Signals"| Host_CPU["Host CPU / Zynq ARM Core"]
    PCIe_Wrap ---|"PCIe Bus Pins"| Ext_PCIe["PCIe Host Controller"]
```

### Architectural Principles:
* **The Shared Register Map (The Repository):** An internal array of registers or Block RAM (BRAM) addresses containing the data model values. The internal DSP core and external interface wrappers share access to this register map.
* **Bus-Wrappers (The Adapters):** VHDL wrappers that translate specific bus protocol signals (such as AXI-Lite read/write handshake lines, or SPI serial clock/data frames) into local register address writes.
* **Data Format Translators:** FSM logic within the wrappers that converts raw serialized bits or floating-point bus packets into the internal fixed-point representation used by the FPGA DSP logic.

---

## 3. Register & Data Format Mapping
To realize the Yang geodetic specifications (`docs/schemas/ietf-geo-location.yang`) in hardware registers, we define a 32-bit memory-mapped register configuration.

### Fixed-Point Coordinate Representation
To avoid the resource overhead of floating-point units (FPUs) in FPGA fabric, latitude, longitude, and height coordinates are stored as **32-bit two's complement fixed-point numbers (Q16.16 format)**:
* **Whole integer part:** 16 bits (signed).
* **Fractional part:** 16 bits.
* **Resolution:** $2^{-16} \approx 0.000015$ degrees (approx. 1.7 meters at the equator), which satisfies coordinate accuracy specifications.

### Register Map Table (Base Offset: `0x43C0_0000`)

| Address Offset | Register Name | Access Type | Description / Bit Fields |
| :--- | :--- | :--- | :--- |
| `0x00` | `CONTROL_STATUS` | R/W | Bit 0: Commit (Trigger update)<br>Bit 1: Busy flag (Read-only)<br>Bit 2: Error flag (Read-only) |
| `0x04` | `GEODETIC_SYSTEM` | R/W | Bits 1-0: Coordinate Choice (00=Unconfigured, 01=Ellipsoid, 10=Cartesian)<br>Bits 7-2: Datum ID |
| `0x08` | `COORD_LAT_X` | R/W | Dim_0 or Cartesian X (32-bit Q16.16 format) |
| `0x0C` | `COORD_LON_Y` | R/W | Dim_1 or Cartesian Y (32-bit Q16.16 format) |
| `0x10` | `COORD_ALT_Z` | R/W | Dim_2 or Cartesian Z (32-bit Q16.16 format) |
| `0x14` | `VALIDITY_LIMIT` | R/W | Epoch timestamp indicating validity boundary |

---

## 4. Agnostic Transport Translation FSM
Each bus wrapper runs a VHDL Finite State Machine to handle interface-specific transactions and commit them to the internal registers.

### FSM Realisation Matrix for `CONTROL_STATUS` Bits

| Bit | Bit Name | Access | FSM Assertion / Condition | State Transitions & Behavior |
| :--- | :--- | :--- | :--- | :--- |
| Bit 0 | Commit bit 0 | R/W | Guard condition for atomic commit | Asserted by host CPU to trigger commit; FSM checks `commit_bit == 1` in `STAGED` state before proceeding to `COMMIT_REG`. |
| Bit 1 | Busy bit 1 | Read-only | Asserted high during transaction processing | Asserted high when transitioning `IDLE --> RECEIVING`; remains high through `RECEIVING`, `DESERIALIZING`, `MAPPING`, `STAGED`, `COMMIT_REG`, and `ERROR`; deasserted low on returning to `IDLE`. |
| Bit 2 | Error bit 2 | Read-only | Asserted high on fault or invalid frame | Asserted high upon transition to `ERROR` state (triggered by invalid encoding `11`, unconfigured geodetic system `00`, truncated frame, or out-of-range coordinate value); cleared on error acknowledgment transition `ERROR --> IDLE`. |

```mermaid
stateDiagram-v2
    IDLE --> RECEIVING : "Bus Transaction Detected / Assert Busy bit 1"
    RECEIVING --> DESERIALIZING : "Read Frame Complete"
    DESERIALIZING --> MAPPING : "Convert format (e.g. SPI stream -> Q16.16)"
    MAPPING --> STAGED : "Hold coordinates safely without premature commit"
    STAGED --> COMMIT_REG : "commit_bit == 1 AND GEODETIC_SYSTEM in (01, 10)"
    COMMIT_REG --> IDLE : "Register write complete / Deassert Busy bit 1"
    RECEIVING --> ERROR : "Truncated frame / Set Error bit 2"
    DESERIALIZING --> ERROR : "Out-of-range value / Set Error bit 2"
    MAPPING --> ERROR : "Invalid encoding 11 or unconfigured 00 / Set Error bit 2"
    STAGED --> ERROR : "Invalid encoding 11 or unconfigured 00 / Set Error bit 2"
    ERROR --> IDLE : "Error acknowledgment / Clear Error bit 2 & Busy bit 1"
```

### VHDL Translator FSM Details:
1. **IDLE:** Waits for interface-specific handshakes (e.g. AXI `AWVALID` and `WVALID` flags, or SPI Chip Select `CS_N` going low). Busy bit 1 and Error bit 2 are deasserted.
2. **RECEIVING:** Shifts in serialization data packets and asserts Busy bit 1. If a truncated frame is detected, transitions to **ERROR** and sets Error bit 2.
3. **DESERIALIZING:** Assembles bits into standard 32-bit hardware words. If an out-of-range value is detected, transitions to **ERROR** and sets Error bit 2.
4. **MAPPING:** Executes binary translation (e.g. converting IEEE-754 single-precision float inputs from a CPU into internal Q16.16 fixed-point format). If invalid encoding (`11`) or unconfigured geodetic system (`00`) is detected, transitions to **ERROR** and sets Error bit 2.
5. **STAGED:** Holds coordinates safely in staging registers without premature atomic commit. Guarded transition to **COMMIT_REG** occurs when `commit_bit == 1` (Commit bit 0) and `GEODETIC_SYSTEM` coordinate choice is valid (`01` Ellipsoid or `10` Cartesian). If unconfigured (`00`) or invalid encoding (`11`), transitions to **ERROR** and sets Error bit 2.
6. **COMMIT_REG:** Asserts the internal register write enable to write values to target registers, then returns to **IDLE** while deasserting Busy bit 1.
7. **ERROR:** Sets Error bit 2. FSM remains in **ERROR** state holding error status until an error acknowledgment transaction is received, which transitions `ERROR --> IDLE`, clearing Error bit 2 and Busy bit 1.

---

## 5. Standalone Simulation & Verification Plan

### 1. Standalone Simulation Testbench (Local Run)
For local development and E2E verification without physical hardware:
* We implement a testbench (`tb_geodetic_register_map.vhd`).
* The testbench reads test data shapes from a local configuration vector file (`stimulus.dat`) containing coordinate values.
* The testbench simulates the physical SPI clock and data lines, feeding the vectors into the wrapper, and asserts that the internal registers resolve to the expected values (e.g. checking that the Q16.16 output matches the input).

### 2. Distributed Synthesis (Production Run)
For physical deployment:
* The core VHDL code is synthesized using **Xilinx Vivado** targeting a specific FPGA board (e.g. Xilinx Zynq-7000 or UltraScale+ SoC).
* The registers are exposed to the host CPU (e.g. ARM Cortex core) over an **AXI4-Lite IP block**, allowing software operating systems to read/write hardware geometry coordinates via memory-mapped pointer offsets (`/dev/mem`).

---

## Source References

| Register | Schema path | Leaf node | Verbatim clause |
| :--- | :--- | :--- | :--- |
| `CONTROL_STATUS` | `docs/schemas/ietf-geo-location.yang` | `control-status` | `container control-status` |
| `GEODETIC_SYSTEM` | `docs/schemas/ietf-geo-location.yang` | `datum-id` | `leaf datum-id` |
| `COORD_LAT_X` | `docs/schemas/ietf-geo-location.yang` | `dim_0` | `leaf dim_0` |
| `COORD_LON_Y` | `docs/schemas/ietf-geo-location.yang` | `dim_1` | `leaf dim_1` |
| `COORD_ALT_Z` | `docs/schemas/ietf-geo-location.yang` | `dim_2` | `leaf dim_2` |
| `VALIDITY_LIMIT` | `docs/schemas/ietf-geo-location.yang` | `validity-limit` | `leaf validity-limit` |
