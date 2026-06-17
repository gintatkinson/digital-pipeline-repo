---
title: "Geographic Reference Frame Configuration"
epic: "epic-01-test-location"
type: "feature"
interface_type: "api"
labels: ["feature", "geo-location"]
---

# Feature: Geographic Reference Frame Configuration

## Description
Configure geodetic reference systems.

## UML Class Diagram
```mermaid
classDiagram
    class GeoLocation {
        +ReferenceFrame referenceFrame[1]
    }
    class ReferenceFrame {
        +String alternateSystem[0..1]
        +String astronomicalBody[1]
        +String geodeticDatum[0..1]
    }
    GeoLocation *-- ReferenceFrame : referenceFrame
```

## Interface Requirements

### 1. Test Data Shape
```json
{
  "alternate-system": "GPS",
  "astronomical-body": "earth",
  "geodetic-datum": "wgs-84"
}
```

### 4. Interactive Flow & States
Exception states when invalid inputs are received.
