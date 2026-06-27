import 'package:flutter/material.dart';
import 'package:app_flutter/components/tree_node.dart';
import 'package:app_flutter/domain/design_tokens.dart';

class TreeNodeWidget extends StatelessWidget {
  final TreeNode node;
  final Map<String, bool> expanded;
  final FocusNode? focusNode;
  final String? currentView;
  final ValueChanged<String>? onTap;
  final ValueChanged<String>? onToggle;
  final GlobalKey? nodeKey;

  const TreeNodeWidget({
    super.key,
    required this.node,
    required this.expanded,
    this.focusNode,
    this.currentView,
    this.onTap,
    this.onToggle,
    this.nodeKey,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentView == node.id;
    final isParent = node.children != null && node.children!.isNotEmpty;
    final isExpanded = expanded[node.id] == true;

    // TODO(#79): Replace hardcoded icon mappings with dynamic config-driven mapping.
    IconData icon;
    if (isParent) {
      icon = isExpanded ? Icons.folder_open : Icons.folder;
    } else {
      switch (node.id) {
        case 'Ingestion':
          icon = Icons.play_arrow;
          break;
        case 'Metrics':
          icon = Icons.bar_chart;
          break;
        case 'Location':
          icon = Icons.location_on;
          break;
        case 'Chassis':
          icon = Icons.dns;
          break;
        case 'Epics':
          icon = Icons.album;
          break;
        case 'Traceability':
          icon = Icons.link;
          break;
        default:
          icon = Icons.insert_drive_file;
      }
    }

    final registry = DesignTokenProvider.of(context);
    final brandPrimary = registry.getColor('alias.color.brand-primary');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: Key('node_${node.id}'),
          onTap: () {
            onTap?.call(node.id);
            focusNode?.requestFocus();
          },
          child: Container(
            key: nodeKey,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? brandPrimary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.0),
              border: isSelected
                  ? Border.all(color: brandPrimary.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                if (isParent)
                  InkWell(
                    key: Key('toggle_${node.id}'),
                    onTap: () {
                      onToggle?.call(node.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        isExpanded ? '−' : '+',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 20),
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? brandPrimary
                      : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? brandPrimary
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isParent && isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: node.children!.map((child) => TreeNodeWidget(
                node: child,
                expanded: expanded,
                focusNode: focusNode,
                currentView: currentView,
                onTap: onTap,
                onToggle: onToggle,
              )).toList(),
            ),
          ),
      ],
    );
  }
}
