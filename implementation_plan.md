# Decontamination & Refactoring Plan - Upstream Specifications

This plan defines the systematic search-and-replace operations to decontaminate all upstream specification, design, requirement, and report files in the repository from geodetic and hardware-specific domain vocabulary.

---

## 1. Decontamination Mapping Rules

We will apply the following mapping rules case-insensitively across all `.md` files in `docs/`:

| Source Domain Term | Target Domain-Agnostic Term |
|---|---|
| `latitude` | `dim_0` |
| `longitude` | `dim_1` |
| `altitude` / `height` / `elevation` | `dim_2` |
| `WGS84` / `Geodetic` / `Ellipsoid` | `Geometry` |
| `Velocity` / `Speed` | `RateOfChange` |
| `Rack` / `Chassis` | `SlotContainer` |
| `Cable Landing Station` | `InterfaceNode` |
| `NTT Exchange` | `CoreExchange` |

### Case-Preservation Rules:
- PascalCase: `Latitude` -> `Dim_0`, `Longitude` -> `Dim_1`, `Altitude` -> `Dim_2`, `Height` -> `Dim_2`, `Elevation` -> `Dim_2`, `WGS84` -> `Geometry`, `Geodetic` -> `Geometry`, `Ellipsoid` -> `Geometry`, `Velocity` -> `RateOfChange`, `Speed` -> `RateOfChange`, `Rack` -> `SlotContainer`, `Chassis` -> `SlotContainer`, `Cable Landing Station` -> `InterfaceNode`, `NTT Exchange` -> `CoreExchange`.
- camelCase/lowercase: `latitude` -> `dim_0`, `longitude` -> `dim_1`, `altitude` -> `dim_2`, `height` -> `dim_2`, `elevation` -> `dim_2`, `wgs84` -> `geometry`, `geodetic` -> `geometry`, `ellipsoid` -> `geometry`, `velocity` -> `rateOfChange`, `speed` -> `rateOfChange`, `rack` -> `slotContainer`, `chassis` -> `slotContainer`, `cable landing station` -> `interfaceNode`, `ntt exchange` -> `coreExchange`.
- snake_case: `cable_landing_station` -> `interface_node`, `ntt_exchange` -> `core_exchange`.

---

## 2. Target Files for Purging

All `.md` files under the `docs/` directory containing any of the source terms will be decontaminated:
*   `docs/features/feat-002-alternate-systems.md`
*   `docs/features/feat-03-dynamics-temporal.md`
*   `docs/features/feat-04-numeric-metrics.md`
*   `docs/features/feat-10-logical-ui-layout.md`
*   `docs/features/feat-11-topology-map.md`
*   `docs/features/feat-18-parent-epic-linkage.md`
*   `docs/features/feat-28-traceability-gate.md`
*   `docs/features/feat-44-downstream-baseline.md`
*   `docs/use-cases/uc-02-local-firebase-emulator.md`
*   `docs/decisions/adversarial_audit_report.md`
*   `docs/decisions/adversarial_audit_synthesis.md`
*   `docs/decisions/adversarial_hardcode_audit_report.md`
*   `docs/decisions/audits/gpgpu_performance_critique.md`
*   `docs/decisions/audits/pipeline_integration_critique.md`
*   `docs/decisions/audits/ui_sync_isolates_critique.md`
*   `docs/decisions/consolidated_decision_making_report.md`
*   `docs/decisions/incident_retrospective.md`
*   `docs/decisions/pipeline_analysis_report.md`
*   `docs/decisions/uml_compliance_audit_report.md`
*   `docs/decisions/uml_frontend_alignment_audit.md`
*   `docs/decisions/upstream_decontamination_baseline_report.md`
*   `docs/designs/feat-11-solution.md`
*   `docs/designs/feat-44-solution.md`
*   `docs/designs/feat-58-solution.md`
*   `docs/designs/feat-65-solution.md`
*   `docs/designs/feat-adversarial-audit-solution.md`
*   `docs/designs/feat-backprop-downstream-changes.md`
*   `docs/designs/feat-backprop-flutter-source-changes.md`
*   `docs/designs/feat-cleanup-stale-domain-features.md`
*   `docs/designs/feat-epic-template-mandate-plan.md`
*   `docs/designs/feat-fix-onboarding-instructions.md`
*   `docs/designs/feat-fix-readme-installation.md`
*   `docs/designs/feat-pipeline-audit-solution.md`
*   `docs/designs/feat-usecase-alternate-flows-solution.md`
*   `docs/designs/multi-process-flutter-orchestration.md`
*   `docs/designs/persistence-architecture-blueprint.md`
*   `docs/feat-decoupled-persistence-layout-engine-design.md`
*   `docs/feat-firestore-persistence-adapter-design.md`
*   `docs/feat-hardware-decoupled-persistence-design.md`
*   `docs/requirements/dynamic-geolocation-motion-blueprint.md`
*   `docs/cable_landing_stations_report.md`
*   `docs/ntt_exchanges_report.md`
*   `docs/remediation_plan.md`
*   `docs/sprint-implementation-plan.md`
*   `docs/audits/domain-pollution-audit.md`
*   `docs/audits/spec-coverage-2026-07-18.md`
*   `docs/consolidated_logical_ui_design_report.md`
*   `docs/operations/sbom.md`
*   `docs/operations/yang-compiler-guide.md`
*   `docs/process/feature-driven-workflow.md`

---

## 3. Execution Plan

We will perform the case-insensitive replacements in these files.
Special care will be taken to ensure:
- Mermaid diagram syntax remains valid (no curly braces inside class member lines, no secondary colons, matching fences).
- In Markdown tables and reference links, we preserve structural delimiters.

---

## 4. Verification Plan

### Automated Checks
1. Run the spec-only coverage linter gate checks:
   `python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only`
2. Run the backlog reconciliation script:
   `python3 skills/spec-orchestrator/scripts/reconcile_backlog.py`
3. Verify that `git diff origin/main` contains only the decontaminated markdown and config updates.
