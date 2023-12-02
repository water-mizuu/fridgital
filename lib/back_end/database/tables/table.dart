import "package:flutter/foundation.dart";
import "package:fridgital/main.dart";

abstract base class DatabaseTable {
  const DatabaseTable();

  String get tableName;
  String get tableCreationStatement;

  @mustCallSuper
  Future<void> create() async {
    await database.execute(tableCreationStatement);
  }

  Future<void> drop() async {
    await database.execute("DROP TABLE IF EXISTS $tableName");
  }

  Future<void> ensureInitialized() async {
    var tables = await database.query("sqlite_master", where: "name = ?", whereArgs: [tableName]);

    /// If the table is empty, create it.
    if (tables.isEmpty) {
      await create();
      return;
    }

    if (tables.first case {"sql": String query} when query != tableCreationStatement.trim()) {
      if (kDebugMode) {
        print("The table $tableName was changed after it was created. Recreating the table.");
      }

      await drop();
      await create();
    }
  }
}
