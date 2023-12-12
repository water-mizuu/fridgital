import "dart:async";
import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:fridgital/shared/globals.dart";
import "package:fridgital/widgets/main.dart";
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

  runApp(const Main());
}
