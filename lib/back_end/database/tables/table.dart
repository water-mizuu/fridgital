import "package:flutter/foundation.dart";
import "package:fridgital/shared/globals.dart";

abstract base class DatabaseTable {
  const DatabaseTable();

  String get tableName;
  String get tableCreationStatement;

  /// This method is called whenever the table is created or updated.
  ///
  /// The way that this method matches if it should update the table is by comparing the [tableCreationStatement] with the current table creation statement.
  @mustCallSuper
  Future<void> create() async {
    await database.execute(tableCreationStatement);
  }

  /// Drops the table. This method is called whenever the table is remade.
  Future<void> drop() async {
    await database.execute("DROP TABLE IF EXISTS ?", [tableName]);
  }

  @protected
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
