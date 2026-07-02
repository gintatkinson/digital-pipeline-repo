import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pipeline_app/core/theme_controller.dart';
import 'package:pipeline_app/core/text_scaler.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/features/detail/detail_view_model.dart';
import 'package:pipeline_app/features/detail/topology_view_model.dart';
import 'package:pipeline_app/features/detail/topology_view.dart';
import 'package:pipeline_app/features/detail/property_grid.dart';
import 'package:pipeline_app/features/detail/table_panel.dart';
import 'package:pipeline_app/features/layout/resizable_splitter.dart';
import 'package:pipeline_app/features/settings/settings_panel.dart';
import 'package:pipeline_app/features/tree/tree_view_model.dart';
import 'package:pipeline_app/features/tree/tree_sidebar.dart';

/// Root widget that wires sidebar and detail panel with resizable splits.
///
/// Layout: horizontal split [sidebar | detail], detail = vertical split
/// [topology | bottom], bottom = vertical split [properties | tables].
/// All splits are user-draggable with 150px minimum panes.
class PipelineApp extends StatefulWidget {
  final Repository repository;
  final TreeViewModel treeViewModel;
  final ThemeController themeController;
  final TextScaleController textScaleController;

  const PipelineApp({
    super.key,
    required this.repository,
    required this.treeViewModel,
    required this.themeController,
    required this.textScaleController,
  });

  @override
  State<PipelineApp> createState() => _PipelineAppState();
}

class _PipelineAppState extends State<PipelineApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pipeline',
      theme: widget.themeController.lightTheme,
      darkTheme: widget.themeController.darkTheme,
      themeMode: widget.themeController.mode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(widget.textScaleController.scale),
          ),
          child: child!,
        );
      },
      home: SelectionArea(child: _DashboardPage(
        repository: widget.repository,
        treeViewModel: widget.treeViewModel,
        themeController: widget.themeController,
        textScaleController: widget.textScaleController,
      )),
    );
  }

  @override
  void dispose() {
    widget.themeController.dispose();
    widget.textScaleController.dispose();
    widget.treeViewModel.dispose();
    widget.repository.close();
    super.dispose();
  }
}

class _DashboardPage extends StatefulWidget {
  final Repository repository;
  final TreeViewModel treeViewModel;
  final ThemeController themeController;
  final TextScaleController textScaleController;

  const _DashboardPage({
    required this.repository,
    required this.treeViewModel,
    required this.themeController,
    required this.textScaleController,
  });

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  late final DetailViewModel _detailViewModel;
  late final TopologyViewModel _topologyViewModel;

  @override
  void initState() {
    super.initState();
    _detailViewModel = DetailViewModel(widget.repository);
    _topologyViewModel = TopologyViewModel(widget.repository);
    unawaited(_topologyViewModel.loadTopologyData());
  }

  void _onNodeSelected(String nodeId) {
    final typeName = nodeId.contains('-')
        ? nodeId.substring(0, nodeId.lastIndexOf('-'))
        : nodeId;
    _detailViewModel.loadNode(typeName, nodeId);
    _topologyViewModel.selectNode(nodeId);
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SettingsPanel(
        themeController: widget.themeController,
        textScaleController: widget.textScaleController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResizableSplitter(
        axis: Axis.horizontal, initialRatio: 0.22,
        minLeadingSize: 200, minTrailingSize: 300,
        leading: TreeSidebar(
          viewModel: widget.treeViewModel,
          onNodeSelected: _onNodeSelected,
          onSettingsPressed: _showSettings,
        ),
        trailing: ResizableSplitter(
          axis: Axis.vertical, initialRatio: 0.4,
          minLeadingSize: 150, minTrailingSize: 200,
          leading: TopologyView(viewModel: _topologyViewModel, onNodeSelected: _onNodeSelected),
          trailing: ListenableBuilder(
            listenable: _detailViewModel,
            builder: (context, _) {
              final error = _detailViewModel.error;
              if (error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text('Failed to load node', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(error, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }
              final fields = _detailViewModel.fields;
              if (fields.isEmpty) return const Center(child: Text('Select a node'));
              return ResizableSplitter(
                axis: Axis.vertical, initialRatio: 0.5,
                leading: PropertyGrid(
                  fields: fields,
                  properties: _detailViewModel.properties,
                  onSave: (data) => _detailViewModel.saveProperties(data),
                ),
                trailing: TablePanel(
                  tabLabels: _detailViewModel.childRelations.map((r) => r.relationName).toList(),
                  tableData: _detailViewModel.children,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _detailViewModel.dispose();
    _topologyViewModel.dispose();
    super.dispose();
  }
}
