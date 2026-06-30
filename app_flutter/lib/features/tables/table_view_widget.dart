import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/domain/column_model.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';

/// Renders tabular data from a [TablesViewModel] as a horizontally
/// scrollable, vertically virtualized table.
///
/// Fixes O(n) widget creation from [DataTable] by using [ListView.builder]
/// for O(1) visible-row widget creation. The column header row is fixed at
/// the top; body rows scroll virtually.
///
/// Edge cases:
///   - When [TablesViewModel.loading] is `true`, a centered
///     [CircularProgressIndicator] is displayed instead of the table.
///   - When [TablesViewModel.error] is non-null, the error text is shown in
///     the theme's error color; the table is not rendered.
///   - An empty [headers] list renders an empty [SizedBox] — no crash.
///   - Long content is scrollable horizontally via [SingleChildScrollView];
///     vertical scrolling is handled by [ListView.builder].
///
/// State changes: this widget is read-only; it watches [TablesViewModel] via
/// `context.watch` and rebuilds on every notifyListeners call from the view
/// model.
class TableViewWidget extends StatelessWidget {
  const TableViewWidget({
    super.key,
    this.headingRowHeight = 32.0,
    this.dataRowMinHeight = 28.0,
    this.dataRowMaxHeight = 28.0,
    this.horizontalMargin = 12.0,
    this.columnSpacing = 24.0,
  });

  final double headingRowHeight;
  final double dataRowMinHeight;
  final double dataRowMaxHeight;
  final double horizontalMargin;
  final double columnSpacing;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TablesViewModel>();

    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            viewModel.error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final headers = viewModel.headers;
    final columnModels = viewModel.columnModels;
    final rows = viewModel.rows;
    final testId = '${viewModel.tabId}-table';

    if (headers.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final colCount = headers.length;
        final spacingWidth = colCount > 1
            ? (colCount - 1) * columnSpacing
            : 0.0;
        final colWidth = (constraints.maxWidth - 2 * horizontalMargin - spacingWidth) / colCount;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            key: Key(testId),
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                ListView.builder(
                  key: Key('$testId-body'),
                  itemCount: rows.length,
                  padding: EdgeInsets.only(top: headingRowHeight),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return _DataRow(
                      cells: row,
                      colWidth: colWidth,
                      dataRowMinHeight: dataRowMinHeight,
                      dataRowMaxHeight: dataRowMaxHeight,
                      horizontalMargin: horizontalMargin,
                      columnSpacing: columnSpacing,
                      index: index,
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _HeaderRow(
                    headers: headers,
                    columnModels: columnModels,
                    colWidth: colWidth,
                    headingRowHeight: headingRowHeight,
                    horizontalMargin: horizontalMargin,
                    columnSpacing: columnSpacing,
                    testId: testId,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final List<String> headers;
  final List<ColumnModel> columnModels;
  final double colWidth;
  final double headingRowHeight;
  final double horizontalMargin;
  final double columnSpacing;
  final String testId;

  const _HeaderRow({
    required this.headers,
    required this.columnModels,
    required this.colWidth,
    required this.headingRowHeight,
    required this.horizontalMargin,
    required this.columnSpacing,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('$testId-header'),
      height: headingRowHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < headers.length; i++)
            _HeaderCell(
              label: i < columnModels.length ? columnModels[i].label : headers[i],
              colWidth: colWidth,
              horizontalMargin: horizontalMargin,
              columnSpacing: columnSpacing,
              isFirst: i == 0,
              isLast: i == headers.length - 1,
            ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double colWidth;
  final double horizontalMargin;
  final double columnSpacing;
  final bool isFirst;
  final bool isLast;

  const _HeaderCell({
    required this.label,
    required this.colWidth,
    required this.horizontalMargin,
    required this.columnSpacing,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: colWidth,
      child: Padding(
        padding: EdgeInsets.only(
          left: isFirst ? horizontalMargin : columnSpacing / 2,
          right: isLast ? horizontalMargin : columnSpacing / 2,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final List<String> cells;
  final double colWidth;
  final double dataRowMinHeight;
  final double dataRowMaxHeight;
  final double horizontalMargin;
  final double columnSpacing;
  final int index;

  const _DataRow({
    required this.cells,
    required this.colWidth,
    required this.dataRowMinHeight,
    required this.dataRowMaxHeight,
    required this.horizontalMargin,
    required this.columnSpacing,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: dataRowMinHeight,
        maxHeight: dataRowMaxHeight,
      ),
      color: index.isEven ? null : Colors.black.withOpacity(0.03),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < cells.length; i++)
            _DataCell(
              value: cells[i],
              colWidth: colWidth,
              horizontalMargin: horizontalMargin,
              columnSpacing: columnSpacing,
              isFirst: i == 0,
              isLast: i == cells.length - 1,
            ),
        ],
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String value;
  final double colWidth;
  final double horizontalMargin;
  final double columnSpacing;
  final bool isFirst;
  final bool isLast;

  const _DataCell({
    required this.value,
    required this.colWidth,
    required this.horizontalMargin,
    required this.columnSpacing,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: colWidth,
      child: Padding(
        padding: EdgeInsets.only(
          left: isFirst ? horizontalMargin : columnSpacing / 2,
          right: isLast ? horizontalMargin : columnSpacing / 2,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(value, style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
    );
  }
}
