import 'package:flutter/material.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';

/// Editable property grid grouped by section with dirty tracking.
///
/// Each [FieldDescriptor] renders as a [TextFormField] inside a section
/// card. A circular dirty indicator marks modified fields. Save commits
/// all fields; Cancel reverts to last committed values.
class PropertyGrid extends StatefulWidget {
  final List<FieldDescriptor> fields;
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onSave;

  const PropertyGrid({
    super.key,
    required this.fields,
    required this.properties,
    required this.onSave,
  });

  @override
  State<PropertyGrid> createState() => _PropertyGridState();
}

class _PropertyGridState extends State<PropertyGrid> {
  late final Map<String, TextEditingController> _controllers = {};
  late Map<String, dynamic> _committed;

  @override
  void initState() {
    super.initState();
    _committed = Map.from(widget.properties);
    for (final fd in widget.fields) {
      _controllers[fd.key] = TextEditingController(text: _committed[fd.key]?.toString() ?? '');
    }
  }

  @override
  void didUpdateWidget(PropertyGrid old) {
    super.didUpdateWidget(old);
    final fieldsChanged = old.fields != widget.fields;
    if (fieldsChanged) {
      for (final c in _controllers.values) {
        c.dispose();
      }
      _controllers.clear();
      for (final fd in widget.fields) {
        _controllers[fd.key] = TextEditingController(text: _committed[fd.key]?.toString() ?? '');
      }
    }
    if (old.properties != widget.properties || fieldsChanged) {
      _committed = Map.from(widget.properties);
      for (final fd in widget.fields) {
        final ctrl = _controllers[fd.key];
        final value = _committed[fd.key]?.toString() ?? '';
        if (ctrl != null && ctrl.text != value) {
          ctrl.text = value;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isDirty(String key) {
    return _controllers[key]?.text != (_committed[key]?.toString() ?? '');
  }

  Map<String, dynamic> _collectData() {
    final data = <String, dynamic>{};
    for (final fd in widget.fields) {
      final raw = _controllers[fd.key]?.text ?? '';
      switch (fd.type) {
        case FieldType.int_:
          data[fd.key] = int.tryParse(raw) ?? 0;
        case FieldType.double_:
          data[fd.key] = double.tryParse(raw) ?? 0.0;
        case FieldType.bool_:
          data[fd.key] = raw.toLowerCase() == 'true';
        default:
          data[fd.key] = raw;
      }
    }
    return data;
  }

  void _handleCancel() {
    for (final fd in widget.fields) {
      _controllers[fd.key]?.text = _committed[fd.key]?.toString() ?? '';
    }
    setState(() {});
  }

  void _handleSave() {
    final data = _collectData();
    _committed = data;
    setState(() {});
    widget.onSave(Map.from(data));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sections = <String?, List<FieldDescriptor>>{};
    for (final fd in widget.fields) {
      sections.putIfAbsent(fd.sectionLabel, () => []).add(fd);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final entry in sections.entries) ...[
                if (entry.key != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 16,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          entry.key!,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                for (final fd in entry.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      controller: _controllers[fd.key],
                      decoration: InputDecoration(
                        labelText: fd.label,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: _isDirty(fd.key)
                            ? Padding(
                                padding: const EdgeInsets.all(14),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: cs.tertiary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      keyboardType: fd.type == FieldType.int_
                          ? TextInputType.number
                          : fd.type == FieldType.double_
                              ? const TextInputType.numberWithOptions(decimal: true)
                              : TextInputType.text,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: _handleCancel, child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton(onPressed: _handleSave, child: const Text('Save')),
            ],
          ),
        ),
      ],
    );
  }
}
