import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/features/tree/tree_node.dart';
import 'package:app_flutter/features/tree/view_models/tree_view_model.dart';

class _MockTreeRepository implements TreeRepository {
  List<TreeNode> roots = [];
  Map<String, List<TreeNode>> childrenMap = {};
  bool returnError = false;

  @override
  Future<Result<List<TreeNode>>> fetchRootNodes() async {
    if (returnError) return const Result.failure(SchemaFieldRequiredError(fieldName: 'root', schemaName: 'tree'));
    return Result.success(roots);
  }

  @override
  Future<Result<List<TreeNode>>> fetchChildrenForNode(String parentId) async {
    if (returnError) return const Result.failure(SchemaFieldRequiredError(fieldName: 'children', schemaName: 'tree'));
    return Result.success(childrenMap[parentId] ?? []);
  }
}

void main() {
  group('TreeViewModel BDD Unit Tests', () {
    late _MockTreeRepository mockRepo;
    late TreeViewModel viewModel;

    setUp(() {
      mockRepo = _MockTreeRepository();
      viewModel = TreeViewModel(mockRepo);
    });

    test('shouldReturnEmptyTreeDataInitially', () {
      expect(viewModel.treeData, isEmpty);
      expect(viewModel.currentView, isEmpty);
    });

    test('shouldLoadTreeRootsSuccess', () async {
      mockRepo.roots = const [
        TreeNode(id: 'node1', label: 'Node 1'),
      ];

      await viewModel.loadTree();

      expect(viewModel.treeData.length, 1);
      expect(viewModel.treeData.first.id, 'node1');
      expect(viewModel.currentView, 'node1');
    });

    test('shouldSupportImmutableTreeStateCopyWithAndEquality', () {
      const state1 = TreeState();
      const state2 = TreeState();

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));

      final updatedState = state1.copyWith(currentView: 'node1');
      expect(updatedState.currentView, equals('node1'));
      expect(updatedState, isNot(equals(state1)));
    });

    test('shouldTriggerFlightAndClearFlightTarget', () {
      viewModel.triggerFlight('nodeA');
      expect(viewModel.flightTarget, equals('nodeA'));

      viewModel.clearFlightTarget();
      expect(viewModel.flightTarget, isNull);
    });
  });
}
