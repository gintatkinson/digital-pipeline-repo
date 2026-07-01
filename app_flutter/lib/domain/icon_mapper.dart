import 'package:flutter/material.dart';

class IconMapper {
  static const _icons = <String, IconData>{
    'data_object': Icons.data_object,
    'folder': Icons.folder,
    'insert_drive_file': Icons.insert_drive_file,
    'label': Icons.label,
    'settings': Icons.settings,
    'storage': Icons.storage,
    'cloud': Icons.cloud,
    'dns': Icons.dns,
  };

  static IconData resolve(String iconName) {
    return _icons[iconName] ?? Icons.data_object;
  }
}
