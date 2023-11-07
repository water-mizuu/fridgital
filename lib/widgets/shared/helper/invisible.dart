import "package:flutter/material.dart";

/// Visibly "deletes" the [child] widget, being transparent graphically and in hit-tests.
class Invisible extends StatelessWidget {
  const Invisible({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: IgnorePointer(child: Opacity(opacity: 0.0, child: child)));
  }
}
