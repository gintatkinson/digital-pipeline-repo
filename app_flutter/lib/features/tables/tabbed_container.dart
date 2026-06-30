import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';
import 'package:app_flutter/features/tables/table_view_widget.dart';

/// Renders a tabbed view whose labels, columns, and data are driven by a
/// [TablesViewModel].
///
/// Exists to display child/related types of the currently selected tree node in
/// separate tabs, removing the need for hardcoded tab definitions. Use this
/// widget anywhere the UI needs data-source-driven tab navigation.
///
/// Edge cases:
///   - If [TablesViewModel.tabs] is empty and [loading] is `true`, a centered
///     [CircularProgressIndicator] is shown.
///   - If [TablesViewModel.tabs] is empty and [loading] is `false`, nothing is
///     rendered ([SizedBox.shrink]).
///   - When tabs change (e.g. navigating to a different node), the
///     [TabController] is disposed and re-created to match the new tab count.
///   - The initial tab index is determined by [TablesViewModel.selectedTabId];
///     if no match is found, index 0 is used.
///
/// State changes: this widget creates a [TabController] with
/// [SingleTickerProviderStateMixin] and disposes it on teardown. Tab selection
/// is forwarded to [TablesViewModel.selectTab] which triggers async data
/// loading.
class TabbedContainer extends StatefulWidget {
  const TabbedContainer({super.key});

  @override
  State<TabbedContainer> createState() => _TabbedContainerState();
}

class _TabbedContainerState extends State<TabbedContainer>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _lastTabCount = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TablesViewModel>();
    final tabs = viewModel.tabs;

    if (tabs.isEmpty) {
      if (viewModel.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return const SizedBox.shrink();
    }

    if (_tabController == null || tabs.length != _lastTabCount) {
      _tabController?.dispose();
      _lastTabCount = tabs.length;
      _tabController = TabController(length: tabs.length, vsync: this);
      final initialIndex =
          tabs.indexWhere((t) => t.id == viewModel.selectedTabId);
      if (initialIndex > 0) _tabController!.index = initialIndex;
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          final tab = tabs[_tabController!.index];
          viewModel.selectTab(tab.id);
        }
      });
    }

    return Column(
      children: [
        Material(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController!,
            tabs: tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController!,
            children: tabs.map((_) => const TableViewWidget()).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
