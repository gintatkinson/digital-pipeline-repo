import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/features/tree/view_models/tree_view_model.dart';
import 'package:app_flutter/features/tree/sidebar_tree.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';

import 'package:app_flutter/features/layout/split_workspace.dart';
import 'package:app_flutter/features/tables/tabbed_container.dart';
import 'package:app_flutter/features/tables/table_view_widget.dart';
import 'package:app_flutter/features/topology/topographical_view.dart';
import 'package:app_flutter/features/topology/topology_map.dart';
import 'package:app_flutter/features/tree/tree_node.dart';

class ComponentFactory {
  final List<TreeNode> treeData;
  final String currentView;
  final int? workerResult;
  final String themeMode;
  final Map<String, dynamic> parsedLayout;
  final void Function(String) onViewSelected;
  final void Function(String) onThemeModeChange;
  final double minPaneSize;
  final double Function() defaultRatio;
  final TopologyData Function() resolveTopologyData;
  final String Function(String) resolveTabLabel;
  final Widget Function(BuildContext) buildChildWidget;
  final TreeViewModel? treeViewModel;

  ComponentFactory({
    required this.treeData,
    required this.currentView,
    required this.workerResult,
    required this.themeMode,
    required this.parsedLayout,
    required this.onViewSelected,
    required this.onThemeModeChange,
    required this.minPaneSize,
    required this.defaultRatio,
    required this.resolveTopologyData,
    required this.resolveTabLabel,
    required this.buildChildWidget,
    this.treeViewModel,
  });

  Widget build(
    Map<String, dynamic> node,
    double parentWidth,
    double parentHeight,
    BuildContext context,
  ) {
    final type = node['type'] as String?;
    switch (type) {
      case 'SidebarLayout':
        final childrenList = node['children'] as List<dynamic>? ?? [];
        final sidebarChild = childrenList.firstWhere(
          (c) => c['type'] == 'HierarchyTreeSelector',
          orElse: () => null,
        );
        final splitWorkspaceChild = childrenList.firstWhere(
          (c) => c['type'] == 'SplitWorkspace',
          orElse: () => null,
        );
        return SplitWorkspace(
          leading: sidebarChild != null
              ? build(sidebarChild as Map<String, dynamic>, parentWidth, parentHeight, context)
              : const SizedBox.shrink(),
          trailing: splitWorkspaceChild != null
              ? build(splitWorkspaceChild as Map<String, dynamic>, parentWidth, parentHeight, context)
              : const SizedBox.shrink(),
          direction: Axis.horizontal,
          minFirstPaneSize: minPaneSize,
          initialRatio: 0.25,
          splitterKey: const Key('vertical_splitter'),
        );
      case 'HierarchyTreeSelector':
        final tree = SidebarTree(
          treeData: treeData,
          workerResult: workerResult,
          themeMode: themeMode,
          onViewSelected: onViewSelected,
          onThemeModeChange: onThemeModeChange,
        );
        if (treeViewModel != null) {
          return ChangeNotifierProvider<TreeViewModel>.value(
            value: treeViewModel!,
            child: tree,
          );
        }
        return tree;
      case 'SplitWorkspace':
        final childrenList = node['children'] as List<dynamic>? ?? [];
        final topoChild = childrenList.firstWhere(
          (c) => c['type'] == 'TopographicalView',
          orElse: () => null,
        );
        final tabbedChild = childrenList.firstWhere(
          (c) => c['type'] == 'TabbedContainer',
          orElse: () => null,
        );
        return SplitWorkspace(
          leading: topoChild != null
              ? build(topoChild as Map<String, dynamic>, parentWidth, parentHeight, context)
              : const SizedBox.shrink(),
          trailing: tabbedChild != null
              ? build(tabbedChild as Map<String, dynamic>, parentWidth, parentHeight, context)
              : const SizedBox.shrink(),
          direction: Axis.vertical,
          minFirstPaneSize: minPaneSize,
          initialRatio: defaultRatio(),
          splitterKey: const Key('horizontal_splitter'),
        );
      case 'TopographicalView':
        return TopographicalView(
          currentView: currentView,
          parsedLayout: parsedLayout,
          onViewSelected: onViewSelected,
          child: buildChildWidget(context),
          topologyData: resolveTopologyData(),
        );
      case 'TabbedContainer':
        final childrenList = node['children'] as List<dynamic>? ?? [];
        final tabs = childrenList.map((c) {
          final id = c['id'] as String;
          final label = resolveTabLabel(id);
          return TabConfig(
            id: id,
            label: label,
            contentBuilder: (_) =>
                build(c as Map<String, dynamic>, parentWidth, parentHeight, context),
          );
        }).toList();
        return TabbedContainer(
          tabs: tabs,
          initialTabId: tabs.isNotEmpty ? tabs.first.id : '',
        );
      case 'TableView':
        final id = node['id'] as String? ?? '';
        final repository = context.read<AbstractRepository>();
        final tablesViewModel = TablesViewModel(repository, id, currentView);
        return ChangeNotifierProvider<TablesViewModel>.value(
          value: tablesViewModel,
          child: const TableViewWidget(),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
