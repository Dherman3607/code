import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'class_selector_menu.dart';
import 'classes.dart';
import 'race_selector_menu.dart';
import 'races.dart';
import 'utils/trait_formatter.dart';
import 'styles.dart';
import 'hp_store.dart';

class CharacterSheet extends StatefulWidget {
  @override
  _CharacterSheetState createState() => _CharacterSheetState();
}

class _CharacterSheetState extends State<CharacterSheet> {
  // Use shared stat styles from lib/styles.dart
  final Map<String, String> _skills = {
    'Acrobatics': 'DEX',
    'Animal Handling': 'WIS',
    'Arcana': 'INT',
    'Athletics': 'STR',
    'Deception': 'CHA',
    'History': 'INT',
    'Insight': 'WIS',
    'Intimidation': 'CHA',
    'Investigation': 'INT',
    'Medicine': 'WIS',
    'Nature': 'INT',
    'Perception': 'WIS',
    'Performance': 'CHA',
    'Persuasion': 'CHA',
    'Religion': 'INT',
    'Sleight of Hand': 'DEX',
    'Stealth': 'DEX',
    'Survival': 'WIS',
  };
  final Map<String, bool> _proficiencies = {};
  String _name = '';
  late TextEditingController _nameController;
  late TextEditingController _levelController;
  final Map<String, TextEditingController> _abilityControllers = {};
  String? _selectedClassName;
  String? _selectedRaceName;
  List<DnDClass>? _classList;
  List<DnDRace>? _raceList;
  DnDClass? _selectedClass;
  DnDRace? _selectedRace;
  int _maxHp = 0;
  int _currentHp = 0;
  // HP is now stored centrally in HpStore; local transient fields removed
  bool _loadingClasses = false;
  bool _loadingRaces = false;
  // Track previously applied race bonuses so selecting a new race removes old bonuses
  final Map<String, int> _appliedRaceBonuses = {};

  @override
  void initState() {
    super.initState();
    for (var key in _skills.keys) {
      _proficiencies[key] = false;
    }
    _nameController = TextEditingController(text: _name);
    _levelController = TextEditingController(text: '1');
    for (var a in ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA']) {
      _abilityControllers[a] = TextEditingController(text: '10');
      _appliedRaceBonuses[a] = 0;
    }
    // initialize HpStore with current local values so UI starts consistent
    HpStore.instance.setHp(_currentHp, _maxHp);
    _loadClasses();
    _loadRaces();
  }

  Future<void> _loadRaces() async {
    setState(() => _loadingRaces = true);
    try {
      final races = await DnDRaceLoader.loadRaces(
          'lib/Data/dnd-export-complete-2025-10-10.json');
      setState(() {
        _raceList = races;
        _loadingRaces = false;
      });
    } catch (e) {
      setState(() => _loadingRaces = false);
    }
  }

  Future<void> _loadClasses() async {
    setState(() => _loadingClasses = true);
    try {
      final classes = await DnDClassLoader.loadClasses(
          'lib/Data/dnd-export-complete-2025-10-10.json');
      setState(() {
        _classList = classes;
        _loadingClasses = false;
      });
    } catch (e) {
      setState(() => _loadingClasses = false);
    }
  }

  void _applyRaceBonuses(DnDRace race) {
    // Remove previous bonuses
    _appliedRaceBonuses.forEach((abbr, bonus) {
      if (bonus != 0) {
        final controller = _abilityControllers[abbr];
        if (controller != null) {
          final base = int.tryParse(controller.text) ?? 10;
          controller.text = (base - bonus).toString();
        }
      }
      _appliedRaceBonuses[abbr] = 0;
    });

    // Try to parse abilityScoreIncrease trait which often looks like "+2 DEX, +1 INT"
    final trait = race.traits['abilityScoreIncrease'];
    if (trait is String) {
      final re = RegExp(r"([+-]?\d+)\s*([A-Za-z]{3})");
      for (final m in re.allMatches(trait)) {
        final val = int.tryParse(m.group(1) ?? '0') ?? 0;
        final abbr = (m.group(2) ?? '').toUpperCase();
        if (_abilityControllers.containsKey(abbr)) {
          final controller = _abilityControllers[abbr]!;
          final base = int.tryParse(controller.text) ?? 10;
          controller.text = (base + val).toString();
          _appliedRaceBonuses[abbr] = val;
        }
      }
    }
  }

  void _recalculateHp({bool preserveCurrent = true}) {
    final level = AbilityMath.parseLevel(_levelController.text);
    final conScore = AbilityMath.parseScore(_abilityControllers['CON']!.text);
    final conMod = AbilityMath.modifierFromScore(conScore);
    final hd = _selectedClass?.hitDice ?? 8;
    // Use maximum HP for each level (take max of hit die each level)
    // i.e., each level adds the full hit die (hd) plus the CON modifier
    final computedMax = hd * level + conMod * level;
    setState(() {
      if (preserveCurrent && _currentHp > 0) {
        // keep current but clamp to new max
        _currentHp = _currentHp.clamp(0, computedMax);
      } else {
        _currentHp = computedMax;
      }
      _maxHp = computedMax;
      HpStore.instance.setHp(_currentHp, _maxHp);
    });
  }

  Future<void> _showHpPopup(BuildContext context, {bool initialHeal = true}) {
    bool isHeal = initialHeal;
    String amountText = '1';
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: Text(isHeal ? 'Heal' : 'Damage'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Text('Heal'),
                      selected: isHeal,
                      onSelected: (v) => setState(() => isHeal = true),
                    ),
                    SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Damage'),
                      selected: !isHeal,
                      onSelected: (v) => setState(() => isHeal = false),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: '1',
                  ),
                  onChanged: (v) => amountText = v,
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final n = int.tryParse(amountText) ?? 1;
                  if (isHeal) {
                    HpStore.instance.inc(n);
                  } else {
                    HpStore.instance.dec(n);
                  }
                  Navigator.of(ctx).pop();
                },
                child: Text('Apply'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    // HpStore is a singleton; no local controllers to dispose
    for (var c in _abilityControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildAbility(String label) {
    final controller = _abilityControllers[label]!;
    int mod =
        AbilityMath.modifierFromScore(AbilityMath.parseScore(controller.text));
    String modText = AbilityMath.formatModifier(mod);
    final Color modColor = mod > 0
        ? Colors.green.shade300
        : (mod < 0 ? Colors.red.shade300 : Colors.white);
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 6),
        Text(modText,
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: modColor)),
        SizedBox(height: 6),
        SizedBox(
          width: 48,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            onChanged: (v) {
              setState(() {});
              if (label == 'CON') {
                _recalculateHp();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCombatStat(String name, String subtitle, {String? value}) {
    // Default placeholders (remove temporary underscores)
    String displayValue = value ?? '';
    final key = name.toLowerCase();
    if (displayValue.isEmpty) {
      if (key == 'ac')
        displayValue = '10';
      else if (key == 'initiative')
        displayValue = '+0';
      else if (key == 'speed')
        displayValue = '30 ft';
      else
        displayValue = '—';
    }
    // Render full-word label and value. Reserve a small helper area above the label
    // so that labels line up across the combat-stat columns. If this is Hit Points
    // render the small helper text there; otherwise leave it empty.
    final topLabel = subtitle.isNotEmpty ? subtitle : name;
    const double helperHeight = 18.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: helperHeight,
          child: Center(
            child: topLabel.toLowerCase() == 'hit points'
                ? Text('Current/max',
                    style: TextStyle(fontSize: 11, color: Colors.white70))
                : SizedBox.shrink(),
          ),
        ),
        // Full word label (bold) - aligned by baseline
        Baseline(
          baseline: 20.0,
          baselineType: TextBaseline.alphabetic,
          child: Text(topLabel,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ),
        SizedBox(height: 4),
        // Value - align by baseline with labels
        Baseline(
          baseline: StatStyles.baseline,
          baselineType: TextBaseline.alphabetic,
          child: Text(displayValue, style: StatStyles.textStyle),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      color: Colors.blueGrey[800]?.withOpacity(0.8),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('D&D Character Sheet'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B4852),
                    Color(0xFF2E3538),
                    Color(0xFF242627)
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
              child: CustomPaint(painter: _GrainPainter(), size: Size.infinite),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              // add top padding to avoid overlapping the centered circular HP card
              padding: EdgeInsets.fromLTRB(8, 180, 8, 8),
              physics: BouncingScrollPhysics(),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.apply(
                      bodyColor: Colors.white, displayColor: Colors.white),
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: Colors.white),
                  child: Column(
                    children: [
                      _buildSectionCard(
                        title: 'Character Info',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text('Name:',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: TextField(
                                          controller: _nameController,
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: 'Enter name',
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 8),
                                          ),
                                          onChanged: (v) =>
                                              setState(() => _name = v),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    key: const Key('classSelectorButton'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[800],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                    ),
                                    onPressed:
                                        _classList == null || _loadingClasses
                                            ? null
                                            : () async {
                                                // open selector dialog
                                                final selected =
                                                    await showDialog<DnDClass>(
                                                  context: context,
                                                  builder: (ctx) =>
                                                      ClassSelectorMenu(
                                                    classes: _classList!,
                                                    onSelected: (c) {
                                                      Navigator.of(ctx).pop(c);
                                                    },
                                                  ),
                                                );
                                                if (selected != null) {
                                                  setState(() {
                                                    _selectedClassName =
                                                        selected.name;
                                                    _selectedClass = selected;
                                                    _recalculateHp(
                                                        preserveCurrent: false);
                                                  });
                                                }
                                              },
                                    icon: Icon(Icons.arrow_drop_down),
                                    label: Text(
                                      _selectedClassName ??
                                          (_loadingClasses
                                              ? 'Loading...'
                                              : 'Class'),
                                      style: TextStyle(
                                        color: _selectedClassName != null
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    key: const Key('raceSelectorButton'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[800],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 8),
                                    ),
                                    onPressed: _raceList == null ||
                                            _loadingRaces
                                        ? null
                                        : () async {
                                            final selected =
                                                await showDialog<DnDRace>(
                                              context: context,
                                              builder: (ctx) =>
                                                  RaceSelectorMenu(
                                                races: _raceList!,
                                                onSelected: (r) =>
                                                    Navigator.of(ctx).pop(r),
                                              ),
                                            );
                                            if (selected != null) {
                                              setState(() {
                                                _applyRaceBonuses(selected);
                                                _selectedRace = selected;
                                                _selectedRaceName =
                                                    selected.name;
                                              });
                                            }
                                          },
                                    icon: Icon(Icons.arrow_drop_down),
                                    label: Text(
                                      _selectedRaceName ??
                                          (_loadingRaces
                                              ? 'Loading...'
                                              : 'Race'),
                                      style: TextStyle(
                                        color: _selectedRaceName != null
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: Text('Background: __________')),
                                SizedBox(width: 8),
                                Expanded(child: Text('Alignment: __________')),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text('Level:',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      SizedBox(width: 6),
                                      SizedBox(
                                        width: 48,
                                        child: TextField(
                                          controller: _levelController,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: '1',
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                          onChanged: (v) {
                                            setState(() {
                                              // level updated; recalc HP
                                            });
                                            _recalculateHp();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildSectionCard(
                        title: 'Ability Scores',
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildAbility('STR'),
                                _buildAbility('DEX'),
                                _buildAbility('CON'),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildAbility('INT'),
                                _buildAbility('WIS'),
                                _buildAbility('CHA'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildSectionCard(
                        title: 'Combat Stats',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            _buildCombatStat('AC', 'Armor Class'),
                            _buildCombatStat('Initiative', ''),
                            _buildCombatStat('Speed', '',
                                value: _selectedRace != null
                                    ? TraitFormatter.formatDistance(
                                        _selectedRace!.traits['speed'])
                                    : null),
                            SizedBox(width: 56),
                            _buildCombatStat('Hit Dice', '',
                                value: _selectedClass != null
                                    ? TraitFormatter.formatHitDie(
                                        _selectedClass!.hitDice)
                                    : null),
                          ],
                        ),
                      ),
                      // Add additional sections here as needed
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Centered circular HP control at top — larger, circular, with a white middle band
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: Card(
              color: Colors.transparent,
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    // outer border for the circle
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 3),
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          // top (green) and bottom (red) halves
                          Column(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      _showHpPopup(context, initialHeal: true),
                                  child: Container(
                                    color: Colors.green[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      _showHpPopup(context, initialHeal: false),
                                  child: Container(
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // HP label in the green half (top) and numbers in the red half (bottom)
                          // Use Align to position them separately and add drop shadows for contrast
                          IgnorePointer(
                            child: Align(
                              alignment: Alignment(0, -0.5),
                              child: Text(
                                'HP',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: Align(
                              alignment: Alignment(0, 0.5),
                              child: AnimatedBuilder(
                                animation: HpStore.instance,
                                builder: (ctx, __) => Text(
                                  '${HpStore.instance.current} / ${HpStore.instance.max}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black87,
                                        offset: Offset(0, 1.5),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
    final paint = Paint()..color = Color.fromRGBO(255, 255, 255, 0.02);
    final int count =
        (size.width * size.height / 4000).clamp(400, 2000).toInt();
    for (int i = 0; i < count; i++) {
      final x = _rnd.nextDouble() * size.width;
      final y = _rnd.nextDouble() * size.height;
      final s = _rnd.nextDouble() * 1.4;
      canvas.drawRect(Rect.fromLTWH(x, y, s, s), paint);
    }
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.25)],
        stops: [0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Utility class for ability score math (D&D 5e)
class AbilityMath {
  static int parseScore(String text) => int.tryParse(text) ?? 0;
  static int modifierFromScore(int score) => ((score - 10) / 2).floor();
  static String formatModifier(int mod) => mod >= 0 ? '+$mod' : '$mod';
  static int clampScore(int score, {int min = 1, int max = 30}) {
    return score.clamp(min, max);
  }

  static int parseLevel(String text) => int.tryParse(text) ?? 1;
  static int proficiencyBonusFromLevel(int level) {
    if (level <= 4) return 2;
    if (level <= 8) return 3;
    if (level <= 12) return 4;
    if (level <= 16) return 5;
    return 6;
  }
}
