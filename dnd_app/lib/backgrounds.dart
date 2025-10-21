import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DnDBackground {
  final String id;
  final String name;
  final String description;

  DnDBackground(
      {required this.id, required this.name, required this.description});

  factory DnDBackground.fromJson(Map<String, dynamic> json) {
    return DnDBackground(
      id: json['id'] ?? json['name'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class DnDBackgroundLoader {
  static Future<List<DnDBackground>> loadBackgrounds(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> data = json.decode(jsonString);

    // Try common locations similar to other loaders
    if (data.containsKey('backgrounds')) {
      final List<dynamic> list = data['backgrounds'];
      return list.map((e) => DnDBackground.fromJson(e)).toList();
    }

    // Search 'data' entries for type 'background'
    final List<dynamic> top = data['data'] ?? [];
    for (final entry in top) {
      if (entry is Map<String, dynamic> &&
          entry['type'] == 'background' &&
          entry['items'] is List) {
        return (entry['items'] as List)
            .map((e) => DnDBackground.fromJson(e))
            .toList();
      }
    }

    // fallback: traverse tree and collect items with type 'background'
    final List<DnDBackground> found = [];
    void search(dynamic node) {
      if (node is List) {
        for (var item in node) search(item);
      } else if (node is Map<String, dynamic>) {
        if (node['type'] == 'background') {
          if (node['items'] is List) {
            for (var it in node['items']) {
              found.add(DnDBackground.fromJson(Map<String, dynamic>.from(it)));
            }
          }
        }
        node.values.forEach(search);
      }
    }

    search(data);
    return found;
  }
}
