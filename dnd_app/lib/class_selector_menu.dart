import 'package:flutter/material.dart';
import 'classes.dart';

typedef OnClassSelected = void Function(DnDClass cls);

class ClassSelectorMenu extends StatefulWidget {
  final List<DnDClass> classes;
  final OnClassSelected onSelected;

  const ClassSelectorMenu(
      {Key? key, required this.classes, required this.onSelected})
      : super(key: key);

  @override
  _ClassSelectorMenuState createState() => _ClassSelectorMenuState();
}

class _ClassSelectorMenuState extends State<ClassSelectorMenu> {
  final ScrollController _scrollController = ScrollController();
  int? _expandedIndex;
  final GlobalKey _listKey = GlobalKey();
  final List<GlobalKey> _cardKeys = [];

  void _toggleExpand(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });

    // If expanded, scroll to make it visible
    if (_expandedIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCard(index));
    }
  }

  void _scrollToCard(int index) {
    try {
      if (index < 0 || index >= _cardKeys.length) return;
      final cardContext = _cardKeys[index].currentContext;
      if (cardContext == null) return;

      // Use Scrollable.ensureVisible which handles different scrollables and
      // will animate the nearest Scrollable to bring the widget into view.
      Scrollable.ensureVisible(
        cardContext,
        duration: Duration(milliseconds: 360),
        curve: Curves.easeInOut,
        alignment: 0.02, // slightly below the top to avoid header overlap
      );
    } catch (e) {
      // ignore measurement errors
    }
  }

  Widget _buildCard(DnDClass c, int index) {
    final expanded = _expandedIndex == index;
    final cardKey = (index < _cardKeys.length) ? _cardKeys[index] : GlobalKey();
    return Container(
      key: cardKey,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800]?.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(c.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: c.primaryAbility.isNotEmpty
                ? Text(
                    'Primary: ${c.primaryAbility.map((s) => s[0].toUpperCase() + s.substring(1)).join(', ')}',
                    style: TextStyle(color: Colors.white70))
                : null,
            trailing: IconButton(
              key: ValueKey('expand_btn_${c.id}'),
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white),
              onPressed: () => _toggleExpand(index),
            ),
            onTap: () => _toggleExpand(index),
          ),
          if (expanded)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.description.isNotEmpty) ...[
                    Text(c.description,
                        style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                  ],
                  if (c.skillProficiencies.isNotEmpty) ...[
                    Text('Skill Proficiencies:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(c.skillProficiencies.join(', '),
                        style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                  ],
                  if (c.weaponProficiencies.isNotEmpty) ...[
                    Text('Weapons:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(c.weaponProficiencies,
                        style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                  ],
                  if (c.armorTraining.isNotEmpty) ...[
                    Text('Armor:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(c.armorTraining,
                        style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                  ],
                  if (c.startingEquipment.isNotEmpty) ...[
                    Text('Starting Equipment:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(
                        c.startingEquipment.replaceAllMapped(
                            RegExp(r"\(A\)|\(B\)|\(C\)"), (m) => "\n${m[0]}"),
                        style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        key: ValueKey('select_btn_${c.id}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          widget.onSelected(c);
                        },
                        child: Text('Select'),
                      ),
                    ],
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B4852), Color(0xFF2E3538), Color(0xFF242627)],
            stops: [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Select a Class',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  IconButton(
                    key: ValueKey('close_selector_btn'),
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white24),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  key: _listKey,
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.classes.length,
                  itemBuilder: (context, index) {
                    final cls = widget.classes[index];
                    // ensure we have a key for this index
                    if (_cardKeys.length <= index)
                      _cardKeys.addAll(List.generate(
                          index - _cardKeys.length + 1, (_) => GlobalKey()));
                    return _buildCard(cls, index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
