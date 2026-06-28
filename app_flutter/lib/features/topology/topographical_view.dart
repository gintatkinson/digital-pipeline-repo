import 'package:flutter/material.dart';
import 'package:app_flutter/features/layout/breadcrumbs.dart';
import 'package:app_flutter/features/topology/topology_map.dart';
import 'package:app_flutter/features/layout/split_workspace.dart';

class TopographicalView extends StatelessWidget {
  final String currentView;
  final Map<String, dynamic> parsedLayout;
  final ValueChanged<String> onViewSelected;
  final Widget? child;
  final TopologyData topologyData;

  const TopographicalView({
    super.key,
    required this.currentView,
    required this.parsedLayout,
    required this.onViewSelected,
    this.child,
    required this.topologyData,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[TOPOGRAPHICAL_VIEW] build: currentView=$currentView');
    final body = child != null
        ? SplitWorkspace(
            leading: TopologyMap(
              activeFocusedNode: currentView,
              onNodeSelect: onViewSelected,
              data: topologyData,
            ),
            trailing: child!,
            direction: Axis.vertical,
            minFirstPaneSize: 100.0,
            initialRatio: 0.4,
            splitterKey: const Key('topo_splitter'),
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
                      items: getBreadcrumbsItems(currentView, parsedLayout, onSelectView: onViewSelected),
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
