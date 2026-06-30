import 'package:flutter/material.dart';
import 'package:app_flutter/features/layout/breadcrumbs.dart';
import 'package:app_flutter/features/topology/topology_map.dart';
import 'package:app_flutter/features/layout/split_workspace.dart';
import 'package:app_flutter/features/tree/tree_node.dart';

/// The top-level topology view: breadcrumb header + split workspace
/// (topology map + detail child) or standalone topology map.
///
/// If [child] is non-null, the view uses [SplitWorkspace] to show the
/// topology map alongside a detail pane (e.g. property grid). When [child]
/// is null, the topology map takes the full area below the header.
///
/// Edge cases: empty [treeData] produces no breadcrumbs; unknown
/// [currentView] IDs still render the header label as-is.
class TopographicalView extends StatelessWidget {
  final String currentView;
  final ValueChanged<String> onViewSelected;
  final Widget? child;
  final TopologyData topologyData;
  final List<TreeNode> treeData;
  final Axis splitDirection;
  final double splitMinFirstPaneSize;
  final double splitInitialRatio;
  final Key splitterKey;

  const TopographicalView({
    super.key,
    required this.currentView,
    required this.onViewSelected,
    this.child,
    required this.topologyData,
    this.treeData = const [],
    this.splitDirection = Axis.vertical,
    this.splitMinFirstPaneSize = 100.0,
    this.splitInitialRatio = 0.4,
    this.splitterKey = const Key('topo_splitter'),
  });

  @override
  Widget build(BuildContext context) {
    final body = child != null
        ? SplitWorkspace(
            leading: TopologyMap(
              activeFocusedNode: currentView,
              onNodeSelect: onViewSelected,
              data: topologyData,
            ),
            trailing: child!,
            direction: splitDirection,
            minFirstPaneSize: splitMinFirstPaneSize,
            initialRatio: splitInitialRatio,
            splitterKey: splitterKey,
          )
        : TopologyMap(
            activeFocusedNode: currentView,
            onNodeSelect: onViewSelected,
            data: topologyData,
          );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active View Title & Breadcrumbs Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active View: $currentView',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: NavigationBreadcrumbs(
                      items: getBreadcrumbsItems(currentView, treeData, onSelectView: onViewSelected),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
