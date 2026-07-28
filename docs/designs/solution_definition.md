# Solution Architecture & Design Specification

This document details the software architecture, data design, and service integration to realize 100% of the specification backlog (Epics #7-#9, Features #1-#13, User Stories, and Use Cases) in the Flutter application.

---

## 1. System Architecture (Clean MVVM)

The application adheres strictly to Clean Architecture separation of concerns, structured into three distinct layers:

```
+-------------------------------------------------------------+
| Presentation Layer (features/)                             |
|   - Widgets (Tree, Map Viewport, Property Grid, Tables)     |
|   - ViewModels (PropertiesViewModel, TablesViewModel)       |
+------------------------------+------------------------------+
                               |
                               v
+------------------------------+------------------------------+
| Domain Layer (domain/)                                      |
|   - Domain Services (Location, Dispatch, Velocity, Rack)    |
|   - Core Entities (TypeDescriptor, InstanceRecord)          |
|   - Validators (validation.dart)                            |
+------------------------------+------------------------------+
                               |
                               v
+------------------------------+------------------------------+
| Data Layer (data/)                                          |
|   - SQLite Database & Seed (DomainSeedStrategy)             |
|   - Data Source Adapters (SqliteDataSource)                 |
+-------------------------------------------------------------+
```

### 1.1 UI Component Grid Wiring
The presentation layer loads the logical interface grid layout dynamically from `.pipeline/logical-ui/logical-layout.json`.
- **Sidebar Tree Panel**: Displays hierarchical nodes. Expanded relations dynamically fetch child instances.
- **Properties Grid**: Renders individual properties and attributes, implementing input constraint validation.
- **Components Table**: Displays lists of hardware slots, chassis, and rack placements.
- **Map Viewport**: Overlays coordinates, lines, and computes real-time positions.

---

## 2. Data Schema & Persistence Model

To comply with the **Zero-Mocking Mandate (Rule 1.9)**, all spatial and hardware topology data resides in the local SQLite database.

### 2.1 RFC 9179 Spatial Entity Seeding
To support geodetic queries, coordinate translations, and location validation:
1.  **Orbits (`space_0` to `space_99`)**:
    - Child `GeoLocation` instance containing references to coordinate systems.
    - Child `EllipsoidCoordinates` containing actual `latitude`, `longitude`, and `height`.
    - Child `VelocityVector` containing motion components `vNorth`, `vEast`, `vUp` (enabling dynamic position rendering).
2.  **NTT Exchanges (`ntt_exchange_0` to `ntt_exchange_762`)**:
    - Child `GeoLocation` instance.
    - Child `ReferenceFrame` (defining the local spatial anchor).
    - Child `EllipsoidCoordinates` mapped to Japan geodetic coordinates.
3.  **Landing Stations (`cable_landing_0` to `cable_landing_X`)**:
    - Child `GeoLocation` and geodetic coordinate instances.
    - Child `NILocation` mapping interface termination points.

### 2.2 Rack & Chassis Hardware Seeding
To support Rack Infrastructure specifications:
- Select a subset of high-density NTT Exchange nodes.
- Under each exchange, seed a hierarchical hardware stack:
  `NTT Exchange` $\rightarrow$ `RackEntity` (with rack dimensions) $\rightarrow$ `RackPlacement` (slot index) $\rightarrow$ `RackChassis` (vendor model & port counts).

---

## 3. Domain Services Design

We define four central services in the Domain layer to execute the logic of User Stories and Use Cases:

### 3.1 LocationService (`lib/domain/services/location_service.dart`)
- **Backlog Scope**: Epic #8 (Location Hierarchy), Story #10 (Query Location Hierarchy).
- **Core Operations**:
  - `Future<List<InstanceRecord>> getHierarchyForNode(String nodeId)`: Performs tree traversal via SQLite to locate nested coordinate and positioning models.

### 3.2 DispatchService (`lib/domain/services/dispatch_service.dart`)
- **Backlog Scope**: Story #12 (Validate Location for Dispatch), Use Case #28 (Validate Dispatch).
- **Core Operations**:
  - `Future<bool> validateDispatch(String sourceNodeId, String destinationNodeId)`: Verifies geodetic compatibilities, reference frame alignment, and active status, returning validation diagnostics.

### 3.3 VelocityService (`lib/domain/services/velocity_service.dart`)
- **Backlog Scope**: Epic #7 (Geo-Location Grouping), Story #15 (Compute Velocity & Position).
- **Core Operations**:
  - `Position computeCurrentPosition(EllipsoidCoordinates coords, VelocityVector velocity, DateTime time)`: Calculates the shifted coordinates of a moving satellite/orbit node at runtime.
  - `double computeSpeed(VelocityVector velocity)`: Calculates speed magnitude in m/s.
  - `double computeHeading(VelocityVector velocity)`: Calculates azimuth heading in degrees.

### 3.4 RackService (`lib/domain/services/rack_service.dart`)
- **Backlog Scope**: Epic #9 (Rack Infrastructure), Story #17/#18/#20.
- **Core Operations**:
  - `Future<bool> allocateSlot(String rackId, int slotIndex, String chassisId)`: Assigns a chassis node to a rack layout, validating slot overlaps and spatial limits.
