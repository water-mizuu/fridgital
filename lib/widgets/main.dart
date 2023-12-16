import "dart:ui";

import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/widgets/route.dart";

/// MAIN WIDGETS

class Main extends StatelessWidget {
  const Main({super.key});

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
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      theme: themeData,
      debugShowCheckedModeBanner: false,
      home: const RouteHandler(),
    );
  }
}
