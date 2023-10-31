import "package:flutter/widgets.dart";
import "package:fridgital/shared/enums.dart";

class RouteState extends InheritedWidget {
  const RouteState({
    required this.activePage,
    required this.moveTo,
    required super.child,
    super.key,
  });

  final Pages activePage;
  final void Function(Pages) moveTo;

  static RouteState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RouteState>();
  }

  static RouteState of(BuildContext context) {
    var state = maybeOf(context);
    assert(state != null, "No RouteState found in context");

    return state!;
  }

  @override
  bool updateShouldNotify(covariant RouteState oldWidget) => oldWidget.activePage != activePage;
}
