/// Utility methods to format common D&D trait values for display.
class TraitFormatter {
  /// Format a distance-like value to a normalized string with feet.
  /// Accepts int, double, or Strings like "60ft", "60 feet", "60 ft".
  static String? formatDistance(dynamic v) {
    if (v == null) return null;
    if (v is num) return "${v.toInt()} ft";
    if (v is String) {
      final s = v.trim();
      // Try to extract a number and feet token
      final ftMatch =
          RegExp(r"(\d+)\s*(?:feet|foot|ft)\b", caseSensitive: false)
              .firstMatch(s);
      if (ftMatch != null) return "${int.parse(ftMatch.group(1)!)} ft";
      // If it's just a plain number string
      final numMatch = RegExp(r"^\d+").firstMatch(s);
      if (numMatch != null) return "${int.parse(numMatch.group(0)!)} ft";
      return s; // fallback to raw
    }
    return v.toString();
  }

  /// Format a hit die integer (e.g. 10 -> d10) or pass-through dice-like strings.
  static String? formatHitDie(dynamic v) {
    if (v == null) return null;
    if (v is num) return 'd${v.toInt()}';
    if (v is String) {
      final s = v.trim();
      if (s.startsWith('d')) return s;
      final n = int.tryParse(s);
      if (n != null) return 'd$n';
      return s;
    }
    return v.toString();
  }

  /// If a value looks like a dice expression (e.g. 2d6+1), format it and include average.
  /// Returns input unchanged if it doesn't match dice pattern.
  static String formatDamage(dynamic v) {
    if (v == null) return '';
    final s = v.toString().trim();
    final m = RegExp(r"^(\d+)d(\d+)([+-]\d+)?").firstMatch(s);
    if (m == null) return s;
    final count = int.parse(m.group(1)!);
    final sides = int.parse(m.group(2)!);
    final mod = m.group(3) != null ? int.parse(m.group(3)!) : 0;
    final avg = (count * (sides + 1) / 2 + mod).round();
    return '$s ($avg avg)';
  }

  /// Extracts integer distances (in feet) from unstructured text.
  /// Returns list of found distances in the order discovered.
  static List<int> extractDistancesFromText(String text) {
    final out = <int>[];
    if (text.isEmpty) return out;
    final re = RegExp(r"(\d+)\s*(?:feet|foot|ft)\b", caseSensitive: false);
    for (final m in re.allMatches(text)) {
      final n = int.tryParse(m.group(1)!);
      if (n != null) out.add(n);
    }
    return out;
  }
}
