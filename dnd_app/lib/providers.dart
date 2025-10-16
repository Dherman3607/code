import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'classes.dart';

final classListProvider = FutureProvider<List<DnDClass>>((ref) async {
  return await DnDClassLoader.loadClasses('test/Data/dnd-export-complete-2025-10-10.json');
});
