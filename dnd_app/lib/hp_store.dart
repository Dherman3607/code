import 'package:flutter/foundation.dart';

class HpStore extends ChangeNotifier {
  HpStore._internal();
  static final HpStore instance = HpStore._internal();

  int _current = 0;
  int _max = 0;

  int get current => _current;
  int get max => _max;

  // Simple change log: most recent first
  final List<HpChange> _log = [];
  List<HpChange> get log => List.unmodifiable(_log);

  String _now() => DateTime.now().toIso8601String();

  void setHp(int current, int max) {
    _current = current.clamp(0, max);
    _max = max;
    notifyListeners();
  }

  void setCurrent(int c) {
    _current = c.clamp(0, _max);
    notifyListeners();
  }

  void inc(int n) {
    applyChange(n, type: 'heal');
  }

  void dec(int n) {
    applyChange(-n, type: 'damage');
  }

  /// Apply a delta to current HP and log it as a single atomic operation.
  void applyChange(int delta, {required String type}) {
    _logInsert(delta, type);
    setCurrent(_current + delta);
  }

  void _logInsert(int delta, String type) {
    final entry =
        HpChange(delta: delta, type: type, when: _now(), before: _current);
    _log.insert(0, entry);
    // keep log reasonable length
    if (_log.length > 200) _log.removeLast();
    notifyListeners();
  }

  /// Undo the most recent logged change. Returns true if undone.
  bool undoLast() {
    if (_log.isEmpty) return false;
    final last = _log.removeAt(0);
    // revert to the recorded 'before' value
    _current = last.before.clamp(0, _max);
    notifyListeners();
    return true;
  }
}

class HpChange {
  final int delta; // negative for damage, positive for heal
  final String type;
  final String when;
  final int before;

  HpChange(
      {required this.delta,
      required this.type,
      required this.when,
      required this.before});
}
