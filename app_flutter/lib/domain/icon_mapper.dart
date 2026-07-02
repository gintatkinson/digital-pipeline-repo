import 'package:flutter/material.dart';

/// Maps a string icon name to a [Material](Icons) value.
///
/// Eight icon names are recognised (cycled by the seed generator per type).
/// Unknown names fall back to [Icons.data_object].
class IconMapper {
  static const _map = <String, IconData>{
    'data_object': Icons.data_object,
    'folder': Icons.folder,
    'insert_drive_file': Icons.insert_drive_file,
    'label': Icons.label,
    'settings': Icons.settings,
    'storage': Icons.storage,
    'cloud': Icons.cloud,
    'dns': Icons.dns,
  };

  /// Returns the [IconData] for [iconName], or a fallback if unknown.
  static IconData resolve(String iconName) {
    return _map[iconName] ?? Icons.data_object;
  }
}
