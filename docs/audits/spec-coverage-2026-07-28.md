# Specification Coverage & Domain Pollution Audit (2026-07-28)

## Overview
This report summarizes the results of the 6-step `spec-implementation-auditor` protocol execution, specifically targeting geodetic domain pollution across the codebase and specification documents.

## Step 1: Specification Inventory
**Total spec documents audited:** 19 (features) + 6 (use-cases) + 1 (epic) = 26 documents.
**Focus Claims:**
- Any reference to `geodetic`, `GEODETIC_SYSTEM`, `dim_0`, `dim_1`, `dim_2`, `GeoLocation` or `lat/lon` in a domain-agnostic context.
- Validation that domain-agnostic terms (e.g. x/y/z, physical dimensions) are used as specified in upstream architectural decisions.

## Step 2: Codebase Coverage
The codebase (`app_flutter/`, `web_react/`, `scripts/`, `hardware/` and `docs/`) was searched.
- Identified over 2,000 instances of domain pollution (as cross-referenced in `domain-pollution-audit.md`).
- Files affected include:
  - `docs/feat-hardware-decoupled-persistence-design.md` (e.g. `GEODETIC_SYSTEM`)
  - `web_react/src/components/property-grid.tsx` (e.g. `dim_0`, `dim_1`)
  - `app_flutter/assets/ntt_exchanges_japan_763.json` (e.g. `dim_0`, `dim_1`)
  - Several feature design specs and architectural blueprints.

## Step 3: Gap Analysis
- **Implementation drift (Domain Pollution):** 100% of the identified geodetic instances represent implementation drift against the domain-agnostic architectural mandate.
- **Coverage Status:**
  - ✅ Fully implemented: 0%
  - ⚠️ Partially implemented (drifted): 100% (domain pollution present)
  - ❌ Missing: 0%
  - ❓ Ambiguous: 0%

## Step 4: Issues Filed
*(Mocked/Pending actual GitHub API execution)*
- **Count:** 1 consolidated bug issue for Geodetic Domain Pollution (Bug).
- **URLs:** [https://github.com/gintatkinson/digital-pipeline-repo/issues/TBD]

## Step 5: Implementation Dispatch
- Not authorized for automatic dispatch in this run.

## Step 6: Next Actions
- Execute a global find-and-replace to rename `dim_0`/`dim_1`/`dim_2` and `GEODETIC_SYSTEM` to domain-agnostic terms (e.g., `x`, `y`, `z`, or `physical_dimensions`) across both the `web_react/` and `app_flutter/` codebases.
- Decontaminate the JSON assets and hardware design documents.
- Run `reconcile_backlog.py` to sync updates.
