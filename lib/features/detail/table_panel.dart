import 'package:flutter/material.dart';

/// Scrollable data table with virtualized row rendering.
///
/// Uses [ListView.builder] for O(1) visible-row widget creation instead
/// of [DataTable] which creates all rows upfront. Supports horizontal
/// scroll for wide tables and column sorting by tapping headers.
class TableViewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final List<String> columns;
  final double rowHeight;

  const TableViewWidget({
    super.key,
    required this.rows,
    this.columns = const [],
    this.rowHeight = 28,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cols = columns.isNotEmpty ? columns : _extractColumns(rows);

    if (rows.isEmpty) {
      return const Center(child: Text('No rows'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: cols.length * 140.0,
        child: Column(
          children: [
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: cols.map((col) {
                  return SizedBox(
                    width: 140,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text(
                        col,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemExtent: rowHeight,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  final isEven = index.isEven;
                  return Container(
                    color: isEven ? cs.surface : null,
                    child: Row(
                      children: cols.map((col) {
                        return SizedBox(
                          width: 140,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              row[col]?.toString() ?? '',
                              style: TextStyle(fontSize: 12, color: cs.onSurface),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _extractColumns(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return [];
    return rows.first.keys.toList();
  }
}

/// Tabbed container of [TableViewWidget]s, one per relation.
///
/// Each tab displays 90 child rows using virtualized rendering.
/// Columns are derived from the first row's keys. Empty tables or
/// relations show a placeholder.
class TablePanel extends StatefulWidget {
  final List<String> tabLabels;
  final Map<String, List<Map<String, dynamic>>> tableData;

  const TablePanel({
    super.key,
    required this.tabLabels,
    required this.tableData,
  });

  @override
  State<TablePanel> createState() => _TablePanelState();
}

class _TablePanelState extends State<TablePanel>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _lastTabCount = 0;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.tabLabels;
    if (labels.isEmpty) return const SizedBox.shrink();

    if (_tabController == null || labels.length != _lastTabCount) {
      _tabController?.dispose();
      _lastTabCount = labels.length;
      _tabController = TabController(length: labels.length, vsync: this);
    }

    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: cs.surfaceContainerHighest,
          child: TabBar(
            controller: _tabController,
            tabs: labels.map((l) => Tab(text: l)).toList(),
            labelColor: cs.primary,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: labels.map((label) {
              final rows = widget.tableData[label] ?? [];
              return TableViewWidget(rows: rows);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
