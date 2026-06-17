---
title: "Geographic Location Configuration & Tracking"
epic: "epic-01-test-location"
type: "epic"
labels: ["epic", "geo-location"]
---

# Epic: Geographic Location Configuration & Tracking

## 1. Context
This Epic describes the core location tracking and coordinate systems used to manage asset positions.

## 2. Requirements & Checklist
- [ ] [feat-01-reference-frame](https://github.com/gintatkinson/digital-pipeline-repo/blob/refactor/test_project/docs/features/feat-01-reference-frame.md) (Need reference frame configuration)

## 3. Architecture

## System-Level UML Class Diagram
```mermaid
classDiagram
    class GeoLocation {
        +Real coordAccuracy[0..1]
        +Real heightAccuracy[0..1]
        +saveLocation() : Boolean[1]
    }
    class ReferenceFrame {
        +String alternateSystem[0..1]
        +String astronomicalBody[1]
        +String geodeticDatum[0..1]
    }
    class Location
    <<choice>> Location
    class Ellipsoid {
        +Real latitude[1]
        +Real longitude[1]
        +Real height[0..1]
    }
    class Cartesian {
        +Real x[1]
        +Real y[1]
        +Real z[1]
    }
    class Velocity {
        +Real vNorth[0..1]
        +Real vEast[0..1]
        +Real vUp[0..1]
    }
    class TemporalMetadata {
        +String timestamp[1]
        +String validUntil[0..1]
    }

    GeoLocation *-- ReferenceFrame : referenceFrame
    GeoLocation *-- Location : location
    GeoLocation o-- Velocity : velocity
    GeoLocation *-- TemporalMetadata : temporalMetadata

    Location <|-- Ellipsoid
    Location <|-- Cartesian

    class UserInterface
    UserInterface --> GeoLocation : uses
```

## System State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> Unconfigured
    Unconfigured --> Configured : configure
    Configured --> Active : activate
    Active --> [*]
```

## 4. Operational Considerations
Operational guidelines for geodetic tracking.

## 5. Security & Governance
Privacy controls for location data.

## 6. Source References
RFC 9179.
