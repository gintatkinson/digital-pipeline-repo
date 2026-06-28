import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/core/design_tokens.dart';

class TabConfig {
  final String id;
  final String label;
  final WidgetBuilder contentBuilder;

  const TabConfig({
    required this.id,
    required this.label,
    required this.contentBuilder,
  });
}

class TabbedContainer extends StatefulWidget {
  final List<TabConfig> tabs;
  final String initialTabId;
  final ValueChanged<String>? onTabChanged;

  const TabbedContainer({
    super.key,
    required this.tabs,
    required this.initialTabId,
    this.onTabChanged,
  });

  @override
  State<TabbedContainer> createState() => _TabbedContainerState();
}

class _TabbedContainerState extends State<TabbedContainer> {
  late String _activeTabId;

  @override
  void initState() {
    super.initState();
    _activeTabId = widget.initialTabId;
  }

  @override
  void didUpdateWidget(covariant TabbedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabId != oldWidget.initialTabId) {
      _activeTabId = widget.initialTabId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final registry = context.watch<DesignTokenRegistry>();
    final brandPrimary = registry.getColor('alias.color.brand-primary');

    final activeTab = widget.tabs.firstWhere(
      (t) => t.id == _activeTabId,
      orElse: () => widget.tabs.isNotEmpty ? widget.tabs.first : TabConfig(id: '', label: '', contentBuilder: (_) => const SizedBox.shrink()),
    );

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tab Selector Row
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: widget.tabs.map((t) {
                final isSelected = t.id == _activeTabId;
                return InkWell(
                  key: Key('tab_btn_${t.id}'),
                  onTap: () {
                    setState(() {
                      _activeTabId = t.id;
                    });
                    widget.onTabChanged?.call(t.id);
                  },
                   child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? brandPrimary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      t.label,
                      style: TextStyle(
                        color: isSelected
                            ? brandPrimary
                            : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Tab content
          Expanded(
            child: activeTab.contentBuilder(context),
          ),
        ],
      ),
    );
  }
}
