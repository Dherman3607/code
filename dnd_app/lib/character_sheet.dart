import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'class_selector_menu.dart';
import 'classes.dart';
import 'race_selector_menu.dart';
import 'races.dart';
import 'utils/trait_formatter.dart';
import 'hp_store.dart';
import 'backgrounds.dart';

// Clean, minimal CharacterSheet implementation.
class CharacterSheet extends StatefulWidget {
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
  String? _selectedBackgroundName;
  @override
  void initState() {
    super.initState();
    HpStore.instance.setHp(0, 0);
    _loadClasses();
    _loadRaces();
  }

  Future<void> _loadClasses() async {
    try {
      _classList = await DnDClassLoader.loadClasses(
          'lib/Data/dnd-export-complete-2025-10-10.json');
      setState(() {});
    } catch (_) {}
  }

  Future<void> _loadRaces() async {
    try {
      _raceList = await DnDRaceLoader.loadRaces(
          'lib/Data/dnd-export-complete-2025-10-10.json');
      setState(() {});
    } catch (_) {}
    // also load backgrounds if available
    try {
      _backgroundList = await DnDBackgroundLoader.loadBackgrounds(
          'lib/Data/dnd-export-complete-2025-10-10.json');
      setState(() {});
    } catch (_) {}
  }

  Future<void> _showBackgroundSelector(BuildContext context) async {
    if (_backgroundList == null) return;
    int? expandedIndex;
    final selected = await showDialog<DnDBackground>(
        context: context,
        builder: (ctx) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.78,
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: StatefulBuilder(builder: (ctx, setStateDialog) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text('Select a Background',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop())
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.white24),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: _backgroundList!.length,
                        itemBuilder: (context, index) {
                          final b = _backgroundList![index];
                          final expanded = expandedIndex == index;
                          return Container(
                            key: ValueKey(b.id),
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[800]?.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(b.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  subtitle: b.description.isNotEmpty
                                      ? Text(b.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              TextStyle(color: Colors.white70))
                                      : null,
                                  trailing: IconButton(
                                      icon: Icon(
                                          expanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Colors.white),
                                      onPressed: () => setStateDialog(() {
                                            expandedIndex =
                                                expanded ? null : index;
                                            // scroll into view after expansion
                                            if (expandedIndex != null) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                Scrollable.ensureVisible(
                                                    context,
                                                    duration: Duration(
                                                        milliseconds: 360),
                                                    alignment: 0.02);
                                              });
                                            }
                                          })),
                                  onTap: () => setStateDialog(() {
                                    expandedIndex = expanded ? null : index;
                                  }),
                                ),
                                if (expanded)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (b.description.isNotEmpty) ...[
                                          Text(b.description,
                                              style: TextStyle(
                                                  color: Colors.white70)),
                                          SizedBox(height: 8),
                                        ],
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(b),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blueGrey[700],
                                                  foregroundColor:
                                                      Colors.white),
                                              child: Text('Select'),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              }),
            ),
          );
        });
    if (selected != null) {
      setState(() {
        _selectedBackground = selected;
        _selectedBackgroundName = selected.name;
      });
    }
  }

  void _recalculateHp({bool preserveCurrent = true}) {
    final level = AbilityMath.parseLevel(_levelController.text);
    final con = AbilityMath.parseScore(_abilityControllers['CON']!.text);
    final conMod = AbilityMath.modifierFromScore(con);
    final hd = _selectedClass?.hitDice ?? 8;
    final computedMax = hd * level + conMod * level;
    HpStore.instance
        .setHp(HpStore.instance.current.clamp(0, computedMax), computedMax);
    setState(() {});
  }

  String _initiativeString() {
    final dex = AbilityMath.parseScore(_abilityControllers['DEX']!.text);
    final mod = AbilityMath.modifierFromScore(dex);
    return (mod >= 0) ? '+$mod' : '$mod';
  }

  Future<void> _showHpPopup(BuildContext context,
      {bool initialHeal = true}) async {
    bool isHeal = initialHeal;
    String amount = '1';
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: Text(isHeal ? 'Heal' : 'Damage'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ChoiceChip(
                  label: Text('Heal'),
                  selected: isHeal,
                  onSelected: (_) => setState(() => isHeal = true)),
              SizedBox(width: 8),
              ChoiceChip(
                  label: Text('Damage'),
                  selected: !isHeal,
                  onSelected: (_) => setState(() => isHeal = false)),
            ]),
            SizedBox(height: 12),
            TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
                onChanged: (v) => amount = v),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showHpLog(context);
                },
                child: Text('Log')),
            ElevatedButton(
                onPressed: () {
                  final n = int.tryParse(amount) ?? 1;
                  HpStore.instance.applyChange(isHeal ? n : -n,
                      type: isHeal ? 'heal' : 'damage');
                  Navigator.of(ctx).pop();
                },
                child: Text('Apply')),
          ],
        );
      }),
    );
  }

  Future<void> _showHpLog(BuildContext context) async {
    await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('HP Log'),
            content: SizedBox(
                width: 360,
                child: AnimatedBuilder(
                    animation: HpStore.instance,
                    builder: (_, __) {
                      final log = HpStore.instance.log;
                      if (log.isEmpty) return Text('No entries');
                      return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: log
                              .map((e) => ListTile(
                                  title: Text('${e.type} ${e.delta}'),
                                  subtitle:
                                      Text('${e.when} — before ${e.before}')))
                              .toList());
                    })),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Close')),
              TextButton(
                  onPressed: () {
                    final undone = HpStore.instance.undoLast();
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text(undone ? 'Undid last' : 'Nothing to undo')));
                  },
                  child: Text('Undo last'))
            ],
          );
        });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    for (var c in _abilityControllers.values) c.dispose();
    super.dispose();
  }

  Widget _sectionCard({required String title, required Widget child}) => Card(
        color: Colors.blueGrey[800]?.withOpacity(0.9),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
            padding: EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 8),
              child
            ])),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('D&D Character Sheet'),
          backgroundColor: Colors.blueGrey[900]),
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF3B4852), Color(0xFF2E3538)])),
              child: CustomPaint(painter: _GrainPainter()),
            ),
          ),

          // main content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(8, 160, 8, 24),
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
                                  Text('Name:',
                                      style: TextStyle(color: Colors.white)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                        controller: _nameController,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Name')),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Level + HD directly under Name (moved here)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Level:',
                                style: TextStyle(color: Colors.white)),
                            SizedBox(width: 8),
                            SizedBox(
                              width: 48,
                              child: TextField(
                                controller: _levelController,
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecoration(border: InputBorder.none),
                                style: TextStyle(color: Colors.white),
                                onChanged: (_) => _recalculateHp(),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              _selectedClass != null
                                  ? 'HD: ${TraitFormatter.formatHitDie(_selectedClass!.hitDice)}'
                                  : 'HD: —',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Spacer(),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[800],
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  side: BorderSide(color: Colors.white24),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                ),
                                onPressed: _classList == null
                                    ? null
                                    : () async {
                                        final selected = await showDialog<
                                                DnDClass>(
                                            context: context,
                                            builder: (_) => ClassSelectorMenu(
                                                classes: _classList!,
                                                onSelected: (c) =>
                                                    Navigator.of(context)
                                                        .pop(c)));
                                        if (selected != null)
                                          setState(() {
                                            _selectedClass = selected;
                                            _selectedClassName = selected.name;
                                            _recalculateHp(
                                                preserveCurrent: false);
                                          });
                                      },
                                child: Text(_selectedClassName ??
                                    (_classList == null
                                        ? 'Loading...'
                                        : 'Class')),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[800],
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  side: BorderSide(color: Colors.white24),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                ),
                                onPressed: _raceList == null
                                    ? null
                                    : () async {
                                        final selected = await showDialog<
                                                DnDRace>(
                                            context: context,
                                            builder: (_) => RaceSelectorMenu(
                                                races: _raceList!,
                                                onSelected: (r) =>
                                                    Navigator.of(context)
                                                        .pop(r)));
                                        if (selected != null)
                                          setState(() {
                                            _selectedRace = selected;
                                            _selectedRaceName = selected.name;
                                          });
                                      },
                                child: Text(_selectedRaceName ??
                                    (_raceList == null
                                        ? 'Loading...'
                                        : 'Race')),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[800],
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  side: BorderSide(color: Colors.white24),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                ),
                                onPressed: _backgroundList == null
                                    ? null
                                    : () => _showBackgroundSelector(context),
                                child: Text(
                                    _selectedBackgroundName ?? 'Background',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[800],
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  side: BorderSide(color: Colors.white24),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8),
                                ),
                                onPressed: () {},
                                child: Text('Alignment',
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
                            .map((k) => Column(children: [
                                  Text(k,
                                      style: TextStyle(color: Colors.white)),
                                  SizedBox(height: 6),
                                  SizedBox(
                                      width: 48,
                                      child: TextField(
                                          controller: _abilityControllers[k],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          style: TextStyle(color: Colors.white),
                                          onChanged: (_) {
                                            if (k == 'CON') _recalculateHp();
                                            if (k == 'DEX') setState(() {});
                                          }))
                                ]))
                            .toList()),
                  ),
                  _sectionCard(
                    title: 'Combat Stats',
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [
                            Text('AC', style: TextStyle(color: Colors.white)),
                            SizedBox(height: 6),
                            Text('10', style: TextStyle(color: Colors.white))
                          ]),
                          Column(children: [
                            Text('Initiative',
                                style: TextStyle(color: Colors.white)),
                            SizedBox(height: 6),
                            Text(_initiativeString(),
                                style: TextStyle(color: Colors.white))
                          ]),
                          Column(children: [
                            Text('Speed',
                                style: TextStyle(color: Colors.white)),
                            SizedBox(height: 6),
                            Text(
                                _selectedRace != null
                                    ? (TraitFormatter.formatDistance(
                                            _selectedRace!.traits['speed']) ??
                                        '30 ft')
                                    : '30 ft',
                                style: TextStyle(color: Colors.white))
                          ])
                        ]),
                  ),
                  SizedBox(height: 120),
                ],
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
                        IgnorePointer(
                            child: Align(
                                alignment: Alignment(0, -0.4),
                                child: Text('HP',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)))),
                        IgnorePointer(
                            child: Align(
                                alignment: Alignment(0, 0.4),
                                child: AnimatedBuilder(
                                    animation: HpStore.instance,
                                    builder: (_, __) => Text(
                                        '${HpStore.instance.current} / ${HpStore.instance.max}',
                                        style: TextStyle(
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
