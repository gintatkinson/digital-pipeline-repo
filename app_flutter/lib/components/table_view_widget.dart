import 'package:flutter/material.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/widgets/repository_provider.dart';

class TableViewWidget extends StatefulWidget {
  final String tabId;
  final String activeView;
  final Map<String, dynamic> parsedLayout;

  const TableViewWidget({
    super.key,
    required this.tabId,
    required this.activeView,
    required this.parsedLayout,
  });

  @override
  State<TableViewWidget> createState() => _TableViewWidgetState();
}

class _TableViewWidgetState extends State<TableViewWidget> {
  AbstractRepository? _repo;
  List<List<String>> _rows = [];
  List<String> _headers = [];
  bool _loading = true;
  late final ScrollController _verticalController;
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_repo == null) {
      _repo = RepositoryProvider.of(context);
      _loadData();
    }
  }

  @override
  void didUpdateWidget(covariant TableViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabId != widget.tabId ||
        oldWidget.activeView != widget.activeView) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final repo = _repo!;
      final nodeId = widget.activeView;

      List<Map<String, dynamic>> data;
      List<String> headers;

      if (widget.tabId == 'sub_elements_table') {
        data = await repo.fetchElements(nodeId);
        headers = ['ID', 'Name', 'Type', 'Status'];
      } else if (widget.tabId == 'active_alarms_table') {
        data = await repo.fetchAlarms(nodeId);
        headers = ['Alarm ID', 'Target', 'Severity', 'Timestamp'];
      } else {
        data = await repo.fetchEvents(nodeId);
        headers = ['Event ID', 'Source', 'Message', 'Timestamp'];
      }

      final rows = data.map((row) {
        if (widget.tabId == 'sub_elements_table') {
          return [
            row['id'] as String? ?? '',
            row['name'] as String? ?? '',
            row['type'] as String? ?? '',
            row['status'] as String? ?? '',
          ];
        } else if (widget.tabId == 'active_alarms_table') {
          return [
            row['id'] as String? ?? '',
            row['target'] as String? ?? '',
            row['severity'] as String? ?? '',
            row['timestamp'] as String? ?? '',
          ];
        } else {
          return [
            row['id'] as String? ?? '',
            row['source'] as String? ?? '',
            row['message'] as String? ?? '',
            row['timestamp'] as String? ?? '',
          ];
        }
      }).toList();

      if (mounted) {
        setState(() {
          _headers = headers;
          _rows = rows;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final testId = widget.tabId == 'sub_elements_table'
        ? 'items-table'
        : widget.tabId == 'active_alarms_table'
            ? 'status-table'
            : 'activity-table';

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          controller: _verticalController,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _horizontalController,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: DataTable(
                    key: Key(testId),
                    headingRowHeight: 32.0,
                    dataRowMinHeight: 28.0,
                    dataRowMaxHeight: 28.0,
                    horizontalMargin: 12.0,
                    columnSpacing: 24.0,
                    columns: _headers
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
                    rows: _rows
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
