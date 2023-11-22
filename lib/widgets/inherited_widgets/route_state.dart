import "package:flutter/widgets.dart";
import "package:fridgital/shared/enums.dart";

class RouteState extends InheritedWidget {
  const RouteState({
    required this.activePage,
    required this.isSecondLayerEnabled,
    required this.moveTo,
    required this.toggleSecondLayer,
    required this.popNotifier,
    required bool isCreatingNewProduct,
    required void Function({required bool value}) setIsCreatingNewProduct,
    required this.toggleCreatingNewProduct,
    required super.child,
    super.key,
  })  : _isCreatingNewProduct = isCreatingNewProduct,
        _setCreatingNewProduct = setIsCreatingNewProduct;

  final bool isSecondLayerEnabled;
  final Pages activePage;
  final void Function(Pages) moveTo;
  final void Function() toggleSecondLayer;
  final void Function() toggleCreatingNewProduct;
  final ValueNotifier<int> popNotifier;

  final bool _isCreatingNewProduct;
  final void Function({required bool value}) _setCreatingNewProduct;

  bool get isCreatingNewProduct => _isCreatingNewProduct;
  set isCreatingNewProduct(bool value) => _setCreatingNewProduct(value: value);

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
