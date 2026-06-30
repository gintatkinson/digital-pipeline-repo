import 'package:flutter/material.dart';
import 'package:app_flutter/features/tree/tree_node.dart';

/// A single item in the breadcrumbs navigation.
class BreadcrumbItem {
  final String id;
  final String label;
  final VoidCallback? onClick;

  const BreadcrumbItem({
    required this.id,
    required this.label,
    this.onClick,
  });
}

/// NavigationBreadcrumbs renders a responsive path trace of the current location/view.
///
/// It automatically collapses middle segments into a clickable ellipsis
/// when the path length exceeds [maxItems].
///
/// Realizes UML::NavigationBreadcrumbs.
class NavigationBreadcrumbs extends StatefulWidget {
  final List<BreadcrumbItem> items;
  final int maxItems;

  const NavigationBreadcrumbs({
    super.key,
    required this.items,
    this.maxItems = 4,
  });

  @override
  State<NavigationBreadcrumbs> createState() => _NavigationBreadcrumbsState();
}

class _NavigationBreadcrumbsState extends State<NavigationBreadcrumbs> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool shouldCollapse = widget.items.length > widget.maxItems && !_isExpanded;

    List<BreadcrumbItem> renderedItems;
    if (shouldCollapse) {
      final BreadcrumbItem first = widget.items.first;
      final List<BreadcrumbItem> lastItems = widget.items.sublist(
        widget.items.length - (widget.maxItems - 1),
      );
      renderedItems = <BreadcrumbItem>[
        first,
        BreadcrumbItem(
          id: 'ellipsis',
          label: '...',
          onClick: () {
            setState(() {
              _isExpanded = true;
            });
          },
        ),
        ...lastItems,
      ];
    } else {
      renderedItems = widget.items;
    }



    final List<Widget> children = <Widget>[];
    for (int i = 0; i < renderedItems.length; i++) {
      final BreadcrumbItem item = renderedItems[i];
      final bool isLast = i == renderedItems.length - 1;
      final bool isEllipsis = item.id == 'ellipsis';

      if (i > 0) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '/',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }

      if (isEllipsis) {
        children.add(
          ActionChip(
            onPressed: item.onClick,
            label: Text(
              item.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      } else if (isLast) {
        children.add(
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      } else {
        children.add(
          ActionChip(
            onPressed: item.onClick,
            label: Text(
              item.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// Returns the ID of the first leaf node reachable from [n].
String getFirstLeafId(TreeNode n) {
  if (n.children == null || n.children!.isEmpty) return n.id;
  return getFirstLeafId(n.children!.first);
}

/// Builds a list of [BreadcrumbItem] from the current [view] and the tree
/// hierarchy. The first item is always the root ("Console").
List<BreadcrumbItem> getBreadcrumbsItems(
  String view,
  List<TreeNode> treeData, {
  ValueChanged<String>? onSelectView,
}) {
  debugPrint('[BREADCRUMBS] getBreadcrumbsItems: view=$view');

  final List<BreadcrumbItem> base = [
    BreadcrumbItem(
      id: 'home',
      label: 'Console',
      onClick: () {
        if (treeData.isNotEmpty) {
          onSelectView?.call(getFirstLeafId(treeData.first));
        } else {
          onSelectView?.call(getFirstLeafId(treeData.first));
        }
      },
    ),
  ];

  List<TreeNode>? findPath(List<TreeNode> nodes, String targetId, List<TreeNode> currentPath) {
    for (final node in nodes) {
      if (node.id == targetId) {
        return [...currentPath, node];
      }
      if (node.children != null) {
        final found = findPath(node.children!, targetId, [...currentPath, node]);
        if (found != null) return found;
      }
    }
    return null;
  }

  final path = findPath(treeData, view, []);
  debugPrint('[BREADCRUMBS] getBreadcrumbsItems: path found=${path?.map((n) => n.id).toList()}');
  if (path == null || path.isEmpty) {
    debugPrint('[BREADCRUMBS] getBreadcrumbsItems: path NOT found, returning fallback');
    return [...base, BreadcrumbItem(id: view, label: view)];
  }

  final List<BreadcrumbItem> items = [...base];
  for (int i = 0; i < path.length; i++) {
    final node = path[i];
    if (i == path.length - 1) {
      items.add(BreadcrumbItem(id: node.id, label: node.label));
    } else {
      items.add(
        BreadcrumbItem(
          id: node.id,
          label: node.label,
          onClick: () => onSelectView?.call(getFirstLeafId(node)),
        ),
      );
    }
  }
  return items;
}
