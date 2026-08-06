# DEAP Tier 1 UAS Infrastructure Safety Constitution

> **Version:** `1.0.0`  
> **Status:** `ACTIVE / RATIFIED`  
> **Scope:** `DEAP Low-Altitude UAS & Infrastructure Safety Platform (packages/DEAP-uas-infrastructure-safety)`  
> **Authority:** `Digital Engineering Agentic Pipeline (DEAP) Safety Governance Board`

---

## Article I: Constitutional Purpose & Governance Principles

1. **Non-Negotiable Safety Primacy:** All code, specifications, and deployment configurations produced for low-altitude infrastructure inspection must conform to verified safety boundaries. Safety assurance gates supersede operational speed, feature addition, and non-safety performance optimizations.
2. **Deterministic Regulatory Traceability:** Every safety-critical requirement, specification element, ROS2 C++ node, and PX4 autopilot module must be traceably linked to international civil aviation standards using explicit `/// Safety-Realises:` tags.
3. **Zero Dynamic Allocation in Critical Flight Loops:** Real-time safety filters, geofence monitors, Remote ID telemetry encoders, and DAA collision avoidance routines must operate without dynamic heap memory allocation (`malloc`/`new`) during flight loop execution.

---

## Article II: Regulatory & SORA Assurance Gates

### Section 2.1: JARUS SORA v2.5 Mitigation Verification
- **SAIL Level Verification:** All software artifacts built under this package must state their target SORA SAIL level (SAIL I through SAIL VI).
- **OSO Compliance:** For SAIL III–VI operations, Operational Safety Objectives (OSOs) governing software integrity, operational containment, and sensor validation must be verified by automated test gates.
- **Bi-Directional Safety Links:** Source code implementations must cite SORA mitigations using tags formatted as: `/// Safety-Realises: [SORA-v2.5/SAIL-IV/OSO-05]`.

### Section 2.2: ASTM F3269-17 Run-Time Assurance (RTA) Geofencing Bounds
- **Simplex Architecture:** Spatial containment logic must enforce strict separation between complex trajectory planners and the Verified Safety Filter (VSF).
- **Containment Breach Fallback:** Breach of soft warning geofence boundaries must trigger immediate loiter/warning events; breach of hard geofence boundaries must force deterministic Return-To-Launch (RTL) or emergency termination commands within $\le 100\text{ ms}$.
- **Boundary Verification Gate:** Containment polygon evaluation functions must be verified against static AST linters asserting zero heap allocation and bounded evaluation execution time.

### Section 2.3: ASTM F3411-22a Remote ID Verification
- **1 Hz Broadcast Rate:** Direct Remote ID transmission engines (BLE 4/5, Wi-Fi NAN) must maintain a continuous $1.0\text{ Hz} \pm 100\text{ ms}$ broadcast loop.
- **Payload Integrity:** Telemetry payloads must contain valid Open-Drone-ID (ODID) formatted UAS ID, geographic location, pressure/barometric altitude, ground speed, heading, timestamp, and operator location.
- **Freshness Gate:** Telemetry data with timestamp age $\Delta t > 1.0\text{ s}$ must trigger a Remote ID degradation flag.

### Section 2.4: RTCA DO-365B Detect and Avoid (DAA) Bounds
- **Well-Clear Volume Protection:** DAA intruder track processing must maintain defined horizontal distance $D_{mod}$, vertical offset $H^*$, and time-to-co-altitude $\tau_{mod}$.
- **3-Tier Alerting Thresholds:** Threat alerts must deterministically escalate from Traffic Advisory (TA) to Preventive Advisory (PA) to Corrective Resolution Advisory (CRA).

---

## Article III: Flight Software & Middleware Engineering Standards

### Section 3.1: ROS2 Node Safety Requirements
- **Distribution Standard:** Target ROS2 Humble Hawksbill or Jazzy Jalisco C++ standards (`rclcpp::Node`).
- **Memory Allocator:** Execution-critical nodes must employ real-time memory allocators (e.g., `tlsf` allocator) or static pool pre-allocations.
- **QoS Policy Compliance:**
  - Control & Telemetry: `Reliable` reliability, `Transient Local` durability, deadline monitoring (`< 100ms`).
  - High-Bandwidth Sensors: `Best Effort` reliability, `Volatile` durability, bounded queue depth ($\le 5$).
- **Lifecycle Management:** Nodes handling safety-critical state transitions must implement `rclcpp_lifecycle::LifecycleNode` interfaces.

### Section 3.2: PX4 Autopilot Module Requirements
- **Module Architecture:** Autopilot tasks must derive from `px4::ModuleBase` and follow non-blocking uORB polling patterns.
- **uORB Topic Handling:** Sensor streams and fail-safe flags (`vehicle_failsafe_flags`, `vehicle_status`, `vehicle_command`) must use atomic or lock-free uORB subscription copies.
- **Fail-Safe State Transitions:**
  - Lost C2 Datalink ($t_{loss} > 2.0\text{ s}$): Automated transition to Loiter -> RTL.
  - EMF Magnetometer Saturation: Immediate failover to visual-inertial odometry / optical flow state estimators.
  - BMS Battery Cell Sag: Multi-stage fail-safe action (Warning -> RTL -> Land).

---

## Article IV: Verification, Auditing & Enforceability

1. **Automated Static Analysis Gate:** All pull requests must pass static AST linters validating zero dynamic memory allocation in critical paths, QoS profile compatibility, and mandatory uORB topic checks.
2. **Simulation & Integration Testing:** Code changes to RTA geofencing or DAA must pass automated SITL (Software-In-The-Loop) Gazebo/PX4 test suites before merging.
3. **Constitution Supremacy:** Any conflict between software feature requests and the safety constraints in this Constitution shall be resolved in favor of this Constitution.
