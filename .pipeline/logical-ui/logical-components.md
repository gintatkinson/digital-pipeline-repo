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

## 5. TopologyMap
- **Anatomy:** Panning/zooming WebGL/Canvas viewport displaying nodes (managed objects) and links (directional relationships), overlay control panel (zoom, fit, depth/hop limit, relation type toggles).
- **Behavior:** Centers layout focus on selection changes. Updates node outline colors matching active ITU-T X.733 Alarm severities.
- **Performance:** Complex layout calculations (force-directed calculations) must run off the main thread (Web Workers in React, Isolates in Flutter). At scale, uses GPGPU compute shaders.

## 6. DensityTable
- **Anatomy:** High-density grid containing columns, rows, sort indicators, and multiselect checkboxes.
- **Columns:** Dynamically constructed based on the selected/associated managed object's data schema to display all configured/allowed attributes, properties, and child elements. Includes standard attributes (Object Icon, Name, Type, Family, Alarms, Primary State, Secondary States) alongside all schema-defined attributes.
- **Performance:** Virtualized row rendering (only viewport rows are rendered in the DOM).

## 7. ContextualPanel
- **Anatomy:** Side drawer panel sliding from the viewport edges.
- **Behavior:** Captures keyboard `Escape` key events to trigger dismiss requests.
