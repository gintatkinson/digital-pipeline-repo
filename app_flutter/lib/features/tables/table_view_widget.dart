import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/domain/column_model.dart';
import 'package:app_flutter/features/tables/cell_renderer.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';

typedef ViewSelectedCallback = void Function(String refType, String id);

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
class TableViewWidget extends StatefulWidget {
  /// Creates a [TableViewWidget] with the given layout parameters.
  const TableViewWidget({
    super.key,
    this.headingRowHeight = 32.0,
    this.dataRowMinHeight = 28.0,
    this.dataRowMaxHeight = 28.0,
    this.horizontalMargin = 12.0,
    this.columnSpacing = 24.0,
    this.cellRenderers,
    this.onViewSelected,
  });

  /// Height of the heading row.
  final double headingRowHeight;

  /// Minimum height of a data row.
  final double dataRowMinHeight;

  /// Maximum height of a data row.
  final double dataRowMaxHeight;

  /// Horizontal margin on the left/right edges.
  final double horizontalMargin;

  /// Spacing between adjacent columns.
  final double columnSpacing;

  /// Optional map of column-type to custom cell renderers.
  final Map<String, CellRenderer>? cellRenderers;

  /// Callback fired when a reference cell is tapped.
  final ViewSelectedCallback? onViewSelected;

  @override
  State<TableViewWidget> createState() => _TableViewWidgetState();
}

class _TableViewWidgetState extends State<TableViewWidget> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

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

    final headers = viewModel.visibleColumnModels;
    final allHeaders = viewModel.headers;
    var rows = viewModel.rows;
    final testId = '${viewModel.tabId}-table';

    if (_sortColumnIndex != null && _sortColumnIndex! < headers.length) {
      final sortedRows = List<List<String>>.from(rows);
      sortedRows.sort((a, b) {
        final aVal = a[_sortColumnIndex!];
        final bVal = b[_sortColumnIndex!];
        return _sortAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      });
      rows = sortedRows;
    }

    if (headers.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final colCount = headers.length;
        final spacingWidth = colCount > 1
            ? (colCount - 1) * widget.columnSpacing
            : 0.0;
        final colWidth = (constraints.maxWidth - 2 * widget.horizontalMargin - spacingWidth) / colCount;

        void onSort(int columnIndex) {
          setState(() {
            if (_sortColumnIndex == columnIndex) {
              _sortAscending = !_sortAscending;
            } else {
              _sortColumnIndex = columnIndex;
              _sortAscending = true;
            }
          });
        }

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
                  padding: EdgeInsets.only(top: widget.headingRowHeight),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return _DataRow(
                      cells: row,
                      columnModels: headers,
                      allHeaders: allHeaders,
                      colWidth: colWidth,
                      dataRowMinHeight: widget.dataRowMinHeight,
                      dataRowMaxHeight: widget.dataRowMaxHeight,
                      horizontalMargin: widget.horizontalMargin,
                      columnSpacing: widget.columnSpacing,
                      index: index,
                      cellRenderers: widget.cellRenderers,
                      onViewSelected: widget.onViewSelected,
                      rawIds: viewModel.rawIds.isNotEmpty
                          ? viewModel.rawIds[index]
                          : null,
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _HeaderRow(
                    headers: headers,
                    colWidth: colWidth,
                    headingRowHeight: widget.headingRowHeight,
                    horizontalMargin: widget.horizontalMargin,
                    columnSpacing: widget.columnSpacing,
                    testId: testId,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: onSort,
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
  final List<ColumnModel> headers;
  final double colWidth;
  final double headingRowHeight;
  final double horizontalMargin;
  final double columnSpacing;
  final String testId;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex) onSort;

  const _HeaderRow({
    required this.headers,
    required this.colWidth,
    required this.headingRowHeight,
    required this.horizontalMargin,
    required this.columnSpacing,
    required this.testId,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
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
              label: headers[i].label,
              columnWidth: headers[i].width,
              colWidth: colWidth,
              horizontalMargin: horizontalMargin,
              columnSpacing: columnSpacing,
              isFirst: i == 0,
              isLast: i == headers.length - 1,
              sortable: headers[i].sortable,
              isActiveSort: sortColumnIndex == i,
              sortAscending: sortAscending,
              onTap: headers[i].sortable ? () => onSort(i) : null,
            ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double? columnWidth;
  final double colWidth;
  final double horizontalMargin;
  final double columnSpacing;
  final bool isFirst;
  final bool isLast;
  final bool sortable;
  final bool isActiveSort;
  final bool sortAscending;
  final VoidCallback? onTap;

  const _HeaderCell({
    required this.label,
    this.columnWidth,
    required this.colWidth,
    required this.horizontalMargin,
    required this.columnSpacing,
    required this.isFirst,
    required this.isLast,
    required this.sortable,
    required this.isActiveSort,
    required this.sortAscending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = isActiveSort
        ? '$label ${sortAscending ? '↑' : '↓'}'
        : label;

    return SizedBox(
      width: columnWidth ?? colWidth,
      child: Padding(
        padding: EdgeInsets.only(
          left: isFirst ? horizontalMargin : columnSpacing / 2,
          right: isLast ? horizontalMargin : columnSpacing / 2,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: sortable
              ? GestureDetector(
                  onTap: onTap,
                  child: Text(displayLabel, style: Theme.of(context).textTheme.labelSmall),
                )
              : Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final List<String> cells;
  final List<ColumnModel> columnModels;
  final List<ColumnModel> allHeaders;
  final double colWidth;
  final double dataRowMinHeight;
  final double dataRowMaxHeight;
  final double horizontalMargin;
  final double columnSpacing;
  final int index;
  final Map<String, CellRenderer>? cellRenderers;
  final ViewSelectedCallback? onViewSelected;
  final List<String?>? rawIds;

  const _DataRow({
    required this.cells,
    required this.columnModels,
    required this.allHeaders,
    required this.colWidth,
    required this.dataRowMinHeight,
    required this.dataRowMaxHeight,
    required this.horizontalMargin,
    required this.columnSpacing,
    required this.index,
    this.cellRenderers,
    this.onViewSelected,
    this.rawIds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: dataRowMinHeight,
        maxHeight: dataRowMaxHeight,
      ),
      color: index.isEven ? null : Colors.black.withValues(alpha: 0.03),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < columnModels.length; i++)
            _DataCell(
              value: cells[allHeaders.indexWhere((h) => h.key == columnModels[i].key)],
              columnModel: columnModels[i],
              colWidth: colWidth,
              horizontalMargin: horizontalMargin,
              columnSpacing: columnSpacing,
              isFirst: i == 0,
              isLast: i == columnModels.length - 1,
              cellRenderers: cellRenderers,
              onViewSelected: onViewSelected,
              rawId: rawIds?[i],
            ),
        ],
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String value;
  final ColumnModel columnModel;
  final double colWidth;
  final double horizontalMargin;
  final double columnSpacing;
  final bool isFirst;
  final bool isLast;
  final Map<String, CellRenderer>? cellRenderers;
  final ViewSelectedCallback? onViewSelected;
  final String? rawId;

  static const Map<String, CellRenderer> _defaultRenderers = {
    'string': TextRenderer(),
    'int': NumericRenderer(),
    'double': NumericRenderer(),
    'enum': EnumRenderer(),
    'date': DateRenderer(),
  };

  const _DataCell({
    required this.value,
    required this.columnModel,
    required this.colWidth,
    required this.horizontalMargin,
    required this.columnSpacing,
    required this.isFirst,
    required this.isLast,
    this.cellRenderers,
    this.onViewSelected,
    this.rawId,
  });

  @override
  Widget build(BuildContext context) {
    final isNumeric = columnModel.type == 'int' || columnModel.type == 'double';

    final renderer = cellRenderers?[columnModel.type]
        ?? _defaultRenderers[columnModel.type]
        ?? TextRenderer();
    final cellContent = renderer.build(context, value, columnModel);

    final refType = columnModel.refType;
    final isReference = refType != null && onViewSelected != null;

    return SizedBox(
      width: colWidth,
      child: Padding(
        padding: EdgeInsets.only(
          left: isFirst ? horizontalMargin : columnSpacing / 2,
          right: isLast ? horizontalMargin : columnSpacing / 2,
        ),
        child: Align(
          alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
          child: isReference
              ? Tooltip(
                  message: 'ID: ${rawId ?? value}',
                  child: GestureDetector(
                    onTap: () => onViewSelected!(refType, rawId ?? ''),
                    child: cellContent,
                  ),
                )
              : cellContent,
        ),
      ),
    );
  }
}
