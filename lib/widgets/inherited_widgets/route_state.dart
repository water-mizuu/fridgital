import "package:flutter/widgets.dart";
import "package:fridgital/shared/enums.dart";

class RouteState extends InheritedWidget {
  const RouteState({
    required this.activePage,
    required this.isSecondLayerEnabled,
    required this.moveTo,
    required this.toggleSecondLayer,
    required super.child,
    super.key,
  });

  final bool isSecondLayerEnabled;
  final Pages activePage;
  final void Function(Pages) moveTo;
  final void Function() toggleSecondLayer;

  static RouteState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RouteState>();
  }

  static RouteState of(BuildContext context) {
    var state = maybeOf(context);
    assert(state != null, "No RouteState found in context");

    return state!;
  }

  @override
  bool updateShouldNotify(covariant RouteState oldWidget) =>
      oldWidget.activePage != activePage || oldWidget.isSecondLayerEnabled != isSecondLayerEnabled;
}
