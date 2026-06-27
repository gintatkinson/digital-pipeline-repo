import 'package:flutter/material.dart';
import 'package:app_flutter/components/table_view_config.dart';

class TableViewWidget extends StatelessWidget {
  final String tabId;
  final Map<String, dynamic> parsedLayout;
  final Map<String, TableViewConfig> tableViewRegistry;
  final ScrollController? verticalController;
  final ScrollController? horizontalController;

  const TableViewWidget({
    super.key,
    required this.tabId,
    required this.parsedLayout,
    required this.tableViewRegistry,
    this.verticalController,
    this.horizontalController,
  });

  @override
  Widget build(BuildContext context) {
    final config = tableViewRegistry[tabId] ?? TableViewConfig(
      testId: 'activity-table',
      headers: const ['Event ID', 'Source', 'Message', 'Timestamp'],
      rows: const [
        ['EVENT-201', 'System', 'Console initialized', '2026-06-23 14:19'],
        ['EVENT-202', 'Worker', 'Registered off-thread background worker', '2026-06-23 14:19'],
        ['EVENT-203', 'UI', 'Selected panel reflow isolation scope active', '2026-06-23 14:19'],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          controller: verticalController,
          notificationPredicate: (notif) => notif.depth == 0,
          child: SingleChildScrollView(
            controller: verticalController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              thumbVisibility: true,
              controller: horizontalController,
              notificationPredicate: (notif) => notif.depth == 0,
              child: SingleChildScrollView(
                controller: horizontalController,
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: DataTable(
                    key: Key(config.testId),
                    headingRowHeight: 32.0,
                    dataRowMinHeight: 28.0,
                    dataRowMaxHeight: 28.0,
                    horizontalMargin: 12.0,
                    columnSpacing: 24.0,
                    columns: config.headers
                        .map((h) => DataColumn(
                              label: Text(
                                h,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                            ))
                        .toList(),
                    rows: config.rows
                        .map((row) => DataRow(
                              cells: row
                                  .map((cell) => DataCell(
                                        Text(
                                          cell,
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
