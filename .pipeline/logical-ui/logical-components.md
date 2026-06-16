# Logical UI Component Specifications

This document defines the platform-agnostic structural, behavioral, and API requirements for the core logical components of the Digital Systems Engineering Pipeline.

---

## 1. HierarchyTree
- **Anatomy:** Scrollable view container, parent/child nodes, expansion toggles, context menus, and node drag/drop anchors.
- **Behavior:** Exposes logical action bindings (such as `NAVIGATE_NEXT`, `NAVIGATE_PREVIOUS`, `EXPAND_NODE`, `COLLAPSE_NODE`) to be mapped to platform-specific inputs (e.g., keyboard shortcuts, touch gestures) at runtime.
- **Accessibility:** The component must expose structural hierarchy metadata (such as node depth, expansion state, and parent-child relationships) to allow the platform-specific implementation layer to construct appropriate accessibility interfaces.
- **Event Limits:** Selection updates trigger selection callbacks only on user interaction. Property setters must modify selections silently.

## 2. ResizableSplitter
- **Anatomy:** Primary and Secondary panes separated by an interactive split bar.
- **Behavior:** Minimum size constraints (default defined by the dynamic layout configuration token). Snap-to-edge collapse capabilities. 
- **Reconfigurability:** Supports swapping vertical/horizontal axis and pane order without state destruction (using platform-native state preservation mechanics).


## 3. NavigationBreadcrumbs
- **Anatomy:** Ordered path segment links with sibling drop-down popover panels.
- **Behavior:** Collapses middle path segments into an ellipsis (`...`) if total text exceeds available container width.

## 4. PropertyGrid
- **Anatomy:** Key-value attribute grid mapped to a schema.
- **Behavior:** Input fields validate upon focus loss or editing completion. Keeps a local change-buffer to prevent triggering global state re-renders on every keystroke.
- **Performance:** JSON-Schemas are compiled *once* at initialization into a flat, typed **Logical Layout Descriptor** list, avoiding render-cycle parsing lag.

## 5. TopologyMap (3D/4D Spatial-Temporal Canvas)
- **Anatomy:** A hardware-accelerated viewport displaying nodes and directional links in 3D coordinate space, dynamic trajectory path lines, volumetric bounding indicators (e.g. orbital cones, subsea sectors), and an overlay time-control bar (play/pause, timeline scrubber, playback speed multiplier).
- **Behavior:** Centers layout focus on selected items. Highlights node outline colors based on the active alarm severity mapping configuration. Supports grouping and filtering objects dynamically based on spatial-temporal boundaries (e.g., displaying rovers, satellites, or subsea sensors inside a specific 3D coordinates volume at time $t$ along their projected trajectories).
- **Performance:** 4D coordinate transformations, orbital path projections, and layout physics are executed off the main thread (using off-thread execution environments) and accelerated in parallel using GPU compute shaders.


## 6. DensityTable
- **Anatomy:** High-density grid containing columns, rows, sort indicators, and multiselect checkboxes.
- **Columns:** Dynamically constructed based on the selected/associated managed object's data schema to display all configured/allowed attributes, properties, and child elements. Includes standard attributes (Object Icon, Name, Type, Family, Alarms, Primary State, Secondary States) alongside all schema-defined attributes.
- **Performance:** Supports virtualized list rendering to optimize viewport performance.
- **Tabbed Layout Integration:** To support legacy industrial state visualizations and next-gen workflows, multiple specialized DensityTables (e.g. Elements, Alarms, Events) are organized inside a bottom-docked `TabbedContainer`, dynamically loading lists associated with the selected topological managed object.

## 7. ContextualPanel
- **Anatomy:** Side drawer panel sliding from the viewport edges.
- **Behavior:** Captures logical escape triggers to dismiss the panel.
