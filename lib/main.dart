import "dart:async";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/globals.dart";
import "package:fridgital/widgets/route.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:window_manager/window_manager.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundIsolateBinaryMessenger.ensureInitialized(RootIsolateToken.instance!);

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        fontSize: 28.0,
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {...PointerDeviceKind.values}),
      theme: themeData,
      home: const RouteHandler(),
    );
  }
}
