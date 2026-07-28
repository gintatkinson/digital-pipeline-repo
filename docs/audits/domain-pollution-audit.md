# Domain Pollution Audit Report

| File Path | Line Number | Snippet | Decontamination / Refactoring Actions |
|---|---|---|---|
| `implementation_plan.md` | 11 | `1.  All files across the entire repository (including `app_flutter/`, `web_react/`, `.pipeline/`, `....` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/features/feat-002-alternate-systems.md` | 20 | `class ReferenceFrame {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/features/feat-002-alternate-systems.md` | 24 | `ReferenceFrame "1" --> "0..1" AlternateSystem : usesAlternateSystem` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/features/feat-12-yang-compiler.md` | 34 | `"yangFile": "ietf-geo-location.yang"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-hardware-decoupled-persistence-design.md` | 51 | `To avoid the resource overhead of floating-point units (FPUs) in FPGA fabric, latitude, longitude, a...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-hardware-decoupled-persistence-design.md` | 61 | `\| `0x04` \| `GEODETIC_SYSTEM` \| R/W \| Bits 1-0: Coordinate Choice (00=Unconfigured, 01=Ellipsoid,...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-hardware-decoupled-persistence-design.md` | 62 | `\| `0x08` \| `COORD_LAT_X` \| R/W \| Latitude or Cartesian X (32-bit Q16.16 format) \|` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-hardware-decoupled-persistence-design.md` | 63 | `\| `0x0C` \| `COORD_LON_Y` \| R/W \| Longitude or Cartesian Y (32-bit Q16.16 format) \|` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/features/feat-44-downstream-baseline.md` | 63 | `"latitude": 35.6762,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/features/feat-44-downstream-baseline.md` | 64 | `"longitude": 139.6503,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/features/feat-44-downstream-baseline.md` | 106 | `- **When** the seeding manager attempts to write a record with a latitude of 95.0 (exceeding the sta...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/components/property-grid.tsx` | 11 | `latitude: 37.7749,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/components/property-grid.tsx` | 12 | `longitude: -122.4194,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/components/property-grid.tsx` | 24 | `{ key: 'latitude', label: 'Latitude', type: 'double', sectionGroup: 'Geodetic Coordinate Frame', isR...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/components/property-grid.tsx` | 25 | `{ key: 'longitude', label: 'Longitude', type: 'double', sectionGroup: 'Geodetic Coordinate Frame', i...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-65-solution.md` | 56 | `Loaded mandated classes dynamically from tmp/test-verify-react/.pipeline/logical-ui/codebase_rules.j...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-65-solution.md` | 57 | `['RackLocation']` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 51 | `- Child `EllipsoidCoordinates` containing actual `latitude`, `longitude`, and `height`.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 52 | `- Child `VelocityVector` containing motion components `vNorth`, `vEast`, `vUp` (enabling dynamic pos...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 55 | `- Child `ReferenceFrame` (defining the local spatial anchor).` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 56 | `- Child `EllipsoidCoordinates` mapped to Japan geodetic coordinates.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 57 | `3.  **Landing Stations (`cable_landing_0` to `cable_landing_X`)**:` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 65 | ``NTT Exchange` $\rightarrow$ `RackEntity` (with rack dimensions) $\rightarrow$ `RackPlacement` (slot...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 79 | `- **Feature #4**: Ellipsoid Coordinates (fetching latitude, longitude, height coordinates)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 98 | `- `Position computeCurrentPosition(EllipsoidCoordinates coords, VelocityVector velocity, DateTime ti...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 99 | `- `double computeSpeed(VelocityVector velocity)`: Calculates speed magnitude in m/s.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-g1-g12-solution-definition.md` | 100 | `- `double computeHeading(VelocityVector velocity)`: Calculates azimuth heading in degrees.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/uml_frontend_alignment_audit.md` | 99 | `+Real latitude [1]` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/uml_frontend_alignment_audit.md` | 100 | `+Real longitude [1]` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/use-cases/uc-02-local-firebase-emulator.md` | 39 | `1. [SeedingManager](https://github.com/gintatkinson/digital-pipeline-repo/blob/main/docs/features/fe...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-epic-template-mandate-plan.md` | 12 | `3. Download the official `ietf-geo-location@2022-02-11.yang` schema from the standard YangModels Git...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-epic-template-mandate-plan.md` | 28 | `+ReferenceFrame referenceFrame` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-epic-template-mandate-plan.md` | 33 | `class ReferenceFrame {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-epic-template-mandate-plan.md` | 46 | `class EllipsoidLocation {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-epic-template-mandate-plan.md` | 47 | `+Latitude latitude` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-epic-template-mandate-plan.md` | 48 | `+Longitude longitude` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-epic-template-mandate-plan.md` | 61 | `GeoLocation *-- ReferenceFrame` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-epic-template-mandate-plan.md` | 62 | `ReferenceFrame *-- GeodeticSystem` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-epic-template-mandate-plan.md` | 63 | `LocationChoice <\|-- EllipsoidLocation` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/types.ts` | 124 | `export interface RackLocation {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/types.ts` | 134 | `location: RackLocation;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/types.ts` | 137 | `export interface ContainedChassis {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/types.ts` | 141 | `validateSlotOverlap(other: ContainedChassis): boolean;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/types.ts` | 144 | `export interface ChassisContainmentSubsystem {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `web_react/src/types.ts` | 145 | `chassis: ContainedChassis[];` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/upstream_decontamination_baseline_report.md` | 147 | `-            "latitude", "longitude", "trajectory", "orbit",` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/upstream_decontamination_baseline_report.md` | 167 | `-                            forbidden_nodes = {"cartesian", "ellipsoid", "location-choice"}` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/astrodynamics_geodesy_critique.md` | 75 | `Bilinear interpolation is only $\mathcal{C}^0$ continuous. At grid boundaries, the first derivative ...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/astrodynamics_geodesy_critique.md` | 106 | `The geoid undulation formula $h_{ellipsoidal} = H_{MSL} + N$ is applied blindly.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/astrodynamics_geodesy_critique.md` | 111 | `* GPS / GNSS receivers on aircraft or spacecraft report ellipsoidal height ($h$) directly.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/persistence-architecture-blueprint.md` | 100 | `* **Action:** Delete the remaining hardcoded Dart/TS dummy classes (e.g., `Velocity`, `PhysicalAddre...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 18 | `\| 🟡 **Major**    \| [UML-SEM-01]  \| UML Semantics \| `ReferenceFrame` composition (`*--`) destroys...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 20 | `\| 🟡 **Major**    \| [UML-GEO-02]  \| Geodetic Model \| `coordAccuracy` and `heightAccuracy` static ...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 43 | `class ReferenceFrame {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 59 | `class Ellipsoid {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 60 | `+Decimal64 latitude {fractionDigits = 16, range = "-90.0..90.0", units = "degrees"}` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 61 | `+Decimal64 longitude {fractionDigits = 16, range = "-180.0..180.0", units = "degrees"}` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 86 | `GeoLocation "1" --> "1" ReferenceFrame : referenceFrame` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 87 | `ReferenceFrame "1" *-- "1" GeodeticSystem : geodeticSystem` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 92 | `Location <\|-- Ellipsoid` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 95 | `ReferenceFrame --> AstronomicalBody : astronomicalBody` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 100 | `2. **Corrected Lifecycles**: `ReferenceFrame` is associated via direct reference (`-->`) to prevent ...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/adversarial_audit_synthesis.md` | 101 | `3. **No Double-Declaration Redundancy**: Removed object-typed properties (`referenceFrame`, `locatio...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/incident_retrospective.md` | 12 | `- **Mock Use Case Leftover:** A mock Use Case file `docs/use-cases/uc-03-handle-location-expiration....` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 9 | `## 1. Ray-Sphere & Ray-Ellipsoid Intersection Math` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 14 | `While this is computationally simple, it is highly inaccurate for ellipsoidal bodies like Earth (WGS...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 21 | `### 1.2. Exact Ray-Ellipsoid Intersection Formulation` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 22 | `For any planet or moon modeled as a triaxial or biaxial ellipsoid centered at $\mathbf{c}_k$ with se...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 31 | `Substituting the ray into the ellipsoid equation yields:` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 44 | `Because $A > 0$, $t_1 \le t_2$. The line segment $[0, 1]$ intersects the ellipsoid if and only if:` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 179 | `### 6.2. GPU (WGSL) Ray-Ellipsoid Occlusion Code` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 180 | `Integrate this exact, branch-optimized ray-ellipsoid occlusion algorithm into the compute shader:` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 183 | `struct Ellipsoid {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 188 | `// Returns true if ray from start to end is occluded by the ellipsoid` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/communications_rf_laser_critique.md` | 189 | `fn check_ellipsoid_occlusion(start: vec3<f32>, end: vec3<f32>, body: Ellipsoid) -> bool {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-44-solution.md` | 72 | `\| `RackLocation` \| `@realizes UML::RackLocation` \| [types.ts](file:///Users/perkunas/digital-pipe...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-44-solution.md` | 73 | `\| \| `@realizes UML::RackLocation` \| [types.dart](file:///Users/perkunas/digital-pipeline-repo/app...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-44-solution.md` | 76 | `\| `ContainedChassis` \| `@realizes UML::ContainedChassis` \| [types.ts](file:///Users/perkunas/digi...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-44-solution.md` | 77 | `\| \| `@realizes UML::ContainedChassis` \| [types.dart](file:///Users/perkunas/digital-pipeline-repo...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-44-solution.md` | 78 | `\| `ChassisContainmentSubsystem` \| `@realizes UML::ChassisContainmentSubsystem` \| [types.ts](file:...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-44-solution.md` | 79 | `\| \| `@realizes UML::ChassisContainmentSubsystem` \| [types.dart](file:///Users/perkunas/digital-pi...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/pipeline_integration_critique.md` | 125 | `- Therefore, if the schema defines multiple trigger nodes (e.g., `latitude`, `longitude`, `altitude`...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/audits/pipeline_integration_critique.md` | 131 | `B --> C{Contains any of Latitude/Longitude/Altitude/etc.?}` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-backprop-flutter-source-changes.md` | 14 | `- [camera_controller.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/domain/...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/designs/feat-backprop-flutter-source-changes.md` | 24 | `- [globe_camera_drag_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/integr...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 5 | `"latitude": 40.8232978,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 6 | `"longitude": 140.7503634` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 11 | `"latitude": 35.8531756,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 12 | `"longitude": 139.3298997` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 17 | `"latitude": 35.6181937,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 18 | `"longitude": 139.626029` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 23 | `"latitude": 35.6608225,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 24 | `"longitude": 138.5724577` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 29 | `"latitude": 24.3424146,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 30 | `"longitude": 124.1543772` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 35 | `"latitude": 33.5444481,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 36 | `"longitude": 130.4619739` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 41 | `"latitude": 35.6516172,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 42 | `"longitude": 139.7041546` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 47 | `"latitude": 36.6814747,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 48 | `"longitude": 137.2366087` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 53 | `"latitude": 35.7048503,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 54 | `"longitude": 139.5798226` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 59 | `"latitude": 35.7033569,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 60 | `"longitude": 139.5788071` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 65 | `"latitude": 35.4618644,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 66 | `"longitude": 139.5114218` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 71 | `"latitude": 36.6743842,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 72 | `"longitude": 136.8681352` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 77 | `"latitude": 35.6194779,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 78 | `"longitude": 138.4648227` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 83 | `"latitude": 43.0558424,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 84 | `"longitude": 141.3344281` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 89 | `"latitude": 35.961876,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 90 | `"longitude": 140.635629` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 95 | `"latitude": 36.5374547,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 96 | `"longitude": 140.5294505` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 101 | `"latitude": 33.9653364,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 102 | `"longitude": 132.1107071` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 107 | `"latitude": 32.019024,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 108 | `"longitude": 130.194179` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 113 | `"latitude": 35.631017,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 114 | `"longitude": 139.725482` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 119 | `"latitude": 35.683423,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 120 | `"longitude": 139.687889` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 125 | `"latitude": 35.671099,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 126 | `"longitude": 139.757656` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 131 | `"latitude": 35.090013,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 132 | `"longitude": 138.9554277` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 137 | `"latitude": 34.397632,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 138 | `"longitude": 132.456619` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 143 | `"latitude": 33.843701,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 144 | `"longitude": 132.773435` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 149 | `"latitude": 33.887351,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 150 | `"longitude": 130.901483` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 155 | `"latitude": 32.801067,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 156 | `"longitude": 130.718274` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 161 | `"latitude": 35.6666239,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 162 | `"longitude": 138.5691456` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 167 | `"latitude": 34.9883169,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 168 | `"longitude": 133.4605143` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 173 | `"latitude": 36.3186401,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 174 | `"longitude": 139.1978382` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 179 | `"latitude": 35.9383964,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 180 | `"longitude": 140.5466896` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 185 | `"latitude": 35.9856102,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 186 | `"longitude": 140.4895069` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 191 | `"latitude": 33.8911307,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 192 | `"longitude": 130.767468` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 197 | `"latitude": 35.4318097,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 198 | `"longitude": 139.4106549` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 203 | `"latitude": 35.431918,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 204 | `"longitude": 139.4102092` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 209 | `"latitude": 35.43209,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 210 | `"longitude": 139.409513` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 215 | `"latitude": 35.9973876,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 216 | `"longitude": 138.1426388` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 221 | `"latitude": 35.9986399,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 222 | `"longitude": 138.1431585` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 227 | `"latitude": 35.703706,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 228 | `"longitude": 139.5606279` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 233 | `"latitude": 35.4993051,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 234 | `"longitude": 135.7461386` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 239 | `"latitude": 34.9502825,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 240 | `"longitude": 138.3548617` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 245 | `"latitude": 34.9585307,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 246 | `"longitude": 138.3532068` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 251 | `"latitude": 39.2662115,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 252 | `"longitude": 141.8482356` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 257 | `"latitude": 35.065998,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 258 | `"longitude": 138.2874892` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 263 | `"latitude": 35.7354408,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 264 | `"longitude": 139.787435` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 269 | `"latitude": 35.7378366,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 270 | `"longitude": 139.327122` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 275 | `"latitude": 26.438728,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 276 | `"longitude": 127.8021718` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 281 | `"latitude": 35.1447925,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 282 | `"longitude": 136.9000811` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 287 | `"latitude": 35.6872668,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 288 | `"longitude": 139.5971731` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 293 | `"latitude": 34.6874147,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 294 | `"longitude": 135.5507858` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 299 | `"latitude": 35.669079,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 300 | `"longitude": 139.725426` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 305 | `"latitude": 35.5872215,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 306 | `"longitude": 139.7315776` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 311 | `"latitude": 36.131513,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 312 | `"longitude": 140.0838561` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 317 | `"latitude": 35.9024038,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 318 | `"longitude": 139.5185908` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 323 | `"latitude": 35.4549513,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 324 | `"longitude": 139.6301061` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 329 | `"latitude": 35.7026905,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 330 | `"longitude": 139.7761707` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 335 | `"latitude": 35.465288,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 336 | `"longitude": 139.6200662` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 341 | `"latitude": 35.6905033,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 342 | `"longitude": 139.7041382` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 347 | `"latitude": 34.703049,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 348 | `"longitude": 135.546082` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 353 | `"latitude": 34.909868,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 354 | `"longitude": 137.4208282` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 359 | `"latitude": 38.3176959,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 360 | `"longitude": 140.6327578` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 365 | `"latitude": 35.5865433,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 366 | `"longitude": 139.7319506` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 371 | `"latitude": 35.6780082,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 372 | `"longitude": 138.5544683` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 377 | `"latitude": 35.61449,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 378 | `"longitude": 139.627532` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 383 | `"latitude": 43.2011119,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 384 | `"longitude": 141.7664742` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 389 | `"latitude": 35.6978016,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 390 | `"longitude": 139.7603133` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 395 | `"latitude": 35.6836682,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 396 | `"longitude": 139.5596113` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 401 | `"latitude": 38.2698868,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 402 | `"longitude": 140.8739382` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 407 | `"latitude": 34.6720542,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 408 | `"longitude": 133.9113646` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 413 | `"latitude": 35.6885077,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 414 | `"longitude": 139.5669273` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 419 | `"latitude": 34.681893,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 420 | `"longitude": 135.824998` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 425 | `"latitude": 34.7229371,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 426 | `"longitude": 135.5497665` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 431 | `"latitude": 34.6982087,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 432 | `"longitude": 135.5033866` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 437 | `"latitude": 41.8759359,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 438 | `"longitude": 140.9465037` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 443 | `"latitude": 41.7733707,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 444 | `"longitude": 140.7395509` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 449 | `"latitude": 41.7889742,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 450 | `"longitude": 140.7620157` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 455 | `"latitude": 37.4788242,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 456 | `"longitude": 139.9827588` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 461 | `"latitude": 35.687556,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 462 | `"longitude": 139.5687762` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 467 | `"latitude": 35.6878418,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 468 | `"longitude": 139.5689773` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 473 | `"latitude": 35.6318985,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 474 | `"longitude": 139.7254729` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 479 | `"latitude": 34.9707804,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 480 | `"longitude": 134.8091935` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 485 | `"latitude": 35.583326,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 486 | `"longitude": 139.658096` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 491 | `"latitude": 35.6943215,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 492 | `"longitude": 139.5613669` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 497 | `"latitude": 33.6366968,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 498 | `"longitude": 130.4441284` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 503 | `"latitude": 33.6487306,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 504 | `"longitude": 130.4254193` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 509 | `"latitude": 35.3692143,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 510 | `"longitude": 139.5639146` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 515 | `"latitude": 34.665264,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 516 | `"longitude": 135.496332` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 521 | `"latitude": 43.081131,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 522 | `"longitude": 141.307631` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 527 | `"latitude": 43.081304,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 528 | `"longitude": 141.306837` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 533 | `"latitude": 42.3444724,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 534 | `"longitude": 141.0301402` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 539 | `"latitude": 36.2373376,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 540 | `"longitude": 137.9699587` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 545 | `"latitude": 35.6495671,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 546 | `"longitude": 138.7212006` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 551 | `"latitude": 33.6896934,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 552 | `"longitude": 130.4079061` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 557 | `"latitude": 39.069846,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 558 | `"longitude": 141.7195817` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 563 | `"latitude": 35.7128536,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 564 | `"longitude": 139.7920868` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 569 | `"latitude": 35.6498834,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 570 | `"longitude": 139.9036642` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 575 | `"latitude": 35.6508004,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 576 | `"longitude": 139.5884369` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 581 | `"latitude": 34.2033698,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 582 | `"longitude": 133.110778` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 587 | `"latitude": 33.8364233,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 588 | `"longitude": 132.7377185` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 593 | `"latitude": 34.816145,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 594 | `"longitude": 135.648006` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 599 | `"latitude": 35.4435519,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 600 | `"longitude": 139.6427383` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 605 | `"latitude": 43.161399,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 606 | `"longitude": 141.413348` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 611 | `"latitude": 43.0662656,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 612 | `"longitude": 141.347764` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 617 | `"latitude": 35.6505907,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 618 | `"longitude": 139.5885565` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 623 | `"latitude": 43.074893,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 624 | `"longitude": 141.296016` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 629 | `"latitude": 43.067643,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 630 | `"longitude": 141.274229` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 635 | `"latitude": 34.4649273,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 636 | `"longitude": 135.737724` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 641 | `"latitude": 36.3774128,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 642 | `"longitude": 140.4694164` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 647 | `"latitude": 35.741877,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 648 | `"longitude": 136.947447` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 653 | `"latitude": 35.445958,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 654 | `"longitude": 137.019196` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 659 | `"latitude": 37.422941,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 660 | `"longitude": 140.3516437` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 665 | `"latitude": 35.707605,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 666 | `"longitude": 139.772868` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 671 | `"latitude": 35.9528489,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 672 | `"longitude": 139.6664989` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 677 | `"latitude": 34.6611737,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 678 | `"longitude": 135.5576237` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 683 | `"latitude": 34.6895639,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 684 | `"longitude": 135.526578` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 689 | `"latitude": 38.6015143,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 690 | `"longitude": 141.0223522` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 695 | `"latitude": 35.7837052,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 696 | `"longitude": 139.0299334` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 701 | `"latitude": 39.4003926,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 702 | `"longitude": 141.9177101` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 707 | `"latitude": 34.3143649,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 708 | `"longitude": 135.609275` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 713 | `"latitude": 34.3131599,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 714 | `"longitude": 135.6087609` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 719 | `"latitude": 34.702675,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 720 | `"longitude": 135.5624` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 725 | `"latitude": 34.702892,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 726 | `"longitude": 135.564727` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 731 | `"latitude": 34.70305,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 732 | `"longitude": 135.569342` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 737 | `"latitude": 34.6632082,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 738 | `"longitude": 133.9264179` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 743 | `"latitude": 34.8912452,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 744 | `"longitude": 139.036261` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 749 | `"latitude": 34.6629743,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 750 | `"longitude": 133.9260612` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 755 | `"latitude": 34.6632333,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 756 | `"longitude": 133.9260638` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 761 | `"latitude": 35.5420691,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 762 | `"longitude": 134.8171682` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 767 | `"latitude": 34.6983542,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 768 | `"longitude": 135.5600928` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 773 | `"latitude": 35.022963,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 774 | `"longitude": 137.0883736` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 779 | `"latitude": 35.627857,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 780 | `"longitude": 139.448368` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 785 | `"latitude": 35.6231045,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 786 | `"longitude": 139.4443515` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 791 | `"latitude": 35.62203,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 792 | `"longitude": 139.448439` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 797 | `"latitude": 35.621301,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 798 | `"longitude": 139.447919` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 803 | `"latitude": 35.621736,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 804 | `"longitude": 139.454109` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 809 | `"latitude": 35.6207542,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 810 | `"longitude": 139.453825` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 815 | `"latitude": 36.3177156,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 816 | `"longitude": 139.8075803` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 821 | `"latitude": 35.0355248,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 822 | `"longitude": 137.0793849` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 827 | `"latitude": 34.6394724,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 828 | `"longitude": 135.538722` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 833 | `"latitude": 35.5873824,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 834 | `"longitude": 139.7318651` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 839 | `"latitude": 36.8326542,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 840 | `"longitude": 139.7165299` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 845 | `"latitude": 36.8324524,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 846 | `"longitude": 139.716589` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 851 | `"latitude": 34.706748,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 852 | `"longitude": 135.565527` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 857 | `"latitude": 40.587143,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 858 | `"longitude": 140.399528` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 863 | `"latitude": 34.8835811,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 864 | `"longitude": 136.5848024` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 869 | `"latitude": 34.8809094,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 870 | `"longitude": 136.5851254` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 875 | `"latitude": 34.7705973,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 876 | `"longitude": 138.0142349` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 881 | `"latitude": 35.635247,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 882 | `"longitude": 139.4434658` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 887 | `"latitude": 32.5817171,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 888 | `"longitude": 131.6670691` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 893 | `"latitude": 34.9571806,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 894 | `"longitude": 137.1671518` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 899 | `"latitude": 36.3777276,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 900 | `"longitude": 139.7341856` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 905 | `"latitude": 36.3778023,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 906 | `"longitude": 139.7341629` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 911 | `"latitude": 43.2302432,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 912 | `"longitude": 143.2931095` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 917 | `"latitude": 34.7030391,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 918 | `"longitude": 135.6347653` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 923 | `"latitude": 35.7223011,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 924 | `"longitude": 139.6742332` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 929 | `"latitude": 33.748058,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 930 | `"longitude": 129.689912` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 935 | `"latitude": 38.2426035,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 936 | `"longitude": 140.9089403` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 941 | `"latitude": 38.2759322,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 942 | `"longitude": 140.8678459` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 947 | `"latitude": 35.6312558,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 948 | `"longitude": 139.7256288` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 953 | `"latitude": 38.2542392,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 954 | `"longitude": 140.8974716` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 959 | `"latitude": 38.249536,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 960 | `"longitude": 140.9025306` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 965 | `"latitude": 38.249186,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 966 | `"longitude": 140.9096622` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 971 | `"latitude": 38.2455736,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 972 | `"longitude": 140.9095308` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 977 | `"latitude": 38.3081053,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 978 | `"longitude": 140.8309344` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 983 | `"latitude": 38.046232,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 984 | `"longitude": 140.7185234` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 989 | `"latitude": 38.2517041,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 990 | `"longitude": 140.9186167` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 995 | `"latitude": 38.1946404,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 996 | `"longitude": 140.8826319` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1001 | `"latitude": 37.8649754,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1002 | `"longitude": 139.1103323` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1007 | `"latitude": 37.8646959,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1008 | `"longitude": 139.1107749` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1013 | `"latitude": 34.8665155,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1014 | `"longitude": 137.0968657` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1019 | `"latitude": 35.7551652,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1020 | `"longitude": 139.6494327` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1025 | `"latitude": 38.2538806,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1026 | `"longitude": 140.9029521` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1031 | `"latitude": 38.2398608,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1032 | `"longitude": 140.869198` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1037 | `"latitude": 34.6853434,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1038 | `"longitude": 135.506705` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1043 | `"latitude": 32.4631506,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1044 | `"longitude": 139.7605581` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1049 | `"latitude": 34.8881105,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1050 | `"longitude": 135.8030678` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1055 | `"latitude": 43.059672,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1056 | `"longitude": 141.335903` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1061 | `"latitude": 38.2610967,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1062 | `"longitude": 140.8960947` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1067 | `"latitude": 38.2536407,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1068 | `"longitude": 140.881987` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1073 | `"latitude": 38.2509821,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1074 | `"longitude": 140.3362594` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1079 | `"latitude": 38.2500152,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1080 | `"longitude": 140.3096648` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1085 | `"latitude": 38.7594893,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1086 | `"longitude": 140.3030128` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1091 | `"latitude": 34.6992466,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1092 | `"longitude": 135.4979477` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1097 | `"latitude": 34.6999283,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1098 | `"longitude": 135.4982139` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1103 | `"latitude": 34.6994549,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1104 | `"longitude": 135.4990761` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1109 | `"latitude": 34.6998568,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1110 | `"longitude": 135.4995045` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1115 | `"latitude": 35.692197,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1116 | `"longitude": 139.7402319` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1121 | `"latitude": 35.6931016,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1122 | `"longitude": 139.7432137` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1127 | `"latitude": 35.6868165,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1128 | `"longitude": 139.7417417` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1133 | `"latitude": 35.7033848,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1134 | `"longitude": 139.747336` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1139 | `"latitude": 35.0915594,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1140 | `"longitude": 138.9556263` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1145 | `"latitude": 35.0432895,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1146 | `"longitude": 137.0383507` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1151 | `"latitude": 34.989451,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1152 | `"longitude": 136.9998657` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1157 | `"latitude": 34.6987675,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1158 | `"longitude": 135.4975385` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1163 | `"latitude": 38.0491958,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1164 | `"longitude": 140.1633021` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1169 | `"latitude": 35.733025,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1170 | `"longitude": 139.716576` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1175 | `"latitude": 35.6911426,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1176 | `"longitude": 139.743325` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1181 | `"latitude": 35.7274913,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1182 | `"longitude": 139.7164829` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1187 | `"latitude": 35.7068932,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1188 | `"longitude": 139.7728638` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1193 | `"latitude": 35.6734397,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1194 | `"longitude": 139.7269513` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1199 | `"latitude": 43.7541794,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1200 | `"longitude": 142.3987172` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1205 | `"latitude": 38.2606643,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1206 | `"longitude": 140.9258492` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1211 | `"latitude": 35.6927208,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1212 | `"longitude": 139.7413779` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1217 | `"latitude": 35.0975631,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1218 | `"longitude": 137.0522347` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1223 | `"latitude": 35.2254068,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1224 | `"longitude": 139.6633476` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1229 | `"latitude": 38.6171219,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1230 | `"longitude": 139.601807` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1235 | `"latitude": 38.6171696,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1236 | `"longitude": 139.6024045` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1241 | `"latitude": 34.9796985,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1242 | `"longitude": 138.9452187` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1247 | `"latitude": 34.7047733,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1248 | `"longitude": 135.4989987` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1253 | `"latitude": 35.8304856,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1254 | `"longitude": 139.5620996` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1259 | `"latitude": 34.7398302,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1260 | `"longitude": 136.8712352` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1265 | `"latitude": 24.348551,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1266 | `"longitude": 124.1577972` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1271 | `"latitude": 38.2694404,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1272 | `"longitude": 140.893314` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1277 | `"latitude": 35.6908802,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1278 | `"longitude": 139.7842408` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1283 | `"latitude": 34.6528424,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1284 | `"longitude": 134.0272067` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1289 | `"latitude": 34.780384,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1290 | `"longitude": 137.7386209` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1295 | `"latitude": 35.8120991,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1296 | `"longitude": 139.3620811` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1301 | `"latitude": 36.9560219,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1302 | `"longitude": 137.5584725` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1307 | `"latitude": 35.7050543,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1308 | `"longitude": 139.7544671` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1313 | `"latitude": 34.7420517,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1314 | `"longitude": 135.5464796` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1319 | `"latitude": 34.7443685,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1320 | `"longitude": 135.5429958` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1325 | `"latitude": 34.5305377,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1326 | `"longitude": 135.4658581` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1331 | `"latitude": 36.0951704,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1332 | `"longitude": 133.0950308` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1337 | `"latitude": 36.6896894,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1338 | `"longitude": 137.2125044` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1343 | `"latitude": 35.6973638,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1344 | `"longitude": 139.813326` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1349 | `"latitude": 35.7934278,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1350 | `"longitude": 139.7970189` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1355 | `"latitude": 35.7510811,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1356 | `"longitude": 139.5942139` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1361 | `"latitude": 35.5178063,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1362 | `"longitude": 139.4731849` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1367 | `"latitude": 37.1649062,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1368 | `"longitude": 138.2377186` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1373 | `"latitude": 35.3785803,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1374 | `"longitude": 139.918189` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1379 | `"latitude": 35.4418378,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1380 | `"longitude": 136.7602386` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1385 | `"latitude": 35.65787,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1386 | `"longitude": 139.7495878` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1391 | `"latitude": 36.6990026,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1392 | `"longitude": 137.8642206` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1397 | `"latitude": 36.7120457,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1398 | `"longitude": 137.1024221` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1403 | `"latitude": 37.8481981,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1404 | `"longitude": 136.9162818` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1409 | `"latitude": 35.6896966,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1410 | `"longitude": 139.785016` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1415 | `"latitude": 35.7331255,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1416 | `"longitude": 139.7101992` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1421 | `"latitude": 35.6946225,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1422 | `"longitude": 139.7518292` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1427 | `"latitude": 35.6966853,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1428 | `"longitude": 139.8945566` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1433 | `"latitude": 34.7376965,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1434 | `"longitude": 136.5177219` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1439 | `"latitude": 34.500848,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1440 | `"longitude": 135.5989229` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1445 | `"latitude": 36.7451291,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1446 | `"longitude": 137.1895178` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1451 | `"latitude": 34.7046967,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1452 | `"longitude": 135.5030816` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1457 | `"latitude": 36.3687273,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1458 | `"longitude": 140.3589946` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1463 | `"latitude": 38.2209819,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1464 | `"longitude": 139.4738401` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1469 | `"latitude": 34.3970515,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1470 | `"longitude": 133.2007559` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1475 | `"latitude": 40.5146357,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1476 | `"longitude": 141.4996037` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1481 | `"latitude": 40.5146819,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1482 | `"longitude": 141.4999586` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1487 | `"latitude": 35.4135253,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1488 | `"longitude": 136.737327` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1493 | `"latitude": 34.8446152,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1494 | `"longitude": 135.5813454` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1499 | `"latitude": 34.7332293,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1500 | `"longitude": 136.5159589` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1505 | `"latitude": 34.5477244,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1506 | `"longitude": 136.9780742` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1511 | `"latitude": 35.429548,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1512 | `"longitude": 139.6445276` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1517 | `"latitude": 35.6857047,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1518 | `"longitude": 139.7769959` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1523 | `"latitude": 34.8929481,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1524 | `"longitude": 133.6825804` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1529 | `"latitude": 35.6897399,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1530 | `"longitude": 139.7665734` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1535 | `"latitude": 35.6828186,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1536 | `"longitude": 139.7725546` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1541 | `"latitude": 36.3792662,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1542 | `"longitude": 140.4683509` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1547 | `"latitude": 36.3792856,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1548 | `"longitude": 140.4685548` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1553 | `"latitude": 35.3781095,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1554 | `"longitude": 139.9185303` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1559 | `"latitude": 35.3780592,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1560 | `"longitude": 139.9186456` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1565 | `"latitude": 35.6557646,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1566 | `"longitude": 139.680962` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1571 | `"latitude": 35.615105,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1572 | `"longitude": 139.6759493` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1577 | `"latitude": 33.5822012,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1578 | `"longitude": 130.2644689` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1583 | `"latitude": 33.5443271,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1584 | `"longitude": 130.3146924` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1589 | `"latitude": 38.2529837,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1590 | `"longitude": 140.8817666` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1595 | `"latitude": 35.3558576,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1596 | `"longitude": 137.0926063` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1601 | `"latitude": 34.5498165,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1602 | `"longitude": 135.513344` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1607 | `"latitude": 34.5475185,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1608 | `"longitude": 135.5143447` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1613 | `"latitude": 38.2582319,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1614 | `"longitude": 140.8708747` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1619 | `"latitude": 38.258302,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1620 | `"longitude": 140.8710161` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1625 | `"latitude": 34.5659446,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1626 | `"longitude": 135.5236751` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1631 | `"latitude": 35.6836647,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1632 | `"longitude": 139.5589869` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1637 | `"latitude": 35.6836673,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1638 | `"longitude": 139.5588956` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1643 | `"latitude": 35.7021128,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1644 | `"longitude": 139.5767357` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1649 | `"latitude": 35.6494055,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1650 | `"longitude": 139.9047687` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1655 | `"latitude": 35.6500921,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1656 | `"longitude": 139.9037571` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1661 | `"latitude": 35.7021209,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1662 | `"longitude": 139.5611212` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1667 | `"latitude": 35.681596,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1668 | `"longitude": 139.5535984` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1673 | `"latitude": 34.5714557,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1674 | `"longitude": 135.6178166` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1679 | `"latitude": 35.6835115,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1680 | `"longitude": 139.7841021` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1685 | `"latitude": 35.6835038,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1686 | `"longitude": 139.78356` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1691 | `"latitude": 38.239925,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1692 | `"longitude": 140.851627` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1697 | `"latitude": 35.7088262,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1698 | `"longitude": 139.7955202` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1703 | `"latitude": 35.7094115,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1704 | `"longitude": 139.791463` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1709 | `"latitude": 35.6849511,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1710 | `"longitude": 139.5832065` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1715 | `"latitude": 35.6832426,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1716 | `"longitude": 139.5633488` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1721 | `"latitude": 35.6995616,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1722 | `"longitude": 139.5742849` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1727 | `"latitude": 35.699267,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1728 | `"longitude": 139.5768383` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1733 | `"latitude": 35.6850459,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1734 | `"longitude": 139.5583257` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1739 | `"latitude": 38.2407413,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1740 | `"longitude": 140.8597844` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1745 | `"latitude": 35.7226754,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1746 | `"longitude": 139.7031563` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1751 | `"latitude": 38.0583552,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1752 | `"longitude": 140.7728404` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1757 | `"latitude": 34.6697826,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1758 | `"longitude": 133.9119539` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1763 | `"latitude": 32.460665,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1764 | `"longitude": 131.1519286` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1769 | `"latitude": 35.736589,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1770 | `"longitude": 139.8800715` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1775 | `"latitude": 35.6935142,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1776 | `"longitude": 139.5613895` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1781 | `"latitude": 35.6695405,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1782 | `"longitude": 139.5558111` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1787 | `"latitude": 36.394964,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1788 | `"longitude": 140.5321634` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1793 | `"latitude": 36.3947351,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1794 | `"longitude": 140.5321205` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1799 | `"latitude": 35.7179341,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1800 | `"longitude": 139.5667519` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1805 | `"latitude": 35.4129092,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1806 | `"longitude": 134.2536703` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1811 | `"latitude": 34.4007242,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1812 | `"longitude": 132.4615317` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1817 | `"latitude": 38.227668,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1818 | `"longitude": 140.8951263` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1823 | `"latitude": 43.056442,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1824 | `"longitude": 141.33425` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1829 | `"latitude": 34.5468595,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1830 | `"longitude": 135.5183754` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1835 | `"latitude": 34.5594958,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1836 | `"longitude": 135.5153317` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1841 | `"latitude": 34.5413345,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1842 | `"longitude": 133.7738168` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1847 | `"latitude": 34.9169703,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1848 | `"longitude": 135.6872047` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1853 | `"latitude": 34.5653541,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1854 | `"longitude": 135.5173854` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1859 | `"latitude": 34.5638341,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1860 | `"longitude": 135.5244332` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1865 | `"latitude": 34.5774892,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1866 | `"longitude": 135.4764334` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1871 | `"latitude": 34.5785612,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1872 | `"longitude": 135.4744773` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1877 | `"latitude": 34.5873672,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1878 | `"longitude": 135.4823384` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1883 | `"latitude": 34.5849995,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1884 | `"longitude": 135.4801314` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1889 | `"latitude": 34.583037,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1890 | `"longitude": 135.4783066` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1895 | `"latitude": 38.2400306,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1896 | `"longitude": 140.851439` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1901 | `"latitude": 38.2540529,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1902 | `"longitude": 140.8817363` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1907 | `"latitude": 37.4781371,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1908 | `"longitude": 138.9948782` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1913 | `"latitude": 38.1114885,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1914 | `"longitude": 140.8703928` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1919 | `"latitude": 35.4382323,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1920 | `"longitude": 139.3078558` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1925 | `"latitude": 35.6239759,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1926 | `"longitude": 135.0627154` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1931 | `"latitude": 35.917722,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1932 | `"longitude": 139.7820863` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1937 | `"latitude": 35.9179131,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1938 | `"longitude": 139.7822741` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1943 | `"latitude": 38.1953698,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1944 | `"longitude": 140.9203161` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1949 | `"latitude": 34.5734445,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1950 | `"longitude": 135.4720626` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1955 | `"latitude": 34.5746532,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1956 | `"longitude": 135.4729912` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1961 | `"latitude": 34.5808325,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1962 | `"longitude": 135.4787052` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1967 | `"latitude": 35.605239,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1968 | `"longitude": 139.5068262` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1973 | `"latitude": 43.0454044,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1974 | `"longitude": 141.3800364` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1979 | `"latitude": 38.2206846,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1980 | `"longitude": 140.8106292` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1985 | `"latitude": 35.9370958,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1986 | `"longitude": 139.8189479` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1991 | `"latitude": 35.9378971,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1992 | `"longitude": 139.8186207` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1997 | `"latitude": 36.7306227,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 1998 | `"longitude": 137.1836122` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2003 | `"latitude": 38.2738924,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2004 | `"longitude": 140.7642756` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2009 | `"latitude": 38.2754543,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2010 | `"longitude": 140.7499637` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2015 | `"latitude": 35.7183325,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2016 | `"longitude": 139.5625404` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2021 | `"latitude": 35.7189486,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2022 | `"longitude": 139.562563` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2027 | `"latitude": 39.717334,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2028 | `"longitude": 141.1424017` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2033 | `"latitude": 38.0492491,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2034 | `"longitude": 140.7342146` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2039 | `"latitude": 34.5407545,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2040 | `"longitude": 135.5206748` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2045 | `"latitude": 38.0048378,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2046 | `"longitude": 140.6206456` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2051 | `"latitude": 37.9951812,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2052 | `"longitude": 140.4416469` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2057 | `"latitude": 38.1002033,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2058 | `"longitude": 140.8562953` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2063 | `"latitude": 38.1191978,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2064 | `"longitude": 140.8734462` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2069 | `"latitude": 38.1028108,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2070 | `"longitude": 140.9121636` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2075 | `"latitude": 38.1240575,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2076 | `"longitude": 140.9021693` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2081 | `"latitude": 35.6269208,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2082 | `"longitude": 139.5731826` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2087 | `"latitude": 38.3570085,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2088 | `"longitude": 140.8547299` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2093 | `"latitude": 34.5818373,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2094 | `"longitude": 135.5089142` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2099 | `"latitude": 38.6881385,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2100 | `"longitude": 141.194612` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2105 | `"latitude": 34.3252161,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2106 | `"longitude": 134.0446629` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2111 | `"latitude": 34.5597242,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2112 | `"longitude": 135.4723619` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2117 | `"latitude": 38.2577154,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2118 | `"longitude": 140.8703943` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2123 | `"latitude": 38.2521045,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2124 | `"longitude": 140.8814242` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2129 | `"latitude": 34.5805485,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2130 | `"longitude": 135.463541` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2135 | `"latitude": 33.3595692,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2136 | `"longitude": 130.7818495` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2141 | `"latitude": 34.5551746,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2142 | `"longitude": 135.5059118` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2147 | `"latitude": 38.2389564,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2148 | `"longitude": 140.9027237` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2153 | `"latitude": 33.3567745,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2154 | `"longitude": 130.7544662` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2159 | `"latitude": 33.3397478,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2160 | `"longitude": 130.7601558` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2165 | `"latitude": 33.3534135,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2166 | `"longitude": 130.7347649` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2171 | `"latitude": 38.8425202,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2172 | `"longitude": 141.5799934` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2177 | `"latitude": 38.2716127,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2178 | `"longitude": 140.7672424` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2183 | `"latitude": 40.8235329,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2184 | `"longitude": 140.7513155` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2189 | `"latitude": 40.8232884,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2190 | `"longitude": 140.7511592` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2195 | `"latitude": 40.8233582,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2196 | `"longitude": 140.7511645` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2201 | `"latitude": 40.8234864,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2202 | `"longitude": 140.7513315` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2207 | `"latitude": 40.8234165,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2208 | `"longitude": 140.7503626` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2213 | `"latitude": 34.8364834,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2214 | `"longitude": 137.4025072` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2219 | `"latitude": 38.2494991,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2220 | `"longitude": 140.8976276` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2225 | `"latitude": 43.0639876,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2226 | `"longitude": 141.3307515` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2231 | `"latitude": 38.2442535,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2232 | `"longitude": 140.8953922` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2237 | `"latitude": 35.6868409,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2238 | `"longitude": 139.7666525` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2243 | `"latitude": 35.6877341,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2244 | `"longitude": 139.7667901` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2249 | `"latitude": 35.6873579,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2250 | `"longitude": 139.7674357` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2255 | `"latitude": 35.6858213,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2256 | `"longitude": 139.7678451` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2261 | `"latitude": 35.685894,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2262 | `"longitude": 139.767112` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2267 | `"latitude": 35.6856511,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2268 | `"longitude": 139.7637584` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2273 | `"latitude": 38.2487409,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2274 | `"longitude": 140.9152589` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2279 | `"latitude": 38.29825,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2280 | `"longitude": 140.6813373` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2285 | `"latitude": 38.292916,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2286 | `"longitude": 140.6867566` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2291 | `"latitude": 38.4436423,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2292 | `"longitude": 141.2681052` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2297 | `"latitude": 35.6309711,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2298 | `"longitude": 139.7263178` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2303 | `"latitude": 34.9888072,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2304 | `"longitude": 139.8623046` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2309 | `"latitude": 34.9892969,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2310 | `"longitude": 139.8624902` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2315 | `"latitude": 35.7769657,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2316 | `"longitude": 140.2876411` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2321 | `"latitude": 35.7770767,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2322 | `"longitude": 140.2878557` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2327 | `"latitude": 34.1673104,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2328 | `"longitude": 131.4615667` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2333 | `"latitude": 34.1678937,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2334 | `"longitude": 131.4622166` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2339 | `"latitude": 34.6791577,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2340 | `"longitude": 132.5321542` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2345 | `"latitude": 34.679041,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2346 | `"longitude": 132.5323042` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2351 | `"latitude": 34.8050152,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2352 | `"longitude": 132.8552967` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2357 | `"latitude": 34.8050147,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2358 | `"longitude": 132.8553118` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2363 | `"latitude": 34.8053998,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2364 | `"longitude": 132.8543216` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2369 | `"latitude": 34.8053665,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2370 | `"longitude": 132.8543549` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2375 | `"latitude": 34.8050832,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2376 | `"longitude": 132.8550549` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2381 | `"latitude": 35.7338406,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2382 | `"longitude": 140.8323455` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2387 | `"latitude": 35.7337056,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2388 | `"longitude": 140.832198` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2393 | `"latitude": 35.8643775,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2394 | `"longitude": 139.6700817` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2399 | `"latitude": 33.9868212,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2400 | `"longitude": 131.4397614` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2405 | `"latitude": 33.9950036,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2406 | `"longitude": 131.432467` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2411 | `"latitude": 35.5104942,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2412 | `"longitude": 137.8359448` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2417 | `"latitude": 34.1663896,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2418 | `"longitude": 131.4358035` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2423 | `"latitude": 35.0761774,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2424 | `"longitude": 138.9422966` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2429 | `"latitude": 33.5234784,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2430 | `"longitude": 130.3839788` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2435 | `"latitude": 35.7104001,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2436 | `"longitude": 139.8739761` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2441 | `"latitude": 35.7100995,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2442 | `"longitude": 139.8740512` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2447 | `"latitude": 36.6461075,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2448 | `"longitude": 138.1783701` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2453 | `"latitude": 38.2768881,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2454 | `"longitude": 140.9239191` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2459 | `"latitude": 34.5581037,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2460 | `"longitude": 135.4712263` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2465 | `"latitude": 35.5584106,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2466 | `"longitude": 140.4072261` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2471 | `"latitude": 34.5580939,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2472 | `"longitude": 135.5085701` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2477 | `"latitude": 34.9893072,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2478 | `"longitude": 139.8624936` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2483 | `"latitude": 34.9888011,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2484 | `"longitude": 139.8623041` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2489 | `"latitude": 35.39857,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2490 | `"longitude": 139.5325889` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2495 | `"latitude": 35.461693,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2496 | `"longitude": 139.512063` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2501 | `"latitude": 35.4757596,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2502 | `"longitude": 139.5723384` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2507 | `"latitude": 35.530251,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2508 | `"longitude": 139.500037` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2513 | `"latitude": 34.6103409,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2514 | `"longitude": 133.863027` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2519 | `"latitude": 34.6615307,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2520 | `"longitude": 133.926725` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2525 | `"latitude": 34.6040588,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2526 | `"longitude": 133.8274584` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2531 | `"latitude": 38.1726046,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2532 | `"longitude": 140.8907109` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2537 | `"latitude": 33.5163729,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2538 | `"longitude": 130.3760366` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2543 | `"latitude": 40.8224419,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2544 | `"longitude": 140.7504602` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2549 | `"latitude": 40.8225566,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2550 | `"longitude": 140.7502502` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2555 | `"latitude": 40.8224499,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2556 | `"longitude": 140.7503595` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2561 | `"latitude": 40.8225681,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2562 | `"longitude": 140.7503588` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2567 | `"latitude": 38.2616682,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2568 | `"longitude": 140.9004403` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2573 | `"latitude": 34.6988676,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2574 | `"longitude": 135.530052` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2579 | `"latitude": 26.692359,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2580 | `"longitude": 127.9281397` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2585 | `"latitude": 26.7103791,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2586 | `"longitude": 127.8025288` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2591 | `"latitude": 34.6933776,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2592 | `"longitude": 134.2047203` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2597 | `"latitude": 34.6467613,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2598 | `"longitude": 135.5109779` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2603 | `"latitude": 34.7387087,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2604 | `"longitude": 135.5415884` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2609 | `"latitude": 34.7377114,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2610 | `"longitude": 135.5418679` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2615 | `"latitude": 34.7390559,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2616 | `"longitude": 135.5401227` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2621 | `"latitude": 43.7701559,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2622 | `"longitude": 142.3630012` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2627 | `"latitude": 34.7432518,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2628 | `"longitude": 135.5360203` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2633 | `"latitude": 34.7499347,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2634 | `"longitude": 135.5354197` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2639 | `"latitude": 34.7553046,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2640 | `"longitude": 135.5511005` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2645 | `"latitude": 34.7516624,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2646 | `"longitude": 135.5487072` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2651 | `"latitude": 34.7442983,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2652 | `"longitude": 135.5265008` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2657 | `"latitude": 34.7478291,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2658 | `"longitude": 135.5278998` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2663 | `"latitude": 34.7491146,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2664 | `"longitude": 135.5295123` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2669 | `"latitude": 34.756636,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2670 | `"longitude": 135.545477` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2675 | `"latitude": 34.7574622,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2676 | `"longitude": 135.534742` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2681 | `"latitude": 34.7284964,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2682 | `"longitude": 135.5422947` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2687 | `"latitude": 34.7280686,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2688 | `"longitude": 135.5382856` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2693 | `"latitude": 34.7262528,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2694 | `"longitude": 135.5350415` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2699 | `"latitude": 34.722409,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2700 | `"longitude": 135.538451` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2705 | `"latitude": 34.7236766,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2706 | `"longitude": 135.5384653` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2711 | `"latitude": 34.7259575,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2712 | `"longitude": 135.5447811` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2717 | `"latitude": 36.6490069,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2718 | `"longitude": 138.1855847` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2723 | `"latitude": 34.7175628,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2724 | `"longitude": 135.5381126` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2729 | `"latitude": 34.7167117,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2730 | `"longitude": 135.5380577` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2735 | `"latitude": 34.7183847,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2736 | `"longitude": 135.538203` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2741 | `"latitude": 34.715705,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2742 | `"longitude": 135.5402157` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2747 | `"latitude": 34.7195279,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2748 | `"longitude": 135.5406151` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2753 | `"latitude": 34.719338,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2754 | `"longitude": 135.5441877` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2759 | `"latitude": 34.7181421,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2760 | `"longitude": 135.5487036` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2765 | `"latitude": 34.1689587,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2766 | `"longitude": 131.0314372` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2771 | `"latitude": 34.2305028,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2772 | `"longitude": 131.366975` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2777 | `"latitude": 34.7166811,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2778 | `"longitude": 135.5560988` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2783 | `"latitude": 35.4027637,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2784 | `"longitude": 134.7706338` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2789 | `"latitude": 35.4026347,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2790 | `"longitude": 134.7703213` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2795 | `"latitude": 34.7202969,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2796 | `"longitude": 135.5542305` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2801 | `"latitude": 34.724684,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2802 | `"longitude": 135.5543193` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2807 | `"latitude": 34.7257563,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2808 | `"longitude": 135.5518045` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2813 | `"latitude": 34.7300845,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2814 | `"longitude": 135.5509174` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2819 | `"latitude": 34.7158112,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2820 | `"longitude": 135.5852483` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2825 | `"latitude": 34.7159506,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2826 | `"longitude": 135.5838402` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2831 | `"latitude": 38.1995876,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2832 | `"longitude": 140.8684704` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2837 | `"latitude": 34.7274062,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2838 | `"longitude": 135.4227322` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2843 | `"latitude": 35.4670892,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2844 | `"longitude": 139.3139116` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2849 | `"latitude": 34.7075533,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2850 | `"longitude": 135.5889856` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2855 | `"latitude": 36.0564009,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2856 | `"longitude": 136.4922345` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2861 | `"latitude": 34.5755275,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2862 | `"longitude": 135.4795518` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2867 | `"latitude": 34.7025607,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2868 | `"longitude": 135.5602395` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2873 | `"latitude": 34.5733578,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2874 | `"longitude": 135.4755037` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2879 | `"latitude": 38.2825509,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2880 | `"longitude": 140.8396569` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2885 | `"latitude": 34.6986472,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2886 | `"longitude": 135.5702616` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2891 | `"latitude": 34.69939,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2892 | `"longitude": 135.5638191` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2897 | `"latitude": 35.6562033,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2898 | `"longitude": 140.3168343` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2903 | `"latitude": 35.6561706,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2904 | `"longitude": 140.316318` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2909 | `"latitude": 35.6563777,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2910 | `"longitude": 140.3169537` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2915 | `"latitude": 34.8781474,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2916 | `"longitude": 135.6960909` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2921 | `"latitude": 34.692519,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2922 | `"longitude": 135.5791081` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2927 | `"latitude": 34.6942477,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2928 | `"longitude": 135.5694786` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2933 | `"latitude": 32.8428378,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2934 | `"longitude": 130.1804595` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2939 | `"latitude": 33.9924329,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2940 | `"longitude": 130.9668734` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2945 | `"latitude": 35.7203459,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2946 | `"longitude": 140.6486517` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2951 | `"latitude": 34.6924023,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2952 | `"longitude": 135.5610288` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2957 | `"latitude": 34.6400347,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2958 | `"longitude": 135.5340784` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2963 | `"latitude": 34.639326,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2964 | `"longitude": 135.5339852` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2969 | `"latitude": 34.6316257,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2970 | `"longitude": 135.5435252` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2975 | `"latitude": 34.6361616,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2976 | `"longitude": 135.5444247` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2981 | `"latitude": 35.6410463,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2982 | `"longitude": 139.444454` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2987 | `"latitude": 34.0105306,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2988 | `"longitude": 132.1964415` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2993 | `"latitude": 34.0083505,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2994 | `"longitude": 131.5804415` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 2999 | `"latitude": 34.0080236,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3000 | `"longitude": 131.5803886` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3005 | `"latitude": 35.1694,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3006 | `"longitude": 136.912338` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3011 | `"latitude": 35.5191363,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3012 | `"longitude": 140.3234553` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3017 | `"latitude": 35.6730767,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3018 | `"longitude": 139.6842336` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3023 | `"latitude": 35.0216179,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3024 | `"longitude": 135.7787301` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3029 | `"latitude": 34.5303244,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3030 | `"longitude": 135.498836` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3035 | `"latitude": 38.2732326,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3036 | `"longitude": 140.9681033` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3041 | `"latitude": 38.1685501,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3042 | `"longitude": 140.8676066` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3047 | `"latitude": 38.7090103,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3048 | `"longitude": 140.8354198` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3053 | `"latitude": 34.62729,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3054 | `"longitude": 135.4766464` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3059 | `"latitude": 34.8832071,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3060 | `"longitude": 135.7356656` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3065 | `"latitude": 34.3362927,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3066 | `"longitude": 134.0514719` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3071 | `"latitude": 33.0931419,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3072 | `"longitude": 139.8024415` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3077 | `"latitude": 31.5573982,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3078 | `"longitude": 130.4941045` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3083 | `"latitude": 38.233522,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3084 | `"longitude": 140.9065244` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3089 | `"latitude": 38.2494896,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3090 | `"longitude": 140.9248316` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3095 | `"latitude": 40.8234535,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3096 | `"longitude": 140.7412015` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3101 | `"latitude": 34.4280439,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3102 | `"longitude": 135.8218724` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3107 | `"latitude": 35.0950436,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3108 | `"longitude": 137.0107666` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3113 | `"latitude": 35.949423,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3114 | `"longitude": 139.696362` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3119 | `"latitude": 35.3336873,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3120 | `"longitude": 137.1289014` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3125 | `"latitude": 36.8479765,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3126 | `"longitude": 138.3638093` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3131 | `"latitude": 39.7207617,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3132 | `"longitude": 140.1404318` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3137 | `"latitude": 38.5743742,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3138 | `"longitude": 140.965339` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3143 | `"latitude": 35.7498186,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3144 | `"longitude": 139.7361491` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3149 | `"latitude": 34.9503421,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3150 | `"longitude": 135.7470279` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3155 | `"latitude": 34.4356433,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3156 | `"longitude": 135.2443968` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3161 | `"latitude": 41.7831712,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3162 | `"longitude": 140.7973542` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3167 | `"latitude": 34.5377149,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3168 | `"longitude": 135.534388` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3173 | `"latitude": 34.5478437,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3174 | `"longitude": 135.5084699` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3179 | `"latitude": 34.7417586,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3180 | `"longitude": 135.7648797` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3185 | `"latitude": 36.3183398,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3186 | `"longitude": 139.1981434` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3191 | `"latitude": 38.3040222,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3192 | `"longitude": 140.8702589` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3197 | `"latitude": 34.39634,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3198 | `"longitude": 132.457382` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3203 | `"latitude": 34.405043,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3204 | `"longitude": 132.464869` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3209 | `"latitude": 34.658772,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3210 | `"longitude": 135.518323` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3215 | `"latitude": 34.617818,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3216 | `"longitude": 135.546783` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3221 | `"latitude": 34.717031,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3222 | `"longitude": 135.48248` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3227 | `"latitude": 34.70305,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3228 | `"longitude": 135.545723` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3233 | `"latitude": 34.710384,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3234 | `"longitude": 135.49789` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3239 | `"latitude": 34.685452,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3240 | `"longitude": 135.466332` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3245 | `"latitude": 34.701302,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3246 | `"longitude": 135.516047` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3251 | `"latitude": 34.66347,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3252 | `"longitude": 135.454534` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3257 | `"latitude": 34.709081,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3258 | `"longitude": 135.457914` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3263 | `"latitude": 34.676765,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3264 | `"longitude": 135.544177` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3269 | `"latitude": 34.691038,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3270 | `"longitude": 135.49418` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3275 | `"latitude": 34.672183,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3276 | `"longitude": 135.514117` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3281 | `"latitude": 36.593627,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3282 | `"longitude": 136.627882` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3287 | `"latitude": 37.9126,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3288 | `"longitude": 139.0531` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3293 | `"latitude": 35.175612,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3294 | `"longitude": 136.921726` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3299 | `"latitude": 35.174412,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3300 | `"longitude": 136.924261` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3305 | `"latitude": 35.164907,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3306 | `"longitude": 136.935845` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3311 | `"latitude": 35.184746,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3312 | `"longitude": 136.942009` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3317 | `"latitude": 35.172234,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3318 | `"longitude": 136.87632` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3323 | `"latitude": 35.166873,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3324 | `"longitude": 136.863019` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3329 | `"latitude": 35.133835,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3330 | `"longitude": 136.934014` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3335 | `"latitude": 35.159334,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3336 | `"longitude": 136.907351` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3341 | `"latitude": 35.166407,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3342 | `"longitude": 136.899142` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3347 | `"latitude": 35.175875,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3348 | `"longitude": 136.883808` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3353 | `"latitude": 35.18021,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3354 | `"longitude": 136.886248` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3359 | `"latitude": 35.478933,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3360 | `"longitude": 139.638926` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3365 | `"latitude": 35.529519,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3366 | `"longitude": 139.704845` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3371 | `"latitude": 35.627373,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3372 | `"longitude": 139.692044` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3377 | `"latitude": 35.652549,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3378 | `"longitude": 139.747789` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3383 | `"latitude": 35.630151,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3384 | `"longitude": 139.725215` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3389 | `"latitude": 35.632191,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3390 | `"longitude": 139.725002` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3395 | `"latitude": 35.528801,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3396 | `"longitude": 139.694661` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3401 | `"latitude": 35.513644,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3402 | `"longitude": 139.712594` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3407 | `"latitude": 35.588106,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3408 | `"longitude": 139.718852` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3413 | `"latitude": 35.666075,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3414 | `"longitude": 139.748008` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3419 | `"latitude": 35.647091,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3420 | `"longitude": 139.817333` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3425 | `"latitude": 35.598601,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3426 | `"longitude": 139.684747` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3431 | `"latitude": 35.435227,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3432 | `"longitude": 139.663295` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3437 | `"latitude": 35.444357,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3438 | `"longitude": 139.643649` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3443 | `"latitude": 35.648021,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3444 | `"longitude": 139.606529` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3449 | `"latitude": 35.63534,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3450 | `"longitude": 139.601602` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3455 | `"latitude": 35.618357,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3456 | `"longitude": 139.626191` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3461 | `"latitude": 35.46555,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3462 | `"longitude": 139.481385` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3467 | `"latitude": 35.374791,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3468 | `"longitude": 139.508775` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3473 | `"latitude": 35.391529,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3474 | `"longitude": 139.521473` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3479 | `"latitude": 35.484182,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3480 | `"longitude": 139.626632` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3485 | `"latitude": 35.670674,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3486 | `"longitude": 139.775993` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3491 | `"latitude": 35.6915,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3492 | `"longitude": 139.75685` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3497 | `"latitude": 35.710285,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3498 | `"longitude": 139.66173` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3503 | `"latitude": 35.699312,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3504 | `"longitude": 139.696468` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3509 | `"latitude": 35.683102,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3510 | `"longitude": 139.688852` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3515 | `"latitude": 35.697898,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3516 | `"longitude": 139.795345` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3521 | `"latitude": 35.714044,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3522 | `"longitude": 139.61688` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3527 | `"latitude": 35.714077,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3528 | `"longitude": 139.61694` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3533 | `"latitude": 35.714151,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3534 | `"longitude": 139.61693` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3539 | `"latitude": 35.691188,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3540 | `"longitude": 139.712079` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3545 | `"latitude": 35.726188,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3546 | `"longitude": 139.741375` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3551 | `"latitude": 35.684451,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3552 | `"longitude": 139.702884` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3557 | `"latitude": 35.750761,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3558 | `"longitude": 139.594457` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3563 | `"latitude": 35.669285,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3564 | `"longitude": 139.597931` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3569 | `"latitude": 35.5980045,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3570 | `"longitude": 139.3456893` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3575 | `"latitude": 36.5334845,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3576 | `"longitude": 138.0979204` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3581 | `"latitude": 35.6664956,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3582 | `"longitude": 139.8161512` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3587 | `"latitude": 36.6531478,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3588 | `"longitude": 138.1853954` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3593 | `"latitude": 33.3131944,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3594 | `"longitude": 130.5555555` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3599 | `"latitude": 35.5760567,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3600 | `"longitude": 139.4204416` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3605 | `"latitude": 34.5426787,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3606 | `"longitude": 135.5265591` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3611 | `"latitude": 34.5493122,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3612 | `"longitude": 132.0346855` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3617 | `"latitude": 35.3917065,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3618 | `"longitude": 139.5212936` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3623 | `"latitude": 36.3903134,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3624 | `"longitude": 139.0679192` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3629 | `"latitude": 34.9148122,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3630 | `"longitude": 135.764223` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3635 | `"latitude": 35.3329274,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3636 | `"longitude": 136.8701424` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3641 | `"latitude": 33.2264514,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3642 | `"longitude": 132.5637461` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3647 | `"latitude": 34.2281328,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3648 | `"longitude": 133.7809295` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3653 | `"latitude": 34.2280279,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3654 | `"longitude": 133.7810087` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3659 | `"latitude": 34.2280806,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3660 | `"longitude": 133.7808387` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3665 | `"latitude": 35.5865706,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3666 | `"longitude": 139.7318657` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3671 | `"latitude": 35.5873161,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3672 | `"longitude": 139.7318748` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3677 | `"latitude": 35.5873028,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3678 | `"longitude": 139.7315732` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3683 | `"latitude": 34.6493846,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3684 | `"longitude": 134.164342` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3689 | `"latitude": 34.6446117,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3690 | `"longitude": 133.8982713` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3695 | `"latitude": 34.6718964,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3696 | `"longitude": 134.171604` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3701 | `"latitude": 34.960233,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3702 | `"longitude": 135.7463457` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3707 | `"latitude": 34.9604522,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3708 | `"longitude": 135.7470023` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3713 | `"latitude": 34.9904136,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3714 | `"longitude": 135.8401961` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3719 | `"latitude": 35.6691104,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3720 | `"longitude": 139.740475` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3725 | `"latitude": 34.7813504,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3726 | `"longitude": 134.3011586` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3731 | `"latitude": 34.7813635,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3732 | `"longitude": 134.3011905` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3737 | `"latitude": 34.7799295,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3738 | `"longitude": 134.30356` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3743 | `"latitude": 34.7799236,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3744 | `"longitude": 134.3035021` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3749 | `"latitude": 34.7682895,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3750 | `"longitude": 134.0735353` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3755 | `"latitude": 34.694112,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3756 | `"longitude": 135.1994615` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3761 | `"latitude": 34.694515,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3762 | `"longitude": 135.1993625` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3767 | `"latitude": 35.6905308,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3768 | `"longitude": 140.0387739` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3773 | `"latitude": 35.6314801,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3774 | `"longitude": 139.7419959` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3779 | `"latitude": 35.6845537,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3780 | `"longitude": 139.703223` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3785 | `"latitude": 34.6445001,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3786 | `"longitude": 133.8983802` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3791 | `"latitude": 34.6524241,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3792 | `"longitude": 134.0354868` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3797 | `"latitude": 33.5883632,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3798 | `"longitude": 130.3974953` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3803 | `"latitude": 34.666715,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3804 | `"longitude": 134.0927982` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3809 | `"latitude": 34.33559,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3810 | `"longitude": 134.0513778` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3815 | `"latitude": 34.5021264,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3816 | `"longitude": 133.7905368` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3821 | `"latitude": 31.3981188,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3822 | `"longitude": 131.3051436` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3827 | `"latitude": 34.4329415,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3828 | `"longitude": 135.243249` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3833 | `"latitude": 34.9316292,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3834 | `"longitude": 133.5162218` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3839 | `"latitude": 35.8575092,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3840 | `"longitude": 139.9706429` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3845 | `"latitude": 35.8574592,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3846 | `"longitude": 139.9704337` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3851 | `"latitude": 35.8296299,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3852 | `"longitude": 139.7380052` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3857 | `"latitude": 35.8649785,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3858 | `"longitude": 139.6473284` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3863 | `"latitude": 35.858109,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3864 | `"longitude": 139.513642` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3869 | `"latitude": 35.6511846,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3870 | `"longitude": 139.7035092` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3875 | `"latitude": 34.38074,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3876 | `"longitude": 132.47201` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3881 | `"latitude": 34.39834,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3882 | `"longitude": 132.44387` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3887 | `"latitude": 34.39783,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3888 | `"longitude": 132.45677` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3893 | `"latitude": 34.960634,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3894 | `"longitude": 135.745871` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3899 | `"latitude": 34.695109,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3900 | `"longitude": 135.49217` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3905 | `"latitude": 35.6845109,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3906 | `"longitude": 139.7029373` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3911 | `"latitude": 34.6807323,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3912 | `"longitude": 135.5148743` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3917 | `"latitude": 34.6806843,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3918 | `"longitude": 135.5149747` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3923 | `"latitude": 34.6482127,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3924 | `"longitude": 133.9181453` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3929 | `"latitude": 35.6845616,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3930 | `"longitude": 139.7030736` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3935 | `"latitude": 34.3384866,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3936 | `"longitude": 134.046918` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3941 | `"latitude": 34.3384724,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3942 | `"longitude": 134.0469764` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3947 | `"latitude": 34.9168695,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3948 | `"longitude": 135.6872521` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3953 | `"latitude": 34.6984578,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3954 | `"longitude": 135.5031802` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3959 | `"latitude": 34.6985569,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3960 | `"longitude": 135.5031982` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3965 | `"latitude": 35.6777578,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3966 | `"longitude": 139.7124984` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3971 | `"latitude": 34.9758503,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3972 | `"longitude": 135.7472096` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3977 | `"latitude": 34.9758054,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3978 | `"longitude": 135.7472233` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3983 | `"latitude": 34.6955151,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3984 | `"longitude": 135.4910672` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3989 | `"latitude": 34.6954351,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3990 | `"longitude": 135.491135` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3995 | `"latitude": 34.9847255,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 3996 | `"longitude": 135.7596386` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4001 | `"latitude": 35.9634504,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4002 | `"longitude": 140.6379047` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4007 | `"latitude": 35.7946153,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4008 | `"longitude": 139.3193164` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4013 | `"latitude": 35.7957047,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4014 | `"longitude": 139.3183651` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4019 | `"latitude": 33.1600131,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4020 | `"longitude": 130.4034064` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4025 | `"latitude": 35.4755861,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4026 | `"longitude": 139.5726537` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4031 | `"latitude": 35.408151,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4032 | `"longitude": 139.5914251` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4037 | `"latitude": 35.4082369,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4038 | `"longitude": 139.591803` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4043 | `"latitude": 33.5885397,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4044 | `"longitude": 130.3983144` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4049 | `"latitude": 25.8678259,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4050 | `"longitude": 131.2366597` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4055 | `"latitude": 33.4229296,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4056 | `"longitude": 130.6600368` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4061 | `"latitude": 35.1036519,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4062 | `"longitude": 138.859842` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4067 | `"latitude": 35.6475749,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4068 | `"longitude": 139.7221663` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4073 | `"latitude": 38.5853416,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4074 | `"longitude": 140.9674834` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4079 | `"latitude": 38.3368705,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4080 | `"longitude": 140.6109013` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4085 | `"latitude": 36.1012852,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4086 | `"longitude": 139.4587355` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4091 | `"latitude": 26.403175,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4092 | `"longitude": 127.7376447` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4097 | `"latitude": 35.7588879,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4098 | `"longitude": 139.4669257` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4103 | `"latitude": 34.167827,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4104 | `"longitude": 131.4622642` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4109 | `"latitude": 34.1673674,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4110 | `"longitude": 131.461511` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4115 | `"latitude": 35.6463183,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4116 | `"longitude": 139.7106279` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4121 | `"latitude": 35.7867332,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4122 | `"longitude": 139.4781241` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4127 | `"latitude": 35.6491322,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4128 | `"longitude": 139.7109839` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4133 | `"latitude": 34.6265999,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4134 | `"longitude": 133.807649` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4139 | `"latitude": 34.6263582,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4140 | `"longitude": 133.8082078` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4145 | `"latitude": 38.2681207,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4146 | `"longitude": 140.7907272` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4151 | `"latitude": 34.66324,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4152 | `"longitude": 133.92644` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4157 | `"latitude": 35.7328151,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4158 | `"longitude": 139.7490576` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4163 | `"latitude": 35.7402144,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4164 | `"longitude": 139.7468151` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4169 | `"latitude": 35.7283993,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4170 | `"longitude": 139.729445` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4175 | `"latitude": 35.7320395,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4176 | `"longitude": 139.7284922` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4181 | `"latitude": 34.9879632,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4182 | `"longitude": 133.4608384` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4187 | `"latitude": 35.1566104,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4188 | `"longitude": 133.6149005` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4193 | `"latitude": 34.3967472,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4194 | `"longitude": 132.4568769` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4199 | `"latitude": 35.7276013,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4200 | `"longitude": 139.7270895` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4205 | `"latitude": 35.7277914,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4206 | `"longitude": 139.7270991` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4211 | `"latitude": 35.7300971,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4212 | `"longitude": 139.7129205` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4217 | `"latitude": 35.484182,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4218 | `"longitude": 139.626632` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4223 | `"latitude": 35.475736,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4224 | `"longitude": 139.572285` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4229 | `"latitude": 35.478933,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4230 | `"longitude": 139.638926` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4235 | `"latitude": 35.435227,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4236 | `"longitude": 139.663295` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4241 | `"latitude": 34.648302,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4242 | `"longitude": 135.781885` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4247 | `"latitude": 34.336224,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4248 | `"longitude": 134.051376` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4253 | `"latitude": 34.336302,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4254 | `"longitude": 134.051724` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4259 | `"latitude": 34.336319,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4260 | `"longitude": 134.051566` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4265 | `"latitude": 34.687213,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4266 | `"longitude": 135.189872` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4271 | `"latitude": 34.38807,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4272 | `"longitude": 132.49186` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4277 | `"latitude": 35.042311,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4278 | `"longitude": 135.779432` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4283 | `"latitude": 34.990339,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4284 | `"longitude": 135.762865` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4289 | `"latitude": 35.004365,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4290 | `"longitude": 135.73605` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4295 | `"latitude": 35.008707,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4296 | `"longitude": 135.760415` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4301 | `"latitude": 35.611878,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4302 | `"longitude": 139.747725` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4307 | `"latitude": 32.938996,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4308 | `"longitude": 129.6399428` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4313 | `"latitude": 35.6731077,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4314 | `"longitude": 139.7408665` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4319 | `"latitude": 35.673166,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4320 | `"longitude": 139.7405892` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4325 | `"latitude": 38.7904478,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4326 | `"longitude": 140.0208576` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4331 | `"latitude": 34.7946172,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4332 | `"longitude": 135.5551767` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4337 | `"latitude": 34.741135,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4338 | `"longitude": 135.7644462` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4343 | `"latitude": 34.6879521,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4344 | `"longitude": 133.9499438` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4349 | `"latitude": 32.979742,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4350 | `"longitude": 130.8087376` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4355 | `"latitude": 35.7289827,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4356 | `"longitude": 139.4779867` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4361 | `"latitude": 34.5434058,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4362 | `"longitude": 133.6698381` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4367 | `"latitude": 33.7481052,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4368 | `"longitude": 129.6899016` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4373 | `"latitude": 34.7200772,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4374 | `"longitude": 134.1921101` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4379 | `"latitude": 35.693183,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4380 | `"longitude": 139.8267889` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4385 | `"latitude": 34.6364685,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4386 | `"longitude": 135.5882383` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4391 | `"latitude": 34.6336861,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4392 | `"longitude": 135.6099056` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4397 | `"latitude": 34.4198563,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4398 | `"longitude": 135.3308274` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4403 | `"latitude": 34.6361514,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4404 | `"longitude": 135.6395299` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4409 | `"latitude": 35.374791,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4410 | `"longitude": 139.508775` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4415 | `"latitude": 35.398605,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4416 | `"longitude": 139.532613` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4421 | `"latitude": 35.46555,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4422 | `"longitude": 139.481385` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4427 | `"latitude": 35.530251,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4428 | `"longitude": 139.500037` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4433 | `"latitude": 35.461693,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4434 | `"longitude": 139.512063` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4439 | `"latitude": 34.681915,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4440 | `"longitude": 135.825142` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4445 | `"latitude": 34.661529,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4446 | `"longitude": 133.926462` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4451 | `"latitude": 35.650306,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4452 | `"longitude": 139.589518` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4457 | `"latitude": 35.650831,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4458 | `"longitude": 139.587835` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4463 | `"latitude": 24.2742639,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4464 | `"longitude": 123.8789127` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4469 | `"latitude": 34.587764,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4470 | `"longitude": 135.4822215` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4475 | `"latitude": 35.7501479,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4476 | `"longitude": 139.4212207` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4481 | `"latitude": 35.7029723,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4482 | `"longitude": 139.4215632` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4487 | `"latitude": 35.7143739,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4488 | `"longitude": 139.5184868` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4493 | `"latitude": 35.6423993,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4494 | `"longitude": 139.5378706` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4499 | `"latitude": 34.6596471,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4500 | `"longitude": 133.9399539` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4505 | `"latitude": 38.333938,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4506 | `"longitude": 140.6130516` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4511 | `"latitude": 34.6952416,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4512 | `"longitude": 133.87163` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4517 | `"latitude": 35.5821308,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4518 | `"longitude": 139.6505493` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4523 | `"latitude": 34.6632984,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4524 | `"longitude": 133.9234126` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4529 | `"latitude": 34.6661204,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4530 | `"longitude": 134.091651` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4535 | `"latitude": 35.0820728,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4536 | `"longitude": 137.0808394` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4541 | `"latitude": 35.0813339,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4542 | `"longitude": 137.0796717` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4547 | `"latitude": 35.0806889,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4548 | `"longitude": 137.06542` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4553 | `"latitude": 43.0306065,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4554 | `"longitude": 141.3592772` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4559 | `"latitude": 43.0319934,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4560 | `"longitude": 141.3597677` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4565 | `"latitude": 36.575038,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4566 | `"longitude": 136.6658401` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4571 | `"latitude": 35.593852,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4572 | `"longitude": 138.5215527` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4577 | `"latitude": 35.571092,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/ntt_exchanges_japan_763.json` | 4578 | `"longitude": 139.6873495` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `tests/test_linter_reliability.py` | 426 | `We track latitude and longitude coordinates.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_drag_test.dart` | 23 | `testWidgets('Globe camera drag: longitude increases after leftward pan gesture', (WidgetTester teste...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_drag_test.dart` | 96 | `final double initialLongitude = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_drag_test.dart` | 99 | `expect(initialLongitude, greaterThan(0), reason: 'Initial longitude should be positive');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_drag_test.dart` | 108 | `final double newLongitude = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_drag_test.dart` | 111 | `expect(newLongitude, greaterThan(initialLongitude),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_drag_test.dart` | 112 | `reason: 'Longitude should increase after leftward drag. '` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_drag_test.dart` | 113 | `'Initial: $initialLongitude, New: $newLongitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/consolidated_decision_making_report.md` | 16 | `3. **Exact Ellipsoidal Occlusion & Physical Jamming Models**: Upgrade line-of-sight checks from ray-...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/consolidated_decision_making_report.md` | 157 | `### 4.1 Exact Ray-Ellipsoid Line-of-Sight (LOS) Occlusion` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/consolidated_decision_making_report.md` | 158 | `Instead of checking spherical approximations (which introduce up to 21 km of geodetic error at the p...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/consolidated_decision_making_report.md` | 161 | `An ellipsoid is defined by $\frac{x^2}{a^2} + \frac{y^2}{b^2} + \frac{z^2}{c^2} = 1$. Let $\mathbf{M...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/decisions/consolidated_decision_making_report.md` | 301 | `* **Math Proofs**: Verify that the ray-ellipsoid quadratic formula in WebGPU produces collision coor...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-firestore-persistence-adapter-design.md` | 60 | `"referenceFrame": {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-firestore-persistence-adapter-design.md` | 68 | `"latitude": 35.6762,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-firestore-persistence-adapter-design.md` | 69 | `"longitude": 139.6503,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-firestore-persistence-adapter-design.md` | 109 | `latitude: data.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-firestore-persistence-adapter-design.md` | 110 | `longitude: data.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-firestore-persistence-adapter-design.md` | 127 | `latitude: loc.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-firestore-persistence-adapter-design.md` | 128 | `longitude: loc.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-firestore-persistence-adapter-design.md` | 172 | `latitude: 35.6762,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/feat-firestore-persistence-adapter-design.md` | 173 | `longitude: 139.6503,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_reset_test.dart` | 109 | `final initialLat = _parseHudValue('Latitude', tester);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_reset_test.dart` | 110 | `final initialLng = _parseHudValue('Longitude', tester);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_reset_test.dart` | 124 | `final afterLat = _parseHudValue('Latitude', tester);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_reset_test.dart` | 125 | `final afterLng = _parseHudValue('Longitude', tester);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_reset_test.dart` | 129 | `reason: 'Latitude must be identical after tree node tap. '` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/globe_camera_reset_test.dart` | 132 | `reason: 'Longitude must be identical after tree node tap. '` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 6 | `"latitude": 34.9767161,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 7 | `"longitude": 139.9546792` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 13 | `"latitude": 35.0387486,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 14 | `"longitude": 139.8371399` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 20 | `"latitude": 35.0377356,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 21 | `"longitude": 140.0172905` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 27 | `"latitude": 35.062414,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 28 | `"longitude": 140.0613872` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 34 | `"latitude": 35.1140584,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 35 | `"longitude": 140.098692` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 41 | `"latitude": 35.0782692,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 42 | `"longitude": 139.9664886` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 48 | `"latitude": 34.3578919,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 49 | `"longitude": 136.8949592` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 55 | `"latitude": 34.3411841,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 56 | `"longitude": 136.8196451` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 62 | `"latitude": 34.6891047,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 63 | `"longitude": 137.4643919` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 69 | `"latitude": 35.2938695,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 70 | `"longitude": 139.2460216` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 76 | `"latitude": 35.1441984,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 77 | `"longitude": 139.6207589` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 83 | `"latitude": 36.7199765,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 84 | `"longitude": 140.7158414` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 90 | `"latitude": 36.8018507,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 91 | `"longitude": 140.7513188` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 97 | `"latitude": 36.3836175,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 98 | `"longitude": 140.6123681` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 104 | `"latitude": 43.171677,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 105 | `"longitude": 141.3159605` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 111 | `"latitude": 42.6341039,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 112 | `"longitude": 141.6054899` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 118 | `"latitude": 37.170264,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 119 | `"longitude": 138.2422616` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 125 | `"latitude": 33.5571816,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 126 | `"longitude": 130.196231` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 132 | `"latitude": 32.097681,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 133 | `"longitude": 131.294542` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 139 | `"latitude": 33.6251241,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 140 | `"longitude": 130.6180016` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 146 | `"latitude": 33.8829996,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 147 | `"longitude": 130.8749015` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 153 | `"latitude": 26.5707754,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/assets/cable_landing_stations_japan.json` | 154 | `"longitude": 128.0255901` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 18 | `The following class diagram defines the logical schema for geolocation, reference frames, and motion...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 27 | `class Ellipsoid {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 28 | `+Real latitude "[1]"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 29 | `+Real longitude "[1]"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 40 | `class ReferenceFrame {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 57 | `GeoLocation *-- ReferenceFrame : "has referenceFrame"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 61 | `Location <\|-- Ellipsoid : "inherits geodetic coordinates"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 71 | `Rail transportation utilizes 1D Linear Referencing Systems (LRS) to track assets along physically co...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 84 | `- Latitude, Longitude, Altitude` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 94 | `- Geodetic position (Latitude, Longitude)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 104 | `- Geodetic position (Latitude, Longitude, GNSS Altitude)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 126 | `* **When** a 3D GPS telemetry update is received with geodetic coordinates (Latitude: 35.6895, Longi...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/requirements/dynamic-geolocation-motion-blueprint.md` | 171 | `- `GeoLocation.referenceFrame` mapped to `properties_view.reference_system`` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/visual_rendering_defect_test.dart` | 124 | `latitude: 35.6074,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/visual_rendering_defect_test.dart` | 125 | `longitude: 140.1063,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/domain/validation.dart` | 5 | `class ReferenceFrameValidation {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/domain/validation.dart` | 10 | `const ReferenceFrameValidation({` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/domain/validation.dart` | 26 | `ReferenceFrameValidation validateReferenceFrame(` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/domain/validation.dart` | 34 | `return ReferenceFrameValidation(` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/domain/validation.dart` | 44 | `return ReferenceFrameValidation(` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/domain/validation.dart` | 51 | `return ReferenceFrameValidation(` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/camera_gestures_navigation_test.dart` | 194 | `final double initialLat = controller.current.latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/camera_gestures_navigation_test.dart` | 195 | `final double initialLng = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/camera_gestures_navigation_test.dart` | 206 | `final double postFlyLat = controller.current.latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/camera_gestures_navigation_test.dart` | 207 | `final double postFlyLng = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/camera_gestures_navigation_test.dart` | 208 | `expect(postFlyLat, isNot(equals(initialLat)), reason: 'Latitude should update after fly-to');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/camera_gestures_navigation_test.dart` | 209 | `expect(postFlyLng, isNot(equals(initialLng)), reason: 'Longitude should update after fly-to');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/camera_gestures_navigation_test.dart` | 218 | `final double postDragLng = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/integration_test/camera_gestures_navigation_test.dart` | 219 | `expect(postDragLng, isNot(equals(postFlyLng)), reason: 'Longitude should change after pan drag gestu...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/ntt_exchanges_report.md` | 20 | `\| Name \| Operator/Brand \| Latitude \| Longitude \|` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/data_sources/sqlite_data_source.dart` | 465 | `final latPath = _findPathToKey(decoded, 'latitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/data_sources/sqlite_data_source.dart` | 466 | `final lngPath = _findPathToKey(decoded, 'longitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/consolidated_logical_ui_design_report.md` | 192 | `2. **Dynamic Trajectory Projection**: The `TopographicalView` rendering engine maps latitude, longit...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/cable_landing_stations_report.md` | 1 | `# Submarine Cable Landing Stations in Japan` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/cable_landing_stations_report.md` | 3 | `This report contains the geocoded dataset of **22 submarine cable landing stations** across Japan, i...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/cable_landing_stations_report.md` | 11 | `## Cable Landing Stations List` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `docs/cable_landing_stations_report.md` | 13 | `\| Station Name (English) \| Station Name (Japanese) \| Location \| Latitude \| Longitude \|` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/data_sources/firebase_data_source.dart` | 397 | `final ellip = loc['ellipsoid'] ?? loc;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/data_sources/firebase_data_source.dart` | 399 | `latVal = double.tryParse(ellip['latitude']?.toString() ?? '');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/data_sources/firebase_data_source.dart` | 400 | `lngVal = double.tryParse(ellip['longitude']?.toString() ?? '');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 10 | `/// cable landing stations, and their interconnectivity links.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 79 | `'lat': (item['latitude'] as num).toDouble(),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 80 | `'lon': (item['longitude'] as num).toDouble(),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 82 | `_addNodeToBatch(batch, id, null, nttDetails, lat: (item['latitude'] as num).toDouble(), lon: (item['...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 85 | `// 4. Load and parse cable landing stations data from assets` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 101 | `'lat': (item['latitude'] as num).toDouble(),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 102 | `'lon': (item['longitude'] as num).toDouble(),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 104 | `_addNodeToBatch(batch, id, null, landingDetails, lat: (item['latitude'] as num).toDouble(), lon: (it...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 221 | `'ellipsoid': {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 222 | `'latitude': lat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/data/seeds/domain_seed_strategy.dart` | 223 | `'longitude': lon,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/visual_test_spec.md` | 13 | `*   **Far Zoom**: `VirtualCamera(latitude: 35.6074, longitude: 140.1063, altitude: 6378137.0 + 20960...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/visual_test_spec.md` | 14 | `*   **Close Zoom**: `VirtualCamera(latitude: 35.6074, longitude: 140.1063, altitude: 6378137.0 + 500...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/spec_validator.py` | 62 | `f"Expected format e.g. 'ietf-geo-location:geo-location/reference-frame'."` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 11 | `latitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 12 | `longitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 19 | `expect(absoluteCamera.altitude, Ellipsoid.wgs84EquatorialRadius + 500.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 24 | `latitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 25 | `longitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 58 | `latitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 59 | `longitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 80 | `latitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 81 | `longitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 107 | `latitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/cesium_3d/viewport_math_test.dart` | 108 | `longitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 27 | `if (altitude >= Ellipsoid.wgs84EquatorialRadius) {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 31 | `latitude: latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 32 | `longitude: longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 33 | `altitude: Ellipsoid.wgs84EquatorialRadius + altitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 106 | `_r2 = Ellipsoid.wgs84EquatorialRadius * Ellipsoid.wgs84EquatorialRadius;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 135 | `final double R = Ellipsoid.wgs84EquatorialRadius;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 249 | `final double R = Ellipsoid.wgs84EquatorialRadius;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 413 | `final double baseRotation = -(camera.longitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 414 | `final double baseTilt = -(camera.latitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 427 | `earthCenterProj = transformer.projectWgs84ToScreen(latRad: 0.0, lngRad: 0.0, heightMeters: -Ellipsoi...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 432 | `final double radDiff = cRad * cRad - Ellipsoid.wgs84EquatorialRadius * Ellipsoid.wgs84EquatorialRadi...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart` | 433 | `projectedRadius = Ellipsoid.wgs84EquatorialRadius * f / math.sqrt(radDiff <= 0.0 ? 1.0 : radDiff);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 43 | `group('validateReferenceFrame', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 46 | `final result = validateReferenceFrame(frame);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 53 | `final result = validateReferenceFrame(frame, alternateSystemEnabled: true);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 61 | `final result = validateReferenceFrame(frame, alternateSystemEnabled: false);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 67 | `final result = validateReferenceFrame(frame);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 75 | `final result = validateReferenceFrame(frame, frameName: 'test\x00name');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 81 | `final result = validateReferenceFrame(frame, frameName: 'test\nname');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 87 | `final result = validateReferenceFrame(frame, frameName: 'test\tname');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 93 | `final result = validateReferenceFrame(frame, frameName: 'test\x7fname');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 99 | `final result = validateReferenceFrame(` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 111 | `final result = validateReferenceFrame(frame, frameName: 'mars');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 117 | `final result = validateReferenceFrame(frame, frameName: 'MarsMoon');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 125 | `final result = validateReferenceFrame(frame, frameName: 'the-mars');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 131 | `final result = validateReferenceFrame(frame, frameName: 'THE-MARS');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 137 | `final result = validateReferenceFrame(frame, frameName: '  the-moon  ');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 145 | `final result = validateReferenceFrame(frame);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 153 | `final result = validateReferenceFrame(frame);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 159 | `final resultEnabled = validateReferenceFrame(frame, alternateSystemEnabled: true);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/domain/validation_test.dart` | 160 | `final resultDisabled = validateReferenceFrame(frame, alternateSystemEnabled: false);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 119 | `double latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 120 | `double longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 136 | `latitude = 35.6074;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 137 | `longitude = 140.1063;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 139 | `latitude = latVal;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 140 | `longitude = lngVal;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 144 | `latitude = 35.6074;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 145 | `longitude = 140.1063;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 148 | `latitude = latitude.clamp(-90.0, 90.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 149 | `longitude = longitude.clamp(-180.0, 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 151 | `print("TopographicalView: final camera lat=$latitude, lng=$longitude");` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 153 | `latitude: latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/topographical_view.dart` | 154 | `longitude: longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_spec_validator_issue237.py` | 109 | `"  - path: \"ietf-geo-location/reference-frame\"\n"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_spec_validator_issue237.py` | 120 | `"  - path: \"ietf-geo-location:geo-location/reference-frame\"\n"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_spec_validator_issue237.py` | 131 | `assert any("feat-01-unqualified.md" in err and "ietf-geo-location/reference-frame" in err and "unqua...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 130 | `const double earthRadius = Ellipsoid.wgs84EquatorialRadius;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 245 | `Ellipsoid.wgs84EquatorialRadius,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 340 | `final double surfaceHeight = Ellipsoid.wgs84EquatorialRadius + elev * state.verticalExaggeration;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 415 | `final double R = Ellipsoid.wgs84EquatorialRadius;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 568 | `cam = VirtualCamera.raw(latitude: -tilt * 180 / math.pi, longitude: -rotationAngle * 180 / math.pi, ...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 579 | `heightMeters: heightMeters - Ellipsoid.wgs84EquatorialRadius,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 632 | `Text('Latitude: ${cam.latitude.toStringAsFixed(6)}', style: const TextStyle(color: Color(0xFFE0E0E0)...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 633 | `Text('Longitude: ${cam.longitude.toStringAsFixed(6)}', style: const TextStyle(color: Color(0xFFE0E0E...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 634 | `Text('Altitude: ${(cam.altitude - Ellipsoid.wgs84EquatorialRadius).toStringAsFixed(2)} meters', styl...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 842 | `double latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 843 | `double longitude, {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 851 | `final camera = rawCamera.altitude < Ellipsoid.wgs84EquatorialRadius` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 853 | `latitude: rawCamera.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 854 | `longitude: rawCamera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 855 | `altitude: Ellipsoid.wgs84EquatorialRadius + rawCamera.altitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 866 | `rotationAngle: -(camera.longitude * math.pi / 180.0),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 867 | `tilt: -(camera.latitude * math.pi / 180.0),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 885 | `final double terrainElev = Scene3DViewportPainter.getElevationStatic(latitude, longitude, _elevation...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 901 | `latRad: latitude * math.pi / 180.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 902 | `lngRad: longitude * math.pi / 180.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 1021 | `return VirtualCamera.raw(latitude: 35.6074, longitude: 140.1063, altitude: 500.0, heading: 0.0, pitc...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 1023 | `return VirtualCamera.raw(latitude: latVal, longitude: lngVal, altitude: 500.0, heading: 0.0, pitch: ...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 1072 | `final surfaceAlt = current.altitude - Ellipsoid.wgs84EquatorialRadius;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 1078 | `latitude: current.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 1079 | `longitude: current.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/topology/scene_3d_viewport.dart` | 1080 | `altitude: targetAlt + Ellipsoid.wgs84EquatorialRadius,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_focus_test.dart` | 11 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_focus_test.dart` | 12 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_focus_test.dart` | 61 | `expect(controller.current.longitude, lessThan(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_focus_test.dart` | 66 | `expect(controller.current.longitude, equals(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_focus_test.dart` | 68 | `// Hold Shift and press Arrow Left key (should rotate heading, longitude stays 135.0)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_focus_test.dart` | 73 | `expect(controller.current.longitude, equals(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_focus_test.dart` | 81 | `expect(controller.current.longitude, equals(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test_output.txt` | 48 | `Latitude should update after fly-to` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/collapse_hud_test.dart` | 9 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/collapse_hud_test.dart` | 10 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 10 | `class Ellipsoid {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 21 | `final double latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 22 | `final double longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 30 | `required double latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 31 | `required double longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 37 | `if (latitude.isNaN \|\| latitude.isInfinite \|\|` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 38 | `longitude.isNaN \|\| longitude.isInfinite \|\|` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 45 | `if (latitude < -90.0 \|\| latitude > 90.0) {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 46 | `throw CoordinateValidationException('Latitude must be in the range [-90.0, 90.0].');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 48 | `if (longitude < -180.0 \|\| longitude > 180.0) {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 49 | `throw CoordinateValidationException('Longitude must be in the range [-180.0, 180.0].');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 55 | `latitude: latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 56 | `longitude: longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 66 | `required this.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 67 | `required this.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 76 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 77 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 85 | `/// Clamps altitude to at least -100.0, latitude to [-90, 90], and longitude to [-180, 180].` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 87 | `required double latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 88 | `required double longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 94 | `final double lat = (latitude.isNaN \|\| latitude.isInfinite) ? 0.0 : latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 95 | `final double lng = (longitude.isNaN \|\| longitude.isInfinite) ? 0.0 : longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 105 | `latitude: clampedLat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 106 | `longitude: clampedLng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 118 | `return other.latitude == latitude &&` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 119 | `other.longitude == longitude &&` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 133 | `return (latitude - other.latitude).abs() <= epsilonCoordinate &&` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 134 | `(longitude - other.longitude).abs() <= epsilonCoordinate &&` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 142 | `int get hashCode => Object.hash(latitude, longitude, altitude, heading, pitch, roll);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart` | 146 | `return 'VirtualCamera(latitude: $latitude, longitude: $longitude, altitude: $altitude, heading: $hea...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli.py` | 161 | `class ReferenceFrame {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli.py` | 164 | `note for ReferenceFrame "alternateSystem guarded by <<feature_guard>> alternate-systems"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli.py` | 167 | `assert "ReferenceFrame" in parsed.classes` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli.py` | 168 | `cls_info = parsed.classes["ReferenceFrame"]` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_angle_wrapping_test.dart` | 25 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_angle_wrapping_test.dart` | 26 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_angle_wrapping_test.dart` | 56 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_angle_wrapping_test.dart` | 57 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli_coverage_choice_case.py` | 38 | `{"path": "ietf-geo-location:geo-location/location/ellipsoid"},` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli_coverage_choice_case.py` | 39 | `{"path": "ietf-geo-location:geo-location/location/cartesian"}` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli_coverage_choice_case.py` | 45 | `"  - path: ietf-geo-location:geo-location/location/ellipsoid\n"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli_coverage_choice_case.py` | 46 | `"  - path: ietf-geo-location:geo-location/location/cartesian\n"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli_coverage_choice_case.py` | 60 | `"ietf-geo-location",` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli_coverage_choice_case.py` | 62 | `"ietf-geo-location:geo-location/location/ellipsoid": {"type": "case"},` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_cli_coverage_choice_case.py` | 63 | `"ietf-geo-location:geo-location/location/cartesian": {"type": "case"}` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_drag_test.dart` | 10 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_drag_test.dart` | 11 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_drag_test.dart` | 30 | `expect(find.textContaining('Latitude: 35.000000'), findsOneWidget);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_drag_test.dart` | 31 | `expect(find.textContaining('Longitude: 135.000000'), findsOneWidget);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_drag_test.dart` | 42 | `expect(controller.current.longitude, isNot(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_drag_test.dart` | 43 | `expect(controller.current.latitude, isNot(35.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_drag_test.dart` | 46 | `expect(find.textContaining('Latitude: 35.000000'), findsNothing);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_drag_test.dart` | 47 | `expect(find.textContaining('Longitude: 135.000000'), findsNothing);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/globe_tile_renderer.dart` | 136 | `/// Converts latitude/longitude (degrees) to a tile coordinate at the` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/globe_tile_renderer.dart` | 152 | `/// Longitude of the *western* edge of tile column [x] at zoom [z].` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/globe_tile_renderer.dart` | 156 | `/// Latitude of the *northern* edge of tile row [y] at zoom [z].` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/globe_tile_renderer.dart` | 173 | `final double R = Ellipsoid.wgs84EquatorialRadius;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/globe_tile_renderer.dart` | 179 | `final center = _latLngToTile(camera.latitude, camera.longitude, zoom);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/globe_tile_renderer.dart` | 182 | `// Horizon angle theta = acos(R / (R + h)) where R = Ellipsoid.wgs84EquatorialRadius` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/globe_tile_renderer.dart` | 196 | `final midCenter = _latLngToTile(camera.latitude, camera.longitude, midZoom);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py` | 30 | `lat_leaf = MockNode("leaf", "latitude", children=[type_stmt])` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py` | 31 | `long_leaf = MockNode("leaf", "longitude", children=[type_stmt])` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py` | 42 | `assert "location/latitude" in attr_keys` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py` | 43 | `assert "location/longitude" in attr_keys` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py` | 149 | `leaf latitude {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py` | 152 | `leaf longitude {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py` | 171 | `assert lui_json["attributes"][0]["key"] == "location/latitude"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_compile_yang_issue240.py` | 172 | `assert lui_json["attributes"][1]["key"] == "location/longitude"` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 33 | `final double minAlt = Ellipsoid.wgs84EquatorialRadius + terrainH + minAltitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 37 | `CameraController(VirtualCamera camera) : _camera = camera.altitude < Ellipsoid.wgs84EquatorialRadius...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 38 | `latitude: camera.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 39 | `longitude: camera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 40 | `altitude: Ellipsoid.wgs84EquatorialRadius + camera.altitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 51 | `final absoluteCamera = camera.altitude < Ellipsoid.wgs84EquatorialRadius ? VirtualCamera.clamped(` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 52 | `latitude: camera.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 53 | `longitude: camera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 54 | `altitude: Ellipsoid.wgs84EquatorialRadius + camera.altitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 59 | `final double targetAlt = _clampAltitudeToTerrain(absoluteCamera.latitude, absoluteCamera.longitude, ...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 61 | `latitude: absoluteCamera.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 62 | `longitude: absoluteCamera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 83 | `final double lat1 = a.latitude * math.pi / 180.0;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 84 | `final double lat2 = b.latitude * math.pi / 180.0;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 85 | `final double lon1 = a.longitude * math.pi / 180.0;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 86 | `final double lon2 = b.longitude * math.pi / 180.0;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 136 | `latitude: a.latitude + (b.latitude - a.latitude) * t,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 137 | `longitude: _interpolateCircular(a.longitude, b.longitude, t, _wrapLngStatic),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 174 | `final double factor = (_camera.altitude - Ellipsoid.wgs84EquatorialRadius + 500000.0) * 2.8074e-5 / ...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 180 | `final newLat = (_camera.latitude - dyAligned * factor).clamp(-90.0, 90.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 181 | `final newLng = _wrapLng(_camera.longitude - dxAligned * factor);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 184 | `latitude: newLat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 185 | `longitude: newLng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 196 | `latitude: _camera.latitude, longitude: _camera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 207 | `latitude: _camera.latitude, longitude: _camera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 216 | `final double terrainH = _getTerrainHeight(_camera.latitude, _camera.longitude);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 217 | `final double currentHeightAGL = _camera.altitude - (Ellipsoid.wgs84EquatorialRadius + terrainH);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 220 | `final double newAlt = Ellipsoid.wgs84EquatorialRadius + clampedHeightAGL + terrainH;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 222 | `latitude: _camera.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 223 | `longitude: _camera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 235 | `final double terrainH = _getTerrainHeight(_camera.latitude, _camera.longitude);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 236 | `final double currentHeightAGL = _camera.altitude - (Ellipsoid.wgs84EquatorialRadius + terrainH);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 239 | `final double newAlt = Ellipsoid.wgs84EquatorialRadius + clampedHeightAGL + terrainH;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 241 | `latitude: _camera.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 242 | `longitude: _camera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 253 | `latitude: _camera.latitude, longitude: _wrapLng(_camera.longitude + degrees),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 262 | `latitude: _camera.latitude, longitude: _camera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart` | 272 | `latitude: _camera.latitude, longitude: _camera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 51 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 52 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 63 | `expect(find.textContaining('Latitude: 35.000000'), findsOneWidget);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 64 | `expect(find.textContaining('Longitude: 135.000000'), findsOneWidget);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 72 | `final double newLat = controller.current.latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 73 | `final double newLng = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 78 | `expect(find.textContaining('Latitude: 35.000000'), findsNothing);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 79 | `expect(find.textContaining('Longitude: 135.000000'), findsNothing);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 89 | `expect(controllerAfter.current.latitude, equals(newLat));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 90 | `expect(controllerAfter.current.longitude, equals(newLng));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 91 | `expect(find.textContaining('Latitude: 35.000000'), findsNothing);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/hud_update_test.dart` | 92 | `expect(find.textContaining('Longitude: 135.000000'), findsNothing);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/cesium_engine.dart` | 63 | `native.ref.latitude = camera.latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/cesium_engine.dart` | 64 | `native.ref.longitude = camera.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_collision_test.dart` | 30 | `test('Nadir Zoom-in Clamps at Ellipsoid Base Over Ocean (Flat Terrain)', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_collision_test.dart` | 32 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_collision_test.dart` | 33 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_collision_test.dart` | 52 | `latitude: 35.3606,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_collision_test.dart` | 53 | `longitude: 138.7274,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_collision_test.dart` | 74 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_collision_test.dart` | 75 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_collision_test.dart` | 86 | `latitude: 35.3606,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_collision_test.dart` | 87 | `longitude: 138.7274,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/cesium_3d_native.dart` | 26 | `latitude: camera.latitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/cesium_3d_native.dart` | 27 | `longitude: camera.longitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/logical_ui_validator.py` | 166 | `FORBIDDEN_CHOICE_NODES = {"location-choice", "cartesian", "ellipsoid", "choice", "case"}` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/src/parity_auditor/validators/logical_ui_validator.py` | 227 | `GEODETIC_REGEX = re.compile(r"\b(?:location\|velocity\|geo-location\|geodetic\|latitude\|longitude\|...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/scroll_zoom_test.dart` | 11 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/scroll_zoom_test.dart` | 12 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/native/bridge_bindings.dart` | 12 | `external double latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/lib/features/map_viewport/cesium_3d/native/bridge_bindings.dart` | 15 | `external double longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/double_click_fly_test.dart` | 10 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/double_click_fly_test.dart` | 11 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_logical_ui_validator_issue222.py` | 374 | `Contains latitude and longitude coordinates.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_logical_ui_validator_issue222.py` | 388 | `Contains latitude and longitude coordinates.` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_logical_ui_validator_issue222.py` | 622 | `- **Data Source Binding:** /ietf-hardware:hardware/component/location-choice, /ietf-hardware:hardwar...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-orchestrator/parity_auditor/tests/test_logical_ui_validator_issue222.py` | 630 | `forbidden_nodes = ["location-choice", "cartesian", "ellipsoid", "my-choice", "my-case"]` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/ctrl_drag_test.dart` | 11 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/ctrl_drag_test.dart` | 12 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/ctrl_drag_test.dart` | 48 | `expect(controller.current.latitude, equals(35.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/ctrl_drag_test.dart` | 49 | `expect(controller.current.longitude, equals(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/virtual_camera_test.dart` | 7 | `const camera = VirtualCamera.raw(latitude: 10, longitude: 20, altitude: 30, heading: 40, pitch: 50, ...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/virtual_camera_test.dart` | 12 | `const camera1 = VirtualCamera.raw(latitude: 10, longitude: 20, altitude: 30, heading: 40, pitch: 50,...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/virtual_camera_test.dart` | 13 | `const camera2 = VirtualCamera.raw(latitude: 10.00000001, longitude: 20.00000001, altitude: 30.0001, ...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/virtual_camera_test.dart` | 18 | `const camera1 = VirtualCamera.raw(latitude: 10, longitude: 20, altitude: 30, heading: 40, pitch: 50,...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/virtual_camera_test.dart` | 19 | `const camera2 = VirtualCamera.raw(latitude: 10.1, longitude: 20.0, altitude: 30.0, heading: 40.0, pi...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/schema-specification-engineering/SKILL.md` | 57 | `- **Container Traceability**: Every Feature MUST declare exactly one schema container in its YAML fr...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/schema-specification-engineering/SKILL.md` | 118 | `> **Container Traceability:** Every Feature MUST declare its schema container in `schema_containers`...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/schema-specification-engineering/SKILL.md` | 305 | `- Geolocation and geodetic attributes (such as reference-frame, geodetic-system, coordinates, veloci...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 34 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 35 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 46 | `final centerTile = renderer.latLngToTileForTesting(camera.latitude, camera.longitude, 8);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 91 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 92 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 103 | `// Now call renderTiles and capture the latitudes passed to projectFn` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 104 | `final latitudes = <double>[];` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 114 | `latitudes.add(lat);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 119 | `// Helper to compute unclamped latitude at zoom 2, y=0 and y=4` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 127 | `// Verify that the captured latitudes contain exactly 90.0 and -90.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 128 | `// and do NOT contain unclamped boundary latitudes (~85.0511 or ~-85.0511)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 129 | `expect(latitudes, contains(90.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 130 | `expect(latitudes, contains(-90.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 131 | `expect(latitudes, isNot(contains(unclampedNorth)));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 132 | `expect(latitudes, isNot(contains(unclampedSouth)));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 214 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 215 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 261 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 262 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 274 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 275 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 291 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 292 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 314 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 315 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 395 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 396 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 436 | `final latitudes = [-35.0, 0.0, 35.3606];` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 437 | `final longitudes = [-135.0, 0.0, 138.7274];` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 443 | `for (final lat in latitudes) {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 444 | `for (final lng in longitudes) {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 448 | `latitude: lat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 449 | `longitude: lng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 541 | `final double baseRotation = -(camera.longitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 542 | `final double baseTilt = -(camera.latitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 566 | `latitude: 35.3606,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 567 | `longitude: 138.7274,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 598 | `final double rotationY = -(camera.longitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/globe_tile_renderer_test.dart` | 599 | `final double tilt = -(camera.latitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/shift_drag_test.dart` | 11 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/shift_drag_test.dart` | 12 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/shift_drag_test.dart` | 48 | `expect(controller.current.latitude, equals(35.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/shift_drag_test.dart` | 49 | `expect(controller.current.longitude, equals(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `skills/spec-usecase-engineering/SKILL.md` | 149 | `> **Container Traceability:** Every Use Case MUST declare its schema container in `schema_containers...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/tile_imagery_repaint_test.dart` | 94 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/tile_imagery_repaint_test.dart` | 95 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/right_click_drag_test.dart` | 11 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/right_click_drag_test.dart` | 12 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/right_click_drag_test.dart` | 48 | `expect(controller.current.latitude, equals(35.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/right_click_drag_test.dart` | 49 | `expect(controller.current.longitude, equals(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 17 | `latitude: lat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 18 | `longitude: lng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 30 | `expect(cam.longitude, lessThan(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 31 | `expect(cam.latitude, lessThan(35.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 34 | `test('pan left (negative dx) increases longitude', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 36 | `final before = c.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 39 | `expect(after.longitude, greaterThan(before));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 40 | `expect(after.latitude, equals(35.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 46 | `test('pan up (negative dy) increases latitude', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 48 | `final before = c.current.latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 51 | `expect(after.latitude, greaterThan(before));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 52 | `expect(after.longitude, equals(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 59 | `expect(c.current.longitude, closeTo(-1.75638, 0.0001));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 60 | `expect(c.current.latitude, closeTo(-1.75638, 0.0001));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 63 | `test('pan clamps latitude to [-90, 90]', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 66 | `expect(c.current.latitude, equals(90.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 69 | `test('pan wraps longitude past 180', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 72 | `expect(c.current.longitude, lessThan(-160.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 81 | `expect(after.latitude, equals(before.latitude));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 82 | `expect(after.longitude, equals(before.longitude));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 90 | `expect(after.latitude, equals(35.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 101 | `expect(after.latitude, equals(before.latitude));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 102 | `expect(after.longitude, equals(before.longitude));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 111 | `expect(after.latitude, equals(before.latitude));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 112 | `expect(after.longitude, equals(before.longitude));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 129 | `test('longitude wraps around -180/+180 boundary', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 132 | `expect(c.current.longitude, lessThan(180));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 133 | `expect(c.current.longitude, greaterThan(155));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 136 | `test('keyboardRotate changes longitude only', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 139 | `expect(c.current.longitude, equals(145.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 140 | `expect(c.current.latitude, equals(35.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 147 | `expect(c.current.longitude, equals(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 148 | `expect(c.current.latitude, equals(35.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 195 | `expect(after.latitude, equals(before.latitude));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 196 | `expect(after.longitude, equals(before.longitude));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 236 | `latitude: 35.6,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 237 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 244 | `latitude: 40.7,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 245 | `longitude: -74.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 271 | `expect(controller.current.latitude, closeTo(40.7, 0.001));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 272 | `expect(controller.current.longitude, closeTo(-74.0, 0.001));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 280 | `final a = VirtualCamera(latitude: 35, longitude: 135, altitude: 500, heading: 0, pitch: -45, roll: 0...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 281 | `final b = VirtualCamera(latitude: 35, longitude: 135, altitude: 500, heading: 0, pitch: -45, roll: 0...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 285 | `final a = VirtualCamera(latitude: 35, longitude: 135, altitude: 500, heading: 0, pitch: -45, roll: 0...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/camera_controller_test.dart` | 286 | `final b = VirtualCamera(latitude: 36, longitude: 135, altitude: 500, heading: 0, pitch: -45, roll: 0...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_widget_test.dart` | 13 | `latitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_widget_test.dart` | 14 | `longitude: 0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 19 | `latitude: 35.0, longitude: 138.0, altitude: 2000000.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 67 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 68 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 107 | `math.pi, // opposite longitude` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 121 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 122 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 162 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 163 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 201 | `math.pi, // opposite longitude` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 230 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 231 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 258 | `0.5, // 30 degrees latitude` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 259 | `2.3, // 131 degrees longitude` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 275 | `final camera = VirtualCamera.clamped(latitude: 35.0, longitude: 138.0, altitude: 2000000.0, heading:...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 323 | `latitude: 35.0, longitude: 138.0, altitude: 2000000.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_test.dart` | 412 | `final camera = VirtualCamera.clamped(latitude: 35.0, longitude: 138.0, altitude: 2000000.0, heading:...` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 35 | `// dim0 = longitude (x), dim1 = latitude (y) per resolveCoordinate` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 43 | `dim0: 140.0, // longitude (x)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 44 | `dim1: 35.0,  // latitude (y)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 55 | `dim0: -75.0, // longitude (x)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 56 | `dim1: 50.0,   // latitude (y)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 131 | `latitude: lat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 132 | `longitude: lng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 177 | `expect(controller.current.latitude, 35.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 178 | `expect(controller.current.longitude, 140.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 182 | `final double pannedLongitude = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 183 | `expect(pannedLongitude, greaterThan(140.0),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 194 | `expect(afterController.current.latitude, 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 195 | `reason: 'Camera latitude should remain at ViewA coordinate since we decoupled single-click');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 196 | `expect(afterController.current.longitude, pannedLongitude,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 197 | `reason: 'Camera longitude should remain at panned coordinate since we decoupled single-click');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 208 | `final double pannedLat = controller.current.latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 209 | `final double pannedLng = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 217 | `expect(afterController.current.latitude, pannedLat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 218 | `reason: 'Camera latitude should be preserved when view is unchanged');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 219 | `expect(afterController.current.longitude, pannedLng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 220 | `reason: 'Camera longitude should be preserved when view is unchanged');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 250 | `expect(controller.current.longitude, isNot(135.0));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 269 | `expect(afterController.current.latitude, 50.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 270 | `expect(afterController.current.longitude, -75.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 284 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 285 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 305 | `final double pannedLng = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 313 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 314 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 328 | `expect(afterController.current.longitude, pannedLng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 338 | `expect(controller.current.latitude, 50.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 339 | `expect(controller.current.longitude, -75.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 342 | `final double pannedLat = controller.current.latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 343 | `final double pannedLng = controller.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 349 | `expect(afterController.current.latitude, pannedLat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 350 | `reason: 'Camera latitude preserved after tree notification');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 351 | `expect(afterController.current.longitude, pannedLng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 352 | `reason: 'Camera longitude preserved after tree notification');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 366 | `expect(afterNavController.current.latitude, 35.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 367 | `expect(afterNavController.current.longitude, 140.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 371 | `final double pannedLat = ctrl.current.latitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 372 | `final double pannedLng = ctrl.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 378 | `expect(afterController.current.latitude, pannedLat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 380 | `expect(afterController.current.longitude, pannedLng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 390 | `expect(controller.current.latitude, 50.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 391 | `reason: 'Initial camera should be at ViewB latitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 392 | `expect(controller.current.longitude, -75.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 393 | `reason: 'Initial camera should be at ViewB longitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 394 | `expect(controller.current.latitude, isNot(35.0),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 404 | `expect(controller.current.latitude, 35.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 405 | `expect(controller.current.longitude, 140.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 412 | `expect(afterSwitchCtrl.current.latitude, 35.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 413 | `expect(afterSwitchCtrl.current.longitude, 140.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 416 | `final double pannedLng = afterSwitchCtrl.current.longitude;` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 422 | `expect(backCtrl.current.latitude, 35.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 423 | `expect(backCtrl.current.longitude, pannedLng);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 435 | `expect(bCtrl.current.latitude, 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 437 | `expect(bCtrl.current.longitude, 140.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 443 | `expect(aCtrl.current.latitude, 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 445 | `expect(aCtrl.current.longitude, 140.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 454 | `latitude: lat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 455 | `longitude: lng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 498 | `expect(controller.current.latitude, closeTo(35.0, 0.1));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 499 | `expect(controller.current.longitude, closeTo(140.0, 0.1));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 537 | `expect(controller.current.latitude, isNot(closeTo(50.0, 0.1)),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 538 | `reason: 'Camera should not jump to B latitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 539 | `expect(controller.current.longitude, isNot(closeTo(-75.0, 0.1)),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 540 | `reason: 'Camera should not jump to B longitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 542 | `expect(controller.current.latitude, closeTo(35.0, 0.1),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 543 | `reason: 'Camera should be on the flight path near 35.0 latitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 544 | `expect(controller.current.longitude, closeTo(140.0, 1.0),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 545 | `reason: 'Camera should be on the flight path near 140.0 longitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 550 | `expect(controller.current.latitude, isNot(closeTo(50.0, 0.1)),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 551 | `reason: 'Camera should NOT jump to B latitude at frame $i');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 552 | `expect(controller.current.longitude, isNot(closeTo(-75.0, 0.1)),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 553 | `reason: 'Camera should NOT jump to B longitude at frame $i');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 607 | `expect(controller.current.latitude, -75.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/camera_reset_reproduction_test.dart` | 608 | `expect(controller.current.longitude, 50.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/adversarial_fuzzer_test.dart` | 63 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/adversarial_fuzzer_test.dart` | 64 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/adversarial_fuzzer_test.dart` | 89 | `latitude: lat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/adversarial_fuzzer_test.dart` | 90 | `longitude: lng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/adversarial_fuzzer_test.dart` | 179 | `-(camera.longitude * math.pi / 180.0),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d/adversarial_fuzzer_test.dart` | 180 | `-(camera.latitude * math.pi / 180.0),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 161 | `dim0: 139.7, // longitude (x)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 162 | `dim1: 35.6,  // latitude (y)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 173 | `dim0: -74.0, // longitude (x)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 174 | `dim1: 40.7,  // latitude (y)` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 286 | `expect(controller.current.latitude, 35.6,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 287 | `reason: 'Initial camera should be centered on Node A latitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 288 | `expect(controller.current.longitude, 139.7,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 289 | `reason: 'Initial camera should be centered on Node A longitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 306 | `expect(controller.current.latitude, 35.6,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 307 | `reason: 'ACCEPTANCE CRITERIA: Camera latitude must NOT jump/move on single-click');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 308 | `expect(controller.current.longitude, 139.7,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 309 | `reason: 'ACCEPTANCE CRITERIA: Camera longitude must NOT jump/move on single-click');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 330 | `expect(controller.current.latitude, greaterThan(35.6),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 331 | `reason: 'Camera latitude should have started moving towards Node B coordinates');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 332 | `expect(controller.current.longitude, isNot(139.7),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 333 | `reason: 'Camera longitude should have started moving towards Node B coordinates');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 339 | `expect(controller.current.latitude, 40.7,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 340 | `reason: 'Camera should have arrived at Node B latitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 341 | `expect(controller.current.longitude, -74.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 342 | `reason: 'Camera should have arrived at Node B longitude');` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 380 | `expect(controller.current.latitude, 35.6);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 381 | `expect(controller.current.longitude, 139.7);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 408 | `expect(controller.current.latitude, greaterThan(35.6));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 409 | `expect(controller.current.longitude, isNot(139.7));` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 413 | `expect(controller.current.latitude, 40.7);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/double_click_fly_acceptance_test.dart` | 414 | `expect(controller.current.longitude, -74.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 13 | `latitude: 37.7749,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 14 | `longitude: -122.4194,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 21 | `expect(camera.latitude, 37.7749);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 22 | `expect(camera.longitude, -122.4194);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 30 | `test('Throws validation exception for invalid latitude', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 33 | `latitude: 95.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 34 | `longitude: -122.4194,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 44 | `test('Throws validation exception for invalid longitude', () {` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 47 | `latitude: 37.7749,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 48 | `longitude: -185.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 61 | `latitude: 37.7749,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 62 | `longitude: -122.4194,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 74 | `latitude: 120.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 75 | `longitude: -200.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 82 | `expect(camera.latitude, 90.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 83 | `expect(camera.longitude, -180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 90 | `latitude: double.nan,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 91 | `longitude: -122.4194,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 101 | `latitude: 37.7749,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 102 | `longitude: double.infinity,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 114 | `latitude: double.nan,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 115 | `longitude: double.infinity,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 122 | `expect(camera.latitude, 0.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 123 | `expect(camera.longitude, 0.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 167 | `latitude: 37.7749,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 168 | `longitude: -122.4194,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 177 | `latitude: 37.7749,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 178 | `longitude: -122.4194,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 200 | `latitude: 37.7749,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/cesium_3d_test.dart` | 201 | `longitude: -122.4194,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scroll_zoom_test.dart` | 18 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scroll_zoom_test.dart` | 19 | `longitude: 140.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/features/topology/globe_rendering_benchmark_test.dart` | 70 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/features/topology/globe_rendering_benchmark_test.dart` | 71 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/features/topology/globe_rendering_benchmark_test.dart` | 88 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/features/topology/globe_rendering_benchmark_test.dart` | 89 | `longitude: 135.0 + (f * 0.1),` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 40 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 41 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 82 | `latitude: 35.3606,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 83 | `longitude: 138.7274,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 97 | `dim0: 138.7274, // longitude` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 98 | `dim1: 35.3606,  // latitude` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 166 | `latitude: lat,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 167 | `longitude: lng,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 189 | `final double rotationAngle = - (camera.longitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 190 | `final double tilt = - (camera.latitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 278 | `latitude: 35.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 279 | `longitude: 135.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 320 | `latitude: 35.18,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 321 | `longitude: 136.90,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 400 | `final double rotationAngle = - (camera.longitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 401 | `final double tilt = - (camera.latitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 425 | `latitude: 35.18,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 426 | `longitude: 136.90,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 466 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 467 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 506 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 507 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 545 | `latitude: 35.3606,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 546 | `longitude: 138.7274,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 602 | `final double rotationAngle = -(camera.longitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 603 | `final double tilt = -(camera.latitude * math.pi / 180.0);` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 629 | `latitude: 35.3606,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 630 | `longitude: 138.7274,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 673 | `latitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 674 | `longitude: 0.0,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 697 | `final double lng = 2.0; // Off-axis culled longitude to ensure non-zero perpendicular component` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 729 | `latitude: 35.3606,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
| `app_flutter/test/topology/scene_3d_viewport_golden_test.dart` | 730 | `longitude: 138.7274,` | Rename to domain-agnostic terms (e.g. x/y/z or physical dimensions) |
