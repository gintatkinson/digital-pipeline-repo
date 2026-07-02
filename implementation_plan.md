# Implementation Plan: Closed-Loop Performance Profiling & Automated Defect Filing

This plan details the changes to integrate frame performance timeline tracking, VM-level memory leak detection, and an automated runner script that parses profile reports and files GitHub defect issues to close the loop with the `debug-protocol`.

---

## Proposed Changes

### 1. VM Leak Detection & Frame Timeline Tracking
- **File**: `app_flutter/integration_test/node_iteration_test.dart`
- **Action**:
  - Wrap the node iteration stress loop in `binding.watchPerformance(...)` to capture the UI/Raster timeline traces.
  - Implement a VM Service connection helper that connects to the Dart VM during test runs.
  - Trigger garbage collection programmatically and verify that instance counts for key State/ViewModel/Controller classes (e.g. `TreeViewModel`, `PropertiesViewModel`, `TablesViewModel`) have returned to their expected baseline.
  - Write detailed JSON records of frame times, memory growth (RSS), and leak details directly to `benchmark_results.jsonl`.
- **File**: `app_flutter/macos/Runner/DebugProfile.entitlements`
- **Action**:
  - Add `com.apple.security.network.client` key set to true to allow the macOS desktop target application to connect to the local VM service via WebSocket.

---

### 2. Closed-Loop Profiler Runner (Automated Bug Filing)
- **File [NEW]**: `scripts/run_profile_audit.py`
- **Action**:
  - A Python automation script that runs the integration test command.
  - Parses the execution stdout and `benchmark_results.jsonl` logs.
  - Detects memory leaks, high frame build times (jank > 16.6ms), or test failures.
  - If a defect or bottleneck is found:
    - Formats a comprehensive markdown report with the profiling traces, RSS deltas, and affected widgets.
    - Files a GitHub issue directly in the repository via the `gh` CLI:
      ```bash
      gh issue create --title "Defect: [Performance/Memory Leak] detected during profile audit" --body-file [report_path] --label "bug"
      ```
    - Prints the created Issue ID, allowing it to be immediately picked up and solved using the `debug-protocol`.

---

### 3. Developer documentation
- **File**: `app_flutter/README.md`
- **Action**:
  - Add execution instructions for running `python scripts/run_profile_audit.py` to trigger the closed-loop profiling and bug-hunting flow.

---

## Verification Plan

### Step 1: Run the Profiler Audit
1. Execute the profiling audit runner:
   ```bash
   python scripts/run_profile_audit.py
   ```
2. Confirm the test executes and writes performance metrics to `benchmark_results.jsonl`.

### Step 2: Verification of Automated Bug Filing
1. Temporarily insert a memory leak (e.g., holding references to disposed ViewModels in a global list).
2. Run `python scripts/run_profile_audit.py`.
3. Verify that the script successfully detects the leak, halts execution, and files a detailed defect issue on GitHub.
4. Verify that the filed issue is labeled `bug` and displays correct trace info.
