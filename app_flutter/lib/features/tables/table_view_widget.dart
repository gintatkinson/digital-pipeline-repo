import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';

/// Renders tabular data from a [TablesViewModel] as a horizontally and
/// vertically scrollable [DataTable].
///
/// Exists to decouple the table presentation from the data-fetching logic in
/// [TablesViewModel]. Use this widget inside [TabbedContainer] or any context
/// where a [TablesViewModel] is provided via [Provider].
///
/// Edge cases:
///   - When [TablesViewModel.loading] is `true`, a centered
///     [CircularProgressIndicator] is displayed instead of the table.
///   - When [TablesViewModel.error] is non-null, the error text is shown in
///     the theme's error color; the table is not rendered.
///   - An empty [headers] or [rows] list renders a [DataTable] with zero
///     columns or rows respectively — no crash or visual glitch.
///   - Long content is scrollable in both axes via nested [SingleChildScrollView]s.
///
/// State changes: this widget is read-only; it watches [TablesViewModel] via
/// `context.watch` and rebuilds on every notifyListeners call from the view
/// model.
class TableViewWidget extends StatelessWidget {
  /// Creates a [TableViewWidget].
  const TableViewWidget({super.key});

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

    final testId = '${viewModel.tabId}-table';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                key: Key(testId),
                headingRowHeight: 32.0,
                dataRowMinHeight: 28.0,
                dataRowMaxHeight: 28.0,
                horizontalMargin: 12.0,
                columnSpacing: 24.0,
                columns: viewModel.headers
                    .map((h) => DataColumn(
                          label: Text(
                            h,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ))
                    .toList(),
                rows: viewModel.rows
                    .map((row) => DataRow(
                          cells: row
                              .map((cell) => DataCell(
                                    Text(
                                      cell,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
