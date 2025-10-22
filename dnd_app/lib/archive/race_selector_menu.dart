import 'package:flutter/material.dart';
import '../races.dart';
import '../utils/trait_formatter.dart';

typedef OnRaceSelected = void Function(DnDRace race);

class RaceSelectorMenu extends StatefulWidget {
  final List<DnDRace> races;
  final OnRaceSelected onSelected;

  const RaceSelectorMenu({Key? key, required this.races, required this.onSelected}) : super(key: key);

  @override
  _RaceSelectorMenuState createState() => _RaceSelectorMenuState();
}

class _RaceSelectorMenuState extends State<RaceSelectorMenu> {
  int? _expandedIndex;
  final List<GlobalKey> _cardKeys = [];

  void _toggleExpand(int index) {
    setState(() => _expandedIndex = _expandedIndex == index ? null : index);
    if (_expandedIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _cardContext(index);
        if (ctx != null) Scrollable.ensureVisible(ctx, duration: Duration(milliseconds: 360), alignment: 0.02);
      });
    }
  }

  BuildContext? _cardContext(int index) {
    final key = _cardKeys.length > index ? _cardKeys[index] : null;
    return key?.currentContext;
  }

  Widget _buildCard(DnDRace r, int index) {
    final expanded = _expandedIndex == index;
    final key = (index < _cardKeys.length) ? _cardKeys[index] : GlobalKey();

    return Container(
      key: key,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800]?.withAlpha((0.9 * 255).round()),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(r.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: r.traits['size'] != null ? Text('Size: ${r.traits['size']}', style: TextStyle(color: Colors.white70)) : null,
            trailing: IconButton(icon: Icon(expanded ? Icons.expand_less : Icons.expand_more, color: Colors.white), onPressed: () => _toggleExpand(index)),
            onTap: () => _toggleExpand(index),
          ),
          if (expanded)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.description.isNotEmpty) ...[Text(r.description, style: TextStyle(color: Colors.white70)), SizedBox(height: 8)],
                  if (r.traits.isNotEmpty) ...[
                    Text('Traits:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 6),
                    ...r.traits.entries.expand<Widget>((e) {
                      final label = e.key.toString();
                      final value = e.value;
                      String formatted;
                      if (value is List) {
                        formatted = value.map((v) => v.toString()).join(', ');
                      } else if (label.toLowerCase() == 'speed' || label.toLowerCase() == 'darkvision') {
                        formatted = TraitFormatter.formatDistance(value) ?? '';
                      } else if (label.toLowerCase() == 'hitdice' || label.toLowerCase() == 'hit_die') {
                        formatted = TraitFormatter.formatHitDie(value) ?? '';
                      } else if (value is String && RegExp(r"^\d+d\d+").hasMatch(value)) {
                        formatted = TraitFormatter.formatDamage(value);
                      } else {
                        formatted = value?.toString() ?? '';
                      }
                      return [
                        Text(label[0].toUpperCase() + label.substring(1) + ':', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Text(formatted, style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 8),
                      ];
                    }).toList(),
                    SizedBox(height: 8),
                  ],
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [ElevatedButton(onPressed: () => widget.onSelected(r), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700], foregroundColor: Colors.white), child: Text('Select'))])
                ],
              ),
            )
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
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3B4852), Color(0xFF2E3538), Color(0xFF242627)], stops: [0.0, 0.6, 1.0]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Padding(padding: EdgeInsets.all(12), child: Row(children: [Expanded(child: Text('Select a Race', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))), IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop())])),
          Divider(height: 1, color: Colors.white24),
          Expanded(child: ListView.builder(padding: EdgeInsets.symmetric(vertical: 8), itemCount: widget.races.length, itemBuilder: (context, index) {
            final r = widget.races[index];
            if (_cardKeys.length <= index) _cardKeys.addAll(List.generate(index - _cardKeys.length + 1, (_) => GlobalKey()));
            return _buildCard(r, index);
          }))
        ]),
      ),
    );
  }
}
