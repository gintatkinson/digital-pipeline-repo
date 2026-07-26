#!/usr/bin/env python3
"""
generate_docs.py: Generator script for feature specifications.
Generates and maintains feature markdown files in docs/features/.
"""

import os
import sys

FEATURE_02_CONTENT = """---
title: "Feature 02: Alternate Coordinate and Geodetic Systems"
type: "feature"
interface_type: "api"
generation_mode: "subagent"
spec_source: "Project Constitution"
issue_id: 2
---

# Feature 02: Alternate Coordinate and Geodetic Systems

## UML Class Diagram
```mermaid
classDiagram
    class AlternateSystem {
        +String systemId [1]
        +String epsgCode [1]
        +String projectionParameters [1]
    }
    class ReferenceFrame {
        +String alternateSystem [1]
        +String geodeticDatum [1]
    }
    ReferenceFrame "1" --> "0..1" AlternateSystem : usesAlternateSystem
```

## Interface Requirements

### 1. Payload Schema
```json
{
  "systemId": "UTM-ZONE-54N",
  "epsgCode": "EPSG:32654",
  "projectionParameters": "+proj=utm +zone=54 +datum=WGS84 +units=m +no_defs"
}
```

### 2. Operational Scenarios

#### Scenario 1: Alternate System Coordinate Conversion
- **Given** a spatial telemetry payload utilizing a non-standard reference frame.
- **When** the spatial processing module parses the `alternateSystem` attribute.
- **Then** the system resolves the matching EPSG transformation parameter set and converts coordinates accordingly.

### 3. Logical Operations & Interface Messages
1. Retrieve active geodetic reference frame parameters.
2. Query alternate system projection definitions by EPSG code.
3. Transform geodetic coordinates to alternate spatial frame representations.

### 4. Logical Exception States & Validation Failures
1. Unsupported EPSG Code: If the alternate system EPSG code cannot be resolved, the parser raises a spatial coordinate conversion exception.

---

## Source References
- **Project Constitution**: [constitution.md:L88-94](../../.pipeline/constitution.md#L88-L94)
- **Adversarial Audit Synthesis**: [adversarial_audit_synthesis.md:L44](../decisions/adversarial_audit_synthesis.md#L44)
"""

def generate_docs():
    output_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "docs", "features"))
    os.makedirs(output_dir, exist_ok=True)
    target_file = os.path.join(output_dir, "feat-002-alternate-systems.md")
    legacy_file = os.path.join(output_dir, "feat-02-alternate-systems.md")
    
    if os.path.exists(legacy_file):
        os.remove(legacy_file)
        print(f"[-] Removed legacy file: {legacy_file}")
    
    with open(target_file, "w", encoding="utf-8") as f:
        f.write(FEATURE_02_CONTENT.lstrip())
    
    print(f"[+] Successfully generated: {target_file}")

if __name__ == "__main__":
    generate_docs()
