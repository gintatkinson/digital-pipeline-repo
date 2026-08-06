# DEAP Profile: ROS2 C++ Node Engineering (`ros2_cpp`)

> **Profile Identifier:** `ros2_cpp`  
> **Target Framework:** `ROS2 Humble Hawksbill / Jazzy Jalisco C++`  
> **Scope:** `ROS2 Node Implementations for Low-Altitude UAS Infrastructure Inspection`  
> **Status:** `APPROVED / MANDATORY`

---

## 1. Core Architecture & Node Model

1. **Node Base Class:** All nodes must inherit from `rclcpp::Node` or `rclcpp_lifecycle::LifecycleNode` for deterministic state transitions (Unconfigured, Inactive, Active, Finalized).
2. **Standard C++ Standard:** C++17 or C++20 compliance strictly enforced.
3. **Execution Executors:** Use `rclcpp::executors::SingleThreadedExecutor` or explicit `rclcpp::executors::MultiThreadedExecutor` with static thread pool assignment. Avoid default unmanaged thread creation.
4. **Safety Annotations:** Every ROS2 node class header must include SORA and safety realization annotations:
   ```cpp
   /// Safety-Realises: [SORA-v2.5/SAIL-IV/OSO-05]
   /// Safety-Realises: [ASTM-F3269-17/RTA-VSF]
   class GeofenceMonitorNode : public rclcpp::Node { ... };
   ```

---

## 2. Real-Time Memory Management Rules

1. **Zero Dynamic Allocation in Execution Loops:**
   - Dynamic memory allocation (`malloc`, `free`, `new`, `delete`, `std::vector::push_back`, `std::make_shared`) is strictly forbidden inside timer callbacks, topic callbacks, and control loops.
   - Use pre-allocated message instances, `std::array`, `bounded_vector`, or static memory pools.
2. **Real-Time Memory Allocator:**
   - Real-time safety-critical nodes must integrate the **TLSF (Two-Level Segregated Fit)** allocator (`tlsf_cpp` / `realtime_tools`).
3. **Pre-Allocation Pattern:**
   - All ROS2 publishers, subscribers, service clients, and message buffers must be constructed and reserved during node initialization (`on_configure` or constructor).

---

## 3. Middleware QoS Profile Policies

Publishers and subscribers must explicitly declare Quality of Service (QoS) profiles based on message domain semantics:

### A. Critical Flight Control & Safety Command QoS
```cpp
auto control_qos = rclcpp::QoS(rclcpp::KeepLast(1))
    .reliability(RCL_TOPIC_RELIABILITY_RELIABLE)
    .durability(RCL_TOPIC_DURABILITY_TRANSIENT_LOCAL)
    .liveliness(RCL_TOPIC_LIVELINESS_SYSTEM_DEFAULT)
    .deadline(std::chrono::milliseconds(100));
```

### B. High-Bandwidth Sensor Telemetry (LiDAR, Radar, Cameras) QoS
```cpp
auto sensor_qos = rclcpp::QoS(rclcpp::KeepLast(5))
    .reliability(RCL_TOPIC_RELIABILITY_BEST_EFFORT)
    .durability(RCL_TOPIC_DURABILITY_VOLATILE);
```

### C. Heartbeats & Remote ID Broadcast QoS
```cpp
auto remote_id_qos = rclcpp::QoS(rclcpp::KeepLast(1))
    .reliability(RCL_TOPIC_RELIABILITY_RELIABLE)
    .durability(RCL_TOPIC_DURABILITY_TRANSIENT_LOCAL)
    .liveliness(RCL_TOPIC_LIVELINESS_AUTOMATIC)
    .liveliness_lease_duration(std::chrono::milliseconds(1000));
```

---

## 4. Launch Safety Monitors & Lifecycle Verification

1. **Automated QoS Compatibility Checks:** Launch files must evaluate QoS compatibility between publishers and subscribers prior to activating flight-critical nodes.
2. **Node Life-Cycle Supervision:** Lifecycle nodes must transition through `on_configure()` -> `on_activate()` before accepting flight control commands.
3. **Heartbeat Monitoring:** Safety supervisor nodes must monitor heartbeat deadlines. If a critical node misses two consecutive deadlines ($\Delta t > 200\text{ ms}$), the supervisor must issue an uORB/ROS2 emergency safe-state fail-safe signal.

---

## 5. Verification & Code Linting Rules

- **Static Linter Gate:** `ament_cpplint`, `ament_uncrustify`, `clang-tidy` with custom DEAP heap allocation check passes.
- **Coverage Target:** Minimum 90% statement coverage for safety-critical ROS2 node callbacks.
