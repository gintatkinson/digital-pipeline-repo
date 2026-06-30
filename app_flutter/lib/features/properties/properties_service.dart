import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_flutter/domain/repository.dart';

class PropertiesService extends ChangeNotifier {
  final AbstractRepository _repository;
  Map<String, dynamic>? currentNodeData;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  Map<String, dynamic> get lastData => currentNodeData ?? const {};

  PropertiesService(this._repository);

  void subscribe(String nodeId) {
    _subscription?.cancel();
    currentNodeData = null;
    _subscription = _repository.watchProperties(nodeId).listen(
      (data) {
        currentNodeData = data;
        notifyListeners();
      },
      onError: (Object error, StackTrace stack) {
        debugPrint('PropertiesService.watchProperties error: $error');
      },
    );
  }

  void unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}
