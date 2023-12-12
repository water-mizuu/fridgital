import "package:flutter/widgets.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/back_end/change_notifiers/recipe_data.dart";
import "package:fridgital/back_end/change_notifiers/tag_data.dart";

class RouteState extends InheritedWidget {
  const RouteState({
    required this.popNotifier,

    /// isCreatingNewProduct
    required bool Function() getIsCreatingNewProduct,
    required void Function({required bool value}) setIsCreatingNewProduct,

    /// workingRecipe
    required Recipe? Function() getWorkingRecipe,
    required void Function({required Recipe? value}) setWorkingRecipe,

    /// workingProduct
    required Product? Function() getWorkingProduct,
    required void Function({required Product? value}) setWorkingProduct,

    /// Others
    required this.createDummyProduct,
    required super.child,
    super.key,
  })  : _getIsCreatingNewProduct = getIsCreatingNewProduct,
        _setCreatingNewProduct = setIsCreatingNewProduct,
        _getWorkingRecipe = getWorkingRecipe,
        _setWorkingRecipe = setWorkingRecipe,
        _getWorkingProduct = getWorkingProduct,
        _setWorkingProduct = setWorkingProduct;

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

  final Product? Function() _getWorkingProduct;
  Product? get workingProduct => _getWorkingProduct();

  final void Function({required Product? value}) _setWorkingProduct;
  set workingProduct(Product? value) => _setWorkingProduct(value: value);

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

      /// Check if the dummy product creator has changed.
      oldWidget.createDummyProduct != createDummyProduct ||

      /// Check if the pop notifier has changed.
      oldWidget.popNotifier != popNotifier ||

      /// Check if the getter for isCreatingNewProduct has changed.
      oldWidget._getIsCreatingNewProduct != _getIsCreatingNewProduct ||

      /// Check if [isCreatingNewProduct] has changed.
      oldWidget._getIsCreatingNewProduct() != _getIsCreatingNewProduct() ||

      /// Check if the setter for isCreatingNewProduct has changed.
      oldWidget._setCreatingNewProduct != _setCreatingNewProduct ||

      /// Check if the getter for workingRecipe has changed.
      oldWidget._getWorkingRecipe != _getWorkingRecipe ||

      /// Check if [workingRecipe] has changed.
      oldWidget._getWorkingRecipe() != _getWorkingRecipe() ||

      /// Check if the setter for workingRecipe has changed.
      oldWidget._setWorkingRecipe != _setWorkingRecipe ||

      /// Trailing false
      false;
}
