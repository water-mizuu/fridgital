// ignore_for_file: unnecessary_await_in_return

import "dart:io";

import "package:flutter/foundation.dart";
import "package:path/path.dart" as path;
import "package:shared_preferences/shared_preferences.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";

// *****************************************
// SQLITE DATABASE
// *****************************************

late Database _database;

Database get database => _database;

@Deprecated("Do not use this setter.")
set database(Database value) => _database = value;

Future<Database>? _fetchedDatabase;
Future<Database> fetchDatabase() async {
  if (_fetchedDatabase case null) {
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

      _fetchedDatabase = databaseFactory.openDatabase(path, options: options);
    } else if (isMobile) {
      var databasePath = path.join(await getDatabasesPath(), "fridgital.db");

      _fetchedDatabase = databaseFactory.openDatabase(databasePath, options: options);
    } else {
      _fetchedDatabase = databaseFactory.openDatabase(inMemoryDatabasePath, options: options);
    }
  }

  return _fetchedDatabase!;
}

// *****************************************
// SHARED PREFERENCES
// *****************************************

late SharedPreferences sharedPreferences;
