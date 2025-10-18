import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DnDClass {
  final String id;
  final String name;
  final List<String> primaryAbility;
  final List<String> savingThrowProficiencies;
  final List<String> skillProficiencies;
  final int skillChoiceCount;
  final String weaponProficiencies;
  final String armorTraining;
  final String startingEquipment;
  final String description;

  DnDClass({
    required this.id,
    required this.name,
    required this.primaryAbility,
    required this.savingThrowProficiencies,
    required this.skillProficiencies,
    required this.skillChoiceCount,
    required this.weaponProficiencies,
    required this.armorTraining,
    required this.startingEquipment,
    required this.description,
  });

  factory DnDClass.fromJson(Map<String, dynamic> json) {
    return DnDClass(
      id: json['id'] ?? json['name'] ?? '',
      name: json['name'] ?? '',
      primaryAbility: List<String>.from(json['primaryAbility'] ?? []),
      savingThrowProficiencies:
          List<String>.from(json['savingThrowProficiencies'] ?? []),
      skillProficiencies: List<String>.from(json['skillProficiencies'] ?? []),
      skillChoiceCount: json['skillChoiceCount'] ?? 0,
      weaponProficiencies: json['weaponProficiencies'] ?? '',
      armorTraining: json['armorTraining'] ?? '',
      startingEquipment: json['startingEquipment'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class DnDClassLoader {
  static Future<List<DnDClass>> loadClasses(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> classesJson = data['classes'] ?? [];
    return classesJson.map((e) => DnDClass.fromJson(e)).toList();
  }
}
