import "dart:math";

import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/back_end/change_notifiers/recipe_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/enums.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/globals.dart";
import "package:fridgital/shared/mixins/product_data_mixin.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/screens/item_info/item_info.dart";
import "package:fridgital/widgets/screens/main_screen/main_screen.dart";
import "package:fridgital/widgets/screens/new_product_screen/new_product_screen.dart";
import "package:fridgital/widgets/screens/recipe_info/recipe_info.dart";
import "package:provider/provider.dart";

class RouteHandler extends StatefulWidget {
  const RouteHandler({super.key});

  @override
  State<RouteHandler> createState() => _RouteHandlerState();
}

class _RouteHandlerState extends State<RouteHandler> with ProductDataMixin {
  late final ValueNotifier<bool> popNotifier = ValueNotifier<bool>(false);

  /// This is the product that is currently being worked on. If there is.
  Recipe? workingRecipe;

  late StorageLocation workingLocation;
  bool isCreatingNewProduct = false;

  @override
  void initState() {
    super.initState();

    workingLocation = StorageLocation.values[sharedPreferences.getInt(SharedPreferencesKeys.inventoryLocation) ?? 0];
  }

  @override
  void dispose() {
    popNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RouteState(
      getIsCreatingNewProduct: () => isCreatingNewProduct,
      setIsCreatingNewProduct: ({required bool value}) {
        setState(() {
          isCreatingNewProduct = value;
        });
      },
      getWorkingRecipe: () => workingRecipe,
      setWorkingRecipe: ({required Recipe? value}) {
        setState(() {
          workingRecipe = value;
        });
      },
      createDummyProduct: (tags) async {
        var productData = await this.productDataFuture;

        await productData.addProduct(
          name: "Product #${Random().nextInt(1111111)}",
          addedDate: DateTime.now(),
          storageUnits: "kg", // The superior unit of measurement.
          storageLocation: workingLocation,
          expiryDate: DateTime.now().add(30.days),
          quantity: Random().nextInt(20),
          notes: "",
          tags: tags,
          image: null,
        );
      },
      popNotifier: popNotifier,
      child: NotificationListener(
        onNotification: (notification) {
          if (notification case ChangeWorkingStorageLocationNotification(:var location)) {
            setState(() {
              workingLocation = location;
            });
            return true;
          }

          return false;
        },
        child: FutureProvider.value(
          initialData: ProductData.empty(),
          value: productDataFuture,
          builder: (context, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: context.watch<ProductData>()),
            ],
            child: Navigator(
              pages: [
                const MaterialPage(child: MainScreen()),
                if (isCreatingNewProduct) const MaterialPage(child: NewProductScreen()),
                if (workingRecipe case var workingRecipe?) //
                  MaterialPage(child: RecipeInfo(recipe: workingRecipe)),
                const MaterialPage(child: ItemInfo()),
              ],
              onPopPage: (route, result) {
                popNotifier.value ^= true;

                /// This is called when the user taps the back button.
                if (isCreatingNewProduct) {
                  setState(() {
                    isCreatingNewProduct = false;
                  });
                } else if (workingRecipe case _?) {
                  setState(() {
                    workingRecipe = null;
                  });
                }

                return route.didPop(result);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ProductInfo {}

class ChangeWorkingStorageLocationNotification extends Notification {
  // ignore: unreachable_from_main
  const ChangeWorkingStorageLocationNotification(this.location);

  final StorageLocation location;
}
