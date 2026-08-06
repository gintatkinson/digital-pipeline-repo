# DEAP Profile: PX4 Autopilot C++ Module Engineering (`px4_module`)

> **Profile Identifier:** `px4_module`  
> **Target Framework:** `PX4 Autopilot C++ Middleware & NuttX RTOS`  
> **Scope:** `PX4 Autopilot Flight Control & Safety Modules for Low-Altitude UAS Infrastructure Inspection`  
> **Status:** `APPROVED / MANDATORY`

---

## 1. Module Lifecycle & Inherited Architecture

1. **Base Class Derivation:** All custom PX4 modules must derive from `px4::ModuleBase<ModuleName>` and implement `px4::ScheduledWorkItem` or `ModuleBase` task loop management.
2. **Lifecycle Methods:** Must implement standard PX4 lifecycle entrypoints:
   - `task_spawn(int argc, char *argv[])`: Spawns module thread/work item.
   - `custom_command(int argc, char *argv[])`: Handles CLI commands (`start`, `stop`, `status`).
   - `print_usage(const char *reason)`: Displays CLI usage.
   - `run()` / `Run()`: Primary execution entry point.

---

## 2. uORB Topic Messaging Standards

1. **uORB Subscription Model:**
   - Use `uORB::Subscription`, `uORB::SubscriptionCallbackWorkItem`, or `uORB::SubscriptionInterval` wrappers.
   - Polling must be non-blocking using `uORB::Subscription::updated()` or `px4_poll()`.
2. **uORB Publication Model:**
   - Use `uORB::Publication<T>` or `uORB::PublicationMulti<T>`.
   - Never publish uORB topics from interrupt service routines (ISRs) or blocking calls.
3. **Core uORB Topics Supervised:**
   - `vehicle_command`: Command dispatch for flight mode changes and emergency RTL.
   - `vehicle_status`: System arming state, navigation state, and safety lock flags.
   - `vehicle_failsafe_flags`: High-priority status bits for lost-link, geofence breach, battery low, and DAA alerts.
   - `vehicle_trajectory_waypoint`: RTA containment trajectory overrides.

---

## 3. Safe State Fail-Safe Transitions

Modules handling flight safety parameters must enforce deterministic state machine transitions:

```
[Normal Navigation] --(Geofence Breach / Lost Link)--> [Loiter / Warning Mode]
                                                             |
                                                   (t_hold > 2.0s / Hard Breach)
                                                             v
                                                  [Return-To-Launch (RTL)]
                                                             |
                                                (Critical System Failure)
                                                             v
                                                  [Emergency Land / Terminate]
```

1. **Lost C2 Datalink ($t_{loss} > 2.0\text{ s}$):** Trigger automated switch from Offboard/Mission mode to `NAVIGATION_STATE_AUTO_RTL`.
2. **RTA Geofence Breach:** Immediate override of vehicle velocity setpoints via `vehicle_trajectory_waypoint` to execute containment bounce-back or force `NAVIGATION_STATE_AUTO_RTL`.
3. **EMF / Magnetometer Interference:** Detection of flux anomaly ($\Delta B > 50\mu\text{T}$) triggers automatic fallback from compass-based heading to visual-inertial odometry or dual-antenna GNSS heading.
4. **Low Battery Cell Voltage Sag:**
   - Stage 1 (Warning): Log alert and notify Remote ID telemetry.
   - Stage 2 (Failsafe): Force RTL command.
   - Stage 3 (Critical): Force immediate controlled descent landing.

---

## 4. Execution Loop Constraints & Performance Controls

1. **Zero-Blocking Loop Constraint:** Thread execution loops must never execute blocking `sleep()`, `usleep()`, or sync I/O calls inside work item callbacks.
2. **Memory Constraints:** Zero dynamic memory allocations (`malloc`/`new`) after `task_spawn()` initialization phase.
3. **Stack Usage Budget:** Thread stack allocation must be explicitly budgeted ($\le 2048\text{ bytes}$ for work items, $\le 4096\text{ bytes}$ for standalone tasks) with stack overflow checks enabled (`CONFIG_STACK_COLORATION`).
4. **Execution Time Budget:** `Run()` callback duration must not exceed $2.0\text{ ms}$ per execution cycle.

---

## 5. Verification & Compliance Requirements

- **PX4 SITL Verification:** Modules must be validated against PX4 Software-In-The-Loop (SITL) Gazebo simulations under simulated RF loss, geofence breaches, and sensor dropouts.
- **AST Safety Linter Pass:** Clean report from DEAP static analysis tools verifying uORB topic initialization and stack boundary safety.
