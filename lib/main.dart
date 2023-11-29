import "dart:async";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:fridgital/back_end/product_data.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/enums.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/screens/item_info/item_info.dart";
import "package:fridgital/widgets/screens/main_screen/main_screen.dart";
import "package:fridgital/widgets/screens/new_product_screen/new_product_screen.dart";
import "package:path/path.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "package:window_manager/window_manager.dart";

late final Database database;
late final SharedPreferences sharedPreferences;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var isWeb = kIsWeb;
  var isDesktop = !isWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  var isMobile = !isWeb && (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia);

  /// Load the shared preferences.
  sharedPreferences = await SharedPreferences.getInstance(); // well that's simple.

  /// Load the sqflite database.
  if (isDesktop) {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
    }

    databaseFactory = databaseFactoryFfi;

    var path = await getDatabasesPath();
    database = await databaseFactory.openDatabase(path);
    // database = await databaseFactory.openDatabase(inMemoryDatabasePath);
  } else if (isMobile) {
    var path = join(await getDatabasesPath(), "fridgital.db");
    database = await databaseFactory.openDatabase(path);
  } else {
    database = await databaseFactory.openDatabase(inMemoryDatabasePath);
  }

  /// Set up the window manager if in desktop.
  if (isDesktop) {
    await windowManager.ensureInitialized();

    const size = Size(430, 768);
    const windowOptions = WindowOptions(
      size: size,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
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
  final ValueNotifier<int> popNotifier = ValueNotifier<int>(0);
  bool isSecondLayerEnabled = false;
  bool isCreatingNewProduct = false;
  Pages activePage = Pages.home;

  void changePage(Pages page) {
    setState(() {
      activePage = page;
    });
  }

  void toggleSecondLayer() {
    ++popNotifier.value;
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
    unawaited(productData.then((data) => data.dispose()));
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
      popNotifier: popNotifier,
      child: NotificationListener(
        onNotification: (notification) {
          if (notification case ChangeWorkingStorageLocationNotification(:var location)) {
            if (kDebugMode) {
              print("Working location changed to $location");
            }
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
                    const MaterialPage(child: ItemInfo()),
                  ],
                  onPopPage: (route, result) {
                    --popNotifier.value;

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
  const ChangeWorkingStorageLocationNotification(this.location);

  final StorageLocation location;
}
