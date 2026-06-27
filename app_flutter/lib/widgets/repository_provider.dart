import 'package:flutter/material.dart';
import '../domain/repository.dart';

class RepositoryProvider extends InheritedWidget {
  final AbstractRepository repository;

  const RepositoryProvider({
    super.key,
    required this.repository,
    required super.child,
  });

  static AbstractRepository of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RepositoryProvider>();
    assert(provider != null, 'No RepositoryProvider found in context');
    return provider!.repository;
  }

  @override
  bool updateShouldNotify(RepositoryProvider oldWidget) =>
      repository != oldWidget.repository;
}
