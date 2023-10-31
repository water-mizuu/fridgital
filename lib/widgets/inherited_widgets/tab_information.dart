import "package:flutter/material.dart";

class TabInformation extends InheritedWidget {
  const TabInformation({
    required this.index,
    required this.controller,
    required super.child,
    super.key,
  });

  final TabController controller;
  final int index;

  static TabInformation? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabInformation>();
  }

  static TabInformation of(BuildContext context) {
    var state = maybeOf(context);
    assert(state != null, "No TabInformation found in context");

    return state!;
  }

  @override
  bool updateShouldNotify(covariant TabInformation oldWidget) =>
      oldWidget.index != index || oldWidget.controller != controller;
}
