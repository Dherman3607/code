import 'package:flutter/material.dart';

/// A small, reusable single-selection dialog with optional expandable details.
///
/// Usage: call `showUnifiedSelector<T>(...)` which returns the chosen item or null.
Future<T?> showUnifiedSelector<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required Widget Function(T item) titleBuilder,
  Widget? Function(T item)? detailsBuilder,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) {
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
              stops: [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _UnifiedSelectorBody<T>(
            title: title,
            items: items,
            titleBuilder: titleBuilder,
            detailsBuilder: detailsBuilder,
          ),
        ),
      );
    },
  );
}

class _UnifiedSelectorBody<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Widget Function(T) titleBuilder;
  final Widget? Function(T)? detailsBuilder;

  const _UnifiedSelectorBody(
      {Key? key,
      required this.title,
      required this.items,
      required this.titleBuilder,
      this.detailsBuilder})
      : super(key: key);

  @override
  State<_UnifiedSelectorBody<T>> createState() =>
      _UnifiedSelectorBodyState<T>();
}

class _UnifiedSelectorBodyState<T> extends State<_UnifiedSelectorBody<T>> {
  int? _expandedIndex;
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white24),
        Expanded(
          child: widget.items.isEmpty
              ? const Center(
                  child:
                      Text('No items', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.items.length,
                  itemBuilder: (ctx, index) {
                    final item = widget.items[index];
                    final expanded = _expandedIndex == index;
                    final isSelected = _selectedIndex == index;
                    return Container(
                      key: ValueKey(index),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueGrey[700]
                                ?.withAlpha((0.95 * 255).round())
                            : Colors.blueGrey[800]
                                ?.withAlpha((0.9 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: widget.titleBuilder(item),
                            subtitle: null,
                            trailing: IconButton(
                              icon: Icon(
                                  expanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.white),
                              onPressed: () => setState(() {
                                _expandedIndex = expanded ? null : index;
                              }),
                            ),
                            onTap: () => setState(() {
                              // select the tapped item and toggle expansion
                              _selectedIndex = index;
                              _expandedIndex = expanded ? null : index;
                            }),
                          ),
                          if (expanded && widget.detailsBuilder != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: widget.detailsBuilder!(item),
                            ),
                          // per-item select button removed in favor of bottom actions
                        ],
                      ),
                    );
                  },
                ),
        ),
        // Bottom action bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    backgroundColor: Colors.transparent,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedIndex == null
                      ? null
                      : () => Navigator.of(context)
                          .pop(widget.items[_selectedIndex!]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Select'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
