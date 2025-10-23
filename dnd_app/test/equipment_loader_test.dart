import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/equipment.dart';

void main() {
  test('extract from top-level equipment list', () {
    final json = {
      'equipment': [
        {'name': 'Longsword'},
        {'name': 'Shield'},
      ]
    };
    final items = EquipmentLoader.extractEquipmentFromJson(json);
    expect(items, ['Longsword', 'Shield']);
  });

  test('extract from equipment map structure', () {
    final json = {
      'equipment': {
        'weapons': [
          {'name': 'Dagger'},
        ],
        'armor': [
          {'name': 'Chain Mail'}
        ]
      }
    };
    final items = EquipmentLoader.extractEquipmentFromJson(json);
    expect(items, ['Chain Mail', 'Dagger']);
  });

  test('extract from data list with type equipment', () {
    final json = {
      'data': [
        {
          'type': 'equipment',
          'items': [
            {'name': 'Potion of Healing'},
            'Rope'
          ]
        }
      ]
    };
    final items = EquipmentLoader.extractEquipmentFromJson(json);
    expect(items, ['Potion of Healing', 'Rope']);
  });

  test('recursive fallback finds nested equipment', () {
    final json = {
      'foo': {
        'bar': {
          'type': 'equipment',
          'items': [
            {'name': 'Lantern'}
          ]
        }
      }
    };
    final items = EquipmentLoader.extractEquipmentFromJson(json);
    expect(items, ['Lantern']);
  });
}
