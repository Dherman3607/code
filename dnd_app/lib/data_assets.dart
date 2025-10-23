import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Utility to list asset paths under `lib/Data/` from the Flutter asset manifest.
class DataAssets {
  /// Returns a list of asset paths that start with `lib/Data/`.
  static Future<List<String>> listDataAssets() async {
    final manifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> map = json.decode(manifest);
    final List<String> paths = [];
    for (final key in map.keys) {
      if (key.startsWith('lib/Data/')) paths.add(key);
    }
    return paths;
  }
}
