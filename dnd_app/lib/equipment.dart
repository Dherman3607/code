import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Simple equipment loader that extracts equipment names from common JSON layouts
/// used in the exported DnD data. It returns a list of equipment item names.
class EquipmentLoader {
  /// Load equipment from an asset path (uses `rootBundle`).
  static Future<List<String>> loadEquipment(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final dynamic data = json.decode(jsonString);
    return extractEquipmentFromJson(data);
  }

  /// Extract equipment names from decoded JSON data. This is public so tests
  /// can call parsing logic without relying on asset IO.
  static List<String> extractEquipmentFromJson(dynamic data) {
    final Set<String> results = {};

    void collectFromList(dynamic list) {
      if (list is List) {
        for (final item in list) {
          if (item is Map && item['name'] is String) {
            results.add(item['name'] as String);
          } else if (item is String) {
            results.add(item);
          }
        }
      }
    }

    try {
      // Common layout: top-level 'equipment'
      if (data is Map && data.containsKey('equipment')) {
        final eq = data['equipment'];
        if (eq is Map) {
          for (final v in eq.values) {
            if (v is Map && v['name'] is String)
              results.add(v['name'] as String);
            if (v is List) collectFromList(v);
          }
        } else if (eq is List) {
          collectFromList(eq);
        }
      }

      // Another common export layout: top-level 'data' list with entries of type 'equipment'
      if (data is Map && data['data'] is List) {
        for (final entry in data['data']) {
          if (entry is Map &&
              entry['type'] == 'equipment' &&
              entry['items'] is List) {
            collectFromList(entry['items']);
          }
        }
      }

      // Fallback: recursive search for maps with 'type' == 'equipment'
      void walk(dynamic node) {
        if (node is Map) {
          if (node['type'] == 'equipment' && node['items'] is List) {
            collectFromList(node['items']);
          }
          for (final v in node.values) {
            walk(v);
          }
        } else if (node is List) {
          for (final v in node) walk(v);
        }
      }

      walk(data);
    } catch (_) {
      // ignore parse errors for robustness
    }

    return results.toList()..sort();
  }
}
