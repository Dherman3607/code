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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ),
        Divider(height: 1, color: Colors.white24),
        Expanded(
          child: widget.items.isEmpty
              ? Center(
                  child:
                      Text('No items', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.items.length,
                  itemBuilder: (ctx, index) {
                    final item = widget.items[index];
                    final expanded = _expandedIndex == index;
                    return Container(
                      key: ValueKey(index),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[800]
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
                              _expandedIndex = expanded ? null : index;
                            }),
                          ),
                          if (expanded && widget.detailsBuilder != null)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: widget.detailsBuilder!(item),
                            ),
                          if (expanded)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(item),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[700],
                                      foregroundColor: Colors.white),
                                  child: Text('Select'),
                                ),
                                SizedBox(width: 12),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
