import 'package:flutter/material.dart';
import '../classes.dart';

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

    if (_expandedIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCard(index));
    }
  }

  void _scrollToCard(int index) {
    try {
      if (index < 0 || index >= _cardKeys.length) return;
      final cardContext = _cardKeys[index].currentContext;
      if (cardContext == null) return;
      Scrollable.ensureVisible(
        cardContext,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOut,
        alignment: 0.02,
      );
    } catch (e) {}
  }

  Widget _buildCard(DnDClass c, int index) {
    final expanded = _expandedIndex == index;
    final cardKey = (index < _cardKeys.length) ? _cardKeys[index] : GlobalKey();
    return Container(
      key: cardKey,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800]?.withAlpha((0.9 * 255).round()),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(c.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: c.primaryAbility.isNotEmpty
                ? Text(
                    'Primary: ${c.primaryAbility.map((s) => s[0].toUpperCase() + s.substring(1)).join(', ')}',
                    style: const TextStyle(color: Colors.white70))
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.description.isNotEmpty) ...[
                    Text(c.description,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                  ],
                  if (c.skillProficiencies.isNotEmpty) ...[
                    const Text('Skill Proficiencies:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(c.skillProficiencies.join(', '),
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                  ],
                  if (c.weaponProficiencies.isNotEmpty) ...[
                    const Text('Weapons:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(c.weaponProficiencies,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                  ],
                  if (c.armorTraining.isNotEmpty) ...[
                    const Text('Armor:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(c.armorTraining,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                  ],
                  if (c.startingEquipment.isNotEmpty) ...[
                    const Text('Starting Equipment:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(
                        c.startingEquipment.replaceAllMapped(
                            RegExp(r"\(A\)|\(B\)|\(C\)"), (m) => "\n${m[0]}"),
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        key: ValueKey('select_btn_${c.id}'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[700],
                            foregroundColor: Colors.white),
                        onPressed: () {
                          widget.onSelected(c);
                        },
                        child: const Text('Select'),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B4852), Color(0xFF2E3538), Color(0xFF242627)],
              stops: [0.0, 0.6, 1.0]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                      child: Text('Select a Class',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  IconButton(
                      key: const ValueKey('close_selector_btn'),
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop())
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  key: _listKey,
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.classes.length,
                  itemBuilder: (context, index) {
                    final cls = widget.classes[index];
                    if (_cardKeys.length <= index) {
                      _cardKeys.addAll(List.generate(
                          index - _cardKeys.length + 1, (_) => GlobalKey()));
                    }
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
