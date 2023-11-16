import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/enums.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/screens/main_screen/main_screen.dart";
import "package:fridgital/widgets/screens/recipe/one_pot_pesto.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";
import "package:window_manager/window_manager.dart";

late final Database database;

Future<void> main() async {
  /// Load the database
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }

  databaseFactory = databaseFactoryFfi;
  var path = await getDatabasesPath();
  database = await databaseFactory.openDatabase(path);

  /// Set up the window manager if in desktop.
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
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
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  final ValueNotifier<int> popNotifier = ValueNotifier<int>(0);

  bool isSecondLayerEnabled = false;
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
  void dispose() {
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
      popNotifier: popNotifier,
      child: MaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
        ),
        theme: themeData,
        home: Navigator(
          pages: [
            const MaterialPage(child: MainScreen()),
            if (isSecondLayerEnabled) const MaterialPage(child: OnePotPesto(index: 0)),
          ],
          onPopPage: (route, result) {
            setState(() {
              isSecondLayerEnabled = false;
            });

            --popNotifier.value;

            return route.didPop(result);
          },
        ),
      ),
    );
  }
}
