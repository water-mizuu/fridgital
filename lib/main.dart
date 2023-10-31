import "dart:ui";

import "package:flutter/material.dart";
import "package:fridgital/shared/constants.dart";
import "package:fridgital/shared/enums.dart";
import "package:fridgital/shared/extensions/times.dart";
import "package:fridgital/widgets/inherited_widgets/route_state.dart";
import "package:fridgital/widgets/screens/main_screen/main_screen.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/home_tab.dart";
import "package:fridgital/widgets/screens/main_screen/tabs/one_pot_pesto_tab.dart";

void main() {
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
        fontSize: 20.0,
        fontWeight: FontWeight.normal,
        color: FigmaColors.textDark,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    ),
    useMaterial3: true,
  );

  Pages activePage = Pages.home;

  void Function() changePage(Pages page) => () {
        setState(() {
          activePage = page;
        });
      };

  @override
  Widget build(BuildContext context) {
    return RouteState(
      activePage: activePage,
      moveTo: changePage,
      child: MaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
        ),
        theme: themeData,
        home: Navigator(
          pages: [
            MaterialPage(
              child: MainScreen(
                children: [
                  const HomeTab(),
                  for (int i in 1.to(4)) OnePotPestoTab(index: i),
                ],
              ),
            ),
          ],
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        ),
      ),
    );
  }
}
