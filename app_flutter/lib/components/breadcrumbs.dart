import 'package:flutter/material.dart';

/// Represents a single item in the breadcrumbs navigation.
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

    // Design Token Colors
    // Blue-500: #1a73e8 (brand primary accent)
    // Blue-600: #1557b0 (brand primary hover)
    const Color brandPrimary = Color(0xFF1A73E8);
    const Color textSecondary = Color(0xFF9AA0A6);
    const Color separatorColor = Color(0xFF666666);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color currentTextColor = isDark ? const Color(0xFFEEEEEE) : const Color(0xFF202124);

    final List<Widget> children = <Widget>[];
    for (int i = 0; i < renderedItems.length; i++) {
      final BreadcrumbItem item = renderedItems[i];
      final bool isLast = i == renderedItems.length - 1;
      final bool isEllipsis = item.id == 'ellipsis';

      if (i > 0) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '/',
              style: TextStyle(
                color: separatorColor,
                fontSize: 13.0,
              ),
            ),
          ),
        );
      }

      if (isEllipsis) {
        children.add(
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onClick,
              borderRadius: BorderRadius.circular(4.0),
              hoverColor: const Color(0x1EFFFFFF), // white with 12% opacity
              splashColor: const Color(0x29FFFFFF), // white with 16% opacity
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: const Color(0x14FFFFFF), // white with 8% opacity
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 13.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (isLast) {
        children.add(
          Text(
            item.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: currentTextColor,
              fontSize: 13.0,
            ),
          ),
        );
      } else {
        children.add(
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onClick,
              borderRadius: BorderRadius.circular(4.0),
              hoverColor: const Color(0x141A73E8), // brandPrimary with 8% opacity
              splashColor: const Color(0x291A73E8), // brandPrimary with 16% opacity
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: brandPrimary,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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
