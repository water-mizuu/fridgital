// ignore_for_file: unnecessary_await_in_return

import "dart:io";

import "package:flutter/foundation.dart";
import "package:path/path.dart" as path;
import "package:shared_preferences/shared_preferences.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";

// *****************************************
// SQLITE DATABASE
// *****************************************

late final Database database;

Future<Database> fetchDatabase() async {
  var options = OpenDatabaseOptions();

  var isWeb = kIsWeb;
  var isDesktop = !isWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  var isMobile = !isWeb && (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia);

  if (isDesktop) {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
    }

    databaseFactory = databaseFactoryFfi;

    var path = await getDatabasesPath();

    return await databaseFactory.openDatabase(path, options: options);
  } else if (isMobile) {
    var databasePath = path.join(await getDatabasesPath(), "fridgital.db");

    return await databaseFactory.openDatabase(databasePath, options: options);
  } else {
    return await databaseFactory.openDatabase(inMemoryDatabasePath, options: options);
  }
}

// *****************************************
// SHARED PREFERENCES
// *****************************************

late SharedPreferences sharedPreferences;
