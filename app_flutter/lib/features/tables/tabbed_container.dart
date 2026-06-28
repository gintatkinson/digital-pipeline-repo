import 'package:flutter/material.dart';

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
  late int _activeTabIndex;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.tabs.indexWhere((t) => t.id == widget.initialTabId);
    if (_activeTabIndex < 0) _activeTabIndex = 0;
  }

  @override
  void didUpdateWidget(covariant TabbedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabId != oldWidget.initialTabId) {
      _activeTabIndex = widget.tabs.indexWhere((t) => t.id == widget.initialTabId);
      if (_activeTabIndex < 0) _activeTabIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: DefaultTabController(
        length: widget.tabs.length,
        initialIndex: _activeTabIndex,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              onTap: (index) {
                setState(() {
                  _activeTabIndex = index;
                });
                widget.onTabChanged?.call(widget.tabs[index].id);
              },
              tabs: widget.tabs.map((t) => Tab(text: t.label)).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: widget.tabs.map((t) => t.contentBuilder(context)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
