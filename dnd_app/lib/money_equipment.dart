import 'package:flutter/material.dart';
import 'data_assets.dart';
import 'equipment.dart';

class MoneyEquipmentPage extends StatefulWidget {
  const MoneyEquipmentPage({Key? key}) : super(key: key);

  @override
  State<MoneyEquipmentPage> createState() => _MoneyEquipmentPageState();
}

class _MoneyEquipmentPageState extends State<MoneyEquipmentPage> {
  late final TextEditingController ppController;
  late final TextEditingController gpController;
  late final TextEditingController spController;
  late final TextEditingController cpController;
  late final TextEditingController equipmentController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _allEquipment = [];
  List<String> _filteredEquipment = [];

  @override
  void initState() {
    super.initState();
    ppController = TextEditingController(text: '0');
    gpController = TextEditingController(text: '0');
    spController = TextEditingController(text: '0');
    cpController = TextEditingController(text: '0');
    equipmentController = TextEditingController();
    _loadEquipmentFromAssets();
    _searchController.addListener(() {
      final q = _searchController.text.toLowerCase();
      setState(() {
        _filteredEquipment =
            _allEquipment.where((e) => e.toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  void dispose() {
    ppController.dispose();
    gpController.dispose();
    spController.dispose();
    cpController.dispose();
    equipmentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _platinumColor() => const Color(0xFFE6E6EA);
  Color _goldColor() => const Color(0xFFFFD54F);
  Color _silverColor() => const Color(0xFFC0C0C0);
  Color _copperColor() => const Color(0xFFB87333);

  Widget _coinBox(String label, TextEditingController controller, Color bg) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: bg,
        ),
        // slightly smaller padding so content fits comfortably
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14)),
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              height: 32, // constrain height so TextField won't overflow
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 160, 8, 24),
      child: Column(
        children: [
          // Money card
          Card(
            color: Colors.blueGrey[800]?.withAlpha((0.9 * 255).round()),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Money',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Container(
                    height: 96,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12)),
                    child: Row(
                      children: [
                        _coinBox('PP', ppController, _platinumColor()),
                        _coinBox('GP', gpController, _goldColor()),
                        _coinBox('SP', spController, _silverColor()),
                        _coinBox('CP', cpController, _copperColor()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Equipment card
          Card(
            color: Colors.blueGrey[800]?.withAlpha((0.9 * 255).round()),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Equipment',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Add pressed')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Equipment text area
                  TextField(
                    controller: equipmentController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                        hintText: 'List items, one per line',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none),
                    style: const TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 12),

                  // Search and equipment list
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search equipment',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.blueGrey[700],
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                      color:
                          Colors.blueGrey[800]?.withAlpha((0.9 * 255).round()),
                    ),
                    child: _filteredEquipment.isEmpty
                        ? const Center(
                            child: Text('No equipment found',
                                style: TextStyle(color: Colors.white70)),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _filteredEquipment.length,
                            itemBuilder: (ctx, i) {
                              final name = _filteredEquipment[i];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(name,
                                            style: const TextStyle(
                                                color: Colors.white))),
                                    IconButton(
                                      onPressed: () {
                                        // append item as a new line
                                        final current =
                                            equipmentController.text;
                                        final append = current.isEmpty
                                            ? name
                                            : '$current\n$name';
                                        setState(() {
                                          equipmentController.text = append;
                                        });
                                      },
                                      icon: const Icon(Icons.add,
                                          color: Colors.white),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadEquipmentFromAssets() async {
    try {
      final assets = await DataAssets.listDataAssets();
      final Set<String> found = {};
      for (final path in assets) {
        try {
          final items = await EquipmentLoader.loadEquipment(path);
          found.addAll(items);
        } catch (_) {
          // ignore per-file errors
        }
      }
      setState(() {
        _allEquipment = found.toList()..sort();
        _filteredEquipment = List.from(_allEquipment);
      });
    } catch (e) {
      // ignore listing errors
    }
  }
}
