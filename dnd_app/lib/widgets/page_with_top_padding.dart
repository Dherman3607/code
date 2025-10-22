import 'package:flutter/material.dart';

/// Simple helper used by character_sheet to wrap page content with a top offset.
class PageWithTopPadding extends StatelessWidget {
  final Widget child;
  const PageWithTopPadding({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 160, 8, 24),
      child: child,
    );
  }
}
