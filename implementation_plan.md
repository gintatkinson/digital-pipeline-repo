# Implementation Plan: Recursive Parent-Child Topological Hierarchy

This plan details the changes to support recursive, lazy-loaded parent-child relationships (roots, children, and grandchildren) in the sidebar tree backed by SQLite.

---

## Proposed Changes

### 1. SQLite Schema & Seeding Expansion
- **File**: `app_flutter/lib/domain/database_initializer.dart`
- **Action**:
  - Update `properties` table creation: Add `parent_node_id TEXT REFERENCES properties(node_id)`.
  - Refactor seeding to generate a nested topology:
    - **Root Nodes (1,000)**: `Master_1` to `Master_1000` (parent is `NULL`).
    - **Child Nodes (5 per root)**: `Master_N_Child_1` to `Master_N_Child_5` (parent is `Master_N`).
    - **Grandchild Nodes (2 per child)**: `Master_N_Child_M_Grandchild_1` to `Master_N_Child_M_Grandchild_2` (parent is `Master_N_Child_M`).
  - Update properties values and types definition loops to match.
  - Compile the new gzipped database asset.

---

### 2. Data Source Query Refactoring
- **Files**:
  - `app_flutter/lib/domain/data_source.dart`
  - `app_flutter/lib/domain/data_sources/sqlite_data_source.dart`
- **Action**:
  - Add query methods:
    - `Future<List<TreeNode>> fetchRootNodes()`: Fetches all nodes where `parent_node_id IS NULL`.
    - `Future<List<TreeNode>> fetchChildrenForNode(String parentId)`: Fetches immediate child nodes where `parent_node_id = parentId`.

---

### 3. Lazy-Loaded View Model (TreeViewModel)
- **File**: `app_flutter/lib/features/tree/view_models/tree_view_model.dart`
- **Action**:
  - Refactor `loadTree` to load only the root nodes on startup.
  - Add `Future<void> expandNode(TreeNode node)` to fetch children on demand from the database and insert them dynamically.
  - Exclude detail instances from expanding as tree nodes if they are represented in detail tables.

---

### 4. UI Expansion Tile Async Integration (SidebarTree)
- **File**: `app_flutter/lib/features/tree/sidebar_tree.dart`
- **Action**:
  - Update `SidebarTree` to trigger `expandNode` when a node is expanded in the tree.
  - Display a dynamic progress indicator next to the node icon during active database fetches.

---

## Verification Plan

### Step 1: Database Verification
1. Run the database compiler:
   ```bash
   (cd app_flutter && dart run lib/domain/database_initializer.dart)
   ```
2. Verify nested references:
   ```bash
   sqlite3 app_flutter/assets/properties_db.db "SELECT count(*) FROM properties WHERE parent_node_id IS NOT NULL;"
   ```

### Step 2: Automated Tests
- Run `flutter test` and integration audits to ensure the lazy loading resolves frame timings within 16.6ms.
