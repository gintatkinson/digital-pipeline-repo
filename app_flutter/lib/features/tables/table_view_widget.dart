import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';

class TableViewWidget extends StatelessWidget {
  const TableViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TablesViewModel>();

    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final testId = viewModel.tabId == 'sub_elements_table'
        ? 'items-table'
        : viewModel.tabId == 'active_alarms_table'
            ? 'status-table'
            : 'activity-table';

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
