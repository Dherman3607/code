import 'package:flutter/foundation.dart';

class HpStore extends ChangeNotifier {
  HpStore._internal();
  static final HpStore instance = HpStore._internal();

  int _current = 0;
  int _max = 0;

  int get current => _current;
  int get max => _max;

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
    setCurrent(_current + n);
  }

  void dec(int n) {
    setCurrent(_current - n);
  }
}
