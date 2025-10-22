import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DnDRace {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> traits;

  DnDRace({required this.id, required this.name, required this.description, required this.traits});

  factory DnDRace.fromJson(Map<String, dynamic> json) {
    return DnDRace(
      id: json['id'] ?? json['name'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      traits: Map<String, dynamic>.from(json['traits'] ?? {}),
    );
  }
}

class DnDRaceLoader {
  static Future<List<DnDRace>> loadRaces(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> data = json.decode(jsonString);
    // some exports put races under 'races' or under an object with id 'races' and items
    if (data.containsKey('races')) {
      final List<dynamic> racesJson = data['races'];
      return racesJson.map((e) => DnDRace.fromJson(e)).toList();
    }

    // find an entry with type 'race' and parse its items
    final List<dynamic> top = data['data'] ?? [];
    for (final entry in top) {
      if (entry is Map<String, dynamic> && entry['type'] == 'race' && entry['items'] is List) {
        return (entry['items'] as List).map((e) => DnDRace.fromJson(e)).toList();
      }
    }

    // fallback: try to find 'items' at root and filter by type
    final List<DnDRace> found = [];
    void search(dynamic node) {
      if (node is List) {
        for (var item in node) {
          search(item);
        }
      } else if (node is Map<String, dynamic>) {
        if (node['type'] == 'race') {
          if (node['items'] is List) {
            for (var it in node['items']) {
              found.add(DnDRace.fromJson(Map<String, dynamic>.from(it)));
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
