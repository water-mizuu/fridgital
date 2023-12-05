import "package:flutter/widgets.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/shared/enums.dart";

class RouteState extends InheritedWidget {
  const RouteState({
    required this.activePage,
    required this.popNotifier,
    required bool Function() getIsCreatingNewProduct,
    required void Function({required bool value}) setIsCreatingNewProduct,
    required this.toggleCreatingNewProduct,
    required this.createDummyProduct,
    required super.child,
    super.key,
  })  : _getIsCreatingNewProduct = getIsCreatingNewProduct,
        _setCreatingNewProduct = setIsCreatingNewProduct;

  final Pages activePage;

  /// A function that toggles the value of [isCreatingNewProduct].
  final void Function() toggleCreatingNewProduct;

  /// A function that creates a dummy product with the given tags.
  final void Function(List<Tag>) createDummyProduct;

  /// A notifier that can be listened to, letting descendants know that the navigator has popped.
  final ValueNotifier<void> popNotifier;

  final bool Function() _getIsCreatingNewProduct;
  bool get isCreatingNewProduct => _getIsCreatingNewProduct();

  final void Function({required bool value}) _setCreatingNewProduct;
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
      oldWidget.activePage != activePage ||
      oldWidget.toggleCreatingNewProduct != toggleCreatingNewProduct ||
      oldWidget.createDummyProduct != createDummyProduct ||
      oldWidget.popNotifier != popNotifier ||
      oldWidget._getIsCreatingNewProduct != _getIsCreatingNewProduct ||
      oldWidget._setCreatingNewProduct != _setCreatingNewProduct;
}
