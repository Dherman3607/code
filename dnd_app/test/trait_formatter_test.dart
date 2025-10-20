import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/utils/trait_formatter.dart';

void main() {
  test('formatDistance with int', () {
    expect(TraitFormatter.formatDistance(30), '30 ft');
  });

  test('formatDistance with string', () {
    expect(TraitFormatter.formatDistance('60ft'), '60 ft');
    expect(TraitFormatter.formatDistance('120 feet'), '120 ft');
  });

  test('formatHitDie numeric and string', () {
    expect(TraitFormatter.formatHitDie(10), 'd10');
    expect(TraitFormatter.formatHitDie('8'), 'd8');
    expect(TraitFormatter.formatHitDie('d12'), 'd12');
  });

  test('formatDamage dice string', () {
    expect(TraitFormatter.formatDamage('2d6'), '2d6 (7 avg)');
    expect(TraitFormatter.formatDamage('1d8+2'), '1d8+2 (7 avg)');
  });

  test('extractDistancesFromText', () {
    final text = 'You can see within 60 feet and another effect at 10 ft.';
    final found = TraitFormatter.extractDistancesFromText(text);
    expect(found, [60, 10]);
  });
}
