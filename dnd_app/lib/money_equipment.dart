import 'package:flutter/material.dart';

class MoneyEquipmentPage extends StatelessWidget {
  final TextEditingController ppController = TextEditingController(text: '0');
  final TextEditingController gpController = TextEditingController(text: '0');
  final TextEditingController spController = TextEditingController(text: '0');
  final TextEditingController cpController = TextEditingController(text: '0');

  MoneyEquipmentPage({Key? key}) : super(key: key);

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

          // Equipment section
          Card(
            color: Colors.blueGrey[800]?.withAlpha((0.9 * 255).round()),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Equipment',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 8),
                  TextField(
                    maxLines: 8,
                    decoration: InputDecoration(
                        hintText: 'List items, one per line',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none),
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
