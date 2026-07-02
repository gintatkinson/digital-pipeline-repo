import 'package:flutter/material.dart';

/// A single segment in the navigation path.
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({required this.label, this.onTap});
}

/// Renders a horizontal navigation path with separators.
///
/// Middle segments collapse to an ellipsis when the total text width
/// exceeds the available container width.
class NavigationBreadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const NavigationBreadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('>', style: Theme.of(context).textTheme.bodySmall),
            ),
          GestureDetector(
            onTap: items[i].onTap,
            child: Text(
              items[i].label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: items[i].onTap != null
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
