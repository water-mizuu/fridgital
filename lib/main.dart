import "dart:async";
import "dart:io";
import "dart:math";

import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:fridgital/back_end/change_notifiers/product_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/enums.dart";
import "package:fridgital/shared/extensions/time.dart";
import "package:fridgital/shared/globals.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/screens/main_screen/main_screen.dart";
import "package:fridgital/widgets/screens/new_product_screen/new_product_screen.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:window_manager/window_manager.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var isWeb = kIsWeb;
  var isDesktop = !isWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// Load the shared preferences.
  sharedPreferences = await SharedPreferences.getInstance(); // well that's simple.

  /// Load the sqflite database.
  database = await fetchDatabase();

  /// Set up the window manager if in desktop.
  if (isDesktop) {
    await windowManager.ensureInitialized();

    // const size = Size(430, 768);
    // const windowOptions = WindowOptions(
    //   size: size,
    //   center: true,
    //   backgroundColor: Colors.transparent,
    //   skipTaskbar: false,
    //   titleBarStyle: TitleBarStyle.normal,
    // );

    // await windowManager.waitUntilReadyToShow(windowOptions, () async {
    //   await windowManager.show();
    //   await windowManager.focus();
    // });
  }

  runApp(const MyApp());
}

/// MAIN WIDGETS

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final ThemeData themeData = ThemeData(
    fontFamily: "Nunito",
    colorScheme: ColorScheme.fromSeed(seedColor: FigmaColors.pinkAccent),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 45.0,
        fontWeight: FontWeight.w900,
        color: FigmaColors.textDark,
      ),
      titleMedium: TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.w800,
        color: FigmaColors.textDark,
      ),
      displayLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: FigmaColors.textDark,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    useMaterial3: true,
  );

  late final Future<ProductData> productData;

  late StorageLocation workingLocation;
  final ValueNotifier<bool> popNotifier = ValueNotifier<bool>(false);
  bool isSecondLayerEnabled = false;
  bool isCreatingNewProduct = false;
  Pages activePage = Pages.home;

  void changePage(Pages page) {
    setState(() {
      activePage = page;
    });
  }

  void toggleSecondLayer() {
    popNotifier.value ^= true;
    setState(() {
      isSecondLayerEnabled = !isSecondLayerEnabled;
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
      isSecondLayerEnabled: isSecondLayerEnabled,
      toggleSecondLayer: toggleSecondLayer,
      moveTo: changePage,
      isCreatingNewProduct: isCreatingNewProduct,
      setIsCreatingNewProduct: ({required bool value}) {
        setState(() {
          isCreatingNewProduct = value;
        });
      },
      toggleCreatingNewProduct: () {
        setState(() {
          isCreatingNewProduct = !isCreatingNewProduct;
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
        child: MaterialApp(
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: PointerDeviceKind.values.toSet(),
          ),
          theme: themeData,
          home: FutureProvider.value(
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
                    // const MaterialPage(child: ItemInfo()),
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
      ),
    );
  }
}

class ChangeWorkingStorageLocationNotification extends Notification {
  // ignore: unreachable_from_main
  const ChangeWorkingStorageLocationNotification(this.location);

  final StorageLocation location;
}
