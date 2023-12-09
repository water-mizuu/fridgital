import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/enums.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/globals.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/screens/item_info/item_info.dart";
import "package:fridgital/widgets/screens/main_screen/main_screen.dart";
import "package:fridgital/widgets/screens/new_product_screen/new_product_screen.dart";
import "package:provider/provider.dart";

class RouteHandler extends StatefulWidget {
  const RouteHandler({super.key});

  @override
  State<RouteHandler> createState() => _RouteHandlerState();
}

class _RouteHandlerState extends State<RouteHandler> {
  late final Future<ProductData> productData;
  late final ValueNotifier<bool> popNotifier = ValueNotifier<bool>(false);

  /// This is the product that is currently being worked on. If there is.
  Product? workingProduct;

  late StorageLocation workingLocation;
  bool isCreatingNewProduct = false;

  MainTab activePage = MainTab.home;

  void changePage(MainTab page) {
    setState(() {
      activePage = page;
    });
  }

  @override
  void initState() {
    super.initState();

    unawaited(() async {
      productData = ProductData.fromDatabase();
      workingLocation = StorageLocation.values[sharedPreferences.getInt(SharedPreferencesKeys.inventoryLocation) ?? 0];
    }());
  }

  @override
  void dispose() {
    unawaited(() async {
      (await productData).dispose();
    }());
    popNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RouteState(
      activePage: activePage,
      getIsCreatingNewProduct: () => isCreatingNewProduct,
      setIsCreatingNewProduct: ({required bool value}) {
        setState(() {
          isCreatingNewProduct = value;
        });
      },
      createDummyProduct: (tags) async {
        var productData = await this.productData;

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
          value: productData,
          builder: (context, child) => Provider.value(
            value: workingLocation,
            child: ChangeNotifierProvider.value(
              value: context.watch<ProductData>(),
              child: Navigator(
                pages: [
                  const MaterialPage(child: MainScreen()),
                  if (isCreatingNewProduct) const MaterialPage(child: NewProductScreen()),
                  const MaterialPage(child: ItemInfo()),
                ],
                onPopPage: (route, result) {
                  popNotifier.value ^= true;

                  return route.didPop(result);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChangeWorkingStorageLocationNotification extends Notification {
  // ignore: unreachable_from_main
  const ChangeWorkingStorageLocationNotification(this.location);

  final StorageLocation location;
}
