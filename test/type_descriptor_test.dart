import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';

void main() {
  group('FieldDescriptor', () {
    test('creates with required fields', () {
      const fd = FieldDescriptor(key: 'attr_01', label: 'I_01', type: FieldType.int_);
      expect(fd.key, 'attr_01');
      expect(fd.label, 'I_01');
      expect(fd.type, FieldType.int_);
      expect(fd.sectionOrder, 0);
      expect(fd.required, false);
    });
  });

  group('TypeRelationDescriptor', () {
    test('creates with all fields', () {
      const trd = TypeRelationDescriptor(
        relationName: 'relates_to_Type1',
        targetTypeName: 'Type1',
        displayLabel: 'Type 1 Records',
      );
      expect(trd.relationName, 'relates_to_Type1');
      expect(trd.targetTypeName, 'Type1');
      expect(trd.displayLabel, 'Type 1 Records');
    });
  });

  group('TypeDescriptor', () {
    test('creates with defaults', () {
      const td = TypeDescriptor(typeName: 'Type0', displayName: 'Type 0', iconName: 'data_object');
      expect(td.typeName, 'Type0');
      expect(td.fields, isEmpty);
      expect(td.childTypes, isEmpty);
      expect(td.parentTypes, isEmpty);
    });
  });

  group('InstanceDescriptor', () {
    test('creates with all fields', () {
      const id = InstanceDescriptor(nodeId: 'Type0-000', typeName: 'Type0', displayLabel: 'Type 0 Type0-000');
      expect(id.nodeId, 'Type0-000');
      expect(id.typeName, 'Type0');
      expect(id.displayLabel, 'Type 0 Type0-000');
    });
  });
}
