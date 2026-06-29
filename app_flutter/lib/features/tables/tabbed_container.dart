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

class _TabbedContainerState extends State<TabbedContainer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.tabs.indexWhere((t) => t.id == widget.initialTabId).clamp(0, widget.tabs.length - 1);
    _tabController = TabController(length: widget.tabs.length, vsync: this, initialIndex: _activeTabIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeTabIndex = _tabController.index);
      }
    });
  }

  @override
  void didUpdateWidget(TabbedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabId != oldWidget.initialTabId) {
      final newIndex = widget.tabs.indexWhere((t) => t.id == widget.initialTabId);
      if (newIndex >= 0 && newIndex != _tabController.index) {
        _tabController.animateTo(newIndex);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            tabs: widget.tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs.map((t) => t.contentBuilder(context)).toList(),
          ),
        ),
      ],
    );
  }
}
