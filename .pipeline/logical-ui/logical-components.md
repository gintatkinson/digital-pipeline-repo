# Logical UI Component Specifications

This document defines the platform-agnostic structural, behavioral, and API requirements for the core logical components of the Digital Systems Engineering Pipeline.

---

## 1. HierarchyTree
- **Anatomy:** Scrollable view container, parent/child nodes, expansion toggles, context menus, and node drag/drop anchors.
- **Behavior:** `ArrowUp`/`ArrowDown` focus navigation. `ArrowRight` expands, `ArrowLeft` collapses.
- **Accessibility:** In virtualized flat-list implementations, each row must carry `role="treeitem"`, `aria-level="[Depth]"`, and `aria-expanded="[true|false]"` tags. The container must declare `role="tree"`.
- **Event Limits:** Selection updates trigger `onNodeSelect` only on user interaction. Property setters must modify selections silently.

## 2. ResizableSplitter
- **Anatomy:** Primary and Secondary panes separated by an interactive split bar.
- **Behavior:** Minimum size constraints (default 150px). Snap-to-edge collapse capabilities. 
- **Reconfigurability:** Supports swapping vertical/horizontal axis and pane order without state destruction (using React DOM absolute isolation or Flutter `GlobalKey` state retention).

## 3. NavigationBreadcrumbs
- **Anatomy:** Ordered path segment links with sibling drop-down popover panels.
- **Behavior:** Collapses middle path segments into an ellipsis (`...`) if total text exceeds available container width.

## 4. PropertyGrid
- **Anatomy:** Key-value attribute grid mapped to a schema.
- **Behavior:** Input fields validate on blur. Keeps a local change-buffer to prevent triggering global state re-renders on every keystroke.
- **Performance:** JSON-Schemas are compiled *once* at initialization into a flat, typed **Logical Layout Descriptor** list, avoiding render-cycle parsing lag.

## 5. TopologyMap (3D/4D Spatial-Temporal Canvas)
- **Anatomy:** 3D WebGL/WebGPU/Impeller viewport displaying nodes and directional links in 3D coordinate space, dynamic trajectory path lines, volumetric bounding indicators (e.g. orbital cones, subsea sectors), and an overlay time-control bar (play/pause, timeline scrubber, playback speed multiplier).
- **Behavior:** Centers layout focus on selected items. Highlights node outline colors matching active ITU-T X.733 alarm severities. Supports grouping and filtering objects dynamically based on spatial-temporal boundaries (e.g., displaying rovers, satellites, or subsea sensors inside a specific 3D coordinates volume at time $t$ along their projected trajectories).
- **Performance:** 4D coordinate transformations, orbital path projections, and layout physics are executed off the main thread (Web Workers/Isolates) and accelerated in parallel using WebGPU/Impeller compute shaders.

## 6. DensityTable
- **Anatomy:** High-density grid containing columns, rows, sort indicators, and multiselect checkboxes.
- **Columns:** Dynamically constructed based on the selected/associated managed object's data schema to display all configured/allowed attributes, properties, and child elements. Includes standard attributes (Object Icon, Name, Type, Family, Alarms, Primary State, Secondary States) alongside all schema-defined attributes.
- **Performance:** Virtualized row rendering (only viewport rows are rendered in the DOM).
- **Tabbed Layout Integration:** To support legacy (e.g. IBM ILOG JViews TGO) and next-gen workflows, multiple specialized DensityTables (e.g. Elements, Alarms, Events) are organized inside a bottom-docked `TabbedContainer`, dynamically loading lists associated with the selected topological managed object.

## 7. ContextualPanel
- **Anatomy:** Side drawer panel sliding from the viewport edges.
- **Behavior:** Captures keyboard `Escape` key events to trigger dismiss requests.
