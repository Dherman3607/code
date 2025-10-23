import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'classes.dart';
import 'races.dart';
import 'data_assets.dart';
import 'utils/trait_formatter.dart';
import 'hp_store.dart';
import 'backgrounds.dart';
import 'money_equipment.dart';
import 'unified_selector_dialog.dart';

// Clean, minimal CharacterSheet implementation.
class CharacterSheet extends StatefulWidget {
  const CharacterSheet({Key? key}) : super(key: key);

  @override
  _CharacterSheetState createState() => _CharacterSheetState();
}

class _CharacterSheetState extends State<CharacterSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _levelController =
      TextEditingController(text: '1');
  final Map<String, TextEditingController> _abilityControllers = {
    'STR': TextEditingController(text: '10'),
    'DEX': TextEditingController(text: '10'),
    'CON': TextEditingController(text: '10'),
    'INT': TextEditingController(text: '10'),
    'WIS': TextEditingController(text: '10'),
    'CHA': TextEditingController(text: '10'),
  };

  List<DnDClass>? _classList;
  List<DnDRace>? _raceList;
  DnDClass? _selectedClass;
  DnDRace? _selectedRace;
  String? _selectedClassName;
  String? _selectedRaceName;
  List<DnDBackground>? _backgroundList;
  DnDBackground? _selectedBackground;

  @override
  void initState() {
    super.initState();
    HpStore.instance.setHp(0, 0);
    _loadClasses();
    _loadRaces();
    _pageController = PageController();
  }

  late PageController _pageController;
  int _pageIndex = 0;

  Future<void> _loadClasses() async {
    // Try to find any assets under lib/Data/ via AssetManifest. If found, try each
    // JSON asset until some classes are loaded. Fallback to the original path.
    try {
      final assets = await DataAssets.listDataAssets();
      for (final a in assets) {
        try {
          final loaded = await DnDClassLoader.loadClasses(a);
          if (loaded.isNotEmpty) {
            _classList = loaded;
            setState(() {});
            return;
          }
        } catch (_) {
          // ignore and try next asset
        }
      }

      // fallback to the single hard-coded asset name used previously
      _classList = await DnDClassLoader.loadClasses(
          'lib/Data/dnd-export-complete-2025-10-10.json');
      setState(() {});
    } catch (_) {
      // ignore errors while loading classes
    }
  }

  Future<void> _loadRaces() async {
    try {
      final assets = await DataAssets.listDataAssets();
      for (final a in assets) {
        try {
          final loaded = await DnDRaceLoader.loadRaces(a);
          if (loaded.isNotEmpty) {
            _raceList = loaded;
            setState(() {});
            break;
          }
        } catch (_) {}
      }

      // backgrounds: try assets too
      for (final a in assets) {
        try {
          final loaded = await DnDBackgroundLoader.loadBackgrounds(a);
          if (loaded.isNotEmpty) {
            _backgroundList = loaded;
            setState(() {});
            break;
          }
        } catch (_) {}
      }

      // fallback single file
      if (_raceList == null) {
        _raceList = await DnDRaceLoader.loadRaces(
            'lib/Data/dnd-export-complete-2025-10-10.json');
        setState(() {});
      }
      if (_backgroundList == null) {
        _backgroundList = await DnDBackgroundLoader.loadBackgrounds(
            'lib/Data/dnd-export-complete-2025-10-10.json');
        setState(() {});
      }
    } catch (_) {
      // ignore races/background load errors
    }
  }

  Future<void> _showBackgroundSelector(BuildContext context) async {
    if (_backgroundList == null) return;
    final selected = await showUnifiedSelector<DnDBackground>(
      context: context,
      title: 'Select a Background',
      items: _backgroundList!,
      titleBuilder: (b) =>
          Text(b.name, style: const TextStyle(color: Colors.white)),
      detailsBuilder: (b) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (b.description.isNotEmpty)
            Text(b.description, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          if (b.raw['skillProficiencies'] != null)
            Text('Skills: ${(b.raw['skillProficiencies'] as List).join(', ')}',
                style: const TextStyle(color: Colors.white70)),
          if (b.raw['equipment'] != null)
            Text(
                'Equipment: ${(b.raw['equipment'] is List) ? (b.raw['equipment'] as List).join(', ') : b.raw['equipment'].toString()}',
                style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedBackground = selected;
      });
    }
  }

  void _recalculateHp({bool preserveCurrent = true}) {
    final level = AbilityMath.parseLevel(_levelController.text);
    final con = AbilityMath.parseScore(_abilityControllers['CON']!.text);
    final conMod = AbilityMath.modifierFromScore(con);
    final baseDie = _selectedClass?.hitDice ?? 0;

    // Simple HP progression: level 1 = baseDie + conMod, subsequent levels add average hit die + conMod
    final int perLevelGain = ((baseDie / 2).floor() + 1) + conMod;
    int newMax;
    if (baseDie > 0) {
      newMax = baseDie + conMod + (level - 1) * perLevelGain;
      if (newMax < 1) newMax = 1;
    } else {
      newMax = (1 + conMod) * level;
      if (newMax < 1) newMax = 1;
    }

    int current = HpStore.instance.current;
    if (!preserveCurrent) current = newMax;
    current = current.clamp(0, newMax);
    HpStore.instance.setHp(current, newMax);
    setState(() {});
  }

  String _initiativeString() {
    final dex = AbilityMath.parseScore(_abilityControllers['DEX']!.text);
    final mod = AbilityMath.modifierFromScore(dex);
    return mod >= 0 ? '+$mod' : '$mod';
  }

  Future<void> _showHpPopup(BuildContext context) async {
    final cur = HpStore.instance.current;
    final max = HpStore.instance.max;
    final curController = TextEditingController(text: cur.toString());
    final maxController = TextEditingController(text: max.toString());

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit HP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: curController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Current'),
            ),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                final newCur = int.tryParse(curController.text) ?? cur;
                final newMax = int.tryParse(maxController.text) ?? max;
                HpStore.instance.setHp(newCur, newMax);
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'))
        ],
      ),
    );

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    for (var c in _abilityControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _sectionCard({required String title, required Widget child}) => Card(
        color: Colors.blueGrey[800]?.withAlpha((0.9 * 255).round()),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              child
            ])),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('D&D Character Sheet'),
          backgroundColor: Colors.blueGrey[900]),
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF3B4852), Color(0xFF2E3538)])),
              child: CustomPaint(painter: _GrainPainter()),
            ),
          ),

          // main content as pages
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              children: [
                // original character sheet content wrapped
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(8, 160, 8, 24),
                  child: Column(
                    children: [
                      _sectionCard(
                        title: 'Character Info',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Text('Name:',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                            controller: _nameController,
                                            style: const TextStyle(
                                                color: Colors.white),
                                            decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Name')),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Level + HD directly under Name (moved here)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Level:',
                                    style: TextStyle(color: Colors.white)),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 48,
                                  child: TextField(
                                    controller: _levelController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none),
                                    style: const TextStyle(color: Colors.white),
                                    onChanged: (_) => _recalculateHp(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  _selectedClass != null
                                      ? 'HD: ${TraitFormatter.formatHitDie(_selectedClass!.hitDice)}'
                                      : 'HD: —',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[800],
                                      foregroundColor: Colors.white,
                                      shape: const StadiumBorder(),
                                      side: const BorderSide(
                                          color: Colors.white24),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                    ),
                                    onPressed: _classList == null
                                        ? null
                                        : () async {
                                            final selected =
                                                await showUnifiedSelector<
                                                    DnDClass>(
                                              context: context,
                                              title: 'Select a Class',
                                              items: _classList!,
                                              titleBuilder: (c) => Text(c.name,
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                              detailsBuilder: (c) => Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (c.description.isNotEmpty)
                                                    Text(c.description,
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white70)),
                                                  const SizedBox(height: 8),
                                                  if (c.primaryAbility
                                                      .isNotEmpty)
                                                    Text(
                                                        'Primary: ${c.primaryAbility.join(', ')}',
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white70)),
                                                  if (c.savingThrowProficiencies
                                                      .isNotEmpty)
                                                    Text(
                                                        'Saves: ${c.savingThrowProficiencies.join(', ')}',
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white70)),
                                                  if (c.skillProficiencies
                                                      .isNotEmpty)
                                                    Text(
                                                        'Skills: ${c.skillProficiencies.join(', ')}',
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white70)),
                                                  if (c.startingEquipment
                                                      .isNotEmpty)
                                                    Text(
                                                        'Starting: ${c.startingEquipment}',
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white70)),
                                                ],
                                              ),
                                            );

                                            if (selected != null) {
                                              setState(() {
                                                _selectedClass = selected;
                                                _selectedClassName =
                                                    selected.name;
                                                _recalculateHp(
                                                    preserveCurrent: false);
                                              });
                                            }
                                          },
                                    child: Text(_selectedClassName ??
                                        (_classList == null
                                            ? 'Loading...'
                                            : 'Class')),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[800],
                                      foregroundColor: Colors.white,
                                      shape: const StadiumBorder(),
                                      side: const BorderSide(
                                          color: Colors.white24),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                    ),
                                    onPressed: _raceList == null
                                        ? null
                                        : () async {
                                            final selected =
                                                await showUnifiedSelector<
                                                    DnDRace>(
                                              context: context,
                                              title: 'Select a Race',
                                              items: _raceList!,
                                              titleBuilder: (r) => Text(r.name,
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                              detailsBuilder: (r) => Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (r.description.isNotEmpty)
                                                    Text(r.description,
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white70)),
                                                  const SizedBox(height: 8),
                                                  if (r.traits.isNotEmpty)
                                                    Text(
                                                        'Traits: ${r.traits.keys.join(', ')}',
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white70)),
                                                ],
                                              ),
                                            );

                                            if (selected != null) {
                                              setState(() {
                                                _selectedRace = selected;
                                                _selectedRaceName =
                                                    selected.name;
                                              });
                                            }
                                          },
                                    child: Text(_selectedRaceName ??
                                        (_raceList == null
                                            ? 'Loading...'
                                            : 'Race')),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[800],
                                      foregroundColor: Colors.white,
                                      shape: const StadiumBorder(),
                                      side: const BorderSide(
                                          color: Colors.white24),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                    ),
                                    onPressed: _backgroundList == null
                                        ? null
                                        : () =>
                                            _showBackgroundSelector(context),
                                    child: Text(
                                        _selectedBackground?.name ??
                                            'Background',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[800],
                                      foregroundColor: Colors.white,
                                      shape: const StadiumBorder(),
                                      side: const BorderSide(
                                          color: Colors.white24),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                    ),
                                    onPressed: () {},
                                    child: const Text('Alignment',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _sectionCard(
                        title: 'Ability Scores',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA']
                              .map((k) {
                            return Column(
                              children: [
                                Text(k,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 48,
                                  child: TextField(
                                    controller: _abilityControllers[k],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none),
                                    style: const TextStyle(color: Colors.white),
                                    onChanged: (_) {
                                      if (k == 'CON') _recalculateHp();
                                      if (k == 'DEX') setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      _sectionCard(
                        title: 'Combat Stats',
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Column(children: [
                                Text('AC',
                                    style: TextStyle(color: Colors.white)),
                                SizedBox(height: 6),
                                Text('10',
                                    style: TextStyle(color: Colors.white))
                              ]),
                              Column(children: [
                                const Text('Initiative',
                                    style: TextStyle(color: Colors.white)),
                                const SizedBox(height: 6),
                                Text(_initiativeString(),
                                    style: const TextStyle(color: Colors.white))
                              ]),
                              Column(children: [
                                const Text('Speed',
                                    style: TextStyle(color: Colors.white)),
                                const SizedBox(height: 6),
                                Text(
                                    _selectedRace != null
                                        ? (TraitFormatter.formatDistance(
                                                _selectedRace!
                                                    .traits['speed']) ??
                                            '30 ft')
                                        : '30 ft',
                                    style: const TextStyle(color: Colors.white))
                              ])
                            ]),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),

                // Money & Equipment page
                MoneyEquipmentPage(),
              ],
            ),
          ),

          // page indicator
          Positioned(
            left: 0,
            right: 0,
            top: 120,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(2, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _pageIndex == i ? 12 : 8,
                    height: _pageIndex == i ? 12 : 8,
                    decoration: BoxDecoration(
                        color: _pageIndex == i ? Colors.white : Colors.white24,
                        shape: BoxShape.circle),
                  );
                }),
              ),
            ),
          ),

          // HP control on top
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: Center(
              child: GestureDetector(
                onTap: () => _showHpPopup(context),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 3, color: Colors.black87)),
                  child: ClipOval(
                    child: Stack(
                      children: [
                        Column(children: [
                          Expanded(child: Container(color: Colors.green[600])),
                          Expanded(child: Container(color: Colors.red[700]))
                        ]),
                        const IgnorePointer(
                            child: Align(
                                alignment: Alignment(0, -0.4),
                                child: Text('HP',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)))),
                        IgnorePointer(
                            child: Align(
                                alignment: const Alignment(0, 0.4),
                                child: AnimatedBuilder(
                                    animation: HpStore.instance,
                                    builder: (_, __) => Text(
                                        '${HpStore.instance.current} / ${HpStore.instance.max}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18))))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final math.Random _rnd = math.Random(42);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromRGBO(255, 255, 255, 0.02);
    final int count =
        (size.width * size.height / 4000).clamp(400, 2000).toInt();
    for (int i = 0; i < count; i++) {
      final x = _rnd.nextDouble() * size.width;
      final y = _rnd.nextDouble() * size.height;
      final s = _rnd.nextDouble() * 1.4;
      canvas.drawRect(Rect.fromLTWH(x, y, s, s), paint);
    }
    final vignette = Paint()
      ..shader = const RadialGradient(
              colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.25)],
              stops: [0.6, 1.0])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AbilityMath {
  static int parseScore(String text) => int.tryParse(text) ?? 0;
  static int modifierFromScore(int score) => ((score - 10) / 2).floor();
  static int parseLevel(String text) => int.tryParse(text) ?? 1;
}
