import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/domain/repository.dart';

class RepositoryProvider extends StatelessWidget {
  final AbstractRepository repository;
  final Widget child;

  const RepositoryProvider({
    super.key,
    required this.repository,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<AbstractRepository>.value(
      value: repository,
      child: child,
    );
  }
}
