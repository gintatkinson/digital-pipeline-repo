---
title: "Implementation Profile — Flutter"
project: "Digital Pipeline"
tier: implementation
platform: flutter
---

# Implementation Profile: Flutter

## Platform & Stack
- Framework: Flutter 3.44.0
- Language: Dart 3.12.0

## Testing
- Unit tests: `cd app_flutter && flutter test`
- Integration tests: `cd app_flutter && flutter test -d macos integration_test/`
- Full stress test: `cd app_flutter && flutter test -d macos integration_test/benchmark_test.dart`
- Benchmark results: `/Users/perkunas/opcode/digital-pipeline-repo/benchmark_results.jsonl`

## Profiling
- Performance regression threshold: >10% from baseline
- Memory leak detection: 5-pass net growth > 20MB
