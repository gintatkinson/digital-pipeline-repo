# Implementation Plan: Refactor Basemap Configuration

This plan covers the dynamic configuration of basemaps in the application. Hardcoded URLs in `TileFetcher` will be moved to `app_flutter/assets/persistence-config.json` and loaded during application/test startup.

## 1. Goal Description
1. Modify `app_flutter/lib/domain/cesium_3d/tile_fetcher.dart` to support dynamic loading of tile URLs using URL templates.
2. Move hardcoded endpoints (OSM, ArcGIS, CartoDB) into `app_flutter/assets/persistence-config.json`.
3. Update `app_flutter/lib/domain/repository_resolver.dart` to read `basemaps` config from `persistence-config.json` at startup and pass it to `TileFetcher`.
4. Update unit tests in `app_flutter/test/cesium_3d/tile_fetcher_test.dart` to verify dynamic loading and URL construction.
5. Run tests to verify the changes.

---

## 2. Target Files & Proposed Changes

### A. [app_flutter/assets/persistence-config.json](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/assets/persistence-config.json)
Update the configuration JSON to include a `basemaps` key containing the URL templates for each provider:
```json
{
  "repository_type": "sqlite",
  "basemaps": {
    "openStreetMap": "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    "arcGisSatellite": "https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
    "cartoDark": "https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png",
    "cartoLight": "https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"
  }
}
```

### B. [app_flutter/lib/domain/cesium_3d/tile_fetcher.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/domain/cesium_3d/tile_fetcher.dart)
- Define a static map `_basemapTemplates` to hold the URL templates.
- Add a static method `static void configure(Map<String, dynamic> configs)` to populate `_basemapTemplates`.
- Replace the hardcoded switch-case in `TileFetcher.urlFor` to construct the URL dynamically from `_basemapTemplates` by replacing `{x}`, `{y}`, `{z}`.
- Provide a default static initializer or fallbacks in `TileFetcher` so that if configure is not called (or template is missing), it has safe default URLs (matching the original ones) or fails gracefully.
  *Note:* To comply fully with "Move hardcoded basemap endpoints (OSM, ArcGIS, CartoDB) to 'app_flutter/assets/persistence-config.json' and read them at startup", the hardcoded endpoints will NOT be the primary static values inside `tile_fetcher.dart`. We will load them from the config. To ensure tests and app always initialize correctly, they will be read at startup, or tests will explicitly configure them.

### C. [app_flutter/lib/domain/repository_resolver.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/domain/repository_resolver.dart)
- In `RepositoryResolver.resolve`, always read the configuration file (even if `dataSourceType` is provided) so we can parse the `basemaps` key.
- If `basemaps` key exists in the loaded configuration, call `TileFetcher.configure(...)`.

### D. [app_flutter/test/cesium_3d/tile_fetcher_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/tile_fetcher_test.dart)
- In `setUp` or `setUpAll`, configure `TileFetcher` with either mock URL templates or the actual ones from `assets/persistence-config.json` so that the synchronous `TileFetcher.urlFor` tests continue to function.

---

## 3. Detailed Execution Matrix

| Step | Action | Target Path / Command |
| :--- | :--- | :--- |
| **1** | Update `persistence-config.json` with the basemap URL templates. | [persistence-config.json](app_flutter/assets/persistence-config.json) |
| **2** | Modify `tile_fetcher.dart` to support configuring templates and building URLs dynamically. | [tile_fetcher.dart](app_flutter/lib/domain/cesium_3d/tile_fetcher.dart) |
| **3** | Update `repository_resolver.dart` to load and pass the config to `TileFetcher`. | [repository_resolver.dart](app_flutter/lib/domain/repository_resolver.dart) |
| **4** | Update `tile_fetcher_test.dart` to configure templates in setup. | [tile_fetcher_test.dart](app_flutter/test/cesium_3d/tile_fetcher_test.dart) |
| **5** | Run the unit tests and integration tests to verify correctness. | `flutter test` / `flutter drive` |

---

## 4. Verification Plan

### Automated Verification
- Run unit tests: `flutter test test/cesium_3d/tile_fetcher_test.dart`
- Run all tests to check for regression: `flutter test`
