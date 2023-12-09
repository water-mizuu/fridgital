import "package:flutter/widgets.dart";
import "package:fridgital/back_end/change_notifiers/recipe_data.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";
import "package:fridgital/shared/enums.dart";

class RouteState extends InheritedWidget {
  const RouteState({
    required this.activePage,
    required this.popNotifier,

    /// isCreatingNewProduct
    required bool Function() getIsCreatingNewProduct,
    required void Function({required bool value}) setIsCreatingNewProduct,

    /// workingRecipe
    required Recipe? Function() getWorkingRecipe,
    required void Function({required Recipe? value}) setWorkingRecipe,
    required this.createDummyProduct,
    required super.child,
    super.key,
  })  : _getIsCreatingNewProduct = getIsCreatingNewProduct,
        _setCreatingNewProduct = setIsCreatingNewProduct,
        _getWorkingRecipe = getWorkingRecipe,
        _setWorkingRecipe = setWorkingRecipe;

  final MainTab activePage;

  /// A function that creates a dummy product with the given tags.
  final void Function(List<Tag>) createDummyProduct;

  /// A notifier that can be listened to, letting descendants know that the navigator has popped.
  final ValueNotifier<void> popNotifier;

  final bool Function() _getIsCreatingNewProduct;
  bool get isCreatingNewProduct => _getIsCreatingNewProduct();

  final void Function({required bool value}) _setCreatingNewProduct;
  set isCreatingNewProduct(bool value) => _setCreatingNewProduct(value: value);

  final Recipe? Function() _getWorkingRecipe;
  Recipe? get workingRecipe => _getWorkingRecipe();

  final void Function({required Recipe? value}) _setWorkingRecipe;
  set workingRecipe(Recipe? value) => _setWorkingRecipe(value: value);

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
      oldWidget.createDummyProduct != createDummyProduct ||
      oldWidget.popNotifier != popNotifier ||
      oldWidget._getIsCreatingNewProduct != _getIsCreatingNewProduct ||
      oldWidget._setCreatingNewProduct != _setCreatingNewProduct;
}
